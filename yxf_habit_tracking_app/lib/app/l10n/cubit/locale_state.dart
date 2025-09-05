import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Supported languages in the application
/// 应用支持的语言
enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  chinese('zh', '中文', '🇨🇳');

  const SupportedLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  /// Convert language code to SupportedLanguage
  /// 将语言代码转换为SupportedLanguage
  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }

  /// Get Locale object
  /// 获取Locale对象
  Locale get locale => Locale(code);

  /// Get display name with flag
  /// 获取带国旗的显示名称
  String get displayName => '$flag $name';
}

/// Locale state for the application
/// 应用的语言状态
class LocaleState extends Equatable {
  const LocaleState({
    this.currentLanguage = SupportedLanguage.english,
    this.isSystemLocale = true,
  });

  /// Current selected language
  /// 当前选择的语言
  final SupportedLanguage currentLanguage;

  /// Whether to follow system locale
  /// 是否跟随系统语言
  final bool isSystemLocale;

  /// Get current locale
  /// 获取当前语言环境
  Locale get locale => currentLanguage.locale;

  /// Get language code
  /// 获取语言代码
  String get languageCode => currentLanguage.code;

  /// Get language name
  /// 获取语言名称
  String get languageName => currentLanguage.name;

  /// Get language display name with flag
  /// 获取带国旗的语言显示名称
  String get languageDisplayName => currentLanguage.displayName;

  /// Copy with new values
  /// 复制并更新值
  LocaleState copyWith({
    SupportedLanguage? currentLanguage,
    bool? isSystemLocale,
  }) {
    return LocaleState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isSystemLocale: isSystemLocale ?? this.isSystemLocale,
    );
  }

  @override
  List<Object?> get props => [currentLanguage, isSystemLocale];

  @override
  String toString() {
    return 'LocaleState(currentLanguage: $currentLanguage, isSystemLocale: $isSystemLocale)';
  }
}

/// Locale configuration model
/// 语言配置模型
class LocaleConfig {
  const LocaleConfig({
    required this.supportedLanguages,
    required this.fallbackLanguage,
  });

  /// List of supported languages
  /// 支持的语言列表
  final List<SupportedLanguage> supportedLanguages;

  /// Fallback language when system locale is not supported
  /// 系统语言不支持时的回退语言
  final SupportedLanguage fallbackLanguage;

  /// Default configuration
  /// 默认配置
  static const LocaleConfig defaultConfig = LocaleConfig(
    supportedLanguages: SupportedLanguage.values,
    fallbackLanguage: SupportedLanguage.english,
  );

  /// Get supported locales
  /// 获取支持的语言环境列表
  List<Locale> get supportedLocales {
    return supportedLanguages.map((lang) => lang.locale).toList();
  }

  /// Check if a language is supported
  /// 检查是否支持某种语言
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.any((lang) => lang.code == languageCode);
  }

  /// Get language by code, return fallback if not found
  /// 根据代码获取语言，未找到时返回回退语言
  SupportedLanguage getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => fallbackLanguage,
    );
  }
}