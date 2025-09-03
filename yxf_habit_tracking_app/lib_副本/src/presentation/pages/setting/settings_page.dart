import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';

/// 设置页面
/// 支持多平台：iOS、Android、macOS、Windows
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends TencentCloudChatState<SettingsPage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoSave = true;
  String _selectedLanguage = 'zh';
  String _selectedTheme = 'system';
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: 从本地存储加载设置
    // 这里使用默认值
    safeSetState(() {});
  }

  void _saveSettings() {
    // TODO: 保存设置到本地存储
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, colorTheme, textStyle),
              Expanded(
                child: _buildContent(context, colorTheme, textStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            '设置',
            style: TextStyle(
              fontSize: textStyle.fontsize_20,
              fontWeight: FontWeight.bold,
              color: colorTheme.onBackground,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: textStyle.fontsize_16,
                color: colorTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 外观设置
          _buildSectionTitle('外观', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildThemeSelector(colorTheme, textStyle),
          const SizedBox(height: 16),
          _buildFontSizeSlider(colorTheme, textStyle),
          const SizedBox(height: 24),

          // 语言设置
          _buildSectionTitle('语言', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildLanguageSelector(colorTheme, textStyle),
          const SizedBox(height: 24),

          // 练习设置
          _buildSectionTitle('练习设置', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildSwitchTile(
            '自动保存进度',
            '练习过程中自动保存进度',
            _autoSave,
            (value) => safeSetState(() => _autoSave = value),
            colorTheme,
            textStyle,
          ),
          const SizedBox(height: 24),

          // 音效设置
          _buildSectionTitle('音效与反馈', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildSwitchTile(
            '音效',
            '启用按键音效',
            _soundEnabled,
            (value) => safeSetState(() => _soundEnabled = value),
            colorTheme,
            textStyle,
          ),
          _buildSwitchTile(
            '震动反馈',
            '错误时震动提醒（仅移动端）',
            _vibrationEnabled,
            (value) => safeSetState(() => _vibrationEnabled = value),
            colorTheme,
            textStyle,
          ),
          const SizedBox(height: 24),

          // 数据管理
          _buildSectionTitle('数据管理', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildActionTile(
            '导出数据',
            '导出学习记录和统计数据',
            Icons.download,
            () => _exportData(),
            colorTheme,
            textStyle,
          ),
          _buildActionTile(
            '清除数据',
            '清除所有学习记录（不可恢复）',
            Icons.delete_forever,
            () => _showClearDataDialog(context, colorTheme, textStyle),
            colorTheme,
            textStyle,
            isDestructive: true,
          ),
          const SizedBox(height: 24),

          // 关于
          _buildSectionTitle('关于', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildActionTile(
            '版本信息',
            'v1.0.0',
            Icons.info_outline,
            () => _showAboutDialog(context, colorTheme, textStyle),
            colorTheme,
            textStyle,
          ),
          _buildActionTile(
            '开源许可',
            '查看开源许可证',
            Icons.code,
            () => _showLicenseDialog(context),
            colorTheme,
            textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Text(
      title,
      style: TextStyle(
        fontSize: textStyle.fontsize_18,
        fontWeight: FontWeight.bold,
        color: colorTheme.onBackground,
      ),
    );
  }

  Widget _buildThemeSelector(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题模式',
              style: TextStyle(
                fontSize: textStyle.fontsize_16,
                fontWeight: FontWeight.w500,
                color: colorTheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    '跟随系统',
                    'system',
                    Icons.brightness_auto,
                    colorTheme,
                    textStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    '浅色',
                    'light',
                    Icons.brightness_7,
                    colorTheme,
                    textStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    '深色',
                    'dark',
                    Icons.brightness_2,
                    colorTheme,
                    textStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String value,
    IconData icon,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    final isSelected = _selectedTheme == value;

    return GestureDetector(
      onTap: () => safeSetState(() => _selectedTheme = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorTheme.primaryColor
                : colorTheme.onBackground.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorTheme.primaryColor
                  : colorTheme.onBackground,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: textStyle.fontsize_12,
                color: isSelected
                    ? colorTheme.primaryColor
                    : colorTheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '字体大小',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_16,
                    fontWeight: FontWeight.w500,
                    color: colorTheme.onBackground,
                  ),
                ),
                Text(
                  '${_fontSize.toInt()}px',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_14,
                    color: colorTheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              activeColor: colorTheme.primaryColor,
              onChanged: (value) => safeSetState(() => _fontSize = value),
            ),
            Text(
              '示例文本 Example Text',
              style: TextStyle(
                fontSize: _fontSize,
                color: colorTheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    final languages = [
      {'code': 'zh', 'name': '中文'},
      {'code': 'en', 'name': 'English'},
    ];

    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: Column(
        children: languages.map((lang) {
          final isSelected = _selectedLanguage == lang['code'];

          return ListTile(
            title: Text(
              lang['name']!,
              style: TextStyle(
                fontSize: textStyle.fontsize_16,
                color: colorTheme.onBackground,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    color: colorTheme.primaryColor,
                  )
                : null,
            onTap: () => safeSetState(() => _selectedLanguage = lang['code']!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            color: colorTheme.onBackground,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: textStyle.fontsize_14,
            color: colorTheme.onBackground.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colorTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle, {
    bool isDestructive = false,
  }) {
    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : colorTheme.onBackground,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            color: isDestructive ? Colors.red : colorTheme.onBackground,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: textStyle.fontsize_14,
            color: colorTheme.onBackground.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _exportData() {
    // TODO: 实现数据导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能开发中...')),
    );
  }

  void _showClearDataDialog(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorTheme.backgroundColor,
        title: Text(
          '清除数据',
          style: TextStyle(
            color: colorTheme.onBackground,
            fontSize: textStyle.fontsize_18,
          ),
        ),
        content: Text(
          '确定要清除所有学习记录吗？此操作不可恢复。',
          style: TextStyle(
            color: colorTheme.onBackground,
            fontSize: textStyle.fontsize_14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: colorTheme.onBackground,
                fontSize: textStyle.fontsize_14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现清除数据功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清除')),
              );
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: Colors.red,
                fontSize: textStyle.fontsize_14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorTheme.backgroundColor,
        title: Text(
          'Qwerty Learner',
          style: TextStyle(
            color: colorTheme.onBackground,
            fontSize: textStyle.fontsize_18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本：v1.0.0',
              style: TextStyle(
                color: colorTheme.onBackground,
                fontSize: textStyle.fontsize_14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '一个简洁的英语单词打字练习应用',
              style: TextStyle(
                color: colorTheme.onBackground,
                fontSize: textStyle.fontsize_14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '基于 Flutter 开发，支持多平台',
              style: TextStyle(
                color: colorTheme.onBackground,
                fontSize: textStyle.fontsize_14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '确定',
              style: TextStyle(
                color: colorTheme.primaryColor,
                fontSize: textStyle.fontsize_14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Qwerty Learner',
      applicationVersion: 'v1.0.0',
    );
  }

  @override
  Widget? mobileBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget? desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: Row(
          children: [
            // 侧边栏（桌面端）
            Container(
              width: 300,
              color: colorTheme.desktopBackgroundColorLinearGradientOne,
              child: Column(
                children: [
                  _buildHeader(context, colorTheme, textStyle),
                  Expanded(
                    child: _buildDesktopSidebar(context, colorTheme, textStyle),
                  ),
                ],
              ),
            ),
            // 主内容区域
            Expanded(
              child: _buildContent(context, colorTheme, textStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    final sections = [
      {'title': '外观', 'icon': Icons.palette},
      {'title': '语言', 'icon': Icons.language},
      {'title': '练习设置', 'icon': Icons.settings},
      {'title': '音效与反馈', 'icon': Icons.volume_up},
      {'title': '数据管理', 'icon': Icons.storage},
      {'title': '关于', 'icon': Icons.info},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置分类',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map((section) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: 滚动到对应部分
                  },
                  icon: Icon(
                    section['icon'] as IconData,
                    color: colorTheme.onBackground,
                    size: 20,
                  ),
                  label: Text(
                    section['title'] as String,
                    style: TextStyle(
                      color: colorTheme.onBackground,
                      fontSize: textStyle.fontsize_14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
