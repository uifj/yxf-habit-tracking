import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:hunnu_auth/hunnu_auth.dart';
import 'theme_preview_page.dart';
import 'locale_page.dart';
import 'theme_page.dart';
import '../cubit/settings_cubit.dart';
// import 'profile_page.dart';
import 'account_settings_page.dart';
import 'privacy_settings_page.dart';
import 'about_page.dart';

/// 现代化设置页面
/// 整合了用户资料、账户设置、隐私设置等功能
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends TencentCloudChatState<SettingsPage> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        authenticationRepository: context.read<AuthenticationRepository>(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('设置'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildUserSection(context, state),
                  const SizedBox(height: 16),
                  _buildAccountSection(context),
                  const SizedBox(height: 16),
                  _buildAppearanceSection(context),
                  const SizedBox(height: 16),
                  _buildPrivacySection(context),
                  const SizedBox(height: 16),
                  _buildAboutSection(context),
                  const SizedBox(height: 16),
                  _buildLogoutSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 用户信息区块
  // Widget _buildUserSection(BuildContext context, SettingsState state) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.all(16),
  //       leading: CircleAvatar(
  //         radius: 30,
  //         backgroundColor: Theme.of(context).colorScheme.primary,
  //         child: state.user.isNotEmpty
  //             ? Text(
  //                 state.user.name?.substring(0, 1) ?? 'U',
  //                 style: TextStyle(
  //                   color: Theme.of(context).colorScheme.onPrimary,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               )
  //             : const Icon(Icons.person, color: Colors.white),
  //       ),
  //       title: Text(
  //         state.user.name ?? '未登录',
  //         style: const TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       subtitle: Text(
  //         state.user.phone ?? '点击查看个人资料',
  //         style: TextStyle(
  //           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  //         ),
  //       ),
  //       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  //       onTap: () {
  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (context) => const ProfilePage(),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  /// 账户设置区块
  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      context,
      title: '账户设置',
      items: [
        // _SettingItem(
        //   icon: Icons.person_outline,
        //   title: '个人资料',
        //   subtitle: '编辑个人信息',
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => const ProfilePage(),
        //       ),
        //     );
        //   },
        // ),
        _SettingItem(
          icon: Icons.security_outlined,
          title: '账户安全',
          subtitle: '密码、手机号设置',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountSettingsPage(),
              ),
            );
          },
        ),
        _SettingItem(
          icon: Icons.home_outlined,
          title: '自定义首页',
          subtitle: '个性化首页布局',
          onTap: () {
            // TODO: 实现自定义首页功能
          },
        ),
      ],
    );
  }

  /// 外观设置区块
  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSection(
      context,
      title: '外观设置',
      items: [
        _SettingItem(
          icon: Icons.palette_outlined,
          title: '主题设置',
          subtitle: '切换深色/浅色主题',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemePage(),
              ),
            );
          },
        ),
        _SettingItem(
          icon: Icons.language_outlined,
          title: '语言设置',
          subtitle: '切换应用语言',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LocalePage(),
              ),
            );
          },
        ),
        _SettingItem(
          icon: Icons.preview_outlined,
          title: '主题预览',
          subtitle: '查看主题效果',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemeDemoPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 隐私设置区块
  Widget _buildPrivacySection(BuildContext context) {
    return _buildSection(
      context,
      title: '隐私与安全',
      items: [
        _SettingItem(
          icon: Icons.privacy_tip_outlined,
          title: '隐私设置',
          subtitle: '管理隐私权限',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacySettingsPage(),
              ),
            );
          },
        ),
        _SettingItem(
          icon: Icons.notifications_outlined,
          title: '通知设置',
          subtitle: '管理推送通知',
          onTap: () {
            // TODO: 实现通知设置
          },
        ),
        _SettingItem(
          icon: Icons.storage_outlined,
          title: '存储管理',
          subtitle: '清理缓存数据',
          onTap: () {
            _showClearCacheDialog(context);
          },
        ),
      ],
    );
  }

  /// 关于区块
  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      title: '关于',
      items: [
        _SettingItem(
          icon: Icons.info_outline,
          title: '关于应用',
          subtitle: '版本信息与帮助',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
          },
        ),
        _SettingItem(
          icon: Icons.feedback_outlined,
          title: '意见反馈',
          subtitle: '帮助我们改进',
          onTap: () {
            // TODO: 实现意见反馈
          },
        ),
      ],
    );
  }

  /// 退出登录区块
  Widget _buildLogoutSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          '退出登录',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => _showLogoutDialog(context),
      ),
    );
  }

  /// 构建设置区块
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children:
                items.map((item) => _buildSettingTile(context, item)).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建设置项
  Widget _buildSettingTile(BuildContext context, _SettingItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: item.onTap,
    );
  }

  /// 显示清理缓存对话框
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除临时文件和图片缓存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsCubit>().clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清理')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsCubit>().logout();
            },
            child: Text(
              '退出',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置项数据类
class _SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
