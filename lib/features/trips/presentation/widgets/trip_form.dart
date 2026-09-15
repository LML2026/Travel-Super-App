import 'package:flutter/material.dart';

import '../../../../core/constants/supported_currencies.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TripForm extends StatelessWidget {
  const TripForm({
    super.key,
    required this.destinationController,
    required this.budgetController,
    required this.notesController,
    required this.currency,
    required this.travellers,
    required this.onCurrencyChanged,
    required this.onTravellersChanged,
    this.onSubmit,
    this.submitLabel = 'Save Trip',
  });

  final TextEditingController destinationController;
  final TextEditingController budgetController;
  final TextEditingController notesController;
  final String currency;
  final int travellers;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<int> onTravellersChanged;
  final VoidCallback? onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: destinationController,
          decoration: InputDecoration(labelText: context.ui('destination')),
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter destination' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: context.ui('budget')),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter budget';
            }
            if (double.tryParse(value) == null) {
              return 'Invalid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: currency,
          decoration: InputDecoration(labelText: context.ui('currency')),
          items: kSupportedTravelCurrencies
              .map(
                (currency) => DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                ),
              )
              .toList(growable: false),
          onChanged: onCurrencyChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(context.ui('travellers'), style: TextStyle(fontSize: 16)),
            const Spacer(),
            IconButton(
              onPressed: () {
                if (travellers > 1) {
                  onTravellersChanged(travellers - 1);
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$travellers', style: const TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () => onTravellersChanged(travellers + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          maxLines: 4,
          decoration: InputDecoration(labelText: context.ui('notes')),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text(submitLabel),
        ),
      ],
    );
  }
}
