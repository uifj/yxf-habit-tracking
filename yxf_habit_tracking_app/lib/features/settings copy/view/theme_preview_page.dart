import 'package:flutter/material.dart';
import '../../../app/theme/extensions/theme_extensions.dart';

/// Theme demonstration page
/// 主题演示页面
class ThemeDemoPage extends StatelessWidget {
  const ThemeDemoPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ThemeDemoPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('企业红色主题演示'),
        actions: [
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Toggle theme through theme cubit
              // This would need to be implemented based on your theme management
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Palette Section
            _buildSectionTitle(context, '颜色调色板'),
            _buildColorPalette(context),
            const SizedBox(height: 24),

            // Buttons Section
            _buildSectionTitle(context, '按钮样式'),
            _buildButtonsSection(context),
            const SizedBox(height: 24),

            // Cards Section
            _buildSectionTitle(context, '卡片样式'),
            _buildCardsSection(context),
            const SizedBox(height: 24),

            // Text Styles Section
            _buildSectionTitle(context, '文本样式'),
            _buildTextStylesSection(context),
            const SizedBox(height: 24),

            // Form Elements Section
            _buildSectionTitle(context, '表单元素'),
            _buildFormSection(context),
            const SizedBox(height: 24),

            // Status Colors Section
            _buildSectionTitle(context, '状态颜色'),
            _buildStatusColorsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: context.textTheme.headlineSmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    final colors = [
      ('主色', context.colorScheme.primary),
      ('主色变体', context.colorScheme.primaryVariant),
      ('次要色', context.colorScheme.secondary),
      ('次要色变体', context.colorScheme.secondaryVariant),
      ('背景色', context.colorScheme.surface),
      ('表面色', context.colorScheme.surfaceContainerHighest),
      ('错误色', context.colorScheme.error),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorInfo) {
        return Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: colorInfo.$2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                colorInfo.$1,
                style: context.textTheme.bodySmall?.copyWith(
                  color: _getContrastColor(colorInfo.$2),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '#${colorInfo.$2.value.toRadixString(16).substring(2).toUpperCase()}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: _getContrastColor(colorInfo.$2),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('主要按钮'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('轮廓按钮'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: const Text('文本按钮'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('填充按钮'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '标准卡片',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '这是一个使用企业红色主题的标准卡片示例。',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户信息卡片',
                        style: context.textTheme.titleMedium,
                      ),
                      Text(
                        '展示用户相关信息',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextStylesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('标题大', style: context.textTheme.headlineLarge),
        Text('标题中', style: context.textTheme.headlineMedium),
        Text('标题小', style: context.textTheme.headlineSmall),
        Text('正文大', style: context.textTheme.bodyLarge),
        Text('正文中', style: context.textTheme.bodyMedium),
        Text('正文小', style: context.textTheme.bodySmall),
        Text('标签大', style: context.textTheme.labelLarge),
        Text('标签中', style: context.textTheme.labelMedium),
        Text('标签小', style: context.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: '用户名',
            hintText: '请输入用户名',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: '密码',
            hintText: '请输入密码',
            prefixIcon: Icon(Icons.lock),
            suffixIcon: Icon(Icons.visibility),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('启用通知'),
          subtitle: const Text('接收应用通知'),
          value: true,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          title: const Text('同意用户协议'),
          subtitle: const Text('阅读并同意用户服务协议'),
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildStatusColorsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.success,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '成功',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.warning,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '警告',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '错误',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.info,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '信息',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use light or dark text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
