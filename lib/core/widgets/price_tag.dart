import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.currency,
    required this.amount,
    this.suffix,
  });

  final String currency;
  final double amount;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final value = '$currency ${amount.toStringAsFixed(0)}';
    return Text(
      suffix == null ? value : '$value $suffix',
      style: AppTextStyles.price,
    );
  }
}
