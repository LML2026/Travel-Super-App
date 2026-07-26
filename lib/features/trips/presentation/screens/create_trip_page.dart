import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/validators/trip_input_validator.dart';
import '../../models/trip.dart';
import '../providers/trip_provider.dart';

class CreateTripPage extends ConsumerStatefulWidget {
  const CreateTripPage({
    super.key,
    this.initialTrip,
    this.forceCreateMode = false,
  });

  final Trip? initialTrip;
  final bool forceCreateMode;

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;
  String _currency = 'GBP';
  int _travellers = 1;
  bool _isSaving = false;

  bool get _isEditMode => widget.initialTrip != null && !widget.forceCreateMode;

  bool get _isDuplicateMode => widget.initialTrip != null && widget.forceCreateMode;

  @override
  void initState() {
    super.initState();

    final initialTrip = widget.initialTrip;
    if (initialTrip == null) {
      return;
    }

    _destinationController.text = widget.forceCreateMode
        ? '${initialTrip.destination} (Copy)'
        : initialTrip.destination;
    _budgetController.text = initialTrip.budget.toStringAsFixed(0);
    _notesController.text = initialTrip.notes;
    _departureDate = initialTrip.departureDate;
    _returnDate = initialTrip.returnDate;
    _currency = initialTrip.currency;
    _travellers = initialTrip.travellers;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (selected != null) {
      setState(() {
        _departureDate = selected;
        if (_returnDate != null && _returnDate!.isBefore(selected)) {
          _returnDate = selected.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? (_departureDate ?? DateTime.now()).add(const Duration(days: 2)),
      firstDate: _departureDate ?? DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (selected != null) {
      setState(() => _returnDate = selected);
    }
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    final destination = _destinationController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    final destinationError = TripInputValidator.validateDestination(destination);
    if (destinationError != null) {
      _showValidationError(destinationError);
      return;
    }

    final dateError = TripInputValidator.validateDates(_departureDate, _returnDate);
    if (dateError != null) {
      _showValidationError(dateError);
      return;
    }

    final budgetError = TripInputValidator.validateBudget(budget);
    if (budgetError != null) {
      _showValidationError(budgetError);
      return;
    }

    final travellersError = TripInputValidator.validateTravellers(_travellers);
    if (travellersError != null) {
      _showValidationError(travellersError);
      return;
    }

    try {
      setState(() => _isSaving = true);

      final trip = Trip(
        id: _isEditMode ? widget.initialTrip!.id : const Uuid().v4(),
        destination: destination,
        departureDate: _departureDate!,
        returnDate: _returnDate!,
        budget: budget,
        currency: _currency,
        travellers: _travellers,
        notes: notes,
        createdAt: widget.initialTrip?.createdAt ?? DateTime.now(),
        selectedFlightId: widget.initialTrip?.selectedFlightId,
        selectedHotelId: widget.initialTrip?.selectedHotelId,
        weatherSnapshot: widget.initialTrip?.weatherSnapshot,
        weatherSnapshotCapturedAt: widget.initialTrip?.weatherSnapshotCapturedAt,
        status: widget.initialTrip?.status ?? 'planned',
      );

      if (_isEditMode) {
        await updateTrip(ref, trip);
      } else {
        await createTrip(ref, trip);
      }
      ref.invalidate(tripsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Trip updated successfully.'
                : 'Trip created successfully.'),
          ),
        );
        context.pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save trip: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? 'Edit Trip'
              : (_isDuplicateMode ? 'Duplicate Trip' : 'Create Trip'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Destination', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _destinationController,
                label: 'Destination',
                hint: 'e.g. Paris',
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Departure Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _DateSelector(
                value: _departureDate,
                fallbackLabel: 'Select Date',
                onTap: _pickDepartureDate,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Return Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _DateSelector(
                value: _returnDate,
                fallbackLabel: 'Select Date',
                onTap: _pickReturnDate,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Budget', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _budgetController,
                label: 'Budget (£)',
                hint: '£________',
                prefixIcon: Icons.currency_pound,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Currency', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                items: const [
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                ],
                decoration: const InputDecoration(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Travellers', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  IconButton(
                    onPressed: _travellers > 1 ? () => setState(() => _travellers--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_travellers', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => setState(() => _travellers++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Notes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Add notes about this trip',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              if (_isSaving)
                const LoadingIndicator(message: 'Saving trip...')
              else
                PrimaryButton(
                  text: _isEditMode ? 'Update Trip' : 'Create Trip',
                  icon: _isEditMode ? Icons.save : Icons.add,
                  onPressed: _submit,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.value,
    required this.fallbackLabel,
    required this.onTap,
  });

  final DateTime? value;
  final String fallbackLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? fallbackLabel
        : '${value!.day} ${_monthName(value!.month)} ${value!.year}';

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_month),
        ),
        child: Text(text),
      ),
    );
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
