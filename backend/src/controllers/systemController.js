const getRoot = (req, res) => {
  res.json({
    status: 'ok',
    message: 'Travel Super App backend is running',
  });
};

const getHealth = (req, res) => {
  res.json({ status: 'ok' });
};

module.exports = {
  getRoot,
  getHealth,
};
