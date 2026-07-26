import '../../../core/api/api_client.dart';
import 'hotel_api_service.dart';

@Deprecated('Use HotelApiService from hotel_api_service.dart')
class HotelService extends HotelApiService {
  HotelService({ApiClient? apiClient}) : super(apiClient: apiClient);
}
