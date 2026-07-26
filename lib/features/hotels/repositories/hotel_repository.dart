import '../../../core/utils/result.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../services/hotel_service.dart';
import '../../../core/utils/app_logger.dart';

class HotelRepository {
  final HotelService _hotelService;

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
        e.toString(),
        error: e,
      );
    }
  }
}
