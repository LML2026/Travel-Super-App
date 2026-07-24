import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Flights', Icons.flight_takeoff),
      ('Hotels', Icons.hotel),
      ('Maps', Icons.map),
      ('Weather', Icons.wb_sunny),
      ('AI Assistant', Icons.smart_toy),
      ('Translator', Icons.translate),
      ('Expenses', Icons.account_balance_wallet),
      ('Profile', Icons.person),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Super App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return Card(
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.$1} coming soon!'),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$2,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
