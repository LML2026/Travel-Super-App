import 'package:flutter/material.dart';

class SavedTrip {
  final String id;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int travelers;
  final List<String> flightIds; // Save flight IDs instead of full Flight objects
  final List<String> hotelIds;
  final double totalBudget;
  final DateTime createdAt;

  const SavedTrip({
    required this.id,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.travelers,
    required this.flightIds,
    required this.hotelIds,
    required this.totalBudget,
    required this.createdAt,
  });

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'travelers': travelers,
      'flightIds': flightIds,
      'hotelIds': hotelIds,
      'totalBudget': totalBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Reconstruct from JSON
  factory SavedTrip.fromJson(Map<String, dynamic> json) {
    return SavedTrip(
      id: json['id'] ?? '',
      destination: json['destination'] ?? '',
      departureDate: DateTime.parse(json['departureDate'] ?? DateTime.now().toIso8601String()),
      returnDate: DateTime.parse(json['returnDate'] ?? DateTime.now().toIso8601String()),
      travelers: json['travelers'] ?? 1,
      flightIds: List<String>.from(json['flightIds'] ?? []),
      hotelIds: List<String>.from(json['hotelIds'] ?? []),
      totalBudget: double.tryParse(json['totalBudget']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Estimate duration
  int get nights => returnDate.difference(departureDate).inDays;
}
