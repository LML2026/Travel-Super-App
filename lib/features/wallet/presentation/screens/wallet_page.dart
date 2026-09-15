import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/wallet_transaction.dart';
import '../providers/wallet_provider.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  final TextEditingController _convertAmountController =
      TextEditingController(text: '50');
  String? _fromCurrency;
  String? _toCurrency;

  @override
  void dispose() {
    _convertAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('travelWallet')),
        actions: [
          IconButton(
            tooltip: context.ui('addCurrency'),
            onPressed: () => _showAddCurrencySheet(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: walletAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(UserFacingError.message(
              error,
              fallback: 'We could not load your wallet.',
            )),
          ),
        ),
        data: (wallet) {
          final balances = wallet.balances;
          final currencies = balances.keys.toList()..sort();
          _fromCurrency ??= currencies.isNotEmpty ? currencies.first : null;
          _toCurrency ??= currencies.length > 1
              ? currencies[1]
              : (currencies.isNotEmpty ? currencies.first : null);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(walletTransactionsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WalletHeader(baseCurrency: wallet.baseCurrency),
                const SizedBox(height: 16),
                ...currencies.map(
                  (currency) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CurrencyCard(
                      currency: currency,
                      balance: balances[currency] ?? 0,
                      baseCurrency: wallet.baseCurrency,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ActionRow(
                  onReceive: () => _showDepositDialog(context),
                  onSend: () => _showSendDialog(context),
                  onConvert: currencies.length < 2
                      ? null
                      : () => _showConvertSheet(context),
                ),
                const SizedBox(height: 24),
                Text(
                  'Spending Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                transactionsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text(UserFacingError.message(
                    error,
                    fallback: 'Spending analytics are unavailable right now.',
                  )),
                  data: (transactions) => _SpendingAnalytics(
                    transactions: transactions,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                transactionsAsync.when(
                  loading: () =>
                      Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text(UserFacingError.message(
                    error,
                    fallback: 'Transactions are unavailable right now.',
                  )),
                  data: (transactions) => _TransactionList(
                    transactions: transactions,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddCurrencySheet(BuildContext context) async {
    final wallet = ref.read(walletProvider).valueOrNull;
    if (wallet == null) {
      return;
    }

    final existing = wallet.balances.keys.toSet();
    final options = kSupportedWalletCurrencies
        .where((currency) => !existing.contains(currency))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        if (options.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(24),
            child: Text(context.ui('allCurrenciesAdded')),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(context.ui('addCurrency')),
              subtitle: Text(context.ui('enableCurrencyWallet')),
            ),
            ...options.map(
              (currency) => ListTile(
                title: Text(currency),
                trailing: const Icon(Icons.add),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(walletActionsProvider).addCurrency(currency);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDepositDialog(BuildContext context) async {
    final amountController = TextEditingController(text: '100');
    final wallet = ref.read(walletProvider).valueOrNull;
    final currencies = wallet?.balances.keys.toList() ?? <String>[];
    String selected = currencies.isNotEmpty ? currencies.first : 'GBP';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.ui('receiveFunds')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected,
                items: currencies
                    .map((currency) => DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selected = value;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: context.ui('amount')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.ui('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  return;
                }
                Navigator.of(context).pop();
                await ref.read(walletActionsProvider).deposit(amount, selected);
              },
              child: Text(context.ui('receive')),
            ),
          ],
        );
      },
    );

    amountController.dispose();
  }

  Future<void> _showSendDialog(BuildContext context) async {
    final amountController = TextEditingController(text: '25');
    final destinationController =
        TextEditingController(text: 'wallet-recipient');
    final wallet = ref.read(walletProvider).valueOrNull;
    final currencies = wallet?.balances.keys.toList() ?? <String>[];
    String selected = currencies.isNotEmpty ? currencies.first : 'GBP';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.ui('sendFunds')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected,
                items: currencies
                    .map((currency) => DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selected = value;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: context.ui('amount')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destinationController,
                decoration:
                    InputDecoration(labelText: context.ui('destinationWalletId')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.ui('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                final destination = destinationController.text.trim();
                if (amount == null || amount <= 0 || destination.isEmpty) {
                  return;
                }
                Navigator.of(context).pop();
                await ref
                    .read(walletActionsProvider)
                    .transfer(amount, selected, destination);
              },
              child: Text(context.ui('send')),
            ),
          ],
        );
      },
    );

    amountController.dispose();
    destinationController.dispose();
  }

  Future<void> _showConvertSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Consumer(
                builder: (context, ref, _) {
                  final wallet = ref.watch(walletProvider).valueOrNull;
                  final currencies =
                      wallet?.balances.keys.toList() ?? <String>[];
                  if (currencies.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  _fromCurrency ??= currencies.first;
                  _toCurrency ??=
                      currencies.length > 1 ? currencies[1] : currencies.first;

                  final from = _fromCurrency!;
                  final to = _toCurrency!;
                  final amount =
                      double.tryParse(_convertAmountController.text.trim()) ??
                          0;

                  final rateAsync = from == to
                      ? const AsyncValue<double>.data(1)
                      : ref.watch(
                          fxRateProvider(FxPair(base: from, target: to)));

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.ui('convertCurrency'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: from,
                              items: currencies
                                  .map((currency) => DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => _fromCurrency = value);
                                }
                              },
                              decoration:
                                  InputDecoration(labelText: context.ui('from')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: to,
                              items: currencies
                                  .map((currency) => DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => _toCurrency = value);
                                }
                              },
                              decoration:
                                  InputDecoration(labelText: context.ui('to')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _convertAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(labelText: context.ui('amount')),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 12),
                      rateAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (error, _) => Text(UserFacingError.message(
                          error,
                          fallback: 'Exchange rate unavailable right now.',
                        )),
                        data: (rate) {
                          final converted = amount * rate;
                          return Text(
                            'Rate: 1 $from = ${rate.toStringAsFixed(4)} $to\n'
                            'You receive: ${converted.toStringAsFixed(2)} $to',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: rateAsync.value == null || amount <= 0
                              ? null
                              : () async {
                                  final rate = rateAsync.value!;
                                  Navigator.of(context).pop();
                                  await ref.read(walletActionsProvider).convert(
                                        amount: amount,
                                        from: from,
                                        to: to,
                                        rate: rate,
                                      );
                                },
                          child: Text(context.ui('convert')),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.baseCurrency});

  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.ui('fintechWallet'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${context.ui('baseCurrency')}: $baseCurrency'),
          ],
        ),
      ),
    );
  }
}

class _CurrencyCard extends ConsumerWidget {
  const _CurrencyCard({
    required this.currency,
    required this.balance,
    required this.baseCurrency,
  });

  final String currency;
  final double balance;
  final String baseCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = NumberFormat.currency(symbol: '$currency ');
    final rateAsync = currency == baseCurrency
        ? const AsyncValue<double>.data(1)
        : ref.watch(
            fxRateProvider(FxPair(base: baseCurrency, target: currency)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(currency),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currency,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(money.format(balance)),
                  const SizedBox(height: 2),
                  rateAsync.when(
                    loading: () => Text(context.ui('fetchingRate')),
                    error: (_, __) => Text(context.ui('rateUnavailable')),
                    data: (rate) => Text(
                      '1 $baseCurrency = ${rate.toStringAsFixed(4)} $currency',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onReceive,
    required this.onSend,
    required this.onConvert,
  });

  final VoidCallback onReceive;
  final VoidCallback onSend;
  final VoidCallback? onConvert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onReceive,
            icon: const Icon(Icons.call_received),
            label: Text(context.ui('receive')),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.call_made),
            label: Text(context.ui('send')),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: onConvert,
            icon: const Icon(Icons.currency_exchange),
            label: Text(context.ui('convert')),
          ),
        ),
      ],
    );
  }
}

class _SpendingAnalytics extends StatelessWidget {
  const _SpendingAnalytics({required this.transactions});

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final outboundByCurrency = <String, double>{};
    for (final tx in transactions) {
      final isSpend = tx.type == WalletTransactionType.transferOut ||
          tx.type == WalletTransactionType.currencyConversion;
      if (!isSpend) {
        continue;
      }
      outboundByCurrency[tx.currency] =
          (outboundByCurrency[tx.currency] ?? 0) + tx.amount;
    }

    if (outboundByCurrency.isEmpty) {
      return Text(context.ui('noSpendingActivity'));
    }

    final rows = outboundByCurrency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: rows
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(entry.value.toStringAsFixed(2)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Text(context.ui('noTransactions'));
    }

    final formatter = DateFormat('dd MMM, HH:mm');

    return Column(
      children: transactions
          .take(20)
          .map(
            (tx) => Card(
              child: ListTile(
                leading: Icon(_iconFor(tx.type)),
                title: Text(tx.description ?? _labelFor(tx.type)),
                subtitle: Text(
                  '${tx.currency} ${tx.amount.toStringAsFixed(2)} • ${formatter.format(tx.createdAt)}',
                ),
                trailing: Text(tx.status.name),
              ),
            ),
          )
          .toList(),
    );
  }

  static String _labelFor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.deposit:
        return 'Deposit';
      case WalletTransactionType.transferIn:
        return 'Transfer In';
      case WalletTransactionType.transferOut:
        return 'Transfer Out';
      case WalletTransactionType.currencyConversion:
        return 'Currency Conversion';
    }
  }

  static IconData _iconFor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.deposit:
        return Icons.south_west;
      case WalletTransactionType.transferIn:
        return Icons.call_received;
      case WalletTransactionType.transferOut:
        return Icons.call_made;
      case WalletTransactionType.currencyConversion:
        return Icons.currency_exchange;
    }
  }
}
