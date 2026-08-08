const express = require('express');

const { createHandleFlightSearch } = require('../controllers/flightsController');

const createFlightsRoutes = ({ DUFFEL_API_KEY, flightCache, CACHE_TTL }) => {
  const router = express.Router();

  router.post('/api/flights/search', createHandleFlightSearch({ DUFFEL_API_KEY, flightCache, CACHE_TTL }));

  return router;
};

module.exports = createFlightsRoutes;
