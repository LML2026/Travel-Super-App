import 'package:flutter/material.dart';

import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';

class AddItineraryItemScreen extends StatefulWidget {
  final Trip trip;

  const AddItineraryItemScreen({
    super.key,
    required this.trip,
  });

  @override
  State<AddItineraryItemScreen> createState() =>
      _AddItineraryItemScreenState();
}

class _AddItineraryItemScreenState extends State<AddItineraryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _date;
  TimeOfDay? _time;
  String _category = 'Activity';
  bool _isBooked = false;

  @override
  void initState() {
    super.initState();
    _date = widget.trip.departureDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.trip.departureDate,
      lastDate: widget.trip.returnDate,
    );

    if (date != null) {
      setState(() => _date = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _time = time);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final item = ItineraryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tripId: widget.trip.id,
      title: _titleController.text.trim(),
      date: _date,
      time: _time == null
          ? null
          : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
      location: _locationController.text.trim(),
      category: _category,
      notes: _notesController.text.trim(),
      estimatedCost: double.tryParse(_costController.text.trim()),
      currency: widget.trip.currency,
      isBooked: _isBooked,
    );

    Navigator.of(context).pop(item);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Itinerary Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an activity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(_formatDate(_date)),
              onTap: _pickDate,
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Time'),
              subtitle: Text(
                _time == null ? 'Optional' : _time!.format(context),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Activity',
                  child: Text('Activity'),
                ),
                DropdownMenuItem(
                  value: 'Attraction',
                  child: Text('Attraction'),
                ),
                DropdownMenuItem(
                  value: 'Restaurant',
                  child: Text('Restaurant'),
                ),
                DropdownMenuItem(
                  value: 'Transport',
                  child: Text('Transport'),
                ),
                DropdownMenuItem(
                  value: 'Hotel',
                  child: Text('Hotel'),
                ),
                DropdownMenuItem(
                  value: 'Shopping',
                  child: Text('Shopping'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Estimated cost',
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: widget.trip.currency,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Already booked'),
              value: _isBooked,
              onChanged: (value) {
                setState(() => _isBooked = value);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Add to Itinerary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
