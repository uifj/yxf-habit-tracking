import 'package:flutter/cupertino.dart';

/// 应用版本管理类
/// 统一管理版本号和构建号，避免硬编码
class AppVersion {
  // 从pubspec.yaml读取的版本信息
  static const String version = '2.6.5';
  static const String buildNumber = '20250819';

  /// 获取完整版本字符串 (version+buildNumber)
  static String get fullVersion => '$version+$buildNumber';

  /// 获取显示用的版本字符串
  static String get displayVersion => 'v$version ($buildNumber)';

  /// 版本比较 - 用于检查是否需要更新
  static bool shouldUpdate(String currentVersion, String newVersion) {
    try {
      final current = _parseVersion(currentVersion);
      final newer = _parseVersion(newVersion);

      // 比较主版本号
      if (newer[0] > current[0]) return true;
      if (newer[0] < current[0]) return false;

      // 比较次版本号
      if (newer[1] > current[1]) return true;
      if (newer[1] < current[1]) return false;

      // 比较修订版本号
      if (newer[2] > current[2]) return true;

      return false;
    } catch (e) {
      debugPrint('版本比较失败: $e');
      return false;
    }
  }

  /// 获取版本代码 - 用于API调用
  static int get versionCode {
    try {
      final parts = _parseVersion(version);
      // 将版本号转换为整数代码: 主版本*10000 + 次版本*100 + 修订版本
      return parts[0] * 10000 + parts[1] * 100 + parts[2];
    } catch (e) {
      debugPrint('获取版本代码失败: $e');
      return 20605; // 默认返回当前版本的代码
    }
  }

  /// 解析版本号字符串为数字数组
  static List<int> _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('版本号格式错误: $version');
    }
    return parts.map((part) => int.parse(part)).toList();
  }

  /// 获取版本映射 - 用于API请求头
  static Map<String, String> getVersionHeaders() {
    return {
      'App-Version': version,
      'Build-Number': buildNumber,
      'Version-Code': versionCode.toString(),
    };
  }

  /// 记录版本信息到日志
  static void logVersionInfo() {
    debugPrint('应用版本信息');
    debugPrint('版本号: $version');
    debugPrint('构建号: $buildNumber');
    debugPrint('版本代码: $versionCode');
    debugPrint('完整版本: $fullVersion');
  }
}
