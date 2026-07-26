import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/models/hotel_search_request.dart';
import 'package:travel_super_app/features/hotels/repositories/hotel_repository.dart';
import 'package:travel_super_app/features/hotels/services/hotel_service.dart';
import 'package:travel_super_app/core/utils/result.dart';

class MockHotelService extends Mock implements HotelService {}

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
        Hotel(
          id: 'h1',
          name: 'Luxury Hotel',
          city: 'Paris',
          rating: 4.8,
          price: 145.00,
          currency: 'GBP',
          address: 'Paris, France',
          amenities: const ['Free Wi-Fi', 'Breakfast Included'],
          totalPrice: 435.00,
          beds: 2,
          image: '🏨',
          nights: 3,
        ),
        Hotel(
          id: 'h2',
          name: 'Budget Hotel',
          city: 'Paris',
          rating: 4.0,
          price: 85.00,
          currency: 'GBP',
          address: 'Paris, France',
          amenities: const ['Free Wi-Fi'],
          totalPrice: 255.00,
          beds: 1,
          image: '🏨',
          nights: 3,
        ),
      ];

      when(() => mockHotelService.searchHotels(request))
          .thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success<List<Hotel>>>());

      final success = result as Success<List<Hotel>>;
      expect(success.data, mockHotels);
      expect(success.data.length, 2);
      expect(success.data[0].name, 'Luxury Hotel');
      expect(success.data[1].name, 'Budget Hotel');

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

      when(() => mockHotelService.searchHotels(request))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Failure<List<Hotel>>>());

      final failure = result as Failure<List<Hotel>>;
      expect(failure.message, contains('Network error'));

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

      when(() => mockHotelService.searchHotels(request))
          .thenAnswer((_) async => []);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success<List<Hotel>>>());

      final success = result as Success<List<Hotel>>;
      expect(success.data, isEmpty);
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
        Hotel(
          id: 'h1',
          name: 'Large Group Hotel',
          city: 'Paris',
          rating: 4.5,
          price: 300.00,
          currency: 'GBP',
          address: 'Paris, France',
          amenities: const ['Free Wi-Fi'],
          totalPrice: 900.00,
          beds: 2,
          image: '🏨',
          nights: 3,
        ),
      ];

      when(() => mockHotelService.searchHotels(request))
          .thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success<List<Hotel>>>());

      final success = result as Success<List<Hotel>>;
      expect(success.data, mockHotels);

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
        Hotel(
          id: 'h1',
          name: 'Week Stay Hotel',
          city: 'London',
          rating: 4.6,
          price: 120.00,
          currency: 'GBP',
          address: 'London, United Kingdom',
          amenities: const ['Free Wi-Fi', 'Late Check-in'],
          totalPrice: 840.00,
          beds: 2,
          image: '🏨',
          nights: 7,
        ),
      ];

      when(() => mockHotelService.searchHotels(request))
          .thenAnswer((_) async => mockHotels);

      // Act
      final result = await hotelRepository.searchHotels(request);

      // Assert
      expect(result, isA<Success<List<Hotel>>>());

      final success = result as Success<List<Hotel>>;
      expect(success.data[0].nights, 7);

      verify(() => mockHotelService.searchHotels(request)).called(1);
    });
  });
}
