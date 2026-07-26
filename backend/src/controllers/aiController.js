const createPostTravelPlan = ({ OPENAI_API_KEY, OPENAI_MODEL, httpsJsonRequest }) => {
  const buildLocalTravelPlan = ({
    trips = [],
    flights = [],
    hotels = [],
    weather,
    nearbyAttractions = [],
  }) => {
    const trip = trips[0] || null;
    const flight = flights[0] || null;
    const hotel = hotels[0] || null;
    const notes = [];

    if (trip) {
      notes.push(
        `You already have a saved trip for ${trip.destination} from ${trip.startDate} to ${trip.endDate} with a ${trip.currency} ${Number(trip.budget || 0).toFixed(0)} budget.`,
      );
    }

    if (flight) {
      notes.push(`Saved flight match: ${flight.airline} ${flight.flightNumber} ${flight.origin} -> ${flight.destination}.`);
    }

    if (hotel) {
      notes.push(`Saved hotel match: ${hotel.name} in ${hotel.city} at ${hotel.currency} ${Number(hotel.pricePerNight || 0).toFixed(0)} per night.`);
    }

    if (weather) {
      notes.push(`Expected weather is around ${Number(weather.tempC || 0).toFixed(0)}C with ${String(weather.description || 'mixed conditions').toLowerCase()}.`);
    }

    if (Array.isArray(nearbyAttractions) && nearbyAttractions.length > 0) {
      notes.push(`Useful nearby attractions: ${nearbyAttractions.slice(0, 3).join(', ')}.`);
    }

    notes.push('Suggested itinerary approach: keep one anchor activity per day, group nearby attractions together, and leave the arrival or departure day lighter.');
    notes.push('Suggested budget split: roughly 40% hotel, 30% flights, and the remainder across food, local transport, and attractions.');
    notes.push('Next step: review your saved Trip, Flight, and Hotel details in the app and adjust bookings before finalising the itinerary.');
    return notes.join('\n\n');
  };

  const buildAiPrompt = ({ prompt, trips = [], flights = [], hotels = [], weather, nearbyAttractions = [] }) => {
    return [
      'You are a travel planning assistant inside the Travel Super App.',
      'Use the user request and account context to produce a practical, concise itinerary and planning advice.',
      'Prefer clear sections and concrete next steps.',
      `User prompt: ${prompt}`,
      `Saved trips: ${JSON.stringify(trips)}`,
      `Saved flights: ${JSON.stringify(flights)}`,
      `Saved hotels: ${JSON.stringify(hotels)}`,
      `Weather context: ${JSON.stringify(weather || null)}`,
      `Nearby attractions: ${JSON.stringify(nearbyAttractions)}`,
    ].join('\n');
  };

  const requestOpenAiPlan = async (plannerContext) => {
    if (!OPENAI_API_KEY) {
      return null;
    }

    const body = {
      model: OPENAI_MODEL,
      messages: [
        {
          role: 'system',
          content: 'You are a helpful travel planner. Produce concise but useful trip planning guidance grounded in the supplied travel context.',
        },
        {
          role: 'user',
          content: buildAiPrompt(plannerContext),
        },
      ],
      temperature: 0.7,
    };

    const response = await httpsJsonRequest(
      {
        hostname: 'api.openai.com',
        path: '/v1/chat/completions',
        method: 'POST',
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
      },
      body,
      1,
    );

    return response?.data?.choices?.[0]?.message?.content?.trim() || null;
  };

  return async (req, res) => {
    const {
      prompt,
      trips = [],
      flights = [],
      hotels = [],
      weather,
      nearbyAttractions = [],
    } = req.body || {};

    if (!prompt || typeof prompt !== 'string' || !prompt.trim()) {
      return res.status(400).json({ error: 'prompt is required' });
    }

    const plannerContext = {
      prompt,
      trips,
      flights,
      hotels,
      weather,
      nearbyAttractions,
    };

    try {
      const aiResponse = await requestOpenAiPlan(plannerContext);
      if (aiResponse) {
        return res.json({ prompt, response: aiResponse, source: 'llm' });
      }
    } catch (error) {
      console.error('AI provider failed, falling back to local planner:', error.message);
    }

    return res.json({
      prompt,
      response: buildLocalTravelPlan(plannerContext),
      source: 'fallback',
    });
  };
};

module.exports = {
  createPostTravelPlan,
};
