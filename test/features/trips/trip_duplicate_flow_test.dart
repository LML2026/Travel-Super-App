import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

void main() {
  test('duplicateTrip creates a new id and keeps key fields', () {
    final source = Trip(
      id: 'trip-1',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 14),
      endDate: DateTime(2026, 9, 18),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
      createdAt: DateTime(2026, 7, 1),
    );

    final duplicate = duplicateTrip(source);

    expect(duplicate.id, isNot(equals(source.id)));
    expect(duplicate.destination, 'Paris (Copy)');
    expect(duplicate.departureDate, source.departureDate);
    expect(duplicate.returnDate, source.returnDate);
    expect(duplicate.budget, source.budget);
    expect(duplicate.currency, source.currency);
    expect(duplicate.travellers, source.travellers);
    expect(duplicate.notes, source.notes);
  });
}
