const express = require('express');

const { createHandleHotelSearch } = require('../controllers/hotelsController');

const createHotelsRoutes = () => {
  const router = express.Router();
  const handleHotelSearch = createHandleHotelSearch();

  router.post('/api/hotels/search', handleHotelSearch);
  router.get('/api/hotels/search', async (req, res, next) => {
    try {
      const {
        destination,
        city,
        checkIn,
        checkInDate,
        checkOut,
        checkOutDate,
        guests = 1,
        rooms = 1,
      } = req.query;

      req.body = {
        city: destination || city,
        checkInDate: checkIn || checkInDate,
        checkOutDate: checkOut || checkOutDate,
        guests: Number(guests),
        rooms: Number(rooms),
      };

      await handleHotelSearch(req, res, next);
    } catch (error) {
      next(error);
    }
  });

  return router;
};

module.exports = createHotelsRoutes;
