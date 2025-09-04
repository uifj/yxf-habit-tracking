// L10n module exports
// 国际化模块导出文件

// Core locale management
export 'cubit/locale_cubit.dart';
export 'cubit/locale_state.dart';

// Widgets
export 'widgets/locale_builder.dart';

// Extensions
export 'extensions/locale_extensions.dart';

// Generated localizations
export 'gen_l10n/app_localizations.dart';

// Legacy exports for backward compatibility
import 'package:flutter/widgets.dart';
import 'package:yxf_habit_tracking_app/app/l10n/gen_l10n/app_localizations.dart';

/// Legacy extension for backward compatibility
/// 向后兼容的旧版扩展
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
