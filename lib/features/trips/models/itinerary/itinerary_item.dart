import 'dart:convert';

class ItineraryItem {
  final String id;
  final String tripId;
  final String title;
  final DateTime date;
  final String? time;
  final String location;
  final String category;
  final String notes;
  final double? estimatedCost;
  final String currency;
  final bool isBooked;

  const ItineraryItem({
    required this.id,
    required this.tripId,
    required this.title,
    required this.date,
    this.time,
    required this.location,
    required this.category,
    required this.notes,
    this.estimatedCost,
    required this.currency,
    required this.isBooked,
  });

  ItineraryItem copyWith({
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? category,
    String? notes,
    double? estimatedCost,
    String? currency,
    bool? isBooked,
  }) {
    return ItineraryItem(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currency: currency ?? this.currency,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'category': category,
      'notes': notes,
      'estimatedCost': estimatedCost,
      'currency': currency,
      'isBooked': isBooked,
    };
  }

  factory ItineraryItem.fromMap(Map<String, dynamic> map) {
    return ItineraryItem(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      location: map['location'] as String,
      category: map['category'] as String,
      notes: map['notes'] as String,
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
      currency: map['currency'] as String,
      isBooked: map['isBooked'] as bool,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ItineraryItem.fromJson(String source) =>
      ItineraryItem.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}
