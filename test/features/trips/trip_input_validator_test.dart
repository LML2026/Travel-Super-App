import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/validators/trip_input_validator.dart';

void main() {
  group('TripInputValidator', () {
    test('validates destination', () {
      expect(
        TripInputValidator.validateDestination(''),
        'Destination must not be empty.',
      );
      expect(TripInputValidator.validateDestination('Paris'), isNull);
    });

    test('validates dates', () {
      expect(
        TripInputValidator.validateDates(null, null),
        'Please select departure and return dates.',
      );

      final departure = DateTime(2026, 8, 1);
      final returnSameDay = DateTime(2026, 8, 1);
      expect(
        TripInputValidator.validateDates(departure, returnSameDay),
        'Return date must be after the departure date.',
      );

      final validReturn = DateTime(2026, 8, 3);
      expect(TripInputValidator.validateDates(departure, validReturn), isNull);
    });

    test('validates budget and travellers', () {
      expect(
        TripInputValidator.validateBudget(0),
        'Budget must be greater than zero.',
      );
      expect(TripInputValidator.validateBudget(10), isNull);

      expect(
        TripInputValidator.validateTravellers(0),
        'Travellers must be at least 1.',
      );
      expect(TripInputValidator.validateTravellers(1), isNull);
    });
  });
}
