const createGetWeather = ({ httpsJson, WEATHER_RETRIES }) => {
  return async (req, res) => {
    const city = req.query.city;
    if (!city) return res.status(400).json({ error: 'city is required' });

    try {
      const geocodeOptions = {
        hostname: 'geocoding-api.open-meteo.com',
        path: `/v1/search?name=${encodeURIComponent(city)}&count=1&language=en&format=json`,
        method: 'GET',
        headers: { Accept: 'application/json' },
      };

      const geocodeData = await httpsJson(geocodeOptions, WEATHER_RETRIES);

      const loc = geocodeData.results?.[0];
      if (!loc) return res.status(404).json({ error: `City not found: ${city}` });

      const { latitude, longitude, name, country } = loc;

      const weatherOptions = {
        hostname: 'api.open-meteo.com',
        path: `/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&wind_speed_unit=kmh`,
        method: 'GET',
        headers: { Accept: 'application/json' },
      };

      const weatherData = await httpsJson(weatherOptions, WEATHER_RETRIES);

      const current = weatherData.current;
      const code = current.weather_code;

      const descriptionMap = (c) => {
        if (c === 0) return { desc: 'Clear sky', cond: 'clear' };
        if (c <= 3) return { desc: 'Partly cloudy', cond: 'cloud' };
        if (c <= 49) return { desc: 'Foggy', cond: 'fog' };
        if (c <= 69) return { desc: 'Rainy', cond: 'rain' };
        if (c <= 79) return { desc: 'Snowy', cond: 'snow' };
        if (c <= 99) return { desc: 'Thunderstorm', cond: 'storm' };
        return { desc: 'Unknown', cond: 'unknown' };
      };

      const { desc, cond } = descriptionMap(code);
      const tempC = current.temperature_2m;
      const tempF = (tempC * 9 / 5) + 32;

      res.json({
        city: name,
        country,
        tempC,
        tempF: Math.round(tempF * 10) / 10,
        description: desc,
        iconCode: String(code),
        humidity: current.relative_humidity_2m,
        windKph: current.wind_speed_10m,
        condition: cond,
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch weather', details: error.message });
    }
  };
};

module.exports = {
  createGetWeather,
};
