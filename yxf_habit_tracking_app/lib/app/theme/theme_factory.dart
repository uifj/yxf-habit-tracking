import 'package:flutter/material.dart';
import 'models/theme_models.dart';
import 'cubit/theme_cubit.dart';

/// Factory class for creating theme configurations
/// 主题配置工厂类
class AppThemeFactory {
  AppThemeFactory._();

  /// Create light theme data
  /// 创建亮色主题数据
  static ThemeData createLightTheme({
    CustomThemeColors? colors,
    Color? primaryColor,
  }) {
    final themeColors = colors ?? const CustomThemeColors();
    final seedColor = primaryColor ?? themeColors.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: themeColors.backgroundColor,
      cardTheme: CardTheme(
        color: themeColors.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  /// Create dark theme data
  /// 创建暗色主题数据
  static ThemeData createDarkTheme({
    CustomThemeColors? colors,
    Color? primaryColor,
  }) {
    final themeColors = colors ?? const DarkCustomThemeColors();
    final seedColor = primaryColor ?? themeColors.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: themeColors.backgroundColor,
      cardTheme: CardTheme(
        color: themeColors.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[800],
      ),
    );
  }

  /// Create theme configuration from theme state
  /// 从主题状态创建主题配置
  static AppThemeConfig createThemeConfig(ThemeState state) {
    return AppThemeConfig(
      lightTheme: createLightTheme(
        colors: state.lightThemeColors,
        primaryColor: state.primaryColor,
      ),
      darkTheme: createDarkTheme(
        colors: state.darkThemeColors,
        primaryColor: state.primaryColor,
      ),
      themeMode: state.themeMode,
    );
  }

  /// Create default light theme
  /// 创建默认亮色主题
  static ThemeData get defaultLight => createLightTheme();

  /// Create default dark theme
  /// 创建默认暗色主题
  static ThemeData get defaultDark => createDarkTheme();

  /// Create theme data based on brightness
  /// 根据亮度创建主题数据
  static ThemeData createThemeByBrightness(
    Brightness brightness, {
    CustomThemeColors? lightColors,
    CustomThemeColors? darkColors,
    Color? primaryColor,
  }) {
    return brightness == Brightness.light
        ? createLightTheme(
            colors: lightColors,
            primaryColor: primaryColor,
          )
        : createDarkTheme(
            colors: darkColors,
            primaryColor: primaryColor,
          );
  }

  /// Get theme colors based on brightness
  /// 根据亮度获取主题颜色
  static AppColorPalette getColorPalette(Brightness brightness) {
    return brightness == Brightness.light
        ? AppColorPalette.light
        : AppColorPalette.dark;
  }
}
