enum JourneyClockSource {
  explicitTripLocal,
  deviceLocal,
  testInjected,
  unknown,
}

class JourneyClock {
  final DateTime value;
  final JourneyClockSource source;

  const JourneyClock({required this.value, required this.source});

  bool get isTrustedForItineraryLocalComparison =>
      source == JourneyClockSource.explicitTripLocal ||
      source == JourneyClockSource.testInjected;
}
