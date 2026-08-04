import 'package:equatable/equatable.dart';

class Journey extends Equatable {
  const Journey({
    required this.id,
    required this.tripId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.items,
  });

  final String id;
  final String tripId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<JourneyItem> items;

  @override
  List<Object?> get props => <Object?>[
        id,
        tripId,
        title,
        destination,
        startDate,
        endDate,
        items,
      ];
}

class JourneyItem extends Equatable {
  const JourneyItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.startTime,
    required this.location,
  });

  final String id;
  final String title;
  final JourneyItemType type;
  final JourneyItemStatus status;
  final DateTime startTime;
  final String location;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        type,
        status,
        startTime,
        location,
      ];
}

enum JourneyItemStatus { upcoming, inProgress, completed, delayed, cancelled }

enum JourneyItemType {
  flight,
  hotel,
  transport,
  activity,
  restaurant,
  reminder,
}
