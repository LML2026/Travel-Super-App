import '../../coins/models/coin_wallet.dart';
import '../../profile/models/user_profile.dart';
import '../../trips/models/journey.dart';
import '../../wallet/domain/entities/wallet.dart';
import '../../../core/providers/travel_provider_contracts.dart';

class TripFinancialContext {
  const TripFinancialContext({
    required this.remainingBudget,
    required this.estimatedSpend,
    this.preferredCurrencyRemaining,
    this.preferredCurrencySpend,
    this.exchangeRateSource = TravelDataSource.mock,
  });

  final MoneyAmount remainingBudget;
  final MoneyAmount estimatedSpend;
  final MoneyAmount? preferredCurrencyRemaining;
  final MoneyAmount? preferredCurrencySpend;
  final TravelDataSource exchangeRateSource;
}

class JourneyContext {
  const JourneyContext({
    this.profile,
    this.activeJourney,
    this.wallet,
    this.coinWallet,
    this.financialContext,
    this.locale = 'en',
    this.preferredCurrency = 'GBP',
  });

  final UserProfile? profile;
  final Journey? activeJourney;
  final Wallet? wallet;
  final CoinWallet? coinWallet;
  final TripFinancialContext? financialContext;
  final String locale;
  final String preferredCurrency;
}
