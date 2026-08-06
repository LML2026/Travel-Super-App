import '../../flights/models/saved_flight.dart';
import '../../hotels/models/saved_hotel.dart';
import '../../trips/domain/entities/trip.dart';
import '../../weather/models/weather_data.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantRepository {
  AiAssistantRepository(this._service);

  final AiAssistantService _service;

  Future<String> generateResponse(
    String prompt, {
    List<Trip> trips = const [],
    List<SavedFlight> flights = const [],
    List<SavedHotel> hotels = const [],
    WeatherData? weather,
    List<String> nearbyAttractions = const [],
  }) {
    return _service.generateResponse(
      prompt,
      trips: trips,
      flights: flights,
      hotels: hotels,
      weather: weather,
      nearbyAttractions: nearbyAttractions,
    );
  }
}
