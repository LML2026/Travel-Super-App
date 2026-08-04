import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/core/utils/result.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/models/hotel_search_request.dart';
import 'package:travel_super_app/features/hotels/repositories/hotel_repository.dart';
import 'package:travel_super_app/features/hotels/services/hotel_api_service.dart';

class MockHotelService extends Mock implements HotelApiService {}

Hotel _hotel({
  required String id,
  required String name,
  required String city,
  required double rating,
  required double price,
  required double totalPrice,
  required int beds,
  required int nights,
}) {
  return Hotel(
    id: id,
    name: name,
    image: 'https://example.com/hotel.jpg',
    city: city,
    rating: rating,
    address: '$city City Center',
    price: price,
    currency: 'GBP',
    amenities: const ['Free Wi-Fi', 'Breakfast Included'],
    totalPrice: totalPrice,
    beds: beds,
    nights: nights,
  );
}

void main() {
  late MockHotelService mockHotelService;
  late HotelRepository hotelRepository;

  setUp(() {
    mockHotelService = MockHotelService();
    hotelRepository = HotelRepository(mockHotelService);
  });

  group('HotelRepository Tests', () {
    test('searchHotels returns Success with hotels list', () async {
      // Arrange
      final request = HotelSearchRequest(
        city: 'Paris',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 2,
        rooms: 1,
      );

      final mockHotels = [
        _hotel(
          id: 'h1',
          name: 'Luxury Hotel',
          city: 'Paris',
          rating: 4.8,
          price: 145.00,
          totalPrice: 435.00,
          beds: 2,
          nights: 3,
        ),
        _hotel(
          id: 'h2',
          name: 'Budget Hotel',
          city: 'Paris',
          rating: 4.0,
          price: 85.00,
          totalPrice: 255.00,
          beds: 1,
          nights: 3,
        ),
      ];

      when(
        () => mockHotelService.searchHotels(request),
      ).thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success>());
      switch (result) {
        case Success<List<Hotel>>(:final data):
          expect(data, mockHotels);
          expect(data.length, 2);
          expect(data[0].name, 'Luxury Hotel');
          expect(data[1].name, 'Budget Hotel');
        case Failure<List<Hotel>>(:final message):
          fail('Expected Success but got Failure: $message');
      }

      verify(() => mockHotelService.searchHotels(request)).called(1);
    });

    test('searchHotels returns Failure on service error', () async {
      // Arrange
      final request = HotelSearchRequest(
        city: 'Paris',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 2,
        rooms: 1,
      );

      when(
        () => mockHotelService.searchHotels(request),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Failure>());
      switch (result) {
        case Failure<List<Hotel>>(:final message):
          expect(message, contains('Network error'));
        case Success<List<Hotel>>(:final data):
          fail('Expected Failure but got Success with ${data.length} hotels');
      }

      verify(() => mockHotelService.searchHotels(request)).called(1);
    });

    test('HotelSearchRequest equality works correctly', () {
      // Test that two identical requests are equal (for provider caching)
      final request1 = HotelSearchRequest(
        city: 'Paris',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 2,
        rooms: 1,
      );

      final request2 = HotelSearchRequest(
        city: 'Paris',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 2,
        rooms: 1,
      );

      final request3 = HotelSearchRequest(
        city: 'London',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 2,
        rooms: 1,
      );

      expect(request1, request2);
      expect(request1 == request3, false);
      expect(request1.hashCode, request2.hashCode);
    });

    test('searchHotels returns empty list when no hotels found', () async {
      // Arrange
      final request = HotelSearchRequest(
        city: 'RemoteCity',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 1,
        rooms: 1,
      );

      when(
        () => mockHotelService.searchHotels(request),
      ).thenAnswer((_) async => []);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success>());
      switch (result) {
        case Success<List<Hotel>>(:final data):
          expect(data, isEmpty);
        case Failure<List<Hotel>>(:final message):
          fail('Expected Success but got Failure: $message');
      }
    });

    test('searchHotels with large guest count', () async {
      // Arrange
      final request = HotelSearchRequest(
        city: 'Paris',
        checkInDate: DateTime(2026, 8, 20),
        checkOutDate: DateTime(2026, 8, 23),
        guests: 10,
        rooms: 5,
      );

      final mockHotels = [
        _hotel(
          id: 'h1',
          name: 'Large Group Hotel',
          city: 'Paris',
          rating: 4.5,
          price: 300.00,
          totalPrice: 900.00,
          beds: 2,
          nights: 3,
        ),
      ];

      when(
        () => mockHotelService.searchHotels(request),
      ).thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success>());
      switch (result) {
        case Success<List<Hotel>>(:final data):
          expect(data, mockHotels);
        case Failure<List<Hotel>>(:final message):
          fail('Expected Success but got Failure: $message');
      }

      verify(() => mockHotelService.searchHotels(request)).called(1);
    });

    test('searchHotels handles date range correctly', () async {
      // Test with different check-in and check-out dates
      final request = HotelSearchRequest(
        city: 'London',
        checkInDate: DateTime(2026, 9, 1),
        checkOutDate: DateTime(2026, 9, 8),
        guests: 2,
        rooms: 1,
      );

      final mockHotels = [
        _hotel(
          id: 'h1',
          name: 'Week Stay Hotel',
          city: 'London',
          rating: 4.6,
          price: 120.00,
          totalPrice: 840.00,
          beds: 2,
          nights: 7,
        ),
      ];

      when(
        () => mockHotelService.searchHotels(request),
      ).thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success>());
      switch (result) {
        case Success<List<Hotel>>(:final data):
          expect(data[0].nights, 7);
        case Failure<List<Hotel>>(:final message):
          fail('Expected Success but got Failure: $message');
      }

      verify(() => mockHotelService.searchHotels(request)).called(1);
    });
  });
}
