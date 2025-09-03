import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'version_service.dart';

/// 应用更新服务
/// 负责检查更新、下载更新、安装更新等功能
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  static UpdateService get instance => _instance;

  UpdateService._internal();

  final VersionService _versionService = VersionService.instance;

  /// 检查应用更新
  /// [showDialog] 是否显示更新对话框
  /// [context] 上下文，用于显示对话框
  Future<bool> checkForUpdates({
    bool showDialog = true,
    BuildContext? context,
  }) async {
    try {
      debugPrint('开始检查应用更新');

      final updateInfo = await _versionService.checkForUpdates();

      if (updateInfo == null) {
        debugPrint('当前已是最新版本');
        if (showDialog && context != null) {
          _showNoUpdateDialog(context);
        }
        return false;
      }

      debugPrint('发现新版本: ${updateInfo.version}');

      if (showDialog && context != null) {
        _showUpdateDialog(context, updateInfo);
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('检查更新失败: $e');
      if (showDialog && context != null) {
        _showErrorDialog(context, '检查更新失败: $e');
        debugPrint('检查更新失败栈Trace: $stackTrace');
      }
      return false;
    }
  }

  /// 显示无更新对话框
  void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('检查更新'),
        content: Text('当前已是最新版本 ${_versionService.displayVersion}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示更新对话框
  void _showUpdateDialog(BuildContext context, VersionUpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最新版本: ${updateInfo.version}'),
            Text('当前版本: ${_versionService.currentVersion}'),
            const SizedBox(height: 8),
            const Text('更新内容:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(updateInfo.description),
            if (updateInfo.isForceUpdate)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '此版本为强制更新',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          if (!updateInfo.isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后更新'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadUpdate(updateInfo);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 下载更新
  Future<void> _downloadUpdate(VersionUpdateInfo updateInfo) async {
    try {
      debugPrint('开始下载更新: ${updateInfo.downloadUrl}');

      if (Platform.isAndroid) {
        // Android平台直接打开下载链接
        await _launchUrl(updateInfo.downloadUrl);
      } else if (Platform.isIOS) {
        // iOS平台跳转到App Store
        await _launchAppStore();
      } else {
        // 其他平台打开下载链接
        await _launchUrl(updateInfo.downloadUrl);
      }
    } catch (e, stackTrace) {
      debugPrint('下载更新失败: $e');
      debugPrint('下载更新失败栈Trace: $stackTrace');
    }
  }

  /// 启动URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('无法打开链接: $url');
    }
  }

  /// 跳转到App Store
  Future<void> _launchAppStore() async {
    // TODO: 替换为实际的App Store链接
    const appStoreUrl = 'https://apps.apple.com/app/id123456789';
    await _launchUrl(appStoreUrl);
  }

  /// 静默检查更新（后台检查）
  Future<bool> silentCheckForUpdates() async {
    return await checkForUpdates(showDialog: false);
  }

  /// 获取更新配置
  Map<String, dynamic> getUpdateConfig() {
    return {
      'currentVersion': _versionService.currentVersion,
      'currentBuildNumber': _versionService.currentBuildNumber,
      'packageName': _versionService.packageName,
      'platform': Platform.operatingSystem,
      'versionHeaders': _versionService.getVersionHeaders(),
    };
  }
}
