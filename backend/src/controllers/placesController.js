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
    toilets: [
      { name: 'City Center Public Restrooms', distanceKm: 0.5, type: 'toilet' },
      { name: 'Museum Quarter Facilities', distanceKm: 1.2, type: 'toilet' },
      { name: 'Park Restroom Pavilion', distanceKm: 1.8, type: 'toilet' },
    ],
    supermarkets: [
      { name: 'Central Market', distanceKm: 0.7, type: 'supermarket' },
      { name: 'Neighbourhood Grocery', distanceKm: 1.0, type: 'supermarket' },
      { name: 'Express Food Hall', distanceKm: 1.5, type: 'supermarket' },
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
    toilets: [
      { name: 'Station Public Toilets', distanceKm: 0.4, type: 'toilet' },
      { name: 'Riverside Facilities', distanceKm: 1.1, type: 'toilet' },
      { name: 'Shopping Arcade Restrooms', distanceKm: 1.6, type: 'toilet' },
    ],
    supermarkets: [
      { name: 'High Street Supermarket', distanceKm: 0.6, type: 'supermarket' },
      { name: 'Local Grocery Market', distanceKm: 1.2, type: 'supermarket' },
      { name: 'Station Food Store', distanceKm: 1.7, type: 'supermarket' },
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
  cafes: [
    { name: 'Corner Coffee', distanceKm: 0.4, type: 'cafe' },
    { name: 'Station Cafe', distanceKm: 0.8, type: 'cafe' },
    { name: 'Garden Espresso Bar', distanceKm: 1.1, type: 'cafe' },
  ],
  transport: [
    { name: 'Main Bus Station', distanceKm: 0.7, type: 'transport' },
    { name: 'Central Metro', distanceKm: 1.1, type: 'transport' },
    { name: 'Taxi Point', distanceKm: 0.4, type: 'transport' },
  ],
  taxis: [
    { name: 'Central Taxi Rank', distanceKm: 0.4, type: 'taxi' },
    { name: 'Station Taxi Point', distanceKm: 0.9, type: 'taxi' },
    { name: 'Hotel Pickup Area', distanceKm: 1.2, type: 'taxi' },
  ],
  toilets: [
    { name: 'Public Restrooms', distanceKm: 0.5, type: 'toilet' },
    { name: 'Visitor Center Facilities', distanceKm: 1.0, type: 'toilet' },
    { name: 'Transit Hub Restrooms', distanceKm: 1.4, type: 'toilet' },
  ],
  atms: [
    { name: 'Central ATM', distanceKm: 0.3, type: 'atm' },
    { name: 'Station Cash Point', distanceKm: 0.7, type: 'atm' },
    { name: 'Bank ATM', distanceKm: 1.1, type: 'atm' },
  ],
  pharmacies: [
    { name: 'Central Pharmacy', distanceKm: 0.6, type: 'pharmacy' },
    { name: 'Travel Health Pharmacy', distanceKm: 1.1, type: 'pharmacy' },
    { name: 'Late Pharmacy', distanceKm: 1.8, type: 'pharmacy' },
  ],
  hospitals: [
    { name: 'City Medical Centre', distanceKm: 1.4, type: 'hospital' },
    { name: 'General Hospital', distanceKm: 2.3, type: 'hospital' },
    { name: 'Urgent Care Clinic', distanceKm: 2.7, type: 'hospital' },
  ],
  supermarkets: [
    { name: 'Central Supermarket', distanceKm: 0.8, type: 'supermarket' },
    { name: 'Daily Grocery', distanceKm: 1.3, type: 'supermarket' },
    { name: 'Market Food Store', distanceKm: 1.9, type: 'supermarket' },
  ],
  parking: [
    { name: 'Central Parking', distanceKm: 0.5, type: 'parking' },
    { name: 'Station Car Park', distanceKm: 0.9, type: 'parking' },
    { name: 'Market Parking Garage', distanceKm: 1.4, type: 'parking' },
  ],
  fuel: [
    { name: 'City Fuel Station', distanceKm: 1.2, type: 'fuel' },
    { name: 'Roadside Petrol Station', distanceKm: 1.9, type: 'fuel' },
    { name: 'Express Gas Station', distanceKm: 2.4, type: 'fuel' },
  ],
  trainStations: [
    { name: 'Central Train Station', distanceKm: 0.9, type: 'trainStation' },
    { name: 'North Rail Station', distanceKm: 1.7, type: 'trainStation' },
    { name: 'Airport Rail Link', distanceKm: 2.8, type: 'trainStation' },
  ],
  busStations: [
    { name: 'Main Bus Station', distanceKm: 0.7, type: 'busStation' },
    { name: 'City Coach Terminal', distanceKm: 1.4, type: 'busStation' },
    { name: 'Transit Bus Hub', distanceKm: 1.9, type: 'busStation' },
  ],
  airports: [
    { name: 'International Airport', distanceKm: 8.6, type: 'airport' },
    { name: 'City Airport Terminal', distanceKm: 10.2, type: 'airport' },
    { name: 'Airport Transfer Hub', distanceKm: 7.8, type: 'airport' },
  ],
  evCharging: [
    { name: 'Central EV Charging', distanceKm: 0.8, type: 'evCharging' },
    { name: 'Station Charge Point', distanceKm: 1.3, type: 'evCharging' },
    { name: 'Parking Garage EV Chargers', distanceKm: 1.7, type: 'evCharging' },
  ],
};

const supportedCategories = [
  'attractions',
  'attraction',
  'restaurants',
  'restaurant',
  'cafes',
  'cafe',
  'transport',
  'transportStation',
  'taxi',
  'taxis',
  'taxiStand',
  'toilet',
  'toilets',
  'atm',
  'atms',
  'pharmacy',
  'pharmacies',
  'hospital',
  'hospitals',
  'supermarket',
  'supermarkets',
  'parking',
  'fuel',
  'fuelStation',
  'gas',
  'gasStation',
  'petrol',
  'petrolStation',
  'trainStation',
  'trainStations',
  'busStation',
  'busStations',
  'airport',
  'airports',
  'evCharging',
  'evChargingStation',
  'electricVehicleChargingStation',
  'electric_vehicle_charging_station',
];

const normalizeCategory = (category) => {
  const normalized = String(category || '').trim();
  const aliases = {
    attraction: 'attractions',
    restaurant: 'restaurants',
    cafe: 'cafes',
    transportStation: 'transport',
    taxi: 'taxis',
    taxiStand: 'taxis',
    toilet: 'toilets',
    atm: 'atms',
    pharmacy: 'pharmacies',
    hospital: 'hospitals',
    supermarket: 'supermarkets',
    fuelStation: 'fuel',
    gas: 'fuel',
    gasStation: 'fuel',
    petrol: 'fuel',
    petrolStation: 'fuel',
    trainStation: 'trainStations',
    busStation: 'busStations',
    airport: 'airports',
    evChargingStation: 'evCharging',
    electricVehicleChargingStation: 'evCharging',
    electric_vehicle_charging_station: 'evCharging',
  };
  return aliases[normalized] || normalized;
};


const liveSearchQueries = {
  attractions: 'things to do',
  restaurants: 'restaurants',
  cafes: 'cafes',
  transport: 'public transport stations',
  taxis: 'taxi stands',
  toilets: 'public toilets',
  atms: 'ATMs',
  pharmacies: 'pharmacies',
  hospitals: 'hospitals',
  supermarkets: 'supermarkets',
  parking: 'parking',
  fuel: 'petrol stations',
  trainStations: 'train stations',
  busStations: 'bus stations',
  airports: 'airports',
  evCharging: 'EV charging stations',
};

const haversineDistanceKm = (lat1, lon1, lat2, lon2) => {
  if ([lat1, lon1, lat2, lon2].some((value) => typeof value !== 'number')) {
    return null;
  }

  const toRad = (value) => value * Math.PI / 180;
  const earthRadiusKm = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) ** 2;

  return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

const createGetNearbyPlaces = ({
  httpsJsonRequest,
  GOOGLE_MAPS_API_KEY,
} = {}) => async (req, res) => {
  const { city, category, latitude, longitude } = req.query;

  if (!city) {
    return res.status(400).json({ error: 'city is required' });
  }

  const key = String(city).toLowerCase();
  const cityData = {
    ...fallbackNearby,
    ...(nearbyPlaceCatalog[key] || {}),
  };

  const categoryKey = normalizeCategory(category);

  if (category && !cityData[categoryKey]) {
    return res.status(400).json({
      error: `category must be ${supportedCategories.join(', ')}`,
    });
  }

  const fallbackResponse = () => {
    if (category) {
      return res.json({
        city,
        category,
        places: cityData[categoryKey],
        source: 'fallback',
      });
    }

    return res.json({
      city,
      attractions: cityData.attractions,
      restaurants: cityData.restaurants,
      cafes: cityData.cafes,
      transport: cityData.transport,
      taxis: cityData.taxis,
      toilets: cityData.toilets,
      atms: cityData.atms,
      pharmacies: cityData.pharmacies,
      hospitals: cityData.hospitals,
      supermarkets: cityData.supermarkets,
      parking: cityData.parking,
      fuel: cityData.fuel,
      trainStations: cityData.trainStations,
      busStations: cityData.busStations,
      airports: cityData.airports,
      evCharging: cityData.evCharging,
      source: 'fallback',
    });
  };

  if (
    !category ||
    !GOOGLE_MAPS_API_KEY ||
    !httpsJsonRequest ||
    !liveSearchQueries[categoryKey]
  ) {
    return fallbackResponse();
  }

  const queryText = `${liveSearchQueries[categoryKey]} near ${city}`;

  try {
    const response = await httpsJsonRequest(
      {
        hostname: 'places.googleapis.com',
        path: '/v1/places:searchText',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': GOOGLE_MAPS_API_KEY,
          'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.currentOpeningHours.openNow',
        },
      },
      {
        textQuery: queryText,
        maxResultCount: 12,
      },
      1,
    );

    if (
      response?.statusCode < 200 ||
      response?.statusCode >= 300 ||
      !Array.isArray(response?.data?.places) ||
      response.data.places.length === 0
    ) {
      return fallbackResponse();
    }

    const originLat = Number(latitude);
    const originLng = Number(longitude);
    const hasOrigin = Number.isFinite(originLat) && Number.isFinite(originLng);

    const places = response.data.places.map((place) => {
      const placeLat = place?.location?.latitude;
      const placeLng = place?.location?.longitude;
      const distanceKm = hasOrigin
        ? haversineDistanceKm(originLat, originLng, placeLat, placeLng)
        : null;

      return {
        id: place.id,
        name: place?.displayName?.text || liveSearchQueries[categoryKey],
        type: categoryKey,
        address: place.formattedAddress,
        latitude: placeLat,
        longitude: placeLng,
        rating: place.rating,
        isOpenNow: place?.currentOpeningHours?.openNow,
        distanceKm:
          typeof distanceKm === 'number'
            ? Number(distanceKm.toFixed(2))
            : undefined,
        description: 'Live Google Places result',
      };
    });

    return res.json({
      city,
      category,
      places,
      source: 'google_places',
    });
  } catch (error) {
    console.error('Google Places search failed, using fallback:', error.message);
    return fallbackResponse();
  }
};

const getNearbyPlaces = async (req, res) => {
  const { city, category } = req.query;

  if (!city) {
    return res.status(400).json({ error: 'city is required' });
  }

  const key = String(city).toLowerCase();
  const cityData = {
    ...fallbackNearby,
    ...(nearbyPlaceCatalog[key] || {}),
  };

  const categoryKey = normalizeCategory(category);

  if (category && !cityData[categoryKey]) {
    return res.status(400).json({
      error: `category must be ${supportedCategories.join(', ')}`,
    });
  }

  if (category) {
    return res.json({
      city,
      category,
      places: cityData[categoryKey],
    });
  }

  return res.json({
    city,
    attractions: cityData.attractions,
    restaurants: cityData.restaurants,
    cafes: cityData.cafes,
    transport: cityData.transport,
    taxis: cityData.taxis,
    toilets: cityData.toilets,
    atms: cityData.atms,
    pharmacies: cityData.pharmacies,
    hospitals: cityData.hospitals,
    supermarkets: cityData.supermarkets,
    parking: cityData.parking,
    fuel: cityData.fuel,
    trainStations: cityData.trainStations,
    busStations: cityData.busStations,
    airports: cityData.airports,
    evCharging: cityData.evCharging,
  });
};

module.exports = {
  getNearbyPlaces,
  createGetNearbyPlaces,
};
