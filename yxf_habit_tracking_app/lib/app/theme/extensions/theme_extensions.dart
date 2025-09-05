import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';

/// Extension on BuildContext for easy theme access
/// BuildContext的主题扩展，便于访问主题
extension ThemeExtension on BuildContext {
  /// Get current theme data
  /// 获取当前主题数据
  ThemeData get theme => Theme.of(this);

  /// Get current color scheme
  /// 获取当前颜色方案
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get current text theme
  /// 获取当前文本主题
  TextTheme get textTheme => theme.textTheme;

  /// Check if current theme is dark
  /// 检查当前是否为暗色主题
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if current theme is light
  /// 检查当前是否为亮色主题
  bool get isLightMode => theme.brightness == Brightness.light;

  /// Get theme cubit
  /// 获取主题Cubit
  ThemeCubit get themeCubit => read<ThemeCubit>();

  /// Get theme state
  /// 获取主题状态
  ThemeState get themeState => watch<ThemeCubit>().state;

  /// Toggle theme mode
  /// 切换主题模式
  void toggleTheme() => themeCubit.toggleTheme();

  /// Set specific theme mode
  /// 设置特定主题模式
  void setThemeMode(ThemeMode mode) => themeCubit.setThemeMode(mode);
}

/// Extension on ThemeData for additional utilities
/// ThemeData的扩展工具
extension ThemeDataExtension on ThemeData {
  /// Get primary container color with fallback
  /// 获取主容器颜色（带回退）
  Color get primaryContainer {
    return colorScheme.primaryContainer;
  }

  /// Get surface variant color with fallback
  /// 获取表面变体颜色（带回退）
  Color get surfaceVariant {
    return colorScheme.surfaceContainerHighest;
  }

  /// Get outline color with fallback
  /// 获取轮廓颜色（带回退）
  Color get outline {
    return colorScheme.outline;
  }

  /// Check if this is a dark theme
  /// 检查是否为暗色主题
  bool get isDark => brightness == Brightness.dark;

  /// Check if this is a light theme
  /// 检查是否为亮色主题
  bool get isLight => brightness == Brightness.light;
}

/// Extension on ColorScheme for additional colors
/// ColorScheme的扩展颜色
extension ColorSchemeExtension on ColorScheme {
  /// Get success color
  /// 获取成功颜色
  Color get success => const Color(0xFF4CAF50);

  /// Get warning color
  /// 获取警告颜色
  Color get warning => const Color(0xFFFF9800);

  /// Get info color
  /// 获取信息颜色
  Color get info => const Color(0xFF2196F3);

  /// Get disabled color
  /// 获取禁用颜色
  Color get disabled => onSurface.withOpacity(0.38);

  /// Get divider color
  /// 获取分割线颜色
  Color get divider => onSurface.withOpacity(0.12);

  /// Get shadow color
  /// 获取阴影颜色
  Color get shadow => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.5)
      : Colors.black.withOpacity(0.2);
}

/// Extension on TextTheme for additional text styles
/// TextTheme的扩展文本样式
extension TextThemeExtension on TextTheme {
  /// Get caption text style (deprecated in Material 3, but useful)
  /// 获取说明文字样式（Material 3中已弃用，但仍有用）
  TextStyle? get caption => bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  /// Get overline text style (deprecated in Material 3, but useful)
  /// 获取上划线文字样式（Material 3中已弃用，但仍有用）
  TextStyle? get overline => labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      );

  /// Get button text style
  /// 获取按钮文字样式
  TextStyle? get button => labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      );
}

/// Utility class for theme-related constants
/// 主题相关常量工具类
class ThemeConstants {
  ThemeConstants._();

  /// Default border radius
  /// 默认边框圆角
  static const double defaultBorderRadius = 8.0;

  /// Large border radius
  /// 大边框圆角
  static const double largeBorderRadius = 16.0;

  /// Small border radius
  /// 小边框圆角
  static const double smallBorderRadius = 4.0;

  /// Default padding
  /// 默认内边距
  static const double defaultPadding = 16.0;

  /// Large padding
  /// 大内边距
  static const double largePadding = 24.0;

  /// Small padding
  /// 小内边距
  static const double smallPadding = 8.0;

  /// Default elevation
  /// 默认阴影高度
  static const double defaultElevation = 2.0;

  /// Large elevation
  /// 大阴影高度
  static const double largeElevation = 8.0;

  /// Animation duration
  /// 动画持续时间
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Fast animation duration
  /// 快速动画持续时间
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Slow animation duration
  /// 慢速动画持续时间
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
}
