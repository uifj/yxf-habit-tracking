import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import 'package:tencent_cloud_chat_demo/src/presentation/pages/typing/typing_test_page.dart';
import 'typing/gallery_page.dart';
import 'typing/typing_page.dart';
import 'typing/type_analysis_page.dart';
import 'setting/settings_page.dart';
import 'tools/tools_page.dart';
import '../../../common/widgets/background/animated_background.dart';

/// 主应用页面
/// 支持多平台：iOS、Android、macOS、Windows
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends TencentCloudChatState<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GalleryPage(),
    // const TypingPage(),
    // const TypingTestPage(),
    const AnalysisPage(),
    const ToolsPage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.library_books,
      label: '词典',
      route: '/gallery',
    ),
    // const NavigationItem(
    //   icon: Icons.keyboard,
    //   label: '练习',
    //   route: '/typing',
    // ),
    // const NavigationItem(
    //   icon: Icons.keyboard,
    //   label: '测试',
    //   route: '/typingTest',
    // ),
    const NavigationItem(
      icon: Icons.analytics,
      label: '分析',
      route: '/analysis',
    ),
    const NavigationItem(
      icon: Icons.build,
      label: '工具',
      route: '/tools',
    ),
    const NavigationItem(
      icon: Icons.settings,
      label: '设置',
      route: '/settings',
    ),
  ];

  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) {
        // 判断是否为暗色模式
        final isDarkMode = Theme.of(context).brightness == Brightness.dark ||
            colorTheme.backgroundColor.computeLuminance() < 0.5;

        return AnimatedBackground(
          isDarkMode: isDarkMode,
          child: Scaffold(
            backgroundColor: Colors.transparent, // 使背景透明以显示动画背景
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar:
                _buildBottomNavigationBar(colorTheme, textStyle),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => safeSetState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorTheme.backgroundColor,
      selectedItemColor: colorTheme.primaryColor,
      unselectedItemColor: colorTheme.onBackground.withOpacity(0.6),
      selectedLabelStyle: TextStyle(
        fontSize: textStyle.fontsize_12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: textStyle.fontsize_12,
      ),
      items: _navigationItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }

  @override
  Widget? mobileBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget? desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) {
        // 判断是否为暗色模式
        final isDarkMode = Theme.of(context).brightness == Brightness.dark ||
            colorTheme.backgroundColor.computeLuminance() < 0.5;

        return AnimatedBackground(
          isDarkMode: isDarkMode,
          child: Scaffold(
            backgroundColor: Colors.transparent, // 使背景透明以显示动画背景
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                // 左侧导航栏（桌面端）
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: colorTheme.desktopBackgroundColorLinearGradientOne
                        .withOpacity(0.9), // 添加透明度以显示背景动画
                  ),
                  child: _buildSideNavigationBar(colorTheme, textStyle),
                ),
                // 主内容区域
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNavigationBar(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Column(
      children: [
        // 应用标题
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qwerty Learner',
                    style: TextStyle(
                      fontSize: textStyle.fontsize_18,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.onBackground,
                    ),
                  ),
                  Text(
                    '英语打字练习',
                    style: TextStyle(
                      fontSize: textStyle.fontsize_12,
                      color: colorTheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 导航菜单
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => safeSetState(() => _currentIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorTheme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color:
                                      colorTheme.primaryColor.withOpacity(0.3),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? colorTheme.primaryColor
                                  : colorTheme.onBackground.withOpacity(0.7),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: textStyle.fontsize_16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorTheme.primaryColor
                                    : colorTheme.onBackground.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 底部信息
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Divider(
                color: colorTheme.onBackground.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colorTheme.primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: colorTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '学习者',
                          style: TextStyle(
                            fontSize: textStyle.fontsize_14,
                            fontWeight: FontWeight.w500,
                            color: colorTheme.onBackground,
                          ),
                        ),
                        Text(
                          '继续加油！',
                          style: TextStyle(
                            fontSize: textStyle.fontsize_12,
                            color: colorTheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 导航项数据类
class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
