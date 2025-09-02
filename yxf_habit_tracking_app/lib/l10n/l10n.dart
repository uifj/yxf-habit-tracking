import 'package:flutter/widgets.dart';
import 'package:yxf_habit_tracking_app/l10n/arb/app_localizations.dart';

export 'package:yxf_habit_tracking_app/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
