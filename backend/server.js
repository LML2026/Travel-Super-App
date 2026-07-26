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
const WEATHER_RETRIES = 2;

app.use(compression());
app.use(
  cors({
    origin: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);
app.use(express.json());

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

const httpsJson = (options, retries = 0) => new Promise((resolve, reject) => {
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
      resolve(httpsJson(options, retries - 1));
      return;
    }
    reject(error);
  });

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
app.use(createHotelsRoutes());
app.use(createAiRoutes({ OPENAI_API_KEY, OPENAI_MODEL, httpsJsonRequest }));

app.use(createPlacesRoutes());
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
  console.log(`Flight search endpoint: POST http://localhost:${PORT}/api/flights/search`);
  console.log(`Hotel search endpoint: GET http://localhost:${PORT}/api/hotels/search`);
  console.log(`Weather endpoint: GET http://localhost:${PORT}/api/weather?city=London`);
  console.log(`Nearby places endpoint: GET http://localhost:${PORT}/api/places/nearby?city=Paris`);
  console.log(`Currency endpoint: GET http://localhost:${PORT}/api/currency/rate?base=GBP&target=EUR`);
  console.log(`AI planner endpoint: POST http://localhost:${PORT}/api/ai/travel-plan`);
});
