import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/locale_cubit.dart';
import '../cubit/locale_state.dart';

/// Widget that builds UI based on current locale state
/// 基于当前语言状态构建UI的Widget
class LocaleBuilder extends StatelessWidget {
  const LocaleBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    Locale locale,
    List<Locale> supportedLocales,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final localeCubit = context.read<LocaleCubit>();
        return builder(
          context,
          state.locale,
          localeCubit.supportedLocales,
        );
      },
    );
  }
}

/// Widget that provides language switching functionality
/// 提供语言切换功能的Widget
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    super.key,
    this.showLabel = false,
    this.iconSize = 24.0,
  });

  final bool showLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
          icon: Icon(
            Icons.language,
            size: iconSize,
          ),
          tooltip: state.currentLanguage == SupportedLanguage.english
              ? '切换到中文'
              : 'Switch to English',
        );
      },
    );
  }
}

/// Widget that shows current language
/// 显示当前语言的Widget
class LanguageIndicator extends StatelessWidget {
  const LanguageIndicator({
    super.key,
    this.showFlag = true,
    this.showName = true,
  });

  final bool showFlag;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) Text(state.currentLanguage.flag),
            if (showFlag && showName) const SizedBox(width: 8),
            if (showName) Text(state.currentLanguage.name),
          ],
        );
      },
    );
  }
}

/// Widget for language selection
/// 语言选择Widget
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    this.isExpanded = false,
  });

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final localeCubit = context.read<LocaleCubit>();
        
        if (isExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.currentLanguage == SupportedLanguage.english
                    ? 'Language'
                    : '语言',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...localeCubit.availableLanguages.map(
                (language) => RadioListTile<SupportedLanguage>(
                  title: Text(language.displayName),
                  value: language,
                  groupValue: state.currentLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      localeCubit.setLanguage(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: Text(
                  state.currentLanguage == SupportedLanguage.english
                      ? 'Follow system language'
                      : '跟随系统语言',
                ),
                value: state.isSystemLocale,
                onChanged: (value) {
                  if (value == true) {
                    localeCubit.setSystemLocale();
                  } else {
                    // Keep current language but disable system following
                    localeCubit.setLanguage(state.currentLanguage);
                  }
                },
              ),
            ],
          );
        }

        return DropdownButton<SupportedLanguage>(
          value: state.currentLanguage,
          onChanged: (value) {
            if (value != null) {
              localeCubit.setLanguage(value);
            }
          },
          items: localeCubit.availableLanguages.map(
            (language) => DropdownMenuItem(
              value: language,
              child: Text(language.displayName),
            ),
          ).toList(),
        );
      },
    );
  }
}

/// Widget for quick language switching buttons
/// 快速语言切换按钮Widget
class QuickLanguageSwitcher extends StatelessWidget {
  const QuickLanguageSwitcher({
    super.key,
    this.buttonStyle,
  });

  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final localeCubit = context.read<LocaleCubit>();
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: localeCubit.isEnglish ? null : localeCubit.setEnglish,
              style: buttonStyle,
              child: Text(SupportedLanguage.english.displayName),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: localeCubit.isChinese ? null : localeCubit.setChinese,
              style: buttonStyle,
              child: Text(SupportedLanguage.chinese.displayName),
            ),
          ],
        );
      },
    );
  }
}

/// Widget that shows language status
/// 显示语言状态的Widget
class LanguageStatus extends StatelessWidget {
  const LanguageStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.currentLanguage == SupportedLanguage.english
                      ? 'Current Language Information'
                      : '当前语言信息',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      state.currentLanguage == SupportedLanguage.english
                          ? 'Language: '
                          : '语言: ',
                    ),
                    Text(
                      state.languageDisplayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      state.currentLanguage == SupportedLanguage.english
                          ? 'Code: '
                          : '代码: ',
                    ),
                    Text(
                      state.languageCode,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      state.currentLanguage == SupportedLanguage.english
                          ? 'Follow system: '
                          : '跟随系统: ',
                    ),
                    Icon(
                      state.isSystemLocale ? Icons.check : Icons.close,
                      size: 16,
                      color: state.isSystemLocale ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}