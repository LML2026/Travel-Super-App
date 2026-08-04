import 'package:travel_super_app/core/providers/travel_provider_contracts.dart';
import 'package:travel_super_app/features/coins/models/coin_wallet.dart';
import 'package:travel_super_app/features/profile/models/user_profile.dart';
import 'package:travel_super_app/features/trips/models/journey.dart';
import 'package:travel_super_app/features/wallet/domain/entities/wallet.dart';
import 'package:travel_super_app/features/weather/models/weather_data.dart';

class FinancialJourneyContext {
  const FinancialJourneyContext({
    required this.totalBudget,
    required this.estimatedSpend,
    required this.remainingBudget,
    this.preferredCurrencyBudget,
    this.preferredCurrencySpend,
    this.preferredCurrencyRemaining,
    required this.exchangeRateSource,
    this.exchangeRateUpdatedAt,
  });

  final MoneyAmount totalBudget;
  final MoneyAmount estimatedSpend;
  final MoneyAmount remainingBudget;
  final MoneyAmount? preferredCurrencyBudget;
  final MoneyAmount? preferredCurrencySpend;
  final MoneyAmount? preferredCurrencyRemaining;
  final TravelDataSource exchangeRateSource;
  final DateTime? exchangeRateUpdatedAt;
}

class JourneyContext {
  const JourneyContext({
    required this.profile,
    required this.activeJourney,
    required this.wallet,
    required this.coinWallet,
    required this.locale,
    required this.preferredCurrency,
    this.financialContext,
    this.weatherContext,
  });

  final UserProfile? profile;
  final Journey? activeJourney;
  final Wallet? wallet;
  final CoinWallet? coinWallet;
  final String locale;
  final String preferredCurrency;
  final FinancialJourneyContext? financialContext;
  final WeatherData? weatherContext;

  bool get hasActiveJourney => activeJourney != null;
}

class AssistantRequest {
  const AssistantRequest({
    required this.message,
    required this.context,
  });

  final String message;
  final JourneyContext context;
}
