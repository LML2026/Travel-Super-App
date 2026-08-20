import '../../../core/utils/result.dart';
import '../../../core/models/booking.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../services/hotel_api_service.dart';
import '../../../core/utils/app_logger.dart';

class HotelRepository {
  final HotelApiService _hotelService;

  HotelRepository(this._hotelService);

  Future<Result<List<Hotel>>> searchHotels(HotelSearchRequest request) async {
    try {
      appLogger.i('🏨 Repository: Searching hotels for ${request.city}');
      final hotels = await _hotelService.searchHotels(request);
      appLogger.i('✅ Repository: Found ${hotels.length} hotels');
      return Success(hotels);
    } catch (e, st) {
      appLogger.e(
        '❌ Repository: Hotel search failed',
        error: e,
        stackTrace: st,
      );
      return Failure(
        'We could not search hotels right now. Please try again.',
        error: e,
      );
    }
  }

  Future<Result<Booking>> bookHotel(
    String tripId,
    String userId,
    Hotel hotel,
  ) async {
    try {
      appLogger
          .i('HotelRepository: booking hotel ${hotel.id} for trip $tripId');
      // Mocked booking process
      await Future.delayed(const Duration(seconds: 2));

      final booking = Booking.hotel(
        id: 'HTL-${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripId,
        userId: userId,
        amount: hotel.pricePerNight,
        currency: hotel.currency,
        metadata: {
          'hotelId': hotel.id,
          'name': hotel.name,
          'address': hotel.address,
        },
      );

      appLogger.i('HotelRepository: hotel booked successfully');
      return Success(booking.copyWith(status: BookingStatus.confirmed));
    } catch (e, st) {
      appLogger.e('HotelRepository: booking failed', error: e, stackTrace: st);
      return Failure(e.toString(), error: e);
    }
  }
}
