import '../../../core/providers/travel_provider_contracts.dart';

class PlacesPrefill {
  const PlacesPrefill({
    required this.query,
    this.locationHint,
    this.scheduledAt,
    this.note,
    this.title,
    this.categories = const <PlaceCategory>{},
  });

  final String query;
  final String? locationHint;
  final DateTime? scheduledAt;
  final String? note;
  final String? title;
  final Set<PlaceCategory> categories;
}
