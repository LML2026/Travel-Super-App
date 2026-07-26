class Expense {
  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.spentAt,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime spentAt;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? spentAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      spentAt: spentAt ?? this.spentAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
