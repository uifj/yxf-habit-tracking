import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app_version.dart';

/// 版本更新信息模型
class VersionUpdateInfo {
  final String version;
  final String buildNumber;
  final String description;
  final bool isForceUpdate;
  final String downloadUrl;
  final DateTime releaseDate;

  const VersionUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.description,
    required this.isForceUpdate,
    required this.downloadUrl,
    required this.releaseDate,
  });

  factory VersionUpdateInfo.fromJson(Map<String, dynamic> json) {
    return VersionUpdateInfo(
      version: json['version'] ?? '',
      buildNumber: json['buildNumber'] ?? '',
      description: json['description'] ?? '',
      isForceUpdate: json['isForceUpdate'] ?? false,
      downloadUrl: json['downloadUrl'] ?? '',
      releaseDate:
          DateTime.tryParse(json['releaseDate'] ?? '') ?? DateTime.now(),
    );
  }
}

/// 版本服务类
/// 负责版本管理、更新检查等功能
class VersionService {
  static final VersionService _instance = VersionService._internal();
  static VersionService get instance => _instance;

  VersionService._internal();

  // 当前版本信息
  late PackageInfo _packageInfo;

  bool _isInitialized = false;

  /// 初始化版本服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _packageInfo = await PackageInfo.fromPlatform();

      _isInitialized = true;
      debugPrint('版本服务初始化成功: ${AppVersion.displayVersion}');
    } catch (e, stackTrace) {
      debugPrint('版本服务初始化失败');
      debugPrint('版本服务初始化失败栈Trace: $stackTrace');
      rethrow;
    }
  }

  /// 获取当前版本号
  String get currentVersion =>
      _isInitialized ? _packageInfo.version : AppVersion.version;

  /// 获取当前构建号
  String get currentBuildNumber =>
      _isInitialized ? _packageInfo.buildNumber : AppVersion.buildNumber;

  /// 获取应用名称
  String get appName => _isInitialized ? _packageInfo.appName : 'HUNNU App';

  /// 获取包名
  String get packageName =>
      _isInitialized ? _packageInfo.packageName : 'com.hunnu.app';

  /// 获取完整版本信息
  String get fullVersionInfo => '$currentVersion+$currentBuildNumber';

  /// 获取显示用版本信息
  String get displayVersion => 'v$currentVersion ($currentBuildNumber)';

  /// 检查是否有新版本
  bool hasNewVersion(String newVersion) {
    return AppVersion.shouldUpdate(currentVersion, newVersion);
  }

  /// 获取版本请求头
  Map<String, String> getVersionHeaders() {
    return {
      'App-Version': currentVersion,
      'Build-Number': currentBuildNumber,
      'Version-Code': AppVersion.versionCode.toString(),
      'Package-Name': packageName,
    };
  }

  /// 检查应用更新
  Future<VersionUpdateInfo?> checkForUpdates() async {
    try {
      // TODO: 实现实际的更新检查API调用
      // 这里应该调用服务器API检查是否有新版本

      // 模拟API响应
      final updateInfo = VersionUpdateInfo(
        version: '2.6.6',
        buildNumber: '20250109',
        description: '修复已知问题，优化用户体验',
        isForceUpdate: false,
        downloadUrl: 'https://example.com/download',
        releaseDate: DateTime.now(),
      );

      debugPrint('检查更新: 当前版本 $currentVersion, 最新版本 ${updateInfo.version}');

      if (hasNewVersion(updateInfo.version)) {
        return updateInfo;
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('检查更新失败');
      debugPrint('检查更新失败栈Trace: $stackTrace');
      return null;
    }
  }

  /// 记录版本信息
  void logVersionInfo() {
    AppVersion.logVersionInfo();
    debugPrint('应用名称: $appName');
    debugPrint('包名: $packageName');
  }
}
