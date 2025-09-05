import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yxf_habit_tracking_app/app/l10n/l10n.dart';

class LocalePage extends StatelessWidget {
  const LocalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.todosOverviewAppBarTitle),
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LanguageInfoSection(),
            SizedBox(height: 24),
            _LanguageControlsSection(),
            SizedBox(height: 24),
            _LocalizedContentSection(),
            SizedBox(height: 24),
            _QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}

class _LanguageInfoSection extends StatelessWidget {
  const _LanguageInfoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isEnglish ? 'Current Language Information' : '当前语言信息',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  context.isEnglish ? 'Language: ' : '语言: ',
                ),
                const LanguageIndicator(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  context.isEnglish ? 'Code: ' : '代码: ',
                ),
                Text(
                  context.languageCode,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  context.isEnglish ? 'Follow system: ' : '跟随系统: ',
                ),
                Icon(
                  context.isSystemLocale ? Icons.check : Icons.close,
                  size: 16,
                  color: context.isSystemLocale ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageControlsSection extends StatelessWidget {
  const _LanguageControlsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isEnglish ? 'Language Controls' : '语言控制',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const LanguageSelector(isExpanded: true),
            const SizedBox(height: 16),
            Text(
              context.isEnglish ? 'Quick Switch' : '快速切换',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const QuickLanguageSwitcher(),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.resetLanguage(),
                  child: Text(
                    context.isEnglish ? 'Reset Language' : '重置语言',
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.setSystemLocale(),
                  child: Text(
                    context.isEnglish ? 'Follow System' : '跟随系统',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalizedContentSection extends StatelessWidget {
  const _LocalizedContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isEnglish ? 'Localized Content Demo' : '本地化内容演示',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _LocalizedTextItem(
              label: context.isEnglish ? 'App Title' : '应用标题',
              value: context.l10n.todosOverviewAppBarTitle,
            ),
            _LocalizedTextItem(
              label: context.isEnglish ? 'Filter Tooltip' : '筛选提示',
              value: context.l10n.todosOverviewFilterTooltip,
            ),
            _LocalizedTextItem(
              label: context.isEnglish ? 'All Filter' : '全部筛选',
              value: context.l10n.todosOverviewFilterAll,
            ),
            _LocalizedTextItem(
              label: context.isEnglish ? 'Active Only' : '仅活跃',
              value: context.l10n.todosOverviewFilterActiveOnly,
            ),
            _LocalizedTextItem(
              label: context.isEnglish ? 'Completed Only' : '仅已完成',
              value: context.l10n.todosOverviewFilterCompletedOnly,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalizedTextItem extends StatelessWidget {
  const _LocalizedTextItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isEnglish ? 'Quick Actions' : '快速操作',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.language, size: 18),
                  label: Text(
                    context.isEnglish ? 'Toggle Language' : '切换语言',
                  ),
                  onPressed: () => context.toggleLanguage(),
                ),
                ActionChip(
                  avatar: Text(SupportedLanguage.english.flag),
                  label: const Text('English'),
                  onPressed:
                      context.isEnglish ? null : () => context.setEnglish(),
                ),
                ActionChip(
                  avatar: Text(SupportedLanguage.chinese.flag),
                  label: const Text('中文'),
                  onPressed:
                      context.isChinese ? null : () => context.setChinese(),
                ),
                ActionChip(
                  avatar: const Icon(Icons.settings_backup_restore, size: 18),
                  label: Text(
                    context.isEnglish ? 'System Default' : '系统默认',
                  ),
                  onPressed: () => context.setSystemLocale(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to integrate with existing app
/// 如何与现有应用集成的示例
class AppWithLocaleManagement extends StatelessWidget {
  const AppWithLocaleManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add LocaleCubit to your existing providers
        // 将 LocaleCubit 添加到现有的 providers 中
        BlocProvider(
          create: (context) => LocaleCubit()
            ..initializeWithSystemLocale(), // Initialize with system locale
        ),
        // ... other providers
      ],
      child: LocaleBuilder(
        builder: (context, locale, supportedLocales) {
          return MaterialApp(
            title: 'Your App',
            locale: locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // ... rest of your app configuration
            home: const Scaffold(
              body: Center(
                child: Text('Your App Content'),
              ),
            ),
          );
        },
      ),
    );
  }
}
