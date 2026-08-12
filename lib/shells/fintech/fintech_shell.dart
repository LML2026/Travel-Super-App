import 'package:flutter/material.dart';

class FintechShell extends StatelessWidget {
  const FintechShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ITAREVO FINANCE'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 72),
            SizedBox(height: 20),
            Text(
              'Fintech',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Wallet • Payments • Exchange • Cards • Transactions'),
          ],
        ),
      ),
    );
  }
}

