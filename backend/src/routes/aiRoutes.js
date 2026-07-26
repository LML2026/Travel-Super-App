const express = require('express');

const { createPostTravelPlan } = require('../controllers/aiController');

const createAiRoutes = ({ OPENAI_API_KEY, OPENAI_MODEL, httpsJsonRequest }) => {
  const router = express.Router();

  router.post(
    '/api/ai/travel-plan',
    createPostTravelPlan({ OPENAI_API_KEY, OPENAI_MODEL, httpsJsonRequest }),
  );

  return router;
};

module.exports = createAiRoutes;
