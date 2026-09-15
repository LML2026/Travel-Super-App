import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/flight_provider.dart';
import '../models/flight.dart';
import '../widgets/flight_card.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

enum _SortType { cheapest, fastest, direct }

class FlightSearchPage extends ConsumerStatefulWidget {
  const FlightSearchPage({super.key});

  @override
  ConsumerState<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends ConsumerState<FlightSearchPage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _returnDateController = TextEditingController();
  int _passengers = 1;
  String _cabinClass = 'economy';
  _SortType _sortType = _SortType.cheapest;

  // The active search request — null until first search
  FlightSearchRequest? _activeRequest;

  // Status message cycles while loading
  String _searchStatus = 'Searching airlines...';
  static const _statusMessages = [
    'Searching airlines...',
    'Checking availability...',
    'Comparing prices...',
    'Preparing your results...',
  ];

  void _triggerSearch() {
    final origin = _fromController.text.trim().toUpperCase();
    final destination = _toController.text.trim().toUpperCase();
    final date = _dateController.text;

    if (origin.isEmpty || destination.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.ui('fillFlightSearchFields'))),
      );
      return;
    }
    if (origin.length != 3 || destination.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(context.ui('enterValidIataCodes'))),
      );
      return;
    }

    // Save search to Firestore
    _saveRecentSearch();

    final request = FlightSearchRequest(
      from: origin,
      to: destination,
      departureDate: date,
      returnDate: _returnDateController.text.isEmpty
          ? null
          : _returnDateController.text,
      passengers: _passengers,
      cabinClass: _cabinClass,
    );

    // Invalidate any cached result for this request so it re-fetches
    ref.invalidate(flightSearchProvider(request));

    setState(() {
      _activeRequest = request;
      _sortType = _SortType.cheapest;
      _searchStatus = _statusMessages[0];
    });

    // Cycle status messages
    for (int i = 1; i < _statusMessages.length; i++) {
      final msg = _statusMessages[i];
      Future.delayed(Duration(seconds: i * 2), () {
        if (mounted) setState(() => _searchStatus = msg);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller,
      {DateTime? firstDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      setState(() => controller.text = date.toString().split(' ')[0]);
    }
  }

  Future<void> _saveRecentSearch() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recent_flight_searches')
        .add({
      'from': _fromController.text.trim().toUpperCase(),
      'to': _toController.text.trim().toUpperCase(),
      'departureDate': _dateController.text,
      'returnDate': _returnDateController.text.isNotEmpty
          ? _returnDateController.text
          : null,
      'passengers': _passengers,
      'cabinClass': _cabinClass,
      'searchedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider only when a search has been triggered
    final flightsAsync = _activeRequest != null
        ? ref.watch(flightSearchProvider(_activeRequest!))
        : null;

    final isLoading = flightsAsync?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('searchFlights'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ── Search Form ──────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: context.ui('fromIataCode'),
                        hintText: context.ui('exampleLhr'),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_takeoff),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _toController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: context.ui('toIataCode'),
                        hintText: context.ui('exampleCdg'),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_land),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: context.ui('departureDate'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () => _selectDate(_dateController),
                        ),
                      ),
                      onTap: () => _selectDate(_dateController),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _returnDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: context.ui('returnDateOptional'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.event_repeat),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_returnDateController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(
                                    () => _returnDateController.clear()),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () => _selectDate(
                                _returnDateController,
                                firstDate:
                                    DateTime.now().add(const Duration(days: 1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => _selectDate(
                        _returnDateController,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _cabinClass,
                      decoration: InputDecoration(
                        labelText: context.ui('cabinClass'),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.airline_seat_recline_extra),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 'economy', child: Text(context.ui('economy'))),
                        DropdownMenuItem(
                            value: 'premium_economy',
                            child: Text(context.ui('premiumEconomy'))),
                        DropdownMenuItem(
                            value: 'business', child: Text(context.ui('business'))),
                        DropdownMenuItem(
                            value: 'first', child: Text(context.ui('firstClass'))),
                      ],
                      onChanged: (v) =>
                          setState(() => _cabinClass = v ?? 'economy'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.sm),
                        Text(context.ui('passengers')),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _passengers > 1
                              ? () => setState(() => _passengers--)
                              : null,
                        ),
                        Text(
                          '$_passengers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _passengers++),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _triggerSearch,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.warmWhite,
                                ),
                              )
                            : const Icon(Icons.search),
                        label:
                            Text(isLoading ? _searchStatus : 'Search Flights'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Results area ────────────────────────────
            if (flightsAsync == null)
              // No search yet
              const SizedBox.shrink()
            else
              flightsAsync.when(
                loading: () => Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        _searchStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                    ...List.generate(3, (_) => const _SkeletonFlightCard()),
                  ],
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.28),
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '$e',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (flights) {
                  // Save the search to Firestore (fire and forget after successful results)
                  if (_activeRequest != null && flights.isNotEmpty) {
                    Future.microtask(() {
                      try {
                        ref.read(saveRecentSearchProvider(_activeRequest!));
                      } catch (e) {
                        // Silently fail - don't interrupt user experience
                      }
                    });
                  }

                  if (flights.isEmpty) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.flight_takeoff,
                            size: 72,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(context.ui('noFlightsFound'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Try changing your travel dates\nor choose another airport.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }

                  List<Flight> sorted = List.from(flights);
                  if (_sortType == _SortType.cheapest) {
                    sorted.sort((a, b) => a.amount.compareTo(b.amount));
                  } else if (_sortType == _SortType.fastest) {
                    sorted.sort((a, b) => a.duration.compareTo(b.duration));
                  } else if (_sortType == _SortType.direct) {
                    sorted = sorted.where((f) => f.stops == 0).toList()
                      ..sort((a, b) => a.amount.compareTo(b.amount));
                  }
                  final visible = sorted.take(30).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Results count
                      Text(
                        '${visible.length} flights found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Sort chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(context.ui('cheapest')),
                              selected: _sortType == _SortType.cheapest,
                              onSelected: (_) => setState(
                                  () => _sortType = _SortType.cheapest),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ChoiceChip(
                              label: Text(context.ui('fastest')),
                              selected: _sortType == _SortType.fastest,
                              onSelected: (_) =>
                                  setState(() => _sortType = _SortType.fastest),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ChoiceChip(
                              label: Text(context.ui('directOnly')),
                              selected: _sortType == _SortType.direct,
                              onSelected: (_) =>
                                  setState(() => _sortType = _SortType.direct),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Flight list with pull-to-refresh
                      RefreshIndicator(
                        onRefresh: () async => _triggerSearch(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: visible.length,
                          itemBuilder: (context, index) =>
                              FlightCard(flight: visible[index]),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton card shown while flights load
class _SkeletonFlightCard extends StatefulWidget {
  const _SkeletonFlightCard();

  @override
  State<_SkeletonFlightCard> createState() => _SkeletonFlightCardState();
}

class _SkeletonFlightCardState extends State<_SkeletonFlightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(double width, double height) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.navy100.withValues(alpha: _anim.value),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _box(40, 40),
              const SizedBox(width: 12),
              Expanded(child: _box(double.infinity, 18)),
              const SizedBox(width: 12),
              _box(80, 22),
            ]),
            const SizedBox(height: 16),
            _box(double.infinity, 14),
            _box(200, 14),
            const SizedBox(height: 8),
            _box(double.infinity, 42),
          ],
        ),
      ),
    );
  }
}
