const express = require('express');

const { createPostTranslation } = require('../controllers/translationController');

const createTranslationRoutes = ({ DEEPL_API_KEY, DEEPL_API_HOST, httpsJsonRequest }) => {
  const router = express.Router();

  router.post(
    '/api/translate',
    createPostTranslation({ DEEPL_API_KEY, DEEPL_API_HOST, httpsJsonRequest }),
  );

  return router;
};

module.exports = createTranslationRoutes;
