import 'package:flutter/material.dart';
import '../models/trip.dart';

class EditTripScreen extends StatefulWidget {
  final Trip trip;

  const EditTripScreen({
    super.key,
    required this.trip,
  });

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _destinationController;
  late final TextEditingController _travellersController;
  late final TextEditingController _budgetController;
  late final TextEditingController _notesController;

  late DateTime _departureDate;
  late DateTime _returnDate;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.destination);
    _travellersController = TextEditingController(text: widget.trip.travellers.toString());
    _budgetController = TextEditingController(text: widget.trip.budget.toStringAsFixed(2));
    _notesController = TextEditingController(text: widget.trip.notes);
    _departureDate = widget.trip.departureDate;
    _returnDate = widget.trip.returnDate;
    _currency = widget.trip.currency;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _travellersController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() {
        _departureDate = date;
        if (_returnDate.isBefore(_departureDate)) {
          _returnDate = _departureDate;
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _departureDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() => _returnDate = date);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTrip = widget.trip.copyWith(
      destination: _destinationController.text.trim(),
      departureDate: _departureDate,
      returnDate: _returnDate,
      travellers: int.parse(_travellersController.text),
      notes: _notesController.text.trim(),
      budget: double.tryParse(_budgetController.text) ?? 0,
      currency: _currency,
    );

    Navigator.of(context).pop(updatedTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a destination'
                  : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Departure date'),
              subtitle: Text(_formatDate(_departureDate)),
              onTap: _pickDepartureDate,
            ),
            ListTile(
              title: const Text('Return date'),
              subtitle: Text(_formatDate(_returnDate)),
              onTap: _pickReturnDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _travellersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Travellers',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _currency = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
