import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/trips/domain/entities/trip.dart' as domain;
import '../../features/trips/presentation/providers/trip_provider.dart';
import '../../features/trips/presentation/screens/create_trip_page.dart';
import '../../features/trips/presentation/screens/edit_trip_page.dart';
import '../../features/trips/presentation/screens/trip_activities_page.dart';
import '../../features/trips/presentation/screens/trip_documents_page.dart';
import '../../features/trips/presentation/screens/trip_dashboard_page.dart';
import '../../features/trips/presentation/screens/trip_list_page.dart';
import '../../features/trips/presentation/screens/trip_notes_page.dart';
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
      builder: (context, state) => const CreateTripPage(),
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
        if (extra is domain.Trip) {
          return TripDashboardPage(trip: extra);
        }

        return _TripDashboardResolverPage(tripId: tripId);
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
        if (extra is domain.Trip) {
          return EditTripPage(trip: extra);
        }

        return _TripEditResolverPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripNotes.routeName,
      path: AppRoute.tripNotes.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Trip notes route requires a trip id path parameter.',
          );
        }

        return TripNotesPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripDocuments.routeName,
      path: AppRoute.tripDocuments.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Trip documents route requires a trip id path parameter.',
          );
        }

        return TripDocumentsPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripActivities.routeName,
      path: AppRoute.tripActivities.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message:
                'Trip activities route requires a trip id path parameter.',
          );
        }

        return TripActivitiesPage(tripId: tripId);
      },
    ),
  ];
}

class _TripDashboardResolverPage extends ConsumerWidget {
  const _TripDashboardResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<domain.Trip?>(
      future: repository.get(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: Center(
              child: Text('Failed to load trip: ${snapshot.error}'),
            ),
          );
        }

        final trip = snapshot.data;
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: const Center(
              child: Text('Trip not found.'),
            ),
          );
        }

        return TripDashboardPage(trip: trip);
      },
    );
  }
}

class _TripEditResolverPage extends ConsumerWidget {
  const _TripEditResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<domain.Trip?>(
      future: repository.get(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Trip')),
            body: Center(
              child: Text('Failed to load trip: ${snapshot.error}'),
            ),
          );
        }

        final trip = snapshot.data;
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Trip')),
            body: const Center(
              child: Text('Trip not found.'),
            ),
          );
        }

        return EditTripPage(trip: trip);
      },
    );
  }
}
