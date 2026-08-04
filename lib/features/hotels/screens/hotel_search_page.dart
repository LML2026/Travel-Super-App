import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../models/hotel_search_request.dart';
import '../providers/hotel_provider.dart';
import '../widgets/hotel_card.dart';

class HotelSearchPage extends ConsumerStatefulWidget {
  const HotelSearchPage({super.key});

  @override
  ConsumerState<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends ConsumerState<HotelSearchPage> {
  final _cityController = TextEditingController();
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  int _guests = 1;
  int _rooms = 1;

  HotelSearchRequest? _currentSearch;

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination.')),
      );
      return;
    }

    if (_checkOutDate.isBefore(_checkInDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out must be after check-in.')),
      );
      return;
    }

    final request = HotelSearchRequest(
      city: _cityController.text.trim(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      guests: _guests,
      rooms: _rooms,
    );

    setState(() {
      _currentSearch = request;
    });

    ref.invalidate(hotelSearchProvider(request));
  }

  Future<void> _selectCheckInDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _checkInDate = selectedDate;
        if (_checkOutDate.isBefore(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _checkOutDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushSavedHotels();
            },
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Saved Hotels',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              elevation: 1,
              child: Column(
                children: [
                  AppInputField(
                    controller: _cityController,
                    label: 'Destination',
                    hint: 'e.g. Paris, London, Tokyo',
                    prefixIcon: Icons.location_city,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Check-in',
                          value: _checkInDate,
                          onTap: _selectCheckInDate,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _DateField(
                          label: 'Check-out',
                          value: _checkOutDate,
                          onTap: _selectCheckOutDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _Counter(
                          label: 'Guests',
                          value: _guests,
                          onDecrement: _guests > 1
                              ? () => setState(() => _guests--)
                              : null,
                          onIncrement: () => setState(() => _guests++),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _Counter(
                          label: 'Rooms',
                          value: _rooms,
                          onDecrement: _rooms > 1
                              ? () => setState(() => _rooms--)
                              : null,
                          onIncrement: () => setState(() => _rooms++),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    onPressed: _triggerSearch,
                    icon: Icons.search,
                    label: 'Search Hotels',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_currentSearch != null) _HotelResults(request: _currentSearch!),
          ],
        ),
      ),
    );
  }
}

class _HotelResults extends ConsumerWidget {
  const _HotelResults({required this.request});

  final HotelSearchRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(hotelSearchProvider(request));

    return hotelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Search failed',
        message: 'We could not load hotels right now. Please try again.',
        iconColor: Colors.red,
        action: AppPrimaryButton(
          onPressed: () => ref.invalidate(hotelSearchProvider(request)),
          icon: Icons.refresh,
          label: 'Try Again',
          expand: false,
        ),
      ),
      data: (hotels) {
        if (hotels.isNotEmpty) {
          Future.microtask(() {
            try {
              ref.read(saveRecentHotelSearchProvider(request));
            } catch (_) {
              // Do not block search results if recent-search persistence fails.
            }
          });
        }

        if (hotels.isEmpty) {
          return const AppEmptyState(
            icon: Icons.hotel,
            title: 'No hotels found',
            message: 'Try another destination\nor different dates.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${hotels.length} hotels found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hotels.length,
              itemBuilder: (context, index) => HotelCard(hotel: hotels[index]),
            ),
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.calendar_month),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label: ${value.day}/${value.month}/${value.year}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
