import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_metric_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/trip_overview_service.dart';
import '../../../core/storage/itinerary_storage_service.dart';
import '../../nearby/nearby_essentials_screen.dart';
import '../models/itinerary/itinerary_item.dart';
import '../models/trip.dart';
import 'edit_trip_screen.dart';
import 'itinerary/itinerary_screen.dart';
import 'map/trip_map_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final ItineraryStorageService _itineraryStorage = ItineraryStorageService();
  List<ItineraryItem> _items = [];
  bool _isLoading = true;

  Trip get _trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    final items = await _itineraryStorage.loadItems(_trip.id);
    if (!mounted) return;

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _openItinerary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ItineraryScreen(trip: _trip)),
    );
    if (mounted) await _loadItinerary();
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripMapScreen(trip: _trip, items: _items),
      ),
    );
  }

  void _openNearby(ItineraryItem fallback) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NearbyEssentialsScreen(
          latitude: fallback.latitude!,
          longitude: fallback.longitude!,
        ),
      ),
    );
  }

  Future<void> _editTrip() async {
    final updatedTrip = await Navigator.of(context).push<Trip>(
      MaterialPageRoute(builder: (_) => EditTripScreen(trip: _trip)),
    );

    if (updatedTrip != null && mounted) {
      Navigator.of(context).pop(updatedTrip);
    }
  }

  Future<void> _deleteTrip() async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTripQuestion),
        content: Text(
          'Are you sure you want to delete the trip to ${_trip.destination}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      Navigator.of(context).pop('delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = TripOverviewService.build(
      trip: _trip,
      items: _items,
      now: DateTime.now(),
    );
    final mappedItems = summary.orderedItems
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripOverview),
        actions: [
          IconButton(
            tooltip: l10n.editTrip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editTrip,
          ),
          IconButton(
            tooltip: l10n.deleteTrip,
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTrip,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  children: [
                    _TripHero(summary: summary),
                    const SizedBox(height: 20),
                    _SummaryMetrics(summary: summary),
                    if (summary.budgetProgress != null) ...[
                      const SizedBox(height: 16),
                      _BudgetProgress(summary: summary),
                    ],
                    if (summary.nextPlan != null) ...[
                      const SizedBox(height: 24),
                      _NextPlanCard(item: summary.nextPlan!),
                    ],
                    const SizedBox(height: 24),
                    _QuickActions(
                      onItinerary: _openItinerary,
                      onMap: mappedItems.isEmpty ? null : _openMap,
                      onNearby: mappedItems.isEmpty
                          ? null
                          : () => _openNearby(mappedItems.first),
                      onEdit: _editTrip,
                    ),
                    if (summary.days.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _ItineraryPreview(
                        summary: summary,
                        onViewAll: _openItinerary,
                      ),
                    ],
                    if (mappedItems.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _MapEntry(
                        mappedCount: summary.mappedCount,
                        onMap: _openMap,
                        onNearby: () => _openNearby(mappedItems.first),
                      ),
                    ],
                    if (_trip.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionCard(
                        title: l10n.notes,
                        child: Text(_trip.notes.trim()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _TripHero extends StatelessWidget {
  final TripOverviewSummary summary;

  const _TripHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: AppRadii.largeBorder.borderRadius,
        border: Border.all(color: colorScheme.primary.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.trip.destination,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatLongDate(summary.trip.departureDate)} – '
            '${_formatLongDate(summary.trip.returnDate)}',
            style: TextStyle(color: colorScheme.onPrimary.withAlpha(220)),
          ),
          const SizedBox(height: 6),
          Text(
            '${summary.durationDays} '
            '${summary.durationDays == 1 ? 'day' : 'days'} · '
            '${summary.trip.travellers} '
            '${summary.trip.travellers == 1 ? 'traveller' : 'travellers'}',
            style: TextStyle(color: colorScheme.onPrimary.withAlpha(220)),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.saffron.withAlpha(230),
              borderRadius: AppRadii.smallBorder.borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                _statusText(summary),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(TripOverviewSummary summary) {
    switch (summary.status) {
      case TripOverviewStatus.upcoming:
        final days = summary.daysUntilStart!;
        return days == 1 ? 'Starts tomorrow' : 'Starts in $days days';
      case TripOverviewStatus.inProgress:
        return 'Trip in progress';
      case TripOverviewStatus.completed:
        return 'Trip completed';
    }
  }
}

class _SummaryMetrics extends StatelessWidget {
  final TripOverviewSummary summary;

  const _SummaryMetrics({required this.summary});

  @override
  Widget build(BuildContext context) {
    final values = <_MetricData>[
      _MetricData('Plans', summary.planCount.toString()),
      _MetricData('Booked', summary.bookedCount.toString()),
      if (summary.hasEstimatedCost)
        _MetricData(
          'Est. cost',
          _money(summary.trip.currency, summary.estimatedCost),
        ),
      if (summary.trip.budget > 0)
        _MetricData(
          'Budget',
          _money(summary.trip.currency, summary.trip.budget),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final value in values)
              SizedBox(
                width: width,
                child: AppMetricTile(label: value.label, value: value.value),
              ),
          ],
        );
      },
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final TripOverviewSummary summary;

  const _BudgetProgress({required this.summary});

  @override
  Widget build(BuildContext context) {
    final progress = summary.budgetProgress!;
    final percentage = (progress * 100).round();

    return _SectionCard(
      title: 'Trip budget',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_money(summary.trip.currency, summary.estimatedCost)} of '
            '${_money(summary.trip.currency, summary.trip.budget)} planned',
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 8),
          Text(
            summary.overBudget > 0
                ? '${_money(summary.trip.currency, summary.overBudget)} over '
                      'planned budget'
                : '$percentage% of budget planned',
            style: TextStyle(
              color: summary.overBudget > 0
                  ? Theme.of(context).colorScheme.error
                  : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPlanCard extends StatelessWidget {
  final ItineraryItem item;

  const _NextPlanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Next plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatShortDate(item.date)}'
            '${item.time == null ? '' : ' · ${item.time}'}',
          ),
          if (item.location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.location),
          ],
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onItinerary;
  final VoidCallback? onMap;
  final VoidCallback? onNearby;
  final VoidCallback onEdit;

  const _QuickActions({
    required this.onItinerary,
    required this.onMap,
    required this.onNearby,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.5 : 1.8,
              children: [
                _QuickAction(
                  icon: Icons.route_outlined,
                  label: 'Itinerary',
                  onTap: onItinerary,
                ),
                _QuickAction(
                  icon: Icons.map_outlined,
                  label: 'Trip Map',
                  onTap: onMap,
                ),
                _QuickAction(
                  icon: Icons.near_me_outlined,
                  label: 'Nearby',
                  onTap: onNearby,
                ),
                _QuickAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit trip',
                  onTap: onEdit,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.medium)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onTap == null ? Colors.black38 : null),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: onTap == null ? Colors.black38 : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItineraryPreview extends StatelessWidget {
  final TripOverviewSummary summary;
  final VoidCallback onViewAll;

  const _ItineraryPreview({required this.summary, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final visibleDays = summary.days.take(3).toList();

    return _SectionCard(
      title: 'Your itinerary',
      trailing: TextButton(
        onPressed: onViewAll,
        child: const Text('View full itinerary'),
      ),
      child: Column(
        children: [
          for (var index = 0; index < visibleDays.length; index++) ...[
            if (index > 0) const Divider(height: 24),
            _DayPreview(
              dayNumber:
                  visibleDays[index].date
                      .difference(
                        DateTime(
                          summary.trip.departureDate.year,
                          summary.trip.departureDate.month,
                          summary.trip.departureDate.day,
                        ),
                      )
                      .inDays +
                  1,
              day: visibleDays[index],
            ),
          ],
          if (summary.days.length > visibleDays.length) ...[
            const SizedBox(height: 12),
            Text('${summary.days.length - visibleDays.length} more days'),
          ],
        ],
      ),
    );
  }
}

class _DayPreview extends StatelessWidget {
  final int dayNumber;
  final TripOverviewDay day;

  const _DayPreview({required this.dayNumber, required this.day});

  @override
  Widget build(BuildContext context) {
    final visibleTitles = day.items
        .take(3)
        .map((item) => item.title)
        .join(' · ');
    final remaining = day.items.length - 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, child: Text('$dayNumber')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day $dayNumber · ${day.items.length} '
                '${day.items.length == 1 ? 'plan' : 'plans'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$visibleTitles${remaining > 0 ? ' · +$remaining more' : ''}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapEntry extends StatelessWidget {
  final int mappedCount;
  final VoidCallback onMap;
  final VoidCallback onNearby;

  const _MapEntry({
    required this.mappedCount,
    required this.onMap,
    required this.onNearby,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Explore nearby',
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$mappedCount mapped ${mappedCount == 1 ? 'place' : 'places'}'),
          OutlinedButton.icon(
            onPressed: onMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('View map'),
          ),
          OutlinedButton.icon(
            onPressed: onNearby,
            icon: const Icon(Icons.near_me_outlined),
            label: const Text('Nearby Essentials'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;

  const _MetricData(this.label, this.value);
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatLongDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

String _formatShortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1].substring(0, 3)}';

String _money(String currency, double value) {
  final decimals = value == value.roundToDouble() ? 0 : 2;
  return '$currency ${value.toStringAsFixed(decimals)}';
}
