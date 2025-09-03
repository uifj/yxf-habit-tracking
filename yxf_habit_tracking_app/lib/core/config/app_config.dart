import 'package:flutter/foundation.dart';

/// 企业级应用配置管理器
/// 统一管理应用的各种配置参数
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // 应用基本信息
  static const String appName = 'Qwerty Learner';
  static const String appVersion = '1.0.0';
  static const String appDescription = '企业级打字练习应用';

  // 默认配置
  static const String defaultDictionaryId = '926';
  static const int defaultChapterIndex = 0;
  static const int defaultWordsPerSession = 10;
  static const int defaultSessionTimeLimit = 300; // 5分钟

  // UI配置
  static const double defaultFontSize = 16.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const int maxRecentDictionaries = 5;

  // 性能配置
  static const int maxCacheSize = 100; // MB
  static const int maxHistoryRecords = 1000;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheExpiration = Duration(hours: 24);

  // 调试配置
  static bool get isDebugMode => kDebugMode;
  static bool get isReleaseMode => kReleaseMode;
  static bool get isProfileMode => kProfileMode;

  // 平台检测
  static bool get isWeb => kIsWeb;
  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  // 功能开关
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = true;
  static const bool enableSoundEffects = true;
  static const bool enableVibration = true;
  static const bool enableAutoSave = true;

  // 路径配置
  static const String dictionariesPath = 'assets/dicts';
  static const String soundsPath = 'assets/sounds';
  static const String imagesPath = 'assets/images';

  // 网络配置
  static const String baseUrl = 'https://api.qwerty-learner.com';
  static const String apiVersion = 'v1';
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 存储键名
  static const String keyUserSettings = 'user_settings';
  static const String keyRecentDictionaries = 'recent_dictionaries';
  static const String keyTypingHistory = 'typing_history';
  static const String keyUserProgress = 'user_progress';
  static const String keyAppPreferences = 'app_preferences';

  // 错误消息
  static const Map<String, String> errorMessages = {
    'network_error': '网络连接失败，请检查网络设置',
    'file_not_found': '文件未找到，请重新下载',
    'permission_denied': '权限不足，请检查应用权限',
    'invalid_data': '数据格式错误，请稍后重试',
    'timeout': '操作超时，请重试',
    'unknown_error': '发生未知错误，请联系技术支持',
  };

  // 成功消息
  static const Map<String, String> successMessages = {
    'save_success': '保存成功',
    'load_success': '加载完成',
    'sync_success': '同步成功',
    'export_success': '导出成功',
    'import_success': '导入成功',
  };

  // 主题配置
  static const Map<String, dynamic> themeConfig = {
    'primary_color': 0xFF2196F3,
    'accent_color': 0xFF03DAC6,
    'error_color': 0xFFB00020,
    'warning_color': 0xFFFF9800,
    'success_color': 0xFF4CAF50,
    'info_color': 0xFF2196F3,
  };

  // 动画配置
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 验证规则
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// 获取环境特定的配置
  static T getEnvironmentConfig<T>({
    required T development,
    required T production,
    T? testing,
  }) {
    if (kDebugMode) {
      return development;
    } else if (kProfileMode && testing != null) {
      return testing;
    } else {
      return production;
    }
  }

  /// 获取平台特定的配置
  static T getPlatformConfig<T>({
    required T mobile,
    required T desktop,
    T? web,
  }) {
    if (kIsWeb && web != null) {
      return web;
    } else if (isMobile) {
      return mobile;
    } else {
      return desktop;
    }
  }

  /// 验证配置参数
  static bool validateConfig() {
    try {
      // 验证基本配置
      assert(appName.isNotEmpty, 'App name cannot be empty');
      assert(appVersion.isNotEmpty, 'App version cannot be empty');
      assert(defaultWordsPerSession > 0, 'Words per session must be positive');
      assert(
          defaultSessionTimeLimit > 0, 'Session time limit must be positive');
      assert(minFontSize < maxFontSize, 'Min font size must be less than max');
      assert(maxCacheSize > 0, 'Cache size must be positive');
      assert(maxHistoryRecords > 0, 'History records limit must be positive');

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Config validation failed: $e');
      }
      return false;
    }
  }

  /// 打印配置信息（仅在调试模式下）
  static void printConfigInfo() {
    if (kDebugMode) {
      debugPrint('=== App Configuration ===');
      debugPrint('App Name: $appName');
      debugPrint('Version: $appVersion');
      debugPrint('Debug Mode: $isDebugMode');
      debugPrint('Platform: ${defaultTargetPlatform.name}');
      debugPrint('Is Web: $isWeb');
      debugPrint('Is Mobile: $isMobile');
      debugPrint('Is Desktop: $isDesktop');
      debugPrint('========================');
    }
  }
}
