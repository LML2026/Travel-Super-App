import 'dart:convert';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';

class HotelApiService {
  HotelApiService({
    ApiClient? apiClient,
    Future<List<Hotel>> Function(HotelSearchRequest request)? backendSearch,
  })  : _apiClient = apiClient ?? ApiClient(),
        _backendSearch = backendSearch;

  final ApiClient _apiClient;
  final Future<List<Hotel>> Function(HotelSearchRequest request)?
      _backendSearch;

  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async {
    try {
      final hotels =
          await (_backendSearch?.call(request) ?? _searchBackend(request));
      if (hotels.isNotEmpty) return hotels;
    } catch (_) {
      // Use local results when the backend is unavailable.
    }

    return _demoHotels(request);
  }

  Future<List<Hotel>> _searchBackend(HotelSearchRequest request) async {
    final response = await _apiClient
        .post(
          ApiEndpoints.hotelsSearch,
          data: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 || response.data is! Map) {
      throw const HotelSearchException();
    }

    final hotelsList = response.data['hotels'];
    if (hotelsList is! List) throw const HotelSearchException();
    return hotelsList
        .whereType<Map>()
        .map((hotel) => Hotel.fromJson(
              Map<String, dynamic>.from(hotel),
              dataSource: HotelDataSource.backend,
            ))
        .take(25)
        .toList(growable: false);
  }

  List<Hotel> _demoHotels(HotelSearchRequest request) {
    final nights = request.checkOutDate.difference(request.checkInDate).inDays;
    final stayNights = nights > 0 ? nights : 1;
    final city = request.city.trim();
    return [
      Hotel(
        id: 'demo-${city.toLowerCase().replaceAll(' ', '-')}-central',
        name: 'Demo Central Hotel',
        image: '',
        rating: 4.2,
        address: '$city City Center',
        city: city,
        price: 118,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi', 'Breakfast Included', '24h Front Desk'],
        totalPrice: 118.0 * stayNights,
        nights: stayNights,
        dataSource: HotelDataSource.demo,
      ),
      Hotel(
        id: 'demo-${city.toLowerCase().replaceAll(' ', '-')}-riverside',
        name: 'Demo Riverside House',
        image: '',
        rating: 4.5,
        address: '$city Riverside District',
        city: city,
        price: 156,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi', 'Restaurant', 'Late Check-in'],
        totalPrice: 156.0 * stayNights,
        nights: stayNights,
        dataSource: HotelDataSource.demo,
      ),
      Hotel(
        id: 'demo-${city.toLowerCase().replaceAll(' ', '-')}-airport',
        name: 'Demo Airport Link Hotel',
        image: '',
        rating: 3.9,
        address: '$city Airport District',
        city: city,
        price: 92,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi', 'Airport Shuttle', '24h Front Desk'],
        totalPrice: 92.0 * stayNights,
        nights: stayNights,
        dataSource: HotelDataSource.demo,
      ),
    ];
  }
}

class HotelSearchException implements Exception {
  const HotelSearchException();
}
