import 'package:flutter/material.dart';

import 'responsive_container.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.maxContentWidth = 720,
    this.bodyPadding = const EdgeInsets.all(24),
    this.resizeToAvoidBottomInset,
    this.useSafeArea = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final double maxContentWidth;
  final EdgeInsetsGeometry bodyPadding;
  final bool? resizeToAvoidBottomInset;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = ResponsiveContainer(
      maxWidth: maxContentWidth,
      padding: bodyPadding,
      child: body,
    );

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}
