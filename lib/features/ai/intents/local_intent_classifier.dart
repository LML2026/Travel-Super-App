import 'assistant_intent.dart';
import 'intent_classifier.dart';

class LocalIntentClassifier implements IntentClassifier {
  const LocalIntentClassifier();

  @override
  AssistantIntent classify(String message) {
    final normalized = _normalize(message);

    if (_containsAny(normalized, [
      'open my wallet',
      'show my wallet',
      'show wallet',
      'open wallet',
      'wallet balance',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.openWallet,
        confidence: 0.95,
      );
    }

    if (_containsAny(normalized, [
      'show my balance',
      'show balance',
      'how much money do i have',
      'my balance',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.showWalletBalance,
        confidence: 0.92,
      );
    }

    if (_containsAny(normalized, [
      'how many coins do i have',
      'show my coins',
      'open travel coin',
      'travel coin balance',
      'how much travel coin',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.showCoinBalance,
        confidence: 0.95,
      );
    }

    if (_containsAny(normalized, [
      'show todays itinerary',
      'show today itinerary',
      'show today’s itinerary',
      'show todays journey',
      'what is next on my trip',
      'what is next on my journey',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.showTodayJourney,
        confidence: 0.93,
      );
    }

    if (_containsAny(normalized, [
      'open my profile',
      'show profile',
      'my profile',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.openProfile,
        confidence: 0.94,
      );
    }

    if (_containsAny(normalized, [
      'plan a new trip',
      'plan my trip',
      'create a trip',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.planTrip,
        confidence: 0.9,
      );
    }

    if (_containsAny(normalized, ['translate', 'translate something'])) {
      return const AssistantIntent(
        type: AssistantIntentType.translate,
        confidence: 0.9,
      );
    }

    if (_containsAny(normalized, [
      'nearest toilet',
      'find a toilet',
      'where is the toilet',
      'where is the nearest toilet',
      'public toilet near me',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.findNearbyToilet,
        confidence: 0.91,
      );
    }

    if (_containsAny(normalized, [
      'nearest atm',
      'find an atm',
      'atm near me',
      'cash machine near me',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.findNearbyAtm,
        confidence: 0.89,
      );
    }

    if (_containsAny(normalized, [
      'open my trips',
      'show trips',
      'trip list',
      'show my trip',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.openTrips,
        confidence: 0.9,
      );
    }

    if (_containsAny(normalized, [
      'find places',
      'show places',
      'places near me',
      'discover places',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.findPlaces,
        confidence: 0.89,
      );
    }

    if (_containsAny(normalized, [
      'recommend a restaurant',
      'find a restaurant',
      'restaurant near me',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.recommendRestaurant,
        confidence: 0.88,
      );
    }

    if (_containsAny(normalized, [
      'recommend an activity',
      'find an activity',
      'what should i do',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.recommendActivity,
        confidence: 0.87,
      );
    }

    if (_containsAny(normalized, [
      'find a pharmacy',
      'nearby pharmacy',
      'pharmacy',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.findNearbyPharmacy,
        confidence: 0.86,
      );
    }

    if (_containsAny(normalized, [
      'find a hospital',
      'nearby hospital',
      'hospital near me',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.findNearbyHospital,
        confidence: 0.86,
      );
    }

    if (_containsAny(normalized, [
      'add this place to my itinerary',
      'add place to itinerary',
    ])) {
      return const AssistantIntent(
        type: AssistantIntentType.addPlaceToItinerary,
        confidence: 0.86,
      );
    }

    return const AssistantIntent(
      type: AssistantIntentType.unknown,
      confidence: 0.1,
    );
  }

  String _normalize(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r"[\p{P}\p{S}]", unicode: true), ' ')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
  }

  bool _containsAny(String message, List<String> phrases) {
    return phrases.any((phrase) => message.contains(phrase));
  }
}
