const nearbyPlaceCatalog = {
  paris: {
    attractions: [
      { name: 'Eiffel Tower', distanceKm: 2.1, type: 'attraction' },
      { name: 'Louvre Museum', distanceKm: 3.4, type: 'attraction' },
      { name: 'Montmartre', distanceKm: 4.2, type: 'attraction' },
    ],
    restaurants: [
      { name: 'Le Petit Bistro', distanceKm: 0.6, type: 'restaurant' },
      { name: 'Maison du Brunch', distanceKm: 1.1, type: 'restaurant' },
      { name: 'Cafe de Seine', distanceKm: 1.7, type: 'restaurant' },
    ],
    transport: [
      { name: 'Metro Line 1', distanceKm: 0.3, type: 'transport' },
      { name: 'RER A Station', distanceKm: 0.7, type: 'transport' },
      { name: 'Airport Shuttle Stop', distanceKm: 1.2, type: 'transport' },
    ],
  },
  london: {
    attractions: [
      { name: 'Tower Bridge', distanceKm: 2.8, type: 'attraction' },
      { name: 'British Museum', distanceKm: 3.2, type: 'attraction' },
      { name: 'Hyde Park', distanceKm: 2.0, type: 'attraction' },
    ],
    restaurants: [
      { name: 'Baker Street Grill', distanceKm: 0.8, type: 'restaurant' },
      { name: 'Thames Kitchen', distanceKm: 1.4, type: 'restaurant' },
      { name: 'Mayfair Social', distanceKm: 1.9, type: 'restaurant' },
    ],
    transport: [
      { name: 'Jubilee Underground', distanceKm: 0.4, type: 'transport' },
      { name: 'Paddington Rail', distanceKm: 1.5, type: 'transport' },
      { name: 'City Bus Hub', distanceKm: 0.6, type: 'transport' },
    ],
  },
};

const fallbackNearby = {
  attractions: [
    { name: 'Historic Center', distanceKm: 1.8, type: 'attraction' },
    { name: 'City Museum', distanceKm: 2.6, type: 'attraction' },
    { name: 'Waterfront Walk', distanceKm: 3.1, type: 'attraction' },
  ],
  restaurants: [
    { name: 'Central Kitchen', distanceKm: 0.9, type: 'restaurant' },
    { name: 'Garden Cafe', distanceKm: 1.5, type: 'restaurant' },
    { name: 'Skyline Diner', distanceKm: 2.3, type: 'restaurant' },
  ],
  transport: [
    { name: 'Main Bus Station', distanceKm: 0.7, type: 'transport' },
    { name: 'Central Metro', distanceKm: 1.1, type: 'transport' },
    { name: 'Taxi Point', distanceKm: 0.4, type: 'transport' },
  ],
};

const getNearbyPlaces = async (req, res) => {
  const { city, category } = req.query;

  if (!city) {
    return res.status(400).json({ error: 'city is required' });
  }

  const key = String(city).toLowerCase();
  const cityData = nearbyPlaceCatalog[key] || fallbackNearby;

  if (category && !cityData[category]) {
    return res.status(400).json({ error: 'category must be attractions, restaurants, or transport' });
  }

  if (category) {
    return res.json({
      city,
      category,
      places: cityData[category],
    });
  }

  return res.json({
    city,
    attractions: cityData.attractions,
    restaurants: cityData.restaurants,
    transport: cityData.transport,
  });
};

module.exports = {
  getNearbyPlaces,
};
