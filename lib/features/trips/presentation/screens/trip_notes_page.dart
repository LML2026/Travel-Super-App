import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class TripNotesPage extends ConsumerStatefulWidget {
  const TripNotesPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  ConsumerState<TripNotesPage> createState() => _TripNotesPageState();
}

class _TripNotesPageState extends ConsumerState<TripNotesPage> {
  late final TextEditingController _notesController;
  Trip? _trip;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadTrip();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    final trip = await ref.read(tripRepositoryProvider).get(widget.tripId);
    if (!mounted) {
      return;
    }

    setState(() {
      _trip = trip;
      _notesController.text = trip?.notes ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    final trip = _trip;
    if (trip == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = trip.copyWith(
        notes: _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await ref.read(createTripProvider.notifier).updateTrip(updated);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip notes saved.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save notes: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Notes')),
        body: const Center(child: Text('Trip not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Add trip notes, ideas, reminders, and links...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveNotes,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
