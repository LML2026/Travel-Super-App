import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/providers/travel_provider_contracts.dart';
import 'package:travel_super_app/features/maps/services/google_maps_platform_service.dart';
import 'package:travel_super_app/features/maps/services/map_route_service.dart';
import 'package:travel_super_app/features/providers/provider_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('demo places are clearly marked when live iOS configuration is absent',
      () async {
    final results = await const DemoProviderGateway().searchPlaces(
      query: 'pharmacy near me',
      categories: <PlaceCategory>{PlaceCategory.pharmacy},
    );

    expect(results, hasLength(1));
    expect(results.single.dataSource, TravelDataSource.mock);
    expect(results.single.description, contains('Not live Google Places'));
  });

  test('native configuration is unavailable without an iOS bridge', () async {
    expect(await const GoogleMapsPlatformService().isConfigured(), isFalse);
    expect(
      await const MapRouteService().computeRoute(
        origin: '51.5,-0.12',
        destination: 'London',
        travelMode: 'WALK',
      ),
      isNull,
    );
  });
}
