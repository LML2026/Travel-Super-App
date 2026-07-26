import '../../flights/models/saved_flight.dart';
import '../../hotels/models/saved_hotel.dart';
import '../../trips/models/trip.dart';
import '../../weather/models/weather_data.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.userName,
    this.upcomingTrip,
    this.linkedFlight,
    this.linkedHotel,
    this.weather,
    this.budget = 0,
    this.currency = 'GBP',
  });

  final String userName;
  final Trip? upcomingTrip;
  final SavedFlight? linkedFlight;
  final SavedHotel? linkedHotel;
  final WeatherData? weather;
  final double budget;
  final String currency;

  bool get hasUpcomingTrip => upcomingTrip != null;
}
