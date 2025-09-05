import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Theme configuration model
/// 主题配置模型
class AppThemeConfig extends Equatable {
  const AppThemeConfig({
    required this.lightTheme,
    required this.darkTheme,
    this.themeMode = ThemeMode.system,
  });

  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  /// Get current theme data based on theme mode and brightness
  /// 根据主题模式和亮度获取当前主题数据
  ThemeData getCurrentTheme(Brightness? systemBrightness) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  AppThemeConfig copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
  }) {
    return AppThemeConfig(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [lightTheme, darkTheme, themeMode];
}

/// Color palette for the application
/// 应用颜色调色板
class AppColorPalette extends Equatable {
  const AppColorPalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
  });

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color onError;

  /// Light color palette
  /// 亮色调色板
  static const AppColorPalette light = AppColorPalette(
    primary: Color(0xFF13B9FF),
    secondary: Color(0xFF75D0F7),
    background: Colors.white,
    surface: Colors.white,
    error: Color(0xFFB00020),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
  );

  /// Dark color palette
  /// 暗色调色板
  static const AppColorPalette dark = AppColorPalette(
    primary: Color(0xFF13B9FF),
    secondary: Color(0xFF102E3B),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
  );

  /// Convert to Flutter ColorScheme
  /// 转换为Flutter ColorScheme
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
    );
  }

  @override
  List<Object> get props => [
        primary,
        secondary,
        background,
        surface,
        error,
        onPrimary,
        onSecondary,
        onBackground,
        onSurface,
        onError,
      ];
}

/// Text theme configuration
/// 文本主题配置
class AppTextTheme extends Equatable {
  const AppTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// Convert to Flutter TextTheme
  /// 转换为Flutter TextTheme
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  @override
  List<Object> get props => [
        displayLarge,
        displayMedium,
        displaySmall,
        headlineLarge,
        headlineMedium,
        headlineSmall,
        titleLarge,
        titleMedium,
        titleSmall,
        bodyLarge,
        bodyMedium,
        bodySmall,
        labelLarge,
        labelMedium,
        labelSmall,
      ];
}
