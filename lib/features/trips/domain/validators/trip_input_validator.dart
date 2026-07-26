class TripInputValidator {
  const TripInputValidator._();

  static String? validateDestination(String destination) {
    if (destination.trim().isEmpty) {
      return 'Destination must not be empty.';
    }
    return null;
  }

  static String? validateDates(DateTime? departureDate, DateTime? returnDate) {
    if (departureDate == null || returnDate == null) {
      return 'Please select departure and return dates.';
    }

    if (!returnDate.isAfter(departureDate)) {
      return 'Return date must be after the departure date.';
    }

    return null;
  }

  static String? validateBudget(double budget) {
    if (budget <= 0) {
      return 'Budget must be greater than zero.';
    }
    return null;
  }

  static String? validateTravellers(int travellers) {
    if (travellers < 1) {
      return 'Travellers must be at least 1.';
    }
    return null;
  }
}
