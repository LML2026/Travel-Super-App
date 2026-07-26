class Expense {
  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.notes,
  });

  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String notes;

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
