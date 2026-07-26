import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/flight_provider.dart';
import '../models/flight.dart';
import '../widgets/flight_card.dart';

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
        const SnackBar(content: Text('Please fill in From, To and Departure Date.')),
      );
      return;
    }
    if (origin.length != 3 || destination.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid 3-letter IATA codes, e.g. LHR and CDG.')),
      );
      return;
    }

    // Save search to Firestore
    _saveRecentSearch();

    final request = FlightSearchRequest(
      from: origin,
      to: destination,
      departureDate: date,
      returnDate: _returnDateController.text.isEmpty ? null : _returnDateController.text,
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

  Future<void> _selectDate(TextEditingController controller, {DateTime? firstDate}) async {
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
      'returnDate': _returnDateController.text.isNotEmpty ? _returnDateController.text : null,
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
      appBar: AppBar(title: const Text('Search Flights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Search Form ──────────────────────────────
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'From (IATA Code)',
                        hintText: 'e.g., LHR',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_takeoff),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _toController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'To (IATA Code)',
                        hintText: 'e.g., CDG',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_land),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Departure Date',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () => _selectDate(_dateController),
                        ),
                      ),
                      onTap: () => _selectDate(_dateController),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _returnDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Return Date (Optional)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.event_repeat),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_returnDateController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _returnDateController.clear()),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () => _selectDate(
                                _returnDateController,
                                firstDate: DateTime.now().add(const Duration(days: 1)),
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _cabinClass,
                      decoration: const InputDecoration(
                        labelText: 'Cabin Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.airline_seat_recline_extra),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'economy', child: Text('Economy')),
                        DropdownMenuItem(value: 'premium_economy', child: Text('Premium Economy')),
                        DropdownMenuItem(value: 'business', child: Text('Business')),
                        DropdownMenuItem(value: 'first', child: Text('First Class')),
                      ],
                      onChanged: (v) => setState(() => _cabinClass = v ?? 'economy'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Passengers:'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _passengers > 1 ? () => setState(() => _passengers--) : null,
                        ),
                        Text('$_passengers', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _passengers++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _triggerSearch,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.search),
                        label: Text(isLoading ? _searchStatus : 'Search Flights'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Results area ────────────────────────────
            if (flightsAsync == null)
              // No search yet
              const SizedBox.shrink()
            else
              flightsAsync.when(
                loading: () => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _searchStatus,
                        style: TextStyle(fontSize: 15, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                    ...List.generate(3, (_) => const _SkeletonFlightCard()),
                  ],
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text('$e', style: const TextStyle(color: Colors.red))),
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
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.flight_takeoff, size: 72, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No flights found', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing your travel dates\nor choose another airport.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),

                      // Sort chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('💷 Cheapest'),
                              selected: _sortType == _SortType.cheapest,
                              onSelected: (_) => setState(() => _sortType = _SortType.cheapest),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('⚡ Fastest'),
                              selected: _sortType == _SortType.fastest,
                              onSelected: (_) => setState(() => _sortType = _SortType.fastest),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('🛫 Direct only'),
                              selected: _sortType == _SortType.direct,
                              onSelected: (_) => setState(() => _sortType = _SortType.direct),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Flight list with pull-to-refresh
                      RefreshIndicator(
                        onRefresh: () async => _triggerSearch(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: visible.length,
                          itemBuilder: (context, index) => FlightCard(flight: visible[index]),
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
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
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
