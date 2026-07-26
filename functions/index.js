const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const http = require('http');

// Duffel API Key from environment
const DUFFEL_API_KEY = process.env.DUFFEL_API_KEY;

exports.searchFlights = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    if (!DUFFEL_API_KEY) {
      return res.status(500).json({ error: 'DUFFEL_API_KEY is not configured' });
    }

    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const { from, to, departureDate, passengers, cabinClass } = req.body;

    // Validate inputs
    if (!from || !to || !departureDate) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const requestBody = {
      data: {
        slices: [
          {
            origin_iata: from,
            destination_iata: to,
            departure_date: departureDate,
          },
        ],
        passengers: Array(passengers || 1).fill({ type: 'adult' }),
        cabin_class: cabinClass || 'economy',
      },
    };

    const options = {
      hostname: 'api.duffel.com',
      path: '/air/offer_requests',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${DUFFEL_API_KEY}`,
        'Duffel-Version': '2024-07-01',
        'Content-Type': 'application/json',
      },
    };

    console.log('📤 Sending request to Duffel:', JSON.stringify(requestBody));

    const proxyReq = http.request(options, (proxyRes) => {
      let data = '';

      proxyRes.on('data', (chunk) => {
        data += chunk;
      });

      proxyRes.on('end', () => {
        console.log(`📥 Duffel response status: ${proxyRes.statusCode}`);
        console.log(`📥 Duffel response body: ${data}`);

        if (proxyRes.statusCode === 200 || proxyRes.statusCode === 201) {
          try {
            const parsedData = JSON.parse(data);
            const offers = parsedData.data?.offers || [];
            console.log(`✈️ Found ${offers.length} offers`);

            // Parse offers into flight objects
            const flights = offers.map((offer) => {
              const slice = offer.slices?.[0];
              return {
                airline: offer.owner?.name || 'Unknown Airline',
                flightNumber: offer.id?.substring(0, 8) || 'N/A',
                from: slice?.origin_iata || from,
                to: slice?.destination_iata || to,
                departure: slice?.departure_at || departureDate,
                arrival: slice?.arrival_at || '',
                price: parseFloat(offer.total_amount) || 0,
              };
            });

            console.log(`✅ Parsed ${flights.length} flights`);
            res.json({ success: true, flights });
          } catch (e) {
            console.error(`❌ Parsing error: ${e}`);
            res.status(500).json({ error: 'Failed to parse response', details: e.message });
          }
        } else if (proxyRes.statusCode === 422) {
          console.error(`⚠️ Validation error (422): ${data}`);
          res.status(422).json({ error: 'Invalid search parameters', details: data });
        } else {
          console.error(`❌ API Error ${proxyRes.statusCode}: ${data}`);
          res.status(proxyRes.statusCode).json({ error: `API Error ${proxyRes.statusCode}`, details: data });
        }
      });
    });

    proxyReq.on('error', (e) => {
      console.error(`❌ Request error: ${e}`);
      res.status(500).json({ error: 'Failed to fetch flights', details: e.message });
    });

    proxyReq.write(JSON.stringify(requestBody));
    proxyReq.end();
  });
});
