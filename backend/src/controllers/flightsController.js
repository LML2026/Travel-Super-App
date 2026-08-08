const https = require('https');

const REQUEST_TIMEOUT_MS = 12000;
const FLIGHT_UPSTREAM_RETRIES = 1;

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

const sendDuffelRequest = (options, body, retries = 0) => new Promise((resolve, reject) => {
  const proxyReq = https.request(
    {
      ...options,
      family: 4,
      timeout: REQUEST_TIMEOUT_MS,
    },
    (proxyRes) => {
      let data = '';

      proxyRes.on('data', (chunk) => {
        data += chunk;
      });

      proxyRes.on('end', () => {
        resolve({ statusCode: proxyRes.statusCode, body: data });
      });
    },
  );

  proxyReq.on('timeout', () => {
    proxyReq.destroy(Object.assign(new Error('Request timed out'), { code: 'ETIMEDOUT' }));
  });

  proxyReq.on('error', (error) => {
    if (retries > 0 && isRetryableNetworkError(error)) {
      resolve(sendDuffelRequest(options, body, retries - 1));
      return;
    }
    reject(error);
  });

  proxyReq.write(JSON.stringify(body));
  proxyReq.end();
});

const createHandleFlightSearch = ({ DUFFEL_API_KEY, flightCache, CACHE_TTL }) => {
  return async (req, res, next) => {
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

      const cacheKey = JSON.stringify({
        origin, destination, departureDate, returnDate, passengers, cabinClass,
      });

      const cached = flightCache.get(cacheKey);
      if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
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

      const options = {
        hostname: 'api.duffel.com',
        path: '/air/offer_requests?return_offers=true&supplier_timeout=8000',
        method: 'POST',
        headers: {
          Authorization: `Bearer ${DUFFEL_API_KEY}`,
          'Duffel-Version': 'v2',
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
      };
      const { statusCode, body } = await sendDuffelRequest(options, duffelBody, FLIGHT_UPSTREAM_RETRIES);

      if (statusCode === 200 || statusCode === 201) {
        try {
          const parsedData = JSON.parse(body);
          const offers = parsedData.data?.offers || [];

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
              airline,
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

          flightCache.set(cacheKey, {
            timestamp: Date.now(),
            flights: limitedFlights,
          });

          res.json({
            flights: limitedFlights,
            totalFound: flights.length,
            cached: false,
          });
        } catch (error) {
          res.status(500).json({ error: 'Failed to parse response', details: error.message });
        }
      } else if (statusCode === 422) {
        res.status(422).json({ error: 'Invalid search parameters', details: body });
      } else {
        res.status(statusCode || 502).json({ error: `API Error ${statusCode}`, details: body });
      }
    } catch (error) {
      if (isRetryableNetworkError(error)) {
        return res.status(502).json({ error: 'Flight provider timeout or network error', details: error.message });
      }
      next(error);
    }
  };
};

module.exports = {
  createHandleFlightSearch,
};
