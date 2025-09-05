import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_state.dart';

/// Cubit for managing application locale
/// 管理应用语言的Cubit
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({
    LocaleConfig config = LocaleConfig.defaultConfig,
  })  : _config = config,
        super(const LocaleState());

  final LocaleConfig _config;

  /// Get current locale configuration
  /// 获取当前语言配置
  LocaleConfig get config => _config;

  /// Set specific language
  /// 设置特定语言
  void setLanguage(SupportedLanguage language) {
    if (_config.supportedLanguages.contains(language)) {
      emit(state.copyWith(
        currentLanguage: language,
        isSystemLocale: false,
      ));
    }
  }

  /// Set language by code
  /// 根据代码设置语言
  void setLanguageByCode(String languageCode) {
    final language = _config.getLanguageByCode(languageCode);
    setLanguage(language);
  }

  /// Toggle between supported languages
  /// 在支持的语言间切换
  void toggleLanguage() {
    final currentIndex =
        _config.supportedLanguages.indexOf(state.currentLanguage);
    final nextIndex = (currentIndex + 1) % _config.supportedLanguages.length;
    final nextLanguage = _config.supportedLanguages[nextIndex];
    setLanguage(nextLanguage);
  }

  /// Set to follow system locale
  /// 设置跟随系统语言
  void setSystemLocale() {
    final systemLocale = _getSystemLocale();
    final systemLanguage = _getLanguageFromLocale(systemLocale);

    emit(state.copyWith(
      currentLanguage: systemLanguage,
      isSystemLocale: true,
    ));
  }

  /// Set to English
  /// 设置为英语
  void setEnglish() {
    setLanguage(SupportedLanguage.english);
  }

  /// Set to Chinese
  /// 设置为中文
  void setChinese() {
    setLanguage(SupportedLanguage.chinese);
  }

  /// Reset to default language
  /// 重置为默认语言
  void resetToDefault() {
    emit(LocaleState(
      currentLanguage: _config.fallbackLanguage,
      isSystemLocale: false,
    ));
  }

  /// Initialize with system locale
  /// 使用系统语言初始化
  void initializeWithSystemLocale() {
    final systemLocale = _getSystemLocale();
    final systemLanguage = _getLanguageFromLocale(systemLocale);

    emit(LocaleState(
      currentLanguage: systemLanguage,
      isSystemLocale: true,
    ));
  }

  /// Initialize with specific language
  /// 使用特定语言初始化
  void initializeWithLanguage(SupportedLanguage language) {
    emit(LocaleState(
      currentLanguage: language,
      isSystemLocale: false,
    ));
  }

  /// Get system locale
  /// 获取系统语言环境
  Locale _getSystemLocale() {
    final systemLocales = ui.PlatformDispatcher.instance.locales;
    if (systemLocales.isNotEmpty) {
      return systemLocales.first;
    }
    return const Locale('en'); // Fallback to English
  }

  /// Get supported language from locale
  /// 从语言环境获取支持的语言
  SupportedLanguage _getLanguageFromLocale(Locale locale) {
    // First try exact match
    for (final language in _config.supportedLanguages) {
      if (language.code == locale.languageCode) {
        return language;
      }
    }

    // If no exact match, return fallback
    return _config.fallbackLanguage;
  }

  /// Check if current language is English
  /// 检查当前语言是否为英语
  bool get isEnglish => state.currentLanguage == SupportedLanguage.english;

  /// Check if current language is Chinese
  /// 检查当前语言是否为中文
  bool get isChinese => state.currentLanguage == SupportedLanguage.chinese;

  /// Get available languages for switching
  /// 获取可切换的语言列表
  List<SupportedLanguage> get availableLanguages => _config.supportedLanguages;

  /// Get current locale for MaterialApp
  /// 获取MaterialApp使用的当前语言环境
  Locale get currentLocale => state.locale;

  /// Get supported locales for MaterialApp
  /// 获取MaterialApp使用的支持语言环境列表
  List<Locale> get supportedLocales => _config.supportedLocales;
}

/// Extension methods for LocaleCubit
/// LocaleCubit的扩展方法
extension LocaleCubitX on LocaleCubit {
  /// Quick access to current language code
  /// 快速访问当前语言代码
  String get languageCode => state.languageCode;

  /// Quick access to current language name
  /// 快速访问当前语言名称
  String get languageName => state.languageName;

  /// Quick access to current language display name
  /// 快速访问当前语言显示名称
  String get languageDisplayName => state.languageDisplayName;
}
