import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

/// Cubit for managing application theme state
/// 主题管理Cubit，负责处理亮暗模式切换和自定义主题配置
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Toggle between light and dark theme modes
  /// 切换亮暗模式
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
  }

  /// Set specific theme mode
  /// 设置特定的主题模式
  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  /// Set custom primary color
  /// 设置自定义主色调
  void setPrimaryColor(Color color) {
    emit(state.copyWith(primaryColor: color));
  }

  /// Set custom colors for light theme
  /// 设置亮色主题的自定义颜色
  void setLightThemeColors({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? appBarColor,
  }) {
    final newColors = state.lightThemeColors.copyWith(
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      appBarColor: appBarColor,
    );
    emit(state.copyWith(lightThemeColors: newColors));
  }

  /// Set custom colors for dark theme
  /// 设置暗色主题的自定义颜色
  void setDarkThemeColors({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? appBarColor,
  }) {
    final newColors = state.darkThemeColors.copyWith(
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      appBarColor: appBarColor,
    );
    emit(state.copyWith(darkThemeColors: newColors));
  }

  /// Reset to default theme
  /// 重置为默认主题
  void resetToDefault() {
    emit(const ThemeState());
  }

  /// Set theme based on system settings
  /// 根据系统设置主题
  void setSystemTheme() {
    emit(state.copyWith(themeMode: ThemeMode.system));
  }
}