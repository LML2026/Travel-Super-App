import 'package:flutter/widgets.dart';

import 'auth_service.dart';

class AuthServiceScope extends InheritedWidget {
  final AuthService service;

  const AuthServiceScope({
    super.key,
    required this.service,
    required super.child,
  });

  static AuthService of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AuthServiceScope>();
    assert(scope != null, 'AuthServiceScope is missing from the widget tree.');
    return scope!.service;
  }

  @override
  bool updateShouldNotify(AuthServiceScope oldWidget) =>
      service != oldWidget.service;
}
