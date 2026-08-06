import 'package:equatable/equatable.dart';

class Journey extends Equatable {
  const Journey({
    required this.id,
    required this.tripId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.items = const [],
  });

  final String id;
  final String tripId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<Object?> items;

  @override
  List<Object?> get props =>
      [id, tripId, title, destination, startDate, endDate, items];
}
