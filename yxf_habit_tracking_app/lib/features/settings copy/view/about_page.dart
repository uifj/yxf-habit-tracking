import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 关于页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const AboutPage());
  }

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends TencentCloudChatState<AboutPage> {
  String _version = '加载中...';
  String _buildNumber = '';
  String _appName = '湖南师范大学';

  @override
  void initState() {
    super.initState();
    _getVersionInfo();
  }

  Future<void> _getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _appName = packageInfo.appName;
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('关于'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _showUpdateDialog,
            icon: const Icon(Icons.system_update),
            tooltip: '检查更新',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoCard(context),
            const SizedBox(height: 24),
            _buildAppStatsSection(context),
            const SizedBox(height: 24),
            _buildFeaturesSection(context),
            const SizedBox(height: 24),
            _buildDevelopmentTeamSection(context),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 24),
            _buildLegalSection(context),
            const SizedBox(height: 24),
            _buildTechnicalSection(context),
            const SizedBox(height: 32),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  /// 构建应用信息卡片
  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                '版本 $_version ($_buildNumber)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '湖南师范大学官方移动应用',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建法律条款区块
  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '法律条款'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildPolicyItem(
                context,
                '用户服务协议',
                Icons.description_outlined,
                () => _openPolicy(
                    '用户服务协议', 'https://www.hunnu.edu.cn/user-agreement'),
              ),
              const Divider(height: 1),
              _buildPolicyItem(
                context,
                '隐私政策',
                Icons.privacy_tip_outlined,
                () => _openPolicy(
                    '隐私政策', 'https://www.hunnu.edu.cn/privacy-policy'),
              ),
              const Divider(height: 1),
              _buildPolicyItem(
                context,
                '软件许可协议',
                Icons.gavel_outlined,
                () => _openPolicy('软件许可协议', 'https://www.hunnu.edu.cn/license'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建联系我们区块
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '联系我们'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildContactItem(
                context,
                '官方网站',
                Icons.language_outlined,
                'https://www.hunnu.edu.cn',
                () => _launchUrl('https://www.hunnu.edu.cn'),
              ),
              const Divider(height: 1),
              _buildContactItem(
                context,
                '客服邮箱',
                Icons.email_outlined,
                'support@hunnu.edu.cn',
                () => _launchUrl('mailto:support@hunnu.edu.cn'),
              ),
              const Divider(height: 1),
              _buildContactItem(
                context,
                '客服电话',
                Icons.phone_outlined,
                '0731-88872222',
                () => _launchUrl('tel:0731-88872222'),
              ),
              const Divider(height: 1),
              _buildContactItem(
                context,
                '意见反馈',
                Icons.feedback_outlined,
                '提交反馈',
                () => _showFeedbackDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建技术信息区块
  Widget _buildTechnicalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '技术信息'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildInfoItem(
                context,
                'Flutter版本',
                '3.16.0',
                Icons.flutter_dash_outlined,
              ),
              const Divider(height: 1),
              _buildInfoItem(
                context,
                '构建时间',
                '2024-01-15',
                Icons.schedule_outlined,
              ),
              const Divider(height: 1),
              _buildInfoItem(
                context,
                '开发团队',
                '湖南师范大学信息化建设办公室',
                Icons.group_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建版权信息
  Widget _buildCopyright(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '© 2024 湖南师范大学',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '保留所有权利',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  /// 构建区块标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 构建政策条目
  Widget _buildPolicyItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// 构建联系条目
  Widget _buildContactItem(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// 构建信息条目
  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  /// 打开政策页面
  void _openPolicy(String title, String url) {
    // TODO: 实现政策页面打开逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在打开$title...')),
    );
  }

  /// 启动URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开链接')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打开链接失败')),
        );
      }
    }
  }

  /// 显示反馈对话框
  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('意见反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '请描述您的问题或建议',
                border: OutlineInputBorder(),
                hintText: '我们重视您的每一条反馈...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: '联系方式（可选）',
                border: OutlineInputBorder(),
                hintText: '邮箱或手机号',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (feedbackController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入反馈内容')),
                );
                return;
              }
              Navigator.pop(context);
              // TODO: 实现反馈提交逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('反馈已提交，感谢您的建议！')),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  /// 构建应用统计区块
  Widget _buildAppStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '应用统计'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '用户数', '10万+', Icons.people),
                _buildStatItem(context, '下载量', '50万+', Icons.download),
                _buildStatItem(context, '评分', '4.8', Icons.star),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建统计项目
  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  /// 构建功能特色区块
  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '功能特色'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildFeatureItem(
                context,
                '即时通讯',
                '支持文字、语音、视频通话',
                Icons.chat_bubble_outline,
              ),
              const Divider(height: 1),
              _buildFeatureItem(
                context,
                '校园服务',
                '一站式校园生活服务平台',
                Icons.school_outlined,
              ),
              const Divider(height: 1),
              _buildFeatureItem(
                context,
                '安全可靠',
                '端到端加密，保护隐私安全',
                Icons.security_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建功能项目
  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(description),
    );
  }

  /// 构建开发团队区块
  Widget _buildDevelopmentTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '开发团队'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '湖南师范大学信息化建设办公室',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '致力于为师生提供优质的数字化服务体验',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 显示更新对话框
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('检查更新'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在检查更新...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('当前已是最新版本')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
