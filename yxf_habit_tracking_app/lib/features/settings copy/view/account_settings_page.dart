import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';

/// 账户设置页面
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const AccountSettingsPage());
  }

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState
    extends TencentCloudChatState<AccountSettingsPage> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('账户安全'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecuritySection(context),
            const SizedBox(height: 24),
            _buildBindingSection(context),
            const SizedBox(height: 24),
            _buildPrivacySection(context),
          ],
        ),
      ),
    );
  }

  /// 构建安全设置区块
  Widget _buildSecuritySection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '安全设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('修改密码'),
            subtitle: const Text('定期更换密码，保护账户安全'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.fingerprint,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('生物识别'),
            subtitle: const Text('指纹或面容识别登录'),
            trailing: Switch(
              value: false, // TODO: 从状态获取
              onChanged: (value) {
                // TODO: 实现生物识别开关
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('两步验证'),
            subtitle: const Text('为账户添加额外安全保护'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 实现两步验证设置
            },
          ),
        ],
      ),
    );
  }

  /// 构建绑定设置区块
  Widget _buildBindingSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '账户绑定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('手机号码'),
            subtitle: const Text('138****8888'), // TODO: 从用户信息获取
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePhoneDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.email_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('邮箱地址'),
            subtitle: const Text('user@example.com'), // TODO: 从用户信息获取
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangeEmailDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.wechat,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('微信绑定'),
            subtitle: const Text('未绑定'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 实现微信绑定
            },
          ),
        ],
      ),
    );
  }

  /// 构建隐私设置区块
  Widget _buildPrivacySection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '隐私保护',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.visibility_off_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('隐私模式'),
            subtitle: const Text('隐藏个人信息显示'),
            trailing: Switch(
              value: false, // TODO: 从状态获取
              onChanged: (value) {
                // TODO: 实现隐私模式开关
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('登录记录'),
            subtitle: const Text('查看最近登录记录'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 显示登录记录
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              '注销账户',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            subtitle: const Text('永久删除账户和所有数据'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  /// 显示修改密码对话框
  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '当前密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                border: OutlineInputBorder(),
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
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('两次输入的密码不一致')),
                );
                return;
              }
              Navigator.pop(context);
              // TODO: 实现密码修改逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('密码修改成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示修改手机号对话框
  void _showChangePhoneDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改手机号'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '新手机号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 发送验证码
                  },
                  child: const Text('发送'),
                ),
              ],
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
              Navigator.pop(context);
              // TODO: 实现手机号修改逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('手机号修改成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示修改邮箱对话框
  void _showChangeEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改邮箱'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '新邮箱地址',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 发送验证码
                  },
                  child: const Text('发送'),
                ),
              ],
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
              Navigator.pop(context);
              // TODO: 实现邮箱修改逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('邮箱修改成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示注销账户对话框
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '注销账户',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: const Text(
          '注销账户将永久删除您的所有数据，包括个人信息、聊天记录等，此操作不可恢复。\n\n确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现账户注销逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('账户注销申请已提交，将在7个工作日内处理'),
                ),
              );
            },
            child: Text(
              '确定注销',
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
