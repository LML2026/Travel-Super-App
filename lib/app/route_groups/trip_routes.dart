import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/trips/models/trip.dart';
import '../../features/trips/presentation/screens/create_trip_page.dart';
import '../../features/trips/presentation/screens/edit_trip_page.dart';
import '../../features/trips/presentation/screens/trip_details_page.dart';
import '../../features/trips/presentation/screens/trip_list_page.dart';
import '../../features/trips/presentation/providers/trip_provider.dart';
import '../app_routes.dart';
import '../route_error_page.dart';

List<RouteBase> buildTripRoutes() {
  return [
    GoRoute(
      name: AppRoute.trips.routeName,
      path: AppRoute.trips.path,
      builder: (context, state) => const TripListPage(),
    ),
    GoRoute(
      name: AppRoute.tripCreate.routeName,
      path: AppRoute.tripCreate.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! TripCreateRouteArgs) {
          return const RouteErrorPage(
            message: 'Create trip route received an invalid payload.',
          );
        }

        final args = extra is TripCreateRouteArgs
            ? extra
            : const TripCreateRouteArgs();

        return CreateTripPage(
          initialTrip: args.initialTrip,
          forceCreateMode: args.forceCreateMode,
        );
      },
    ),
    GoRoute(
      name: AppRoute.tripDetails.routeName,
      path: AppRoute.tripDetails.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Trip details route requires a trip id path parameter.',
          );
        }

        final extra = state.extra;
        if (extra is Trip) {
          return TripDetailsPage(trip: extra);
        }

        return _TripDetailsResolverPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripEdit.routeName,
      path: AppRoute.tripEdit.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Edit trip route requires a trip id path parameter.',
          );
        }

        final extra = state.extra;
        return EditTripPage(
          tripId: tripId,
          initialTrip: extra is Trip ? extra : null,
        );
      },
    ),
  ];
}

class _TripDetailsResolverPage extends StatelessWidget {
  const _TripDetailsResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tripAsync = ref.watch(selectedTripProvider(tripId));

        return tripAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(title: const Text('Trip Details')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load trip: $error', textAlign: TextAlign.center),
              ),
            ),
          ),
          data: (trip) {
            if (trip == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Trip Details')),
                body: const Center(child: Text('Trip not found.')),
              );
            }
            return TripDetailsPage(trip: trip);
          },
        );
      },
    );
  }
}
