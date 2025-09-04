import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../theme_factory.dart';
import '../extensions/theme_extensions.dart';

/// Widget that builds UI based on current theme state
/// 基于当前主题状态构建UI的Widget
class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    ThemeData lightTheme,
    ThemeData darkTheme,
    ThemeMode themeMode,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final lightTheme = AppThemeFactory.createLightTheme(
          colors: state.lightThemeColors,
          primaryColor: state.primaryColor,
        );

        final darkTheme = AppThemeFactory.createDarkTheme(
          colors: state.darkThemeColors,
          primaryColor: state.primaryColor,
        );

        return builder(
          context,
          lightTheme,
          darkTheme,
          state.themeMode,
        );
      },
    );
  }
}

/// Widget that provides theme switching functionality
/// 提供主题切换功能的Widget
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({
    super.key,
    this.showLabel = true,
    this.iconSize = 24.0,
  });

  final bool showLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => context.toggleTheme(),
          icon: Icon(
            state.isDark ? Icons.light_mode : Icons.dark_mode,
            size: iconSize,
          ),
          tooltip: state.isDark ? '切换到亮色模式' : '切换到暗色模式',
        );
      },
    );
  }
}

/// Widget that shows current theme mode
/// 显示当前主题模式的Widget
class ThemeModeIndicator extends StatelessWidget {
  const ThemeModeIndicator({
    super.key,
    this.showIcon = true,
    this.showText = true,
  });

  final bool showIcon;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        IconData icon;
        String text;

        switch (state.themeMode) {
          case ThemeMode.light:
            icon = Icons.light_mode;
            text = '亮色模式';
            break;
          case ThemeMode.dark:
            icon = Icons.dark_mode;
            text = '暗色模式';
            break;
          case ThemeMode.system:
            icon = Icons.brightness_auto;
            text = '跟随系统';
            break;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) Icon(icon),
            if (showIcon && showText) const SizedBox(width: 8),
            if (showText) Text(text),
          ],
        );
      },
    );
  }
}

/// Widget for theme mode selection
/// 主题模式选择Widget
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    this.isExpanded = false,
  });

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        if (isExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '主题模式',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...ThemeMode.values.map(
                (mode) => RadioListTile<ThemeMode>(
                  title: Text(_getThemeModeText(mode)),
                  value: mode,
                  groupValue: state.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.setThemeMode(value);
                    }
                  },
                ),
              ),
            ],
          );
        }

        return DropdownButton<ThemeMode>(
          value: state.themeMode,
          onChanged: (value) {
            if (value != null) {
              context.setThemeMode(value);
            }
          },
          items: ThemeMode.values
              .map(
                (mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(_getThemeModeText(mode)),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '亮色模式';
      case ThemeMode.dark:
        return '暗色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
}

/// Widget for color picker
/// 颜色选择器Widget
class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
    this.colors = const [
      Color(0xFF13B9FF),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFF44336),
      Color(0xFF9C27B0),
      Color(0xFF607D8B),
      Color(0xFF795548),
    ],
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors
          .map(
            (color) => GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: currentColor == color
                      ? Border.all(
                          color: context.colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: currentColor == color
                    ? Icon(
                        Icons.check,
                        color: color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
