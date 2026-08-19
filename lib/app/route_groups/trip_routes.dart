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
import '../../features/ai_planner/presentation/screens/ai_trip_planner_page.dart';
import '../../features/live_trip/presentation/screens/live_trip_page.dart';
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
            message: 'Trip activities route requires a trip id path parameter.',
          );
        }

        return TripActivitiesPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripAiPlanner.routeName,
      path: AppRoute.tripAiPlanner.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Trip AI planner route requires a trip id path parameter.',
          );
        }

        final extra = state.extra;
        if (extra is domain.Trip) {
          return AiTripPlannerPage(trip: extra);
        }

        return _TripAiPlannerResolverPage(tripId: tripId);
      },
    ),
    GoRoute(
      name: AppRoute.tripLive.routeName,
      path: AppRoute.tripLive.path,
      builder: (context, state) {
        final tripId = state.pathParameters['id'];
        if (tripId == null || tripId.isEmpty) {
          return const RouteErrorPage(
            message: 'Live trip route requires a trip id path parameter.',
          );
        }

        final extra = state.extra;
        if (extra is domain.Trip) {
          return LiveTripPage(trip: extra);
        }

        return _LiveTripResolverPage(tripId: tripId);
      },
    ),
  ];
}

class _TripDashboardResolverPage extends ConsumerWidget {
  const _TripDashboardResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(selectedTripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Trip Dashboard')),
        body: Center(
          child: Text('Failed to load trip: $error'),
        ),
      ),
      data: (trip) {
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
    final tripAsync = ref.watch(selectedTripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Trip')),
        body: Center(
          child: Text('Failed to load trip: $error'),
        ),
      ),
      data: (trip) {
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

class _TripAiPlannerResolverPage extends ConsumerWidget {
  const _TripAiPlannerResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(selectedTripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('AI Travel Planner')),
        body: Center(
          child: Text('Failed to load trip: $error'),
        ),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('AI Travel Planner')),
            body: const Center(
              child: Text('Trip not found.'),
            ),
          );
        }

        return AiTripPlannerPage(trip: trip);
      },
    );
  }
}

class _LiveTripResolverPage extends ConsumerWidget {
  const _LiveTripResolverPage({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(selectedTripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Live Trip')),
        body: Center(
          child: Text('Failed to load live trip: $error'),
        ),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Live Trip')),
            body: const Center(
              child: Text('Trip not found.'),
            ),
          );
        }

        return LiveTripPage(trip: trip);
      },
    );
  }
}
