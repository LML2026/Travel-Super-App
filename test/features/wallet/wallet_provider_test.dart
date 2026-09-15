import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/authentication/domain/entities/auth_user.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:travel_super_app/features/wallet/data/services/wallet_fx_service.dart';
import 'package:travel_super_app/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:travel_super_app/features/wallet/domain/entities/wallet.dart';
import 'package:travel_super_app/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:travel_super_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:travel_super_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:travel_super_app/features/wallet/presentation/screens/wallet_page.dart';

class _FakeWalletRepository implements WalletRepository {
  _FakeWalletRepository();

  final Wallet _wallet = const Wallet(
    id: 'wallet-user-1',
    userId: 'user-1',
    baseCurrency: 'GBP',
    balances: <String, double>{'GBP': 1000, 'EUR': 0},
  );

  bool depositCalled = false;
  String? lastDepositWalletId;
  double? lastDepositAmount;
  String? lastDepositCurrency;

  @override
  Stream<Wallet> watchWallet(String userId) {
    return Stream<Wallet>.value(
        _wallet.copyWith(userId: userId, id: 'wallet-$userId'));
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions(String walletId) {
    return Stream<List<WalletTransaction>>.value(<WalletTransaction>[]);
  }

  @override
  Future<Wallet?> getWallet(String userId) async {
    return _wallet.copyWith(userId: userId, id: 'wallet-$userId');
  }

  @override
  Future<void> addCurrency({
    required String walletId,
    required String currency,
  }) async {}

  @override
  Future<void> deposit({
    required String walletId,
    required double amount,
    required String currency,
  }) async {
    depositCalled = true;
    lastDepositWalletId = walletId;
    lastDepositAmount = amount;
    lastDepositCurrency = currency;
  }

  @override
  Future<void> transfer({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    required String currency,
  }) async {}

  @override
  Future<void> convertCurrency({
    required String walletId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required double exchangeRate,
  }) async {
    lastConvertedAmount = amount;
    lastFromCurrency = fromCurrency;
    lastToCurrency = toCurrency;
    lastExchangeRate = exchangeRate;
  }

  double? lastConvertedAmount;
  String? lastFromCurrency;
  String? lastToCurrency;
  double? lastExchangeRate;
}

class _FakeWalletFxService extends WalletFxService {
  _FakeWalletFxService(this.rate);

  final double rate;
  int callCount = 0;

  @override
  Future<double> getRate({
    required String base,
    required String target,
  }) async {
    callCount += 1;
    return rate;
  }
}

void main() {
  group('FxPair', () {
    test('uses stable value equality for equivalent currency pairs', () {
      const first = FxPair(base: 'GBP', target: 'EUR');
      const second = FxPair(base: 'GBP', target: 'EUR');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('treats different currency pairs as different keys', () {
      const gbpToEur = FxPair(base: 'GBP', target: 'EUR');
      const eurToGbp = FxPair(base: 'EUR', target: 'GBP');

      expect(gbpToEur, isNot(eurToGbp));
    });

    test('fxRateProvider reuses equivalent family keys', () async {
      final fxService = _FakeWalletFxService(1.17);
      final container = ProviderContainer(
        overrides: [
          walletFxServiceProvider.overrideWithValue(fxService),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(
        fxRateProvider(const FxPair(base: 'GBP', target: 'EUR')).future,
      );
      final second = await container.read(
        fxRateProvider(const FxPair(base: 'GBP', target: 'EUR')).future,
      );

      expect(first, 1.17);
      expect(second, 1.17);
      expect(fxService.callCount, 1);
    });
  });

  group('walletRepositoryProvider', () {
    test('uses in-memory repository when user is not authenticated', () {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(walletRepositoryProvider);

      expect(repository, isA<InMemoryWalletRepository>());
    });

    test('authenticated user path resolves repository provider', () {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            const AuthUser(
              uid: 'user-1',
              email: 'user@example.com',
              emailVerified: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(walletRepositoryProvider),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('walletProvider and actions', () {
    test('walletProvider returns auth error when user is not authenticated',
        () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(walletProvider.future),
        throwsA(isA<StateError>()),
      );
    });

    test('walletActions delegates to repository when authenticated', () async {
      final fakeRepository = _FakeWalletRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            const AuthUser(
              uid: 'user-1',
              email: 'user@example.com',
              emailVerified: true,
            ),
          ),
          walletRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final actions = container.read(walletActionsProvider);
      await actions.deposit(42.5, 'GBP');

      expect(actions.isAuthenticated, isTrue);
      expect(fakeRepository.depositCalled, isTrue);
      expect(fakeRepository.lastDepositWalletId, 'wallet-user-1');
      expect(fakeRepository.lastDepositAmount, 42.5);
      expect(fakeRepository.lastDepositCurrency, 'GBP');
    });

    test('walletActions throws state error when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final actions = container.read(walletActionsProvider);

      expect(actions.isAuthenticated, isFalse);
      expect(
        () => actions.deposit(10, 'GBP'),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('currency converter displays returned GBP to EUR result',
        (tester) async {
      final fakeRepository = _FakeWalletRepository();
      final fxService = _FakeWalletFxService(1.1666);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              const AuthUser(
                uid: 'user-1',
                email: 'user@example.com',
                emailVerified: true,
              ),
            ),
            walletRepositoryProvider.overrideWithValue(fakeRepository),
            walletFxServiceProvider.overrideWithValue(fxService),
          ],
          child: const MaterialApp(home: WalletPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Convert').first);
      await tester.pumpAndSettle();

      expect(find.text('Convert Currency'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '100');
      await tester.pump();

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('GBP').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Rate: 1 GBP = 1.1666 EUR'), findsOneWidget);
      expect(find.textContaining('You receive: 116.66 EUR'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
