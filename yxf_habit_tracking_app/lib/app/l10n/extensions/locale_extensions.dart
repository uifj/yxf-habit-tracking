import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/locale_cubit.dart';
import '../cubit/locale_state.dart';
import '../gen_l10n/app_localizations.dart';

/// Extensions for BuildContext to access locale functionality
/// BuildContext的扩展，用于访问语言功能
extension LocaleContextExtensions on BuildContext {
  /// Get LocaleCubit instance
  /// 获取LocaleCubit实例
  LocaleCubit get localeCubit => read<LocaleCubit>();

  /// Get current LocaleState
  /// 获取当前LocaleState
  LocaleState get localeState => read<LocaleCubit>().state;

  /// Get current locale
  /// 获取当前语言环境
  Locale get currentLocale => localeState.locale;

  /// Get current language code
  /// 获取当前语言代码
  String get languageCode => localeState.languageCode;

  /// Get current language name
  /// 获取当前语言名称
  String get languageName => localeState.languageName;

  /// Get current language display name
  /// 获取当前语言显示名称
  String get languageDisplayName => localeState.languageDisplayName;

  /// Check if current language is English
  /// 检查当前语言是否为英语
  bool get isEnglish => localeCubit.isEnglish;

  /// Check if current language is Chinese
  /// 检查当前语言是否为中文
  bool get isChinese => localeCubit.isChinese;

  /// Check if following system locale
  /// 检查是否跟随系统语言
  bool get isSystemLocale => localeState.isSystemLocale;

  /// Get localized strings
  /// 获取本地化字符串
  AppLocalizations get localizations => AppLocalizations.of(this);
}

/// Extensions for BuildContext to control locale
/// BuildContext的扩展，用于控制语言
extension LocaleControlExtensions on BuildContext {
  /// Set specific language
  /// 设置特定语言
  void setLanguage(SupportedLanguage language) {
    localeCubit.setLanguage(language);
  }

  /// Set language by code
  /// 根据代码设置语言
  void setLanguageByCode(String languageCode) {
    localeCubit.setLanguageByCode(languageCode);
  }

  /// Toggle between supported languages
  /// 在支持的语言间切换
  void toggleLanguage() {
    localeCubit.toggleLanguage();
  }

  /// Set to follow system locale
  /// 设置跟随系统语言
  void setSystemLocale() {
    localeCubit.setSystemLocale();
  }

  /// Set to English
  /// 设置为英语
  void setEnglish() {
    localeCubit.setEnglish();
  }

  /// Set to Chinese
  /// 设置为中文
  void setChinese() {
    localeCubit.setChinese();
  }

  /// Reset to default language
  /// 重置为默认语言
  void resetLanguage() {
    localeCubit.resetToDefault();
  }
}

/// Extensions for Locale
/// Locale的扩展
extension LocaleExtensions on Locale {
  /// Check if this locale is supported
  /// 检查此语言环境是否受支持
  bool get isSupported {
    return SupportedLanguage.values.any((lang) => lang.code == languageCode);
  }

  /// Get SupportedLanguage from this locale
  /// 从此语言环境获取SupportedLanguage
  SupportedLanguage? get supportedLanguage {
    try {
      return SupportedLanguage.fromCode(languageCode);
    } catch (e) {
      return null;
    }
  }

  /// Get display name for this locale
  /// 获取此语言环境的显示名称
  String get displayName {
    final supported = supportedLanguage;
    if (supported != null) {
      return supported.displayName;
    }
    return languageCode.toUpperCase();
  }

  /// Check if this is English locale
  /// 检查是否为英语环境
  bool get isEnglish => languageCode == 'en';

  /// Check if this is Chinese locale
  /// 检查是否为中文环境
  bool get isChinese => languageCode == 'zh';
}

/// Extensions for SupportedLanguage
/// SupportedLanguage的扩展
extension SupportedLanguageExtensions on SupportedLanguage {
  /// Check if this is the current language
  /// 检查是否为当前语言
  bool isCurrent(BuildContext context) {
    return context.localeState.currentLanguage == this;
  }

  /// Set this language as current
  /// 将此语言设置为当前语言
  void setAsCurrent(BuildContext context) {
    context.setLanguage(this);
  }

  /// Get localized name based on current locale
  /// 根据当前语言环境获取本地化名称
  String getLocalizedName(BuildContext context) {
    if (context.isChinese) {
      switch (this) {
        case SupportedLanguage.english:
          return '英语';
        case SupportedLanguage.chinese:
          return '中文';
      }
    }
    return name; // Return English name as default
  }
}

/// Utility class for locale operations
/// 语言操作工具类
class LocaleUtils {
  LocaleUtils._();

  /// Get system locale
  /// 获取系统语言环境
  static Locale getSystemLocale() {
    return Locale(
        WidgetsBinding.instance.platformDispatcher.locale.languageCode);
  }

  /// Check if a locale is RTL (Right-to-Left)
  /// 检查语言环境是否为从右到左
  static bool isRTL(Locale locale) {
    // Add RTL language codes here if needed
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode);
  }

  /// Get text direction for a locale
  /// 获取语言环境的文本方向
  static TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Format locale for display
  /// 格式化语言环境用于显示
  static String formatLocaleForDisplay(Locale locale) {
    final supported = SupportedLanguage.values
        .where((lang) => lang.code == locale.languageCode)
        .firstOrNull;

    if (supported != null) {
      return supported.displayName;
    }

    return '${locale.languageCode.toUpperCase()}${locale.countryCode != null ? ' (${locale.countryCode})' : ''}';
  }

  /// Get available locales
  /// 获取可用的语言环境
  static List<Locale> getAvailableLocales() {
    return SupportedLanguage.values.map((lang) => lang.locale).toList();
  }

  /// Parse locale from string
  /// 从字符串解析语言环境
  static Locale? parseLocale(String localeString) {
    try {
      final parts = localeString.split('_');
      if (parts.length == 1) {
        return Locale(parts[0]);
      } else if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Convert locale to string
  /// 将语言环境转换为字符串
  static String localeToString(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}
