const express = require('express');

const { createGetCurrencyRate } = require('../controllers/currencyController');

const createCurrencyRoutes = ({ httpsJson }) => {
  const router = express.Router();

  router.get('/api/currency/rate', createGetCurrencyRate({ httpsJson }));

  return router;
};

module.exports = createCurrencyRoutes;
