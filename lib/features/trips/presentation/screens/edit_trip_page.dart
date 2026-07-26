import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class EditTripPage extends ConsumerStatefulWidget {
  const EditTripPage({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  ConsumerState<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends ConsumerState<EditTripPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  late final TextEditingController _notesController;

  late DateTime _departureDate;
  late DateTime _returnDate;

  late String _currency;
  late int _travellers;

  @override
  void initState() {
    super.initState();

    final trip = widget.trip;

    _destinationController = TextEditingController(text: trip.destination);

    _budgetController = TextEditingController(text: trip.budget.toString());

    _notesController = TextEditingController(text: trip.notes);

    _departureDate = trip.departureDate;
    _returnDate = trip.returnDate;
    _currency = trip.currency;
    _travellers = trip.travellers;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _departureDate = date);
    }
  }

  Future<void> _pickReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _departureDate,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _returnDate = date);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repository = ref.read(tripRepositoryProvider);

    final updatedTrip = widget.trip.copyWith(
      destination: _destinationController.text.trim(),
      departureDate: _departureDate,
      returnDate: _returnDate,
      budget: double.parse(_budgetController.text),
      currency: _currency,
      travellers: _travellers,
      notes: _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await repository.updateTrip(updatedTrip);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter destination' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_departureDate.toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDepartureDate,
            ),
            ListTile(
              title: Text(_returnDate.toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickReturnDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter budget';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP'),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR'),
                ),
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD'),
                ),
              ],
              onChanged: (value) {
                setState(() => _currency = value!);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Travellers',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (_travellers > 1) {
                      setState(() => _travellers--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_travellers',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _travellers++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
