import '../../../core/providers/travel_provider_contracts.dart';
import '../../journey_context/models/journey_context.dart';
import '../../nearby/models/nearby_service_type.dart';
import '../command_cards/assistant_command_card.dart';
import '../command_cards/coin_command_card.dart';
import '../command_cards/journey_command_card.dart';
import '../command_cards/wallet_command_card.dart';
import '../intents/assistant_intent.dart';
import 'assistant_action.dart';
import 'assistant_navigation_target.dart';

class AssistantActionRouter {
  const AssistantActionRouter();

  AssistantAction route({
    required AssistantIntent intent,
    required JourneyContext context,
  }) {
    if (intent.confidence < 0.8) {
      return const ReplyAssistantAction(
        'I can help with your wallet, Travel Coin, itinerary, or trip planning. What would you like to do?',
      );
    }

    switch (intent.type) {
      case AssistantIntentType.openWallet:
        return ShowCommandCardAction(
          message: 'Here is your current wallet summary.',
          card: WalletCommandCard(
            id: 'wallet-summary',
            title: 'Smart Wallet',
            subtitle:
                'Total value: ${_formatCurrency(context.wallet?.baseCurrency ?? context.preferredCurrency, context.wallet?.balances[context.wallet?.baseCurrency ?? 'GBP'] ?? 0)}',
          ),
        );
      case AssistantIntentType.showWalletBalance:
        return ShowCommandCardAction(
          message:
              'Your wallet total is approximately ${_formatCurrency(context.wallet?.baseCurrency ?? context.preferredCurrency, context.wallet?.balances[context.wallet?.baseCurrency ?? 'GBP'] ?? 0)}.',
          card: WalletCommandCard(
            id: 'wallet-balance',
            title: 'Smart Wallet',
            subtitle:
                'Balance: ${_formatCurrency(context.wallet?.baseCurrency ?? context.preferredCurrency, context.wallet?.balances[context.wallet?.baseCurrency ?? 'GBP'] ?? 0)}',
          ),
        );
      case AssistantIntentType.showCoinBalance:
        final coinWallet = context.coinWallet;
        if (coinWallet != null) {
          return ShowCommandCardAction(
            message:
                'You currently have ${_formatWithSeparator(coinWallet.balance)} ${coinWallet.symbol}, with an estimated reward value of £${coinWallet.valueInGbp}.',
            card: CoinCommandCard(
              id: 'coin-balance',
              title: 'Travel Coin',
              subtitle:
                  'Balance: ${_formatWithSeparator(coinWallet.balance)} ${coinWallet.symbol}',
            ),
          );
        }
        return const ReplyAssistantAction(
            'I cannot see your Travel Coin balance right now.');
      case AssistantIntentType.showTodayJourney:
        if (context.activeJourney != null) {
          return ShowCommandCardAction(
            message:
                'Your ${context.activeJourney!.destination} journey is active.',
            card: JourneyCommandCard(
              id: 'active-journey',
              title: 'Today\'s Journey',
              subtitle:
                  '${context.activeJourney!.destination} • ${_formatDate(context.activeJourney!.startDate)}',
            ),
          );
        }
        return const ReplyAssistantAction(
          'You don’t currently have an active journey. I can help you plan one.',
        );
      case AssistantIntentType.openProfile:
        return ShowCommandCardAction(
          message: 'Here is your profile summary.',
          card: AssistantCommandCard(
            id: 'profile-summary',
            type: AssistantCommandCardType.profile,
            title: 'Profile',
            subtitle: context.profile?.displayName ?? 'Traveler profile',
            actionLabel: 'Open Profile',
            navigationTarget: AssistantNavigationTarget.profile,
          ),
        );
      case AssistantIntentType.openTrips:
        return const NavigateAssistantAction(AssistantNavigationTarget.trips);
      case AssistantIntentType.openTravelCoin:
        return const NavigateAssistantAction(
            AssistantNavigationTarget.travelCoin);
      case AssistantIntentType.planTrip:
        return ShowCommandCardAction(
          message: 'I can help you plan a trip.',
          card: AssistantCommandCard(
            id: 'trip-planner',
            type: AssistantCommandCardType.tripPlanner,
            title: 'Trip Planner',
            subtitle: 'Create a new itinerary or planning brief.',
            actionLabel: 'Start Planning',
            navigationTarget: AssistantNavigationTarget.tripPlanner,
          ),
        );
      case AssistantIntentType.translate:
        return ShowCommandCardAction(
          message: 'I can help you translate something.',
          card: AssistantCommandCard(
            id: 'translation-helper',
            type: AssistantCommandCardType.translation,
            title: 'Translation',
            subtitle: 'Open the translation experience.',
            actionLabel: 'Open Translation',
            navigationTarget: AssistantNavigationTarget.translation,
          ),
        );
      case AssistantIntentType.findNearbyToilet:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
          parameters: <String, Object?>{'serviceType': 'toilet'},
        );
      case AssistantIntentType.findNearbyAtm:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
          parameters: <String, Object?>{'serviceType': 'atm'},
        );
      case AssistantIntentType.showBudget:
        if (context.financialContext != null) {
          final financial = context.financialContext!;
          final preferredCurrencyValue =
              financial.preferredCurrencyRemaining ?? financial.remainingBudget;
          final baseSpend = financial.estimatedSpend;
          final convertedSpend = financial.preferredCurrencySpend;
          final rateLabel = _rateLabel(financial.exchangeRateSource);
          final rateNote = financial.exchangeRateSource ==
                  TravelDataSource.cached
              ? 'Exchange rates haven\'t been refreshed recently, so the converted amount is an estimate.'
              : (financial.preferredCurrencySpend == null
                  ? 'A converted value isn\'t available at the moment.'
                  : '');
          final spendText = convertedSpend != null
              ? '${convertedSpend.currency} ${convertedSpend.amount.toStringAsFixed(2)}'
              : '${baseSpend.currency} ${baseSpend.amount.toStringAsFixed(2)}';
          final remainingText =
              '${preferredCurrencyValue.currency} ${preferredCurrencyValue.amount.toStringAsFixed(2)}';
          return ReplyAssistantAction(
            'Your current itinerary is estimated to cost $spendText, with about $remainingText remaining. $rateLabel $rateNote'
                .trim(),
          );
        }
        return const ReplyAssistantAction(
            'Your remaining trip budget is available in your wallet summary.');
      case AssistantIntentType.showActiveJourney:
        return const NavigateAssistantAction(
            AssistantNavigationTarget.activeJourney);
      case AssistantIntentType.updateProfile:
        return const UnsupportedAssistantAction(
            'Profile updates are not available yet.');
      case AssistantIntentType.findPlaces:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
        );
      case AssistantIntentType.recommendRestaurant:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
          parameters: <String, Object?>{'serviceType': 'restaurant'},
        );
      case AssistantIntentType.recommendActivity:
        return const ReplyAssistantAction(
          'I can suggest culture, sightseeing, or relaxed activities that suit your itinerary.',
        );
      case AssistantIntentType.findNearbyPharmacy:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
          parameters: <String, Object?>{'serviceType': 'pharmacy'},
        );
      case AssistantIntentType.findNearbyHospital:
        return const NavigateAssistantAction(
          AssistantNavigationTarget.nearbyEssentials,
          parameters: <String, Object?>{'serviceType': 'hospital'},
        );
      case AssistantIntentType.addPlaceToItinerary:
        return const ReplyAssistantAction(
          'I can add a selected place to your itinerary as an unconfirmed suggestion.',
        );
      case AssistantIntentType.unknown:
        return const ReplyAssistantAction(
          'I can help with your wallet, Travel Coin, itinerary, or trip planning. What would you like to do?',
        );
    }
  }

  String _formatCurrency(String currency, double amount) {
    final normalized = amount.toStringAsFixed(2);
    return '$currency $normalized';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _rateLabel(TravelDataSource source) {
    switch (source) {
      case TravelDataSource.live:
        return 'Using the latest available exchange rate.';
      case TravelDataSource.cached:
        return 'Exchange rates haven\'t been refreshed recently, so the converted amount is an estimate.';
      case TravelDataSource.mock:
        return 'A converted value isn\'t available at the moment.';
    }
  }

  String _formatWithSeparator(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  NearbyServiceType? nearbyServiceTypeFromName(String? raw) {
    switch (raw) {
      case 'toilet':
        return NearbyServiceType.toilet;
      case 'atm':
        return NearbyServiceType.atm;
      case 'pharmacy':
        return NearbyServiceType.pharmacy;
      case 'hospital':
        return NearbyServiceType.hospital;
      case 'restaurant':
        return NearbyServiceType.restaurant;
      case 'cafe':
        return NearbyServiceType.cafe;
      default:
        return null;
    }
  }
}
