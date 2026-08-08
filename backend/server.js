require('dotenv').config();

// Fix for Node.js TLS connection issues on Windows
// Prioritizes IPv4 over IPv6 for DNS resolution, which resolves TLS handshake failures
// on systems with unreliable IPv6 routes (common Windows environment issue)
const dns = require('node:dns');
dns.setDefaultResultOrder('ipv4first');

const express = require('express');
const cors = require('cors');
const https = require('https');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const admin = require('firebase-admin');
const createSystemRoutes = require('./src/routes/systemRoutes');
const createPlacesRoutes = require('./src/routes/placesRoutes');
const createCurrencyRoutes = require('./src/routes/currencyRoutes');
const createFlightsRoutes = require('./src/routes/flightsRoutes');
const createWeatherRoutes = require('./src/routes/weatherRoutes');
const createHotelsRoutes = require('./src/routes/hotelsRoutes');
const createAiRoutes = require('./src/routes/aiRoutes');

const app = express();
const PORT = process.env.PORT || 5000;
const DUFFEL_API_KEY = process.env.DUFFEL_API_KEY;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT;
const NODE_ENV = process.env.NODE_ENV || 'development';
const IS_PRODUCTION = NODE_ENV === 'production';
const AUTH_REQUIRED = process.env.AUTH_REQUIRED
  ? process.env.AUTH_REQUIRED.toLowerCase() === 'true'
  : IS_PRODUCTION;
const RATE_LIMIT_WINDOW_MS = Number(process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000);
const RATE_LIMIT_MAX = Number(process.env.RATE_LIMIT_MAX || 120);
const CORS_ALLOWED_ORIGINS = (process.env.CORS_ALLOWED_ORIGINS || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const AUTH_PROTECTED_PATHS = (process.env.AUTH_PROTECTED_PATHS || '/api/flights,/api/hotels,/api/ai')
  .split(',')
  .map((pathValue) => pathValue.trim())
  .filter(Boolean);
const WEATHER_RETRIES = 2;

if (IS_PRODUCTION && CORS_ALLOWED_ORIGINS.length === 0) {
  throw new Error('CORS_ALLOWED_ORIGINS must be configured in production.');
}

if (!admin.apps.length) {
  if (FIREBASE_PROJECT_ID) {
    admin.initializeApp({ projectId: FIREBASE_PROJECT_ID });
  } else {
    admin.initializeApp();
  }
}

const verifyFirebaseAuth = async (req, res, next) => {
  if (!AUTH_REQUIRED) {
    return next();
  }

  const authorization = req.header('Authorization') || '';
  const [scheme, token] = authorization.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Missing or invalid Authorization bearer token.' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired authentication token.' });
  }
};

const apiLimiter = rateLimit({
  windowMs: RATE_LIMIT_WINDOW_MS,
  max: RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many requests from this client. Please try again later.',
  },
});

app.use(compression());
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (CORS_ALLOWED_ORIGINS.includes(origin)) {
        callback(null, true);
        return;
      }

      if (!IS_PRODUCTION && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i.test(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error(`CORS origin denied: ${origin}`));
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);
app.use(express.json());
app.set('trust proxy', 1);
app.use('/api', apiLimiter);
app.use('/api', (req, res, next) => {
  if (!AUTH_REQUIRED) {
    return next();
  }

  const pathWithApiPrefix = `/api${req.path}`;
  const needsAuth = AUTH_PROTECTED_PATHS.some((protectedPath) => (
    pathWithApiPrefix === protectedPath || pathWithApiPrefix.startsWith(`${protectedPath}/`)
  ));

  if (!needsAuth) {
    return next();
  }

  return verifyFirebaseAuth(req, res, next);
});

// Flight search cache
const flightCache = new Map();
const CACHE_TTL = 10 * 60 * 1000; // 10 minutes

const isRetryableNetworkError = (error) => {
  if (!error || typeof error !== 'object') {
    return false;
  }

  return [
    'ECONNRESET',
    'ETIMEDOUT',
    'EAI_AGAIN',
    'ECONNABORTED',
  ].includes(error.code);
};

const httpsJson = (options, retries = 0, requestBody = null) => new Promise((resolve, reject) => {
  const req = https.request(
    {
      ...options,
      family: 4,
      timeout: 12000,
    },
    (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (parseError) {
          reject(parseError);
        }
      });
    },
  );

  req.on('timeout', () => {
    req.destroy(Object.assign(new Error('Request timed out'), { code: 'ETIMEDOUT' }));
  });

  req.on('error', (error) => {
    if (retries > 0 && isRetryableNetworkError(error)) {
      console.warn(`Retrying weather upstream request (${error.code}), retries left: ${retries}`);
      resolve(httpsJson(options, retries - 1, requestBody));
      return;
    }
    reject(error);
  });

  if (requestBody) {
    req.write(requestBody);
  }

  req.end();
});

const httpsJsonRequest = (options, body, retries = 0) => new Promise((resolve, reject) => {
  const req = https.request(
    {
      ...options,
      family: 4,
      timeout: 15000,
    },
    (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({ statusCode: res.statusCode, data: JSON.parse(data) });
        } catch (parseError) {
          reject(parseError);
        }
      });
    },
  );

  req.on('timeout', () => {
    req.destroy(Object.assign(new Error('Request timed out'), { code: 'ETIMEDOUT' }));
  });

  req.on('error', (error) => {
    if (retries > 0 && isRetryableNetworkError(error)) {
      resolve(httpsJsonRequest(options, body, retries - 1));
      return;
    }
    reject(error);
  });

  if (body) {
    req.write(JSON.stringify(body));
  }

  req.end();
});

// Periodically remove expired cache entries
setInterval(() => {
  const now = Date.now();
  for (const [key, value] of flightCache.entries()) {
    if (now - value.timestamp > CACHE_TTL) {
      flightCache.delete(key);
    }
  }
  console.log(`🗄️ Cache size: ${flightCache.size} entries`);
}, 10 * 60 * 1000);

app.use(createSystemRoutes());
app.use(createFlightsRoutes({ DUFFEL_API_KEY, flightCache, CACHE_TTL }));
app.use(createWeatherRoutes({ httpsJson, WEATHER_RETRIES }));
app.use(createHotelsRoutes({ httpsJson }));
app.use(createAiRoutes({ OPENAI_API_KEY, OPENAI_MODEL, httpsJsonRequest }));

app.use(createPlacesRoutes({ httpsJson }));
app.use(createCurrencyRoutes({ httpsJson }));

app.use((error, req, res, next) => {
  console.error('Unhandled backend error:', error);

  if (res.headersSent) {
    return next(error);
  }

  res.status(500).json({
    error: 'Internal server error',
    details: error.message,
  });
});

app.use((req, res) => {
  console.log('Route not found:', req.method, req.originalUrl);

  res.status(404).json({
    error: 'Route not found',
    method: req.method,
    path: req.originalUrl,
  });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Environment: ${NODE_ENV}`);
  console.log(`Auth required for /api routes: ${AUTH_REQUIRED}`);
  console.log(`Auth protected paths: ${AUTH_PROTECTED_PATHS.join(', ')}`);
  console.log(`Flight search endpoint: POST http://localhost:${PORT}/api/flights/search`);
  console.log(`Hotel search endpoint: GET http://localhost:${PORT}/api/hotels/search`);
  console.log(`Weather endpoint: GET http://localhost:${PORT}/api/weather?city=London`);
  console.log(`Nearby places endpoint: GET http://localhost:${PORT}/api/places/nearby?city=Paris`);
  console.log(`Currency endpoint: GET http://localhost:${PORT}/api/currency/rate?base=GBP&target=EUR`);
  console.log(`AI planner endpoint: POST http://localhost:${PORT}/api/ai/travel-plan`);
});
