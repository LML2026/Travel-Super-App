import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../flights/models/saved_flight.dart';
import '../../hotels/models/saved_hotel.dart';
import '../../trips/models/trip.dart';
import '../../weather/models/weather_data.dart';

class AiAssistantService {
  AiAssistantService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> generateResponse(
    String prompt, {
    List<Trip> trips = const [],
    List<SavedFlight> flights = const [],
    List<SavedHotel> hotels = const [],
    WeatherData? weather,
    List<String> nearbyAttractions = const [],
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.aiTravelPlan,
        data: {
          'prompt': prompt,
          'trips': trips.map((trip) => trip.toJson()).toList(),
          'flights': flights
              .map(
                (flight) => {
                  'flightId': flight.flightId,
                  'airline': flight.airline,
                  'flightNumber': flight.flightNumber,
                  'origin': flight.origin,
                  'destination': flight.destination,
                  'currency': flight.currency,
                },
              )
              .toList(),
          'hotels': hotels
              .map(
                (hotel) => {
                  'hotelId': hotel.hotelId,
                  'name': hotel.name,
                  'city': hotel.city,
                  'pricePerNight': hotel.pricePerNight,
                  'currency': hotel.currency,
                },
              )
              .toList(),
          'weather': weather?.toJson(),
          'nearbyAttractions': nearbyAttractions,
        },
      );

      final backendResponse = response.data['response']?.toString();
      if (backendResponse != null && backendResponse.isNotEmpty) {
        return backendResponse;
      }
    } catch (_) {
      // Fall back to local planner guidance if the backend endpoint is unavailable.
    }

    final lower = prompt.toLowerCase();
    final destination = _extractDestination(prompt);
    final budget = _extractBudget(prompt);
    final nights = _extractNights(lower);
    final linkedTrip = _findRelevantTrip(destination, trips);
    final linkedFlight = _findRelevantFlight(destination, flights);
    final linkedHotel = _findRelevantHotel(destination, hotels);

    final advice = <String>[];

    if (trips.isNotEmpty || flights.isNotEmpty || hotels.isNotEmpty) {
      advice.add(
        'I can see ${trips.length} saved trip${trips.length == 1 ? '' : 's'}, '
        '${flights.length} saved flight${flights.length == 1 ? '' : 's'}, and '
        '${hotels.length} saved hotel${hotels.length == 1 ? '' : 's'} in your account.',
      );
    }

    if (linkedTrip != null) {
      advice.add(
        'You already have a trip for ${linkedTrip.destination} from '
        '${linkedTrip.startDate.day}/${linkedTrip.startDate.month} to '
        '${linkedTrip.endDate.day}/${linkedTrip.endDate.month} with a '
        '${linkedTrip.currency} ${linkedTrip.budget.toStringAsFixed(0)} budget.',
      );
    }

    if (linkedFlight != null) {
      advice.add(
        'Saved flight match: ${linkedFlight.airline} ${linkedFlight.flightNumber} '
        '${linkedFlight.origin} → ${linkedFlight.destination}.',
      );
    }

    if (linkedHotel != null) {
      advice.add(
        'Saved hotel match: ${linkedHotel.name} in ${linkedHotel.city} at '
        '${linkedHotel.currency} ${linkedHotel.pricePerNight.toStringAsFixed(0)} per night.',
      );
    }

    if (weather != null) {
      advice.add(
        'Expected weather is about ${weather.tempC.toStringAsFixed(0)}°C with ${weather.description.toLowerCase()}, so plan a mix of outdoor sightseeing and indoor stops.',
      );
    }

    if (nearbyAttractions.isNotEmpty) {
      advice.add(
        'Good nearby attractions to organise into the itinerary: ${nearbyAttractions.take(3).join(', ')}.',
      );
    }

    if (destination != null) {
      advice.add('For $destination, start by locking in flights early and booking a central hotel to reduce daily transport costs.');
      advice.add('Prioritise 2-3 major attractions and keep one lighter day for local neighbourhoods and restaurants.');
    }

    if (budget != null) {
      advice.add('With a budget of £${budget.toStringAsFixed(0)}, aim to keep about 40% for hotel, 30% for flights, and reserve the rest for food, transport, and attractions.');
    }

    if (nights != null) {
      advice.add('For a ${nights}-day trip, plan one anchor activity per day and group nearby sights together to avoid wasted travel time.');
    }

    if (linkedTrip != null && linkedHotel != null) {
      advice.add(
        'Based on your saved trip, a good itinerary pattern is arrival and hotel check-in on day one, two sightseeing days around ${linkedHotel.city}, and a lighter final morning before departure.',
      );
    }

    if (advice.isEmpty) {
      advice.add('Tell me your destination, trip length, and budget, and I can suggest flights, hotels, daily pacing, and likely spending.');
    }

    advice.add('Next step: open Flights, Hotels, and Trips to turn this plan into a saved itinerary.');
    return advice.join('\n\n');
  }

  Trip? _findRelevantTrip(String? destination, List<Trip> trips) {
    if (destination == null) return trips.isEmpty ? null : trips.first;
    final lower = destination.toLowerCase();
    for (final trip in trips) {
      if (trip.destination.toLowerCase().contains(lower)) {
        return trip;
      }
    }
    return trips.isEmpty ? null : trips.first;
  }

  SavedFlight? _findRelevantFlight(String? destination, List<SavedFlight> flights) {
    if (destination == null) return flights.isEmpty ? null : flights.first;
    final lower = destination.toLowerCase();
    for (final flight in flights) {
      if (flight.destination.toLowerCase().contains(lower) || flight.origin.toLowerCase().contains(lower)) {
        return flight;
      }
    }
    return flights.isEmpty ? null : flights.first;
  }

  SavedHotel? _findRelevantHotel(String? destination, List<SavedHotel> hotels) {
    if (destination == null) return hotels.isEmpty ? null : hotels.first;
    final lower = destination.toLowerCase();
    for (final hotel in hotels) {
      if (hotel.city.toLowerCase().contains(lower) || hotel.name.toLowerCase().contains(lower)) {
        return hotel;
      }
    }
    return hotels.isEmpty ? null : hotels.first;
  }

  String? _extractDestination(String prompt) {
    final regex = RegExp(r'to\s+([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*)');
    final match = regex.firstMatch(prompt);
    return match?.group(1);
  }

  double? _extractBudget(String prompt) {
    final regex = RegExp(r'[£$]\s?(\d+(?:,\d{3})*(?:\.\d+)?)');
    final match = regex.firstMatch(prompt);
    final value = match?.group(1)?.replaceAll(',', '');
    return value == null ? null : double.tryParse(value);
  }

  int? _extractNights(String prompt) {
    final regex = RegExp(r'(\d+)\s+(?:day|days|night|nights)');
    final match = regex.firstMatch(prompt);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}
