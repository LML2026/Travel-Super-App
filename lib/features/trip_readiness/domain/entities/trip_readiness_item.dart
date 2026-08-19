enum ReadinessCategory {
  passport,
  visa,
  insurance,
  flight,
  accommodation,
  transport,
  documents,
  packing,
  medication,
  money,
  custom,
}

class TripReadinessItem {
  const TripReadinessItem({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.dueAt,
    this.notes,
    this.source = 'custom',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tripId;
  final String title;
  final ReadinessCategory category;
  final bool isCompleted;
  final DateTime? dueAt;
  final String? notes;
  final String source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool isOverdue(DateTime now) =>
      !isCompleted && dueAt != null && dueAt!.isBefore(now);

  bool isDueToday(DateTime now) {
    if (isCompleted || dueAt == null) return false;
    return dueAt!.year == now.year &&
        dueAt!.month == now.month &&
        dueAt!.day == now.day;
  }

  TripReadinessItem copyWith({
    String? id,
    String? tripId,
    String? title,
    ReadinessCategory? category,
    bool? isCompleted,
    DateTime? dueAt,
    String? notes,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripReadinessItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      dueAt: dueAt ?? this.dueAt,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TripReminder {
  const TripReminder({
    required this.id,
    required this.tripId,
    required this.title,
    required this.dueAt,
    this.sourceId,
    this.sourceType = 'custom',
    this.notes,
    this.isCompleted = false,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final DateTime dueAt;
  final String? sourceId;
  final String sourceType;
  final String? notes;
  final bool isCompleted;
  final DateTime? createdAt;

  bool isOverdue(DateTime now) => !isCompleted && dueAt.isBefore(now);

  bool isDueToday(DateTime now) {
    if (isCompleted) return false;
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  TripReminder copyWith({
    String? id,
    String? tripId,
    String? title,
    DateTime? dueAt,
    String? sourceId,
    String? sourceType,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TripReminder(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      sourceId: sourceId ?? this.sourceId,
      sourceType: sourceType ?? this.sourceType,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TripReadinessSummary {
  const TripReadinessSummary({
    required this.items,
    required this.reminders,
    required this.now,
  });

  final List<TripReadinessItem> items;
  final List<TripReminder> reminders;
  final DateTime now;

  int get completedCount => items.where((item) => item.isCompleted).length;
  int get totalCount => items.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
  int get remainingCount => totalCount - completedCount;

  List<TripReadinessItem> get overdueItems =>
      items.where((item) => item.isOverdue(now)).toList(growable: false);

  List<TripReadinessItem> get dueTodayItems =>
      items.where((item) => item.isDueToday(now)).toList(growable: false);

  List<TripReminder> get overdueReminders => reminders
      .where((reminder) => reminder.isOverdue(now))
      .toList(growable: false);

  List<TripReminder> get dueTodayReminders => reminders
      .where((reminder) => reminder.isDueToday(now))
      .toList(growable: false);

  TripReadinessItem? get nextTask {
    final pending = items.where((item) => !item.isCompleted).toList()
      ..sort((a, b) {
        final aDue = a.dueAt ?? DateTime(9999);
        final bDue = b.dueAt ?? DateTime(9999);
        return aDue.compareTo(bDue);
      });
    return pending.isEmpty ? null : pending.first;
  }
}
