import 'package:flutter/material.dart';

import '../theme/app_radii.dart';

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
