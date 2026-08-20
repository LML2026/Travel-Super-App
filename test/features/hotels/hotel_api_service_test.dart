import 'package:flutter_test/flutter_test.dart';

import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/models/hotel_search_request.dart';
import 'package:travel_super_app/features/hotels/services/amadeus_hotel_service.dart';
import 'package:travel_super_app/features/hotels/services/hotel_api_service.dart';

HotelSearchRequest _request() => HotelSearchRequest(
      city: 'Lisbon',
      checkInDate: DateTime(2026, 10, 1),
      checkOutDate: DateTime(2026, 10, 4),
      guests: 2,
      rooms: 1,
    );

void main() {
  test('maps successful backend results with backend source', () async {
    final service = HotelApiService(
      amadeusService: AmadeusHotelService(credentialReader: (_) => null),
      backendSearch: (_) async => [
        Hotel.fromJson(<String, dynamic>{
          'id': 'backend-1',
          'name': 'Backend Lisbon Hotel',
          'city': 'Lisbon',
          'price': 140,
          'totalPrice': 420,
          'currency': 'GBP',
          'rating': 4.4,
          'amenities': <String>['Free Wi-Fi'],
        }, dataSource: HotelDataSource.backend),
      ],
    );

    final hotels = await service.searchHotels(_request());

    expect(hotels, hasLength(1));
    expect(hotels.single.id, 'backend-1');
    expect(hotels.single.dataSource, HotelDataSource.backend);
  });

  test('returns stable realistic demo results when providers are unavailable',
      () async {
    final service = HotelApiService(
      amadeusService: AmadeusHotelService(credentialReader: (_) => null),
      backendSearch: (_) async => throw const HotelSearchException(),
    );

    final first = await service.searchHotels(_request());
    final second = await service.searchHotels(_request());

    expect(first.map((hotel) => hotel.id).toList(),
        second.map((hotel) => hotel.id).toList());
    expect(first, hasLength(3));
    expect(first.every((hotel) => hotel.dataSource == HotelDataSource.demo),
        isTrue);
    expect(first.map((hotel) => hotel.name), contains('Demo Central Hotel'));
    expect(first.map((hotel) => hotel.totalPrice), contains(354));
  });
}
