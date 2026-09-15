import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/taxi_ride_request.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TaxiSearchPage extends StatefulWidget {
  const TaxiSearchPage({super.key});

  @override
  State<TaxiSearchPage> createState() => _TaxiSearchPageState();
}

class _TaxiSearchPageState extends State<TaxiSearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTime? _pickupTime;
  int _passengers = 1;
  int _luggage = 0;

  double _pickupLatitude = 51.5074;
  double _pickupLongitude = -0.1278;
  double _destinationLatitude = 51.4700;
  double _destinationLongitude = -0.4543;

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'Current location';
    _destinationController.text = 'Airport';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _pickupTime ?? now,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupTime ?? now),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _pickupTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _useCurrentLocation() {
    setState(() {
      _pickupController.text = 'Sample pickup - central London';
      _pickupLatitude = 51.5074;
      _pickupLongitude = -0.1278;
    });
  }

  void _searchRides() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = TaxiRideRequest(
      pickupLatitude: _pickupLatitude,
      pickupLongitude: _pickupLongitude,
      pickupAddress: _pickupController.text.trim(),
      destinationLatitude: _destinationLatitude,
      destinationLongitude: _destinationLongitude,
      destinationAddress: _destinationController.text.trim(),
      pickupTime: _pickupTime,
      passengers: _passengers,
      luggage: _luggage,
    );

    context.pushTaxiResults(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('taxiHub')),
        actions: [
          TextButton(
            onPressed: () => context.pushSavedRides(),
            child: Text(context.ui('savedRides')),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextFormField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: context.ui('pickup'),
                  prefixIcon: Icon(Icons.my_location),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a pickup address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: Text(context.ui('useSamplePickup')),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: context.ui('destination'),
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.ui('pickupDateTime')),
                subtitle: Text(
                  _pickupTime == null ? 'ASAP' : _pickupTime.toString(),
                ),
                trailing: IconButton(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.event),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _StepperField(
                      label: 'Passengers',
                      value: _passengers,
                      onChanged: (next) {
                        setState(() {
                          _passengers = next.clamp(1, 8);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StepperField(
                      label: 'Luggage',
                      value: _luggage,
                      onChanged: (next) {
                        setState(() {
                          _luggage = next.clamp(0, 10);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _searchRides,
                icon: const Icon(Icons.local_taxi),
                label: Text(context.ui('compareRideOptions')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onChanged(value - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  onPressed: () => onChanged(value + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
