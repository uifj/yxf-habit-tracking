part of 'theme_cubit.dart';

/// Custom theme colors configuration
/// 自定义主题颜色配置
class CustomThemeColors extends Equatable {
  const CustomThemeColors({
    this.primaryColor = const Color(0xFF13B9FF),
    this.backgroundColor = Colors.white,
    this.surfaceColor = Colors.white,
    this.appBarColor = const Color.fromARGB(255, 117, 208, 247),
  });

  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color appBarColor;

  CustomThemeColors copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? appBarColor,
  }) {
    return CustomThemeColors(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      appBarColor: appBarColor ?? this.appBarColor,
    );
  }

  @override
  List<Object> get props => [
        primaryColor,
        backgroundColor,
        surfaceColor,
        appBarColor,
      ];
}

/// Dark theme colors configuration
/// 暗色主题颜色配置
class DarkCustomThemeColors extends CustomThemeColors {
  const DarkCustomThemeColors()
      : super(
          primaryColor: const Color(0xFF13B9FF),
          backgroundColor: const Color(0xFF121212),
          surfaceColor: const Color(0xFF1E1E1E),
          appBarColor: const Color.fromARGB(255, 16, 46, 59),
        );

  @override
  CustomThemeColors copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? appBarColor,
  }) {
    return CustomThemeColors(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      appBarColor: appBarColor ?? this.appBarColor,
    );
  }
}

/// Theme state for the application
/// 应用主题状态
final class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.primaryColor = const Color(0xFF13B9FF),
    this.lightThemeColors = const CustomThemeColors(),
    this.darkThemeColors = const DarkCustomThemeColors(),
  });

  final ThemeMode themeMode;
  final Color primaryColor;
  final CustomThemeColors lightThemeColors;
  final CustomThemeColors darkThemeColors;

  /// Check if current theme is dark
  /// 检查当前是否为暗色主题
  bool get isDark => themeMode == ThemeMode.dark;

  /// Check if current theme is light
  /// 检查当前是否为亮色主题
  bool get isLight => themeMode == ThemeMode.light;

  /// Check if current theme follows system
  /// 检查当前是否跟随系统主题
  bool get isSystem => themeMode == ThemeMode.system;

  /// Get current theme colors based on theme mode
  /// 根据主题模式获取当前主题颜色
  CustomThemeColors get currentThemeColors {
    switch (themeMode) {
      case ThemeMode.light:
        return lightThemeColors;
      case ThemeMode.dark:
        return darkThemeColors;
      case ThemeMode.system:
        // In real implementation, you would check system brightness
        // 在实际实现中，你需要检查系统亮度设置
        return lightThemeColors;
    }
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    CustomThemeColors? lightThemeColors,
    CustomThemeColors? darkThemeColors,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      lightThemeColors: lightThemeColors ?? this.lightThemeColors,
      darkThemeColors: darkThemeColors ?? this.darkThemeColors,
    );
  }

  @override
  List<Object> get props => [
        themeMode,
        primaryColor,
        lightThemeColors,
        darkThemeColors,
      ];
}
