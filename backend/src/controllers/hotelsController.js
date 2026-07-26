const createHandleHotelSearch = () => {
  return async (req, res, next) => {
    try {
      const {
        city,
        checkInDate,
        checkOutDate,
        guests = 1,
        rooms = 1,
      } = req.body;

      if (!city || !checkInDate || !checkOutDate) {
        return res.status(400).json({ error: 'city, checkInDate, and checkOutDate are required' });
      }

      const hotelsByCity = {
        paris: [
          { id: 'h1', name: 'Le Marais Boutique', rating: 4.8, price: 145, image: '🏨', beds: 2 },
          { id: 'h2', name: 'Eiffel Tower Classic', rating: 4.5, price: 120, image: '🏨', beds: 1 },
          { id: 'h3', name: 'Champs-Élysées Luxury', rating: 4.9, price: 280, image: '🏨', beds: 2 },
          { id: 'h4', name: 'Latin Quarter Budget', rating: 4.2, price: 85, image: '🏨', beds: 1 },
          { id: 'h5', name: 'Montmartre Charm', rating: 4.6, price: 110, image: '🏨', beds: 2 },
        ],
        london: [
          { id: 'h6', name: 'Westminster Palace', rating: 4.7, price: 160, image: '🏨', beds: 2 },
          { id: 'h7', name: 'Soho Trendy', rating: 4.4, price: 95, image: '🏨', beds: 1 },
          { id: 'h8', name: 'Kensington Elegant', rating: 4.9, price: 250, image: '🏨', beds: 2 },
          { id: 'h9', name: 'Covent Garden Central', rating: 4.5, price: 130, image: '🏨', beds: 1 },
        ],
        barcelona: [
          { id: 'h10', name: 'Gothic Quarter Historic', rating: 4.6, price: 105, image: '🏨', beds: 2 },
          { id: 'h11', name: 'Gaudí View Premium', rating: 4.8, price: 200, image: '🏨', beds: 2 },
          { id: 'h12', name: 'Beach Front Relax', rating: 4.5, price: 140, image: '🏨', beds: 1 },
        ],
        'new york': [
          { id: 'h13', name: 'Manhattan Dream', rating: 4.9, price: 320, image: '🏨', beds: 2 },
          { id: 'h14', name: 'Times Square Plaza', rating: 4.4, price: 180, image: '🏨', beds: 1 },
          { id: 'h15', name: 'Brooklyn Cool', rating: 4.6, price: 120, image: '🏨', beds: 2 },
        ],
        tokyo: [
          { id: 'h16', name: 'Shibuya Modern', rating: 4.7, price: 150, image: '🏨', beds: 1 },
          { id: 'h17', name: 'Kyoto Traditional', rating: 4.8, price: 130, image: '🏨', beds: 2 },
          { id: 'h18', name: 'Ginza Luxury', rating: 4.9, price: 290, image: '🏨', beds: 2 },
        ],
      };

      const cityLower = city.toLowerCase();
      const hotels = hotelsByCity[cityLower] || [];

      if (hotels.length === 0) {
        return res.json({
          city,
          checkInDate,
          checkOutDate,
          guests,
          rooms,
          hotels: [],
          count: 0,
        });
      }

      const checkIn = new Date(checkInDate);
      const checkOut = new Date(checkOutDate);
      const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));

      const results = hotels.map((h) => ({
        id: h.id,
        name: h.name,
        city,
        rating: h.rating,
        pricePerNight: h.price,
        totalPrice: h.price * nights * rooms,
        beds: h.beds,
        image: h.image,
        nights,
      }));

      results.sort((a, b) => a.totalPrice - b.totalPrice);

      res.json({
        city,
        checkInDate,
        checkOutDate,
        guests,
        rooms,
        nights,
        hotels: results.slice(0, 20),
        count: results.length,
      });
    } catch (error) {
      next(error);
    }
  };
};

module.exports = {
  createHandleHotelSearch,
};
