import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/taxi/domain/entities/taxi_ride_request.dart';
import '../../features/flights/models/flight.dart';
import '../../features/flights/models/flight_search_request.dart';
import '../../features/hotels/models/hotel.dart';
import '../../features/hotels/models/hotel_search_request.dart';
import '../../features/weather/models/weather_data.dart';

enum TravelProviderCapability {
  search,
  booking,
  weather,
  currency,
  places,
  translation,
  notifications,
  offlineStorage,
}

enum TravelDataSource {
  live,
  cached,
  mock,
}

class TravelProviderDescriptor {
  const TravelProviderDescriptor({
    required this.id,
    required this.displayName,
    required this.capabilities,
    required this.isLive,
    required this.requiresNetwork,
  });

  final String id;
  final String displayName;
  final Set<TravelProviderCapability> capabilities;
  final bool isLive;
  final bool requiresNetwork;
}

class ExchangeRateQuote {
  const ExchangeRateQuote({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.retrievedAt,
    required this.isLive,
  });

  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime? retrievedAt;
  final bool isLive;
}

class MoneyAmount {
  const MoneyAmount({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;
}

class TranslationResult {
  const TranslationResult({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.dataSource,
  });

  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final TravelDataSource dataSource;
}

class PlaceResult {
  const PlaceResult({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.location,
    this.rating,
    this.priceLevel,
    this.imageUrl,
    this.description,
    required this.dataSource,
    this.isOpenNow,
  });

  final String id;
  final String name;
  final PlaceCategory category;
  final String? address;
  final GeoPoint? location;
  final double? rating;
  final String? priceLevel;
  final String? imageUrl;
  final String? description;
  final TravelDataSource dataSource;
  final bool? isOpenNow;
}

class PlaceDetails extends PlaceResult {
  const PlaceDetails({
    required super.id,
    required super.name,
    required super.category,
    super.address,
    super.location,
    super.rating,
    super.priceLevel,
    super.imageUrl,
    super.description,
    required super.dataSource,
    super.isOpenNow,
    this.phone,
    this.website,
  });

  final String? phone;
  final String? website;
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}

enum NotificationSource {
  planner,
  itinerary,
  weather,
  budget,
  wallet,
  assistant,
  system,
}

class TravelNotification {
  const TravelNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.scheduledFor,
    this.journeyId,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
    this.source = NotificationSource.system,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final TravelNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String? journeyId;
  final bool isRead;
  final NotificationPriority priority;
  final NotificationSource source;
  final Map<String, Object?> metadata;

  factory TravelNotification.fromJson(Map<String, dynamic> json) {
    return TravelNotification(
      id: json['id'] as String,
      type: TravelNotificationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => TravelNotificationType.journeyReminder,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      journeyId: json['journeyId'] as String?,
      isRead: json['isRead'] == true,
      priority: NotificationPriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      source: NotificationSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => NotificationSource.system,
      ),
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'journeyId': journeyId,
      'isRead': isRead,
      'priority': priority.name,
      'source': source.name,
      'metadata': metadata,
    };
  }
}

enum TravelNotificationType {
  journeyReminder,
  disruption,
  weatherAlert,
  budgetWarning,
  reward,
  documentReminder,
}

enum PlaceCategory {
  attraction,
  museum,
  restaurant,
  cafe,
  toilet,
  atm,
  shopping,
  pharmacy,
  hospital,
  fuelStation,
  parking,
  supermarket,
  taxiStand,
  transportStation,
  accommodation,
}

abstract class TravelProvider {
  TravelProviderDescriptor get descriptor => const TravelProviderDescriptor(
        id: 'default-provider',
        displayName: 'Default Provider',
        capabilities: <TravelProviderCapability>{},
        isLive: false,
        requiresNetwork: false,
      );

  Future<bool> isAvailable();

  String get name => descriptor.displayName;
}

abstract class TransportProvider implements TravelProvider {
  Future<void> openBooking(TaxiRideRequest request);
}

abstract class FlightProvider implements TravelProvider {
  Future<List<Flight>> searchFlights(FlightSearchRequest request);
}

abstract class WeatherProvider implements TravelProvider {
  Future<WeatherData> getWeather(String city);
}

abstract class HotelProvider implements TravelProvider {
  Future<List<Hotel>> searchHotels(HotelSearchRequest request);
}

abstract class PaymentProvider implements TravelProvider {
  Future<void> startCheckout({
    required String reference,
    required double amount,
    required String currency,
  });
}

abstract interface class ActivityProvider implements TravelProvider {
  Future<List<String>> searchActivities({
    required String destination,
  });
}

abstract interface class TranslationProvider implements TravelProvider {
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  });
}

abstract class TravelCurrencyProvider implements TravelProvider {
  Future<ExchangeRateQuote> getRate({
    required String baseCurrency,
    required String targetCurrency,
  });

  Future<MoneyAmount> convert({
    required MoneyAmount amount,
    required String targetCurrency,
  });
}

abstract class TravelPlacesProvider implements TravelProvider {
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    GeoPoint? near,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  });

  Future<PlaceDetails?> getPlaceDetails(String placeId);
}

abstract class TravelTranslationProvider implements TravelProvider {
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });
}

abstract interface class TravelNotificationProvider implements TravelProvider {
  Future<List<TravelNotification>> getPendingNotifications({
    String? journeyId,
  });
}

abstract interface class TravelOfflineStore implements TravelProvider {
  Future<void> save<T>(String key, T value);
  Future<T?> read<T>(String key);
  Future<void> remove(String key);
  Future<bool> contains(String key);
}
