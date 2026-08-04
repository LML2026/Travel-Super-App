import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class CreateTripPage extends ConsumerStatefulWidget {
  const CreateTripPage({super.key});

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();

  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;

  String _currency = 'GBP';
  int _travellers = 1;

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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _departureDate = date);
    }
  }

  Future<void> _pickReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: _departureDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _returnDate = date);
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_departureDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates.')),
      );
      return;
    }

    final notifier = ref.read(createTripProvider.notifier);

    final now = DateTime.now();

    final trip = Trip(
      id: const Uuid().v4(),
      title: _destinationController.text.trim(),
      destination: _destinationController.text.trim(),
      departureDate: _departureDate!,
      returnDate: _returnDate!,
      budget: double.parse(_budgetController.text),
      currency: _currency,
      travellers: _travellers,
      notes: _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await notifier.createTrip(trip);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter destination' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _departureDate == null
                    ? 'Select departure date'
                    : _departureDate.toString().split(' ').first,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDepartureDate,
            ),
            ListTile(
              title: Text(
                _returnDate == null
                    ? 'Select return date'
                    : _returnDate.toString().split(' ').first,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickReturnDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Budget'),
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
              decoration: const InputDecoration(labelText: 'Currency'),
              items: const [
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (value) {
                setState(() => _currency = value!);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Travellers', style: TextStyle(fontSize: 16)),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (_travellers > 1) {
                      setState(() => _travellers--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_travellers', style: const TextStyle(fontSize: 18)),
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
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveTrip,
              child: const Text('Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
