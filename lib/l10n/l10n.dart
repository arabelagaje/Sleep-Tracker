import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

// Short access to the app's text in the current language: context.l10n.save
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
