import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../trips/domain/entities/trip.dart';
import '../providers/trip_readiness_provider.dart';
import '../../domain/entities/trip_readiness_item.dart';

class TripReadinessPage extends ConsumerWidget {
  const TripReadinessPage({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(tripReadinessItemsProvider(trip.id));
    final remindersAsync = ref.watch(tripRemindersProvider(trip.id));
    final suggestions = ref.watch(suggestedReadinessItemsProvider(trip));
    final summary = ref.watch(tripReadinessSummaryProvider(trip.id));
    final savedTitles = summary.items.map((item) => item.title).toSet();
    final availableSuggestions =
        suggestions.where((item) => !savedTitles.contains(item.title)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Readiness')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTask(context, ref),
        icon: const Icon(Icons.add_task),
        label: const Text('Task'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressCard(summary: summary),
          const SizedBox(height: 12),
          if (availableSuggestions.isNotEmpty)
            _SuggestionsCard(
              suggestions: availableSuggestions,
              onAdd: (item) =>
                  ref.read(tripReadinessActionsProvider).saveItem(item),
            ),
          const SizedBox(height: 12),
          _ChecklistCard(
            items: itemsAsync.valueOrNull ?? const [],
            isLoading: itemsAsync.isLoading,
            onToggle: (item) =>
                ref.read(tripReadinessActionsProvider).toggleItem(item),
            onDelete: (item) =>
                ref.read(tripReadinessActionsProvider).deleteItem(item),
            onReminder: (item) => _showAddReminder(context, ref, item),
          ),
          const SizedBox(height: 12),
          _RemindersCard(
            reminders: remindersAsync.valueOrNull ?? const [],
            isLoading: remindersAsync.isLoading,
            onToggle: (reminder) =>
                ref.read(tripReadinessActionsProvider).toggleReminder(reminder),
            onDelete: (reminder) =>
                ref.read(tripReadinessActionsProvider).deleteReminder(reminder),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTask(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    var category = ReadinessCategory.custom;
    DateTime? dueAt;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReadinessCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final item in ReadinessCategory.values)
                    DropdownMenuItem(value: item, child: Text(_label(item))),
                ],
                onChanged: (value) => setState(
                    () => category = value ?? ReadinessCategory.custom),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => dueAt = picked);
                },
                icon: const Icon(Icons.event_outlined),
                label: Text(dueAt == null
                    ? 'Due date'
                    : DateFormat('dd MMM yyyy').format(dueAt!)),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  await ref.read(tripReadinessActionsProvider).addCustomItem(
                        tripId: trip.id,
                        title: title,
                        category: category,
                        dueAt: dueAt,
                        notes: notesController.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddReminder(
    BuildContext context,
    WidgetRef ref,
    TripReadinessItem item,
  ) async {
    final dueAt = item.dueAt ?? DateTime.now().add(const Duration(days: 1));
    await ref.read(tripReadinessActionsProvider).addReminder(
          tripId: trip.id,
          title: item.title,
          dueAt: dueAt,
          sourceId: item.id,
          sourceType: 'checklist',
          notes: item.notes,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder added for ${item.title}.')),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary});

  final TripReadinessSummary summary;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.progress * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Readiness $percent%',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: summary.progress),
            const SizedBox(height: 8),
            Text('${summary.remainingCount} tasks remaining'),
            if (summary.nextTask != null)
              Text('Next: ${summary.nextTask!.title}'),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  const _SuggestionsCard({required this.suggestions, required this.onAdd});

  final List<TripReadinessItem> suggestions;
  final ValueChanged<TripReadinessItem> onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggested preparation',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final item in suggestions.take(6))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(_due(item.dueAt)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onAdd(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.items,
    required this.isLoading,
    required this.onToggle,
    required this.onDelete,
    required this.onReminder,
  });

  final List<TripReadinessItem> items;
  final bool isLoading;
  final ValueChanged<TripReadinessItem> onToggle;
  final ValueChanged<TripReadinessItem> onDelete;
  final ValueChanged<TripReadinessItem> onReminder;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) {
        final aDue = a.dueAt ?? DateTime(9999);
        final bDue = b.dueAt ?? DateTime(9999);
        return aDue.compareTo(bDue);
      });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Checklist',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child:
                    Text('Add suggested or custom tasks to prepare this trip.'),
              )
            else
              for (final item in sorted)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: item.isCompleted,
                  onChanged: (_) => onToggle(item),
                  title: Text(item.title),
                  subtitle:
                      Text('${_label(item.category)} · ${_due(item.dueAt)}'),
                  secondary: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'reminder') onReminder(item);
                      if (value == 'delete') onDelete(item);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: 'reminder', child: Text('Add reminder')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  const _RemindersCard({
    required this.reminders,
    required this.isLoading,
    required this.onToggle,
    required this.onDelete,
  });

  final List<TripReminder> reminders;
  final bool isLoading;
  final ValueChanged<TripReminder> onToggle;
  final ValueChanged<TripReminder> onDelete;

  @override
  Widget build(BuildContext context) {
    final sorted = [...reminders]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reminders',
                style: TextStyle(fontWeight: FontWeight.w800)),
            if (isLoading) const LinearProgressIndicator(),
            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No reminders yet.'),
              )
            else
              for (final reminder in sorted)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: reminder.isCompleted,
                  onChanged: (_) => onToggle(reminder),
                  title: Text(reminder.title),
                  subtitle: Text(_due(reminder.dueAt)),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete(reminder),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

String _label(ReadinessCategory category) {
  return category.name[0].toUpperCase() + category.name.substring(1);
}

String _due(DateTime? value) {
  if (value == null) return 'No due date';
  return DateFormat('dd MMM yyyy').format(value);
}
