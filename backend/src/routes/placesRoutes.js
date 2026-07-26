const express = require('express');

const { getNearbyPlaces } = require('../controllers/placesController');

const createPlacesRoutes = () => {
  const router = express.Router();

  router.get('/api/places/nearby', getNearbyPlaces);

  return router;
};

module.exports = createPlacesRoutes;
