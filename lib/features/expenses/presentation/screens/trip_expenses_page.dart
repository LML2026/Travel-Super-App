import 'package:flutter/material.dart';

import '../../../trips/domain/entities/trip.dart';

class TripExpensesPage extends StatelessWidget {
  const TripExpensesPage({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Budget: ${trip.currency} ${trip.budget.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Expenses tracking is the next sprint.'),
          ],
        ),
      ),
    );
  }
}
