import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String ui(String key) => l10n.uiText('k_$key');
}
