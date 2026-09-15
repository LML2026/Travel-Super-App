import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/features/taxi/domain/entities/taxi_ride_option.dart';
import 'package:travel_super_app/features/taxi/domain/entities/taxi_ride_request.dart';
import 'package:travel_super_app/features/taxi/presentation/screens/taxi_booking_details_page.dart';
import 'package:travel_super_app/features/taxi/presentation/screens/taxi_results_page.dart';
import 'package:travel_super_app/features/taxi/presentation/screens/taxi_search_page.dart';

void main() {
  testWidgets('Taxi search uses truthful sample and estimate wording',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TaxiSearchPage()),
    );

    expect(find.text('Use sample pickup'), findsOneWidget);
    expect(find.text('Compare estimated ride options'), findsOneWidget);
    expect(find.text('Use current location'), findsNothing);

    await tester.tap(find.text('Use sample pickup'));
    await tester.pump();

    expect(find.text('Sample pickup - central London'), findsOneWidget);
    expect(find.text('Current location (detected)'), findsNothing);
  });

  testWidgets('Taxi results describe options as planning estimates',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: TaxiResultsPage(request: _request())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review planned ride'), findsWidgets);
    expect(
      find.textContaining('Planning estimate only'),
      findsWidgets,
    );
    expect(find.textContaining('provider order has been placed'), findsWidgets);
  });

  testWidgets('Taxi details exposes itinerary save but no mock booking CTA',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TaxiBookingDetailsPage(
            args: TaxiBookingRouteArgs(
              request: _request(),
              option: _option(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Save ride to itinerary'), findsOneWidget);
    expect(find.text('View route on map'), findsOneWidget);
    expect(find.text('Save planned transport'), findsNothing);
    expect(find.text('Booking Status'), findsNothing);
  });
}

TaxiRideRequest _request() {
  return const TaxiRideRequest(
    pickupLatitude: 51.5074,
    pickupLongitude: -0.1278,
    pickupAddress: 'Sample pickup - central London',
    destinationLatitude: 51.4700,
    destinationLongitude: -0.4543,
    destinationAddress: 'Airport',
    passengers: 2,
    luggage: 1,
  );
}

TaxiRideOption _option() {
  return const TaxiRideOption(
    providerName: 'Uber',
    estimatedFare: 21,
    currency: 'GBP',
    estimatedPickupMinutes: 4,
    description: 'Fast pickup planning estimate',
  );
}
