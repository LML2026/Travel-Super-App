import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../models/trip.dart';
import '../providers/trip_provider.dart';
import 'trip_details_page.dart';
import '../widgets/trip_card.dart';

class TripListPage extends ConsumerStatefulWidget {
  const TripListPage({super.key});

  @override
  ConsumerState<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends ConsumerState<TripListPage> {
  final Set<String> _deletingTripIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: tripsAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading trips...'),
        error: (error, _) => ErrorView(
          title: 'Trips unavailable',
          message: error.toString(),
          onRetry: () => ref.invalidate(tripsProvider),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshTrips,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppEmptyState(
                          icon: Icons.luggage_outlined,
                          title: 'No trips yet',
                          message: 'Create your first trip.',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          text: 'Create Trip',
                          icon: Icons.add,
                          onPressed: _openCreateTrip,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTrips,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];

                return TripCard(
                  trip: trip,
                  onTap: () => _openTripDetails(trip),
                  onEdit: () => _openEditTrip(trip),
                  onDuplicate: () => _openCreateTrip(
                    initialTrip: trip,
                    forceCreateMode: true,
                  ),
                  onDelete: () => _confirmDelete(trip),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTrip,
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
    );
  }

  Future<void> _refreshTrips() async {
    ref.invalidate(tripsProvider);
    await ref.read(tripsProvider.future);
  }

  Future<void> _openCreateTrip({
    Trip? initialTrip,
    bool forceCreateMode = false,
  }) async {
    final created = await context.pushCreateTrip<bool>(
      initialTrip: initialTrip,
      forceCreateMode: forceCreateMode,
    );

    if (created == true && mounted) {
      ref.invalidate(tripsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(forceCreateMode
              ? 'Trip duplicated successfully.'
              : 'Trip saved successfully.'),
        ),
      );
    }
  }

  Future<void> _openEditTrip(Trip trip) async {
    final updated = await context.pushEditTrip<bool>(trip.id, initialTrip: trip);

    if (updated == true && mounted) {
      ref.invalidate(tripsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip to ${trip.destination} updated.')),
      );
    }
  }

  Future<void> _openTripDetails(Trip trip) async {
    final action = await context.pushTripDetails<TripDetailsAction>(trip);
    if (!mounted || action == null) {
      return;
    }

    if (action == TripDetailsAction.edit) {
      await _openEditTrip(trip);
      return;
    }

    if (action == TripDetailsAction.duplicate) {
      await _openCreateTrip(initialTrip: trip, forceCreateMode: true);
    }
  }

  Future<void> _confirmDelete(Trip trip) async {
    if (_deletingTripIds.contains(trip.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete already in progress...')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete trip?'),
          content: Text(
            'Remove your trip to ${trip.destination}? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        _deletingTripIds.add(trip.id);
      });
      await deleteTrip(ref, trip.id);
      ref.invalidate(tripsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted trip to ${trip.destination}.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete trip: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingTripIds.remove(trip.id);
        });
      } else {
        _deletingTripIds.remove(trip.id);
      }
    }
  }
}
