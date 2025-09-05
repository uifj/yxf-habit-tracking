import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThemeUsageExample());
}

/// Example showing how to use the new theme management system
/// 展示如何使用新主题管理系统的示例
class ThemeUsageExample extends StatelessWidget {
  const ThemeUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: const _ThemeExampleApp(),
    );
  }
}

class _ThemeExampleApp extends StatelessWidget {
  const _ThemeExampleApp();

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, lightTheme, darkTheme, themeMode) {
        return MaterialApp(
          title: 'Theme Example',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const _HomePage(),
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题管理示例'),
        actions: const [
          ThemeSwitcher(),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThemeInfoSection(),
            SizedBox(height: 24),
            _ThemeControlsSection(),
            SizedBox(height: 24),
            _ColorDemoSection(),
            SizedBox(height: 24),
            _TextStyleDemoSection(),
          ],
        ),
      ),
    );
  }
}

class _ThemeInfoSection extends StatelessWidget {
  const _ThemeInfoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前主题信息',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text('主题模式: '),
                ThemeModeIndicator(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('是否为暗色模式: '),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return Text(state.isDark ? '是' : '否');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('主色调: '),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(context.colorScheme.primary.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeControlsSection extends StatelessWidget {
  const _ThemeControlsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题控制',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const ThemeModeSelector(isExpanded: true),
            const SizedBox(height: 16),
            Text(
              '主色调选择',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return ColorPicker(
                  currentColor: state.primaryColor,
                  onColorChanged: (color) {
                    context.read<ThemeCubit>().setPrimaryColor(color);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.read<ThemeCubit>().resetToDefault(),
                  child: const Text('重置主题'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.read<ThemeCubit>().setSystemTheme(),
                  child: const Text('跟随系统'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDemoSection extends StatelessWidget {
  const _ColorDemoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '颜色演示',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChip('Primary', context.colorScheme.primary),
                _ColorChip('Secondary', context.colorScheme.secondary),
                _ColorChip('Surface', context.colorScheme.surface),
                _ColorChip('Background', context.colorScheme.surface),
                _ColorChip('Error', context.colorScheme.error),
                const _ColorChip('Success', Colors.green),
                const _ColorChip('Warning', Colors.orange),
                const _ColorChip('Info', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color,
      label: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

class _TextStyleDemoSection extends StatelessWidget {
  const _TextStyleDemoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文本样式演示',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Display Large', style: context.textTheme.displayLarge),
            Text('Headline Large', style: context.textTheme.headlineLarge),
            Text('Title Large', style: context.textTheme.titleLarge),
            Text('Body Large', style: context.textTheme.bodyLarge),
            Text('Label Large', style: context.textTheme.labelLarge),
            Text('Caption Style', style: context.textTheme.bodySmall),
            Text('Overline Style', style: context.textTheme.labelSmall),
            Text('Button Style', style: context.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

/// Example of how to integrate with existing app
/// 如何与现有应用集成的示例
class AppWithThemeManagement extends StatelessWidget {
  const AppWithThemeManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add ThemeCubit to your existing providers
        // 将 ThemeCubit 添加到现有的 providers 中
        BlocProvider(
          create: (context) => ThemeCubit()
            ..setSystemTheme() // Initialize with system theme
            ..setPrimaryColor(
                const Color(0xFF13B9FF)), // Set default primary color
        ),
        // ... other providers
      ],
      child: ThemeBuilder(
        builder: (context, lightTheme, darkTheme, themeMode) {
          return MaterialApp(
            title: 'Your App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
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
