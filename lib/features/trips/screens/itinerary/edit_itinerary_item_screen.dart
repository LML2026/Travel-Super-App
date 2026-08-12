import 'package:flutter/material.dart';

import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';

class EditItineraryItemScreen extends StatefulWidget {
  final Trip trip;
  final ItineraryItem item;

  const EditItineraryItemScreen({
    super.key,
    required this.trip,
    required this.item,
  });

  @override
  State<EditItineraryItemScreen> createState() =>
      _EditItineraryItemScreenState();
}

class _EditItineraryItemScreenState extends State<EditItineraryItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late DateTime _date;
  TimeOfDay? _time;
  late String _category;
  late bool _isBooked;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.item.title);
    _locationController = TextEditingController(text: widget.item.location);
    _costController = TextEditingController(
      text: widget.item.estimatedCost?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.item.notes);
    _latitudeController = TextEditingController(text: widget.item.latitude?.toString() ?? '');
    _longitudeController = TextEditingController(text: widget.item.longitude?.toString() ?? '');

    _date = widget.item.date;
    _category = widget.item.category;
    _isBooked = widget.item.isBooked;

    final storedTime = widget.item.time;

    if (storedTime != null && storedTime.contains(':')) {
      final parts = storedTime.split(':');
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour != null && minute != null) {
        _time = TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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

    final updatedItem = widget.item.copyWith(
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
      latitude: double.tryParse(_latitudeController.text.trim()),
      longitude: double.tryParse(_longitudeController.text.trim()),
    );

    Navigator.of(context).pop(updatedItem);
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
        title: const Text('Edit Itinerary Item'),
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.explore_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
              icon: const Icon(Icons.save_outlined),
              label: const Padding(
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

