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

const app = express();
const PORT = process.env.PORT || 5000;
const DUFFEL_API_KEY = process.env.DUFFEL_API_KEY;
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

app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Travel Super App backend is running',
  });
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

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const handleFlightSearch = async (req, res, next) => {
  try {
    if (!DUFFEL_API_KEY) {
      return res.status(500).json({
        error: 'DUFFEL_API_KEY is not configured on the backend.',
      });
    }

    const payload = req.body || {};
    const {
      origin: rawOrigin,
      destination: rawDestination,
      from,
      to,
      departureDate,
      returnDate,
      passengers = 1,
      cabinClass = 'economy',
    } = payload;

    const origin = rawOrigin || from;
    const destination = rawDestination || to;

    console.log('Flight request received:', payload);

    // Cache key based on search parameters
    const cacheKey = JSON.stringify({
      origin, destination, departureDate, returnDate, passengers, cabinClass,
    });

    const cached = flightCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      console.log('✅ Returning cached flights');
      return res.json({ flights: cached.flights, cached: true });
    }

    if (!origin || !destination || !departureDate) {
      return res.status(400).json({
        error: 'Origin, destination and departure date are required.',
      });
    }

    const slices = [
      {
        origin: origin.trim().toUpperCase(),
        destination: destination.trim().toUpperCase(),
        departure_date: departureDate,
      },
    ];

    if (returnDate) {
      slices.push({
        origin: destination.trim().toUpperCase(),
        destination: origin.trim().toUpperCase(),
        departure_date: returnDate,
      });
    }

    const duffelBody = {
      data: {
        slices,
        passengers: Array.from(
          { length: Number(passengers) },
          () => ({ type: 'adult' }),
        ),
        cabin_class: cabinClass.toLowerCase(),
        max_connections: 1,
      },
    };

    console.log(`📤 Sending to Duffel: ${origin} → ${destination} on ${departureDate}`);

    const options = {
      hostname: 'api.duffel.com',
      path: '/air/offer_requests?return_offers=true&supplier_timeout=8000',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${DUFFEL_API_KEY}`,
        'Duffel-Version': 'v2',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    };

    const proxyReq = https.request(options, (proxyRes) => {
      let data = '';

      proxyRes.on('data', (chunk) => {
        data += chunk;
      });

      proxyRes.on('end', () => {
        console.log(`📥 Duffel response status: ${proxyRes.statusCode}`);
        console.log(`📥 Response body: ${data}`);

        if (proxyRes.statusCode === 200 || proxyRes.statusCode === 201) {
          try {
            const parsedData = JSON.parse(data);
            const offers = parsedData.data?.offers || [];
            console.log(`✈️ Found ${offers.length} offers`);

            // Parse offers into simplified flight objects
            const flights = offers.map((offer) => {
              const outboundSlice = offer.slices?.[0];
              const segments = outboundSlice?.segments ?? [];

              const firstSegment = segments[0];
              const lastSegment = segments[segments.length - 1];

              const airline =
                offer.owner?.name ??
                firstSegment?.marketing_carrier?.name ??
                'Unknown airline';

              const airlineCode =
                firstSegment?.marketing_carrier?.iata_code ?? '';

              const airlineFlightNumber =
                firstSegment?.marketing_carrier_flight_number ?? '';

              return {
                id: offer.id ?? '',
                airline: airline,
                airlineLogo: offer.owner?.logo_symbol_url ?? '',
                flightNumber: `${airlineCode}${airlineFlightNumber}`,
                origin:
                  outboundSlice?.origin?.iata_code ??
                  firstSegment?.origin?.iata_code ??
                  '',
                destination:
                  outboundSlice?.destination?.iata_code ??
                  lastSegment?.destination?.iata_code ??
                  '',
                departureAt: firstSegment?.departing_at ?? '',
                arrivalAt: lastSegment?.arriving_at ?? '',
                duration: outboundSlice?.duration ?? '',
                stops: Math.max(segments.length - 1, 0),
                amount: offer.total_amount ?? '0',
                currency: offer.total_currency ?? 'GBP',
              };
            });

            const limitedFlights = flights
              .filter((flight) => Number.isFinite(Number(flight.amount)))
              .sort((a, b) => Number(a.amount) - Number(b.amount))
              .slice(0, 30);

            console.log(`✅ Duffel returned ${flights.length} offers; sending ${limitedFlights.length}`);

            flightCache.set(cacheKey, {
              timestamp: Date.now(),
              flights: limitedFlights,
            });

            res.json({
              flights: limitedFlights,
              totalFound: flights.length,
              cached: false,
            });
          } catch (e) {
            console.error(`❌ Parsing error: ${e}`);
            res.status(500).json({ error: 'Failed to parse response', details: e.message });
          }
        } else if (proxyRes.statusCode === 422) {
          console.error(`⚠️ Validation error (422)`);
          res.status(422).json({ error: 'Invalid search parameters', details: data });
        } else {
          console.error(`❌ API Error ${proxyRes.statusCode}`);
          res.status(proxyRes.statusCode).json({ error: `API Error ${proxyRes.statusCode}`, details: data });
        }
      });
    });

    proxyReq.on('error', (e) => {
      console.error(`❌ Request error: ${e}`);
      res.status(500).json({ error: 'Failed to connect to Duffel API', details: e.message });
    });

    proxyReq.write(JSON.stringify(duffelBody));
    proxyReq.end();
  } catch (e) {
    next(e);
  }
};

// Flight search endpoint
app.post('/api/flights/search', handleFlightSearch);

// Weather endpoint — uses Open-Meteo (free, no API key required)
app.get('/api/weather', async (req, res) => {
  const city = req.query.city;
  if (!city) return res.status(400).json({ error: 'city is required' });

  try {
    // Geocode city → lat/lon using Open-Meteo geocoding API
    const geocodeOptions = {
      hostname: 'geocoding-api.open-meteo.com',
      path: `/v1/search?name=${encodeURIComponent(city)}&count=1&language=en&format=json`,
      method: 'GET',
      headers: { 'Accept': 'application/json' },
    };

    const geocodeData = await httpsJson(geocodeOptions, WEATHER_RETRIES);

    const loc = geocodeData.results?.[0];
    if (!loc) return res.status(404).json({ error: `City not found: ${city}` });

    const { latitude, longitude, name, country } = loc;

    // Fetch weather using Open-Meteo weather API
    const weatherOptions = {
      hostname: 'api.open-meteo.com',
      path: `/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&wind_speed_unit=kmh`,
      method: 'GET',
      headers: { 'Accept': 'application/json' },
    };

    const weatherData = await httpsJson(weatherOptions, WEATHER_RETRIES);

    const current = weatherData.current;
    const code = current.weather_code;

    // Map WMO weather codes to descriptions
    const descriptionMap = (c) => {
      if (c === 0) return { desc: 'Clear sky', cond: 'clear' };
      if (c <= 3) return { desc: 'Partly cloudy', cond: 'cloud' };
      if (c <= 49) return { desc: 'Foggy', cond: 'fog' };
      if (c <= 69) return { desc: 'Rainy', cond: 'rain' };
      if (c <= 79) return { desc: 'Snowy', cond: 'snow' };
      if (c <= 99) return { desc: 'Thunderstorm', cond: 'storm' };
      return { desc: 'Unknown', cond: 'unknown' };
    };

    const { desc, cond } = descriptionMap(code);
    const tempC = current.temperature_2m;
    const tempF = (tempC * 9 / 5) + 32;

    console.log(`🌤️ Weather for ${name}: ${tempC}°C, ${desc}`);

    res.json({
      city: name,
      country: country,
      tempC: tempC,
      tempF: Math.round(tempF * 10) / 10,
      description: desc,
      iconCode: String(code),
      humidity: current.relative_humidity_2m,
      windKph: current.wind_speed_10m,
      condition: cond,
    });
  } catch (e) {
    console.error('❌ Weather error:', e);
    res.status(500).json({ error: 'Failed to fetch weather', details: e.message });
  }
});

const nearbyPlaceCatalog = {
  paris: {
    attractions: [
      { name: 'Eiffel Tower', distanceKm: 2.1, type: 'attraction' },
      { name: 'Louvre Museum', distanceKm: 3.4, type: 'attraction' },
      { name: 'Montmartre', distanceKm: 4.2, type: 'attraction' },
    ],
    restaurants: [
      { name: 'Le Petit Bistro', distanceKm: 0.6, type: 'restaurant' },
      { name: 'Maison du Brunch', distanceKm: 1.1, type: 'restaurant' },
      { name: 'Cafe de Seine', distanceKm: 1.7, type: 'restaurant' },
    ],
    transport: [
      { name: 'Metro Line 1', distanceKm: 0.3, type: 'transport' },
      { name: 'RER A Station', distanceKm: 0.7, type: 'transport' },
      { name: 'Airport Shuttle Stop', distanceKm: 1.2, type: 'transport' },
    ],
  },
  london: {
    attractions: [
      { name: 'Tower Bridge', distanceKm: 2.8, type: 'attraction' },
      { name: 'British Museum', distanceKm: 3.2, type: 'attraction' },
      { name: 'Hyde Park', distanceKm: 2.0, type: 'attraction' },
    ],
    restaurants: [
      { name: 'Baker Street Grill', distanceKm: 0.8, type: 'restaurant' },
      { name: 'Thames Kitchen', distanceKm: 1.4, type: 'restaurant' },
      { name: 'Mayfair Social', distanceKm: 1.9, type: 'restaurant' },
    ],
    transport: [
      { name: 'Jubilee Underground', distanceKm: 0.4, type: 'transport' },
      { name: 'Paddington Rail', distanceKm: 1.5, type: 'transport' },
      { name: 'City Bus Hub', distanceKm: 0.6, type: 'transport' },
    ],
  },
};

const fallbackNearby = {
  attractions: [
    { name: 'Historic Center', distanceKm: 1.8, type: 'attraction' },
    { name: 'City Museum', distanceKm: 2.6, type: 'attraction' },
    { name: 'Waterfront Walk', distanceKm: 3.1, type: 'attraction' },
  ],
  restaurants: [
    { name: 'Central Kitchen', distanceKm: 0.9, type: 'restaurant' },
    { name: 'Garden Cafe', distanceKm: 1.5, type: 'restaurant' },
    { name: 'Skyline Diner', distanceKm: 2.3, type: 'restaurant' },
  ],
  transport: [
    { name: 'Main Bus Station', distanceKm: 0.7, type: 'transport' },
    { name: 'Central Metro', distanceKm: 1.1, type: 'transport' },
    { name: 'Taxi Point', distanceKm: 0.4, type: 'transport' },
  ],
};

app.get('/api/places/nearby', async (req, res) => {
  const { city, category } = req.query;

  if (!city) {
    return res.status(400).json({ error: 'city is required' });
  }

  const key = String(city).toLowerCase();
  const cityData = nearbyPlaceCatalog[key] || fallbackNearby;

  if (category && !cityData[category]) {
    return res.status(400).json({ error: 'category must be attractions, restaurants, or transport' });
  }

  if (category) {
    return res.json({
      city,
      category,
      places: cityData[category],
    });
  }

  return res.json({
    city,
    attractions: cityData.attractions,
    restaurants: cityData.restaurants,
    transport: cityData.transport,
  });
});

app.get('/api/currency/rate', async (req, res) => {
  const base = (req.query.base || 'GBP').toString().toUpperCase();
  const target = (req.query.target || 'EUR').toString().toUpperCase();

  if (base === target) {
    return res.json({ base, target, rate: 1 });
  }

  try {
    const rateOptions = {
      hostname: 'open.er-api.com',
      path: `/v6/latest/${encodeURIComponent(base)}`,
      method: 'GET',
      headers: { Accept: 'application/json' },
    };

    const rateData = await httpsJson(rateOptions, 1);
    const rate = rateData?.rates?.[target];

    if (!rate) {
      return res.status(404).json({ error: `Rate not found for ${base} -> ${target}` });
    }

    return res.json({ base, target, rate });
  } catch (error) {
    console.error('❌ Currency rate error:', error);
    return res.status(500).json({ error: 'Failed to fetch currency rate', details: error.message });
  }
});

const handleHotelSearch = async (req, res, next) => {
  try {
    const {
      city,
      checkInDate,
      checkOutDate,
      guests = 1,
      rooms = 1,
    } = req.body;

    if (!city || !checkInDate || !checkOutDate) {
      return res.status(400).json({ error: 'city, checkInDate, and checkOutDate are required' });
    }

    console.log('🏨 Hotel search request:', req.body);

    // Mock hotel database by city
    const hotelsByCity = {
      paris: [
        { id: 'h1', name: 'Le Marais Boutique', rating: 4.8, price: 145, image: '🏨', beds: 2 },
        { id: 'h2', name: 'Eiffel Tower Classic', rating: 4.5, price: 120, image: '🏨', beds: 1 },
        { id: 'h3', name: 'Champs-Élysées Luxury', rating: 4.9, price: 280, image: '🏨', beds: 2 },
        { id: 'h4', name: 'Latin Quarter Budget', rating: 4.2, price: 85, image: '🏨', beds: 1 },
        { id: 'h5', name: 'Montmartre Charm', rating: 4.6, price: 110, image: '🏨', beds: 2 },
      ],
      london: [
        { id: 'h6', name: 'Westminster Palace', rating: 4.7, price: 160, image: '🏨', beds: 2 },
        { id: 'h7', name: 'Soho Trendy', rating: 4.4, price: 95, image: '🏨', beds: 1 },
        { id: 'h8', name: 'Kensington Elegant', rating: 4.9, price: 250, image: '🏨', beds: 2 },
        { id: 'h9', name: 'Covent Garden Central', rating: 4.5, price: 130, image: '🏨', beds: 1 },
      ],
      barcelona: [
        { id: 'h10', name: 'Gothic Quarter Historic', rating: 4.6, price: 105, image: '🏨', beds: 2 },
        { id: 'h11', name: 'Gaudí View Premium', rating: 4.8, price: 200, image: '🏨', beds: 2 },
        { id: 'h12', name: 'Beach Front Relax', rating: 4.5, price: 140, image: '🏨', beds: 1 },
      ],
      'new york': [
        { id: 'h13', name: 'Manhattan Dream', rating: 4.9, price: 320, image: '🏨', beds: 2 },
        { id: 'h14', name: 'Times Square Plaza', rating: 4.4, price: 180, image: '🏨', beds: 1 },
        { id: 'h15', name: 'Brooklyn Cool', rating: 4.6, price: 120, image: '🏨', beds: 2 },
      ],
      tokyo: [
        { id: 'h16', name: 'Shibuya Modern', rating: 4.7, price: 150, image: '🏨', beds: 1 },
        { id: 'h17', name: 'Kyoto Traditional', rating: 4.8, price: 130, image: '🏨', beds: 2 },
        { id: 'h18', name: 'Ginza Luxury', rating: 4.9, price: 290, image: '🏨', beds: 2 },
      ],
    };

    const cityLower = city.toLowerCase();
    const hotels = hotelsByCity[cityLower] || [];

    if (hotels.length === 0) {
      console.log(`ℹ️ No hotels found for ${city}, returning empty`);
      return res.json({
        city,
        checkInDate,
        checkOutDate,
        guests,
        rooms,
        hotels: [],
        count: 0,
      });
    }

    // Calculate number of nights
    const checkIn = new Date(checkInDate);
    const checkOut = new Date(checkOutDate);
    const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));

    // Calculate total price per room
    const results = hotels.map(h => ({
      id: h.id,
      name: h.name,
      city: city,
      rating: h.rating,
      pricePerNight: h.price,
      totalPrice: h.price * nights * rooms,
      beds: h.beds,
      image: h.image,
      nights: nights,
    }));

    // Sort by price
    results.sort((a, b) => a.totalPrice - b.totalPrice);

    console.log(`🏨 Found ${results.length} hotels for ${city}`);

    res.json({
      city,
      checkInDate,
      checkOutDate,
      guests,
      rooms,
      nights,
      hotels: results.slice(0, 20),
      count: results.length,
    });
  } catch (e) {
    next(e);
  }
};

// Hotel search endpoint — mock data
app.post('/api/hotels/search', handleHotelSearch);
app.get('/api/hotels/search', async (req, res, next) => {
  try {
    const {
      destination,
      city,
      checkIn,
      checkInDate,
      checkOut,
      checkOutDate,
      guests = 1,
      rooms = 1,
    } = req.query;

    req.body = {
      city: destination || city,
      checkInDate: checkIn || checkInDate,
      checkOutDate: checkOut || checkOutDate,
      guests: Number(guests),
      rooms: Number(rooms),
    };

    await handleHotelSearch(req, res, next);
  } catch (e) {
    next(e);
  }
});

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
});
