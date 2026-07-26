const express = require('express');

const { createGetWeather } = require('../controllers/weatherController');

const createWeatherRoutes = ({ httpsJson, WEATHER_RETRIES }) => {
  const router = express.Router();

  router.get('/api/weather', createGetWeather({ httpsJson, WEATHER_RETRIES }));

  return router;
};

module.exports = createWeatherRoutes;
