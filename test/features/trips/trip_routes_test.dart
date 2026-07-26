import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/app/route_groups/trip_routes.dart';

void main() {
  test('trip routes expose expected names and paths', () {
    final routes = buildTripRoutes().whereType<GoRoute>().toList();

    expect(routes.map((route) => route.path), containsAll(<String>[
      AppRoute.trips.path,
      AppRoute.tripCreate.path,
      AppRoute.tripDetails.path,
      AppRoute.tripEdit.path,
    ]));

    expect(routes.map((route) => route.name), containsAll(<String?>[
      AppRoute.trips.routeName,
      AppRoute.tripCreate.routeName,
      AppRoute.tripDetails.routeName,
      AppRoute.tripEdit.routeName,
    ]));
  });
}
