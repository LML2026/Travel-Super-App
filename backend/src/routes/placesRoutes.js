const express = require('express');
const {
  createGetNearbyPlaces,
} = require('../controllers/placesController');

const createPlacesRoutes = ({
  httpsJsonRequest,
  GOOGLE_MAPS_API_KEY,
} = {}) => {
  const router = express.Router();

  router.get(
    '/api/places/nearby',
    createGetNearbyPlaces({
      httpsJsonRequest,
      GOOGLE_MAPS_API_KEY,
    }),
  );

  return router;
};

module.exports = createPlacesRoutes;
