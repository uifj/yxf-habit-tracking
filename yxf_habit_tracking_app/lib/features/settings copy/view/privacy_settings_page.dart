import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';

/// 隐私设置页面
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PrivacySettingsPage());
  }

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState
    extends TencentCloudChatState<PrivacySettingsPage> {
  bool _allowFriendRequests = true;
  bool _allowGroupInvites = true;
  bool _showOnlineStatus = true;
  bool _allowSearchByPhone = false;
  bool _allowSearchByEmail = false;
  bool _dataCollection = true;
  bool _personalizedAds = false;
  bool _locationSharing = false;

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('隐私设置'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactPrivacySection(context),
            const SizedBox(height: 24),
            _buildDiscoverabilitySection(context),
            const SizedBox(height: 24),
            _buildDataPrivacySection(context),
            const SizedBox(height: 24),
            _buildLocationSection(context),
            const SizedBox(height: 24),
            _buildBlockedUsersSection(context),
          ],
        ),
      ),
    );
  }

  /// 构建联系人隐私区块
  Widget _buildContactPrivacySection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '联系人隐私',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.person_add_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('允许好友申请'),
            subtitle: const Text('其他用户可以向您发送好友申请'),
            value: _allowFriendRequests,
            onChanged: (value) {
              setState(() {
                _allowFriendRequests = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.group_add_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('允许群组邀请'),
            subtitle: const Text('其他用户可以邀请您加入群组'),
            value: _allowGroupInvites,
            onChanged: (value) {
              setState(() {
                _allowGroupInvites = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.circle,
              color: _showOnlineStatus
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
            ),
            title: const Text('显示在线状态'),
            subtitle: const Text('让其他用户看到您的在线状态'),
            value: _showOnlineStatus,
            onChanged: (value) {
              setState(() {
                _showOnlineStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 构建可发现性设置区块
  Widget _buildDiscoverabilitySection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '可发现性',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('通过手机号搜索'),
            subtitle: const Text('允许其他用户通过手机号找到您'),
            value: _allowSearchByPhone,
            onChanged: (value) {
              setState(() {
                _allowSearchByPhone = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.email_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('通过邮箱搜索'),
            subtitle: const Text('允许其他用户通过邮箱找到您'),
            value: _allowSearchByEmail,
            onChanged: (value) {
              setState(() {
                _allowSearchByEmail = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 构建数据隐私区块
  Widget _buildDataPrivacySection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '数据隐私',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('数据收集'),
            subtitle: const Text('允许收集使用数据以改善服务'),
            value: _dataCollection,
            onChanged: (value) {
              setState(() {
                _dataCollection = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.ads_click_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('个性化广告'),
            subtitle: const Text('基于您的兴趣显示相关广告'),
            value: _personalizedAds,
            onChanged: (value) {
              setState(() {
                _personalizedAds = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.download_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('下载我的数据'),
            subtitle: const Text('获取您在平台上的所有数据副本'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showDownloadDataDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.policy_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('隐私政策'),
            subtitle: const Text('查看我们的隐私政策'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 打开隐私政策页面
            },
          ),
        ],
      ),
    );
  }

  /// 构建位置设置区块
  Widget _buildLocationSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '位置信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('位置共享'),
            subtitle: const Text('允许应用访问您的位置信息'),
            value: _locationSharing,
            onChanged: (value) {
              setState(() {
                _locationSharing = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.history_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('位置历史'),
            subtitle: const Text('管理您的位置历史记录'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 打开位置历史页面
            },
          ),
        ],
      ),
    );
  }

  /// 构建黑名单区块
  Widget _buildBlockedUsersSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '黑名单管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.block_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('已屏蔽用户'),
            subtitle: const Text('管理您屏蔽的用户列表'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showBlockedUsersPage(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.report_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('举报记录'),
            subtitle: const Text('查看您的举报历史'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 打开举报记录页面
            },
          ),
        ],
      ),
    );
  }

  /// 显示下载数据对话框
  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('下载我的数据'),
        content: const Text(
          '我们将为您准备一份包含您所有数据的文件。准备完成后，我们会通过邮件通知您下载链接。\n\n此过程可能需要几个工作日。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现数据下载请求
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('数据下载请求已提交，我们会尽快处理'),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示黑名单用户页面
  void _showBlockedUsersPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '已屏蔽用户',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: 3, // TODO: 从状态获取实际数量
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text('U${index + 1}'),
                      ),
                      title: Text('用户${index + 1}'),
                      subtitle: Text('屏蔽时间：2024-01-${15 + index}'),
                      trailing: TextButton(
                        onPressed: () {
                          // TODO: 实现解除屏蔽
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已解除对用户${index + 1}的屏蔽'),
                            ),
                          );
                        },
                        child: const Text('解除屏蔽'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
