const createGetCurrencyRate = ({ httpsJson }) => {
  return async (req, res) => {
    const base = (req.query.base || 'GBP').toString().toUpperCase();
    const target = (req.query.target || 'EUR').toString().toUpperCase();

    if (base === target) {
      return res.json({ base, target, rate: 1 });
    }

    try {
      const rateOptions = {
        hostname: 'open.er-api.com',
        path: `/v6/latest/${encodeURIComponent(base)}`,
        method: 'GET',
        headers: { Accept: 'application/json' },
      };

      const rateData = await httpsJson(rateOptions, 1);
      const rate = rateData?.rates?.[target];

      if (!rate) {
        return res.status(404).json({ error: `Rate not found for ${base} -> ${target}` });
      }

      return res.json({ base, target, rate });
    } catch (error) {
      console.error('Currency rate error:', error);
      return res.status(500).json({ error: 'Failed to fetch currency rate', details: error.message });
    }
  };
};

module.exports = {
  createGetCurrencyRate,
};
