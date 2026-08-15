import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_trip_card.dart';
import '../../../core/storage/trip_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/trip.dart';
import 'create_trip_screen.dart';
import 'trip_details_screen.dart';

class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  final List<Trip> _trips = [];
  final TripStorageService _storage = TripStorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await _storage.loadTrips();

    if (!mounted) return;

    setState(() {
      _trips
        ..clear()
        ..addAll(trips);
      _isLoading = false;
    });
  }

  Future<void> _persistTrips() async {
    await _storage.saveTrips(_trips);
  }

  Future<void> _createTrip() async {
    final trip = await Navigator.of(
      context,
    ).push<Trip>(MaterialPageRoute(builder: (_) => const CreateTripScreen()));

    if (trip != null) {
      setState(() {
        _trips.add(trip);
      });
      await _persistTrips();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trips)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTrip,
        icon: const Icon(Icons.add),
        label: Text(l10n.newTrip),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
          ? AppEmptyState(
              icon: Icons.luggage_outlined,
              title: l10n.noTripsYet,
              message: l10n.createFirstTrip,
              actionLabel: l10n.createTrip,
              onAction: _createTrip,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth >= 900
                    ? 760.0
                    : constraints.maxWidth;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _trips.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final trip = _trips[index];

                        return AppTripCard(
                          destination: trip.destination,
                          dates:
                              '${_formatDate(trip.departureDate)} - ${_formatDate(trip.returnDate)}',
                          details:
                              '${trip.travellers} traveller(s) • ${trip.currency} ${trip.budget.toStringAsFixed(2)}',
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .push<Object?>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TripDetailsScreen(trip: trip),
                                  ),
                                );

                            if (!mounted) return;

                            if (result == 'delete') {
                              setState(() {
                                _trips.removeAt(index);
                              });
                              await _persistTrips();
                            } else if (result is Trip) {
                              setState(() {
                                _trips[index] = result;
                              });
                              await _persistTrips();
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
