import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/ai/intents/assistant_intent.dart';
import 'package:travel_super_app/features/ai/intents/local_intent_classifier.dart';
import 'package:travel_super_app/features/ai/routing/assistant_action.dart';
import 'package:travel_super_app/features/ai/routing/assistant_action_router.dart';
import 'package:travel_super_app/features/ai/routing/assistant_navigation_target.dart';
import 'package:travel_super_app/features/coins/models/coin_wallet.dart';
import 'package:travel_super_app/features/journey_context/models/journey_context.dart';
import 'package:travel_super_app/features/profile/models/user_profile.dart';
import 'package:travel_super_app/features/trips/models/journey.dart';
import 'package:travel_super_app/features/wallet/domain/entities/wallet.dart';

void main() {
  late LocalIntentClassifier classifier;
  late AssistantActionRouter router;
  late JourneyContext context;

  setUp(() {
    classifier = LocalIntentClassifier();
    router = AssistantActionRouter();
    context = JourneyContext(
      profile: const UserProfile(
        uid: 'u1',
        displayName: 'Mina',
        email: 'mina@example.com',
        preferredLanguage: 'en',
        preferredCurrency: 'GBP',
        homeCity: 'Milan',
        dietaryPreferences: ['Vegetarian'],
        travelPreferences: [],
      ),
      activeJourney: Journey(
        id: 'journey-1',
        tripId: 'trip-1',
        title: 'Rome journey',
        destination: 'Rome',
        startDate: DateTime(2026, 8, 12),
        endDate: DateTime(2026, 8, 17),
        items: const [],
      ),
      wallet: const Wallet(
        id: 'wallet-1',
        userId: 'u1',
        baseCurrency: 'GBP',
        balances: {'GBP': 742.5},
      ),
      coinWallet: const CoinWallet(
        walletId: 'coin-1',
        balance: 12450,
        symbol: 'TRC',
        valueInGbp: '124.50',
      ),
      locale: 'en',
      preferredCurrency: 'GBP',
    );
  });

  test('classifies an open wallet request', () {
    final intent = classifier.classify('Open my wallet');

    expect(intent.type, AssistantIntentType.openWallet);
    expect(intent.confidence, greaterThan(0.9));
  });

  test('routes wallet intents to wallet navigation', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.openWallet,
        confidence: 0.95,
      ),
      context: context,
    );

    expect(action, isA<ShowCommandCardAction>());
    expect((action as ShowCommandCardAction).card.title, contains('Smart Wallet'));
  });

  test('routes coin requests to a live balance reply', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.showCoinBalance,
        confidence: 0.95,
      ),
      context: context,
    );

    expect(action, isA<ShowCommandCardAction>());
    expect((action as ShowCommandCardAction).message, contains('12,450 TRC'));
  });

  test('routes active journey requests to journey navigation', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.showTodayJourney,
        confidence: 0.95,
      ),
      context: context,
    );

    expect(action, isA<ShowCommandCardAction>());
    expect((action as ShowCommandCardAction).card.title, contains('Today'));
  });

  test('classifies nearest toilet request and routes to nearby essentials', () {
    final intent = classifier.classify('Where is the nearest toilet?');

    expect(intent.type, AssistantIntentType.findNearbyToilet);

    final action = router.route(intent: intent, context: context);
    expect(action, isA<NavigateAssistantAction>());
    expect(
      (action as NavigateAssistantAction).target,
      AssistantNavigationTarget.nearbyEssentials,
    );
    expect(action.parameters['serviceType'], 'toilet');
  });

  test('routes pharmacy request to nearby essentials with pharmacy prefill', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.findNearbyPharmacy,
        confidence: 0.91,
      ),
      context: context,
    );

    expect(action, isA<NavigateAssistantAction>());
    expect(
      (action as NavigateAssistantAction).target,
      AssistantNavigationTarget.nearbyEssentials,
    );
    expect(action.parameters['serviceType'], 'pharmacy');
  });

  test('returns a safe reply when no active journey exists', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.showTodayJourney,
        confidence: 0.95,
      ),
      context: JourneyContext(
        profile: context.profile,
        activeJourney: null,
        wallet: context.wallet,
        coinWallet: context.coinWallet,
        locale: context.locale,
        preferredCurrency: context.preferredCurrency,
      ),
    );

    expect(action, isA<ReplyAssistantAction>());
    expect((action as ReplyAssistantAction).message, contains('active journey'));
  });

  test('returns a fallback reply for unknown requests', () {
    final action = router.route(
      intent: const AssistantIntent(
        type: AssistantIntentType.unknown,
        confidence: 0.1,
      ),
      context: context,
    );

    expect(action, isA<ReplyAssistantAction>());
    expect((action as ReplyAssistantAction).message, contains('wallet'));
  });
}
