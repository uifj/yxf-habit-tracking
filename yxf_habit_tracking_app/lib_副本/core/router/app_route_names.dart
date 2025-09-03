import 'package:flutter/material.dart';
import '../../src/app.dart';
import '../../src/presentation/pages/typing/gallery_page.dart';
import '../../src/presentation/pages/typing/typing_page.dart';
import '../../src/presentation/pages/typing/typing_test_page.dart';
import '../../src/presentation/pages/typing/type_analysis_page.dart';
import '../../src/presentation/pages/setting/settings_page.dart';
import '../../src/presentation/pages/tools/tools_page.dart';

/// 应用路由名称定义
///
/// 企业级路由管理系统，提供：
/// - 集中化路由名称管理
/// - 类型安全的路由定义
/// - 路由分组和命名空间
/// - 路由元数据管理
/// - 动态路由支持
class AppRouteNames {
  // 私有构造函数，防止实例化
  AppRouteNames._();

  // ==================== 核心路由 ====================
  /// 应用主页
  static const String home = '/';

  /// 启动页面
  static const String splash = '/splash';

  /// 登录页面
  static const String login = '/login';

  /// 注册页面
  static const String register = '/register';

  // ==================== 功能模块路由 ====================
  /// 图库模块
  static const String gallery = '/gallery';

  /// 图片详情页
  static const String galleryDetail = '/gallery/detail';

  // ==================== 打字练习模块 ====================
  /// 打字练习主页
  static const String typing = '/typing';

  /// 打字测试页面
  static const String typingTest = '/typingTest';

  /// 打字分析页面
  static const String analysis = '/analysis';

  /// 打字历史记录
  static const String typingHistory = '/typing/history';

  /// 打字排行榜
  static const String typingLeaderboard = '/typing/leaderboard';

  // ==================== 工具模块路由 ====================
  /// 工具页面
  static const String tools = '/tools';

  // ==================== 设置模块路由 ====================
  /// 应用设置
  static const String settings = '/settings';

  /// 账户设置
  static const String accountSettings = '/settings/account';

  /// 隐私设置
  static const String privacySettings = '/settings/privacy';

  /// 通知设置
  static const String notificationSettings = '/settings/notification';

  /// 关于页面
  static const String about = '/settings/about';

  // ==================== 错误页面 ====================
  /// 404页面
  static const String notFound = '/404';

  /// 网络错误页面
  static const String networkError = '/error/network';

  /// 服务器错误页面
  static const String serverError = '/error/server';

  /// 路由映射表
  ///
  /// 将路由名称映射到对应的页面构建器
  /// 支持懒加载和动态路由注册
  static final Map<String, WidgetBuilder> routes = {
    // 核心页面
    home: (context) => const MyHomePage(),
    gallery: (context) => const GalleryPage(),

    // 打字练习模块
    typing: (context) => const TypingPage(),
    typingTest: (context) => const TypingTestPage(),
    analysis: (context) => const AnalysisPage(),

    // 工具和设置
    tools: (context) => const ToolsPage(),
    settings: (context) => const SettingsPage(),

    // 错误页面
    notFound: (context) => const _NotFoundPage(),
    networkError: (context) => const _NetworkErrorPage(),
    serverError: (context) => const _ServerErrorPage(),
  };

  /// 路由元数据
  ///
  /// 存储路由的额外信息，如权限要求、标题等
  static const Map<String, RouteMetadata> routeMetadata = {
    home: RouteMetadata(
      title: '首页',
      requiresAuth: false,
      category: RouteCategory.core,
    ),
    gallery: RouteMetadata(
      title: '图库',
      requiresAuth: false,
      category: RouteCategory.feature,
    ),
    typing: RouteMetadata(
      title: '打字练习',
      requiresAuth: false,
      category: RouteCategory.feature,
    ),
    typingTest: RouteMetadata(
      title: '打字测试',
      requiresAuth: false,
      category: RouteCategory.feature,
    ),
    analysis: RouteMetadata(
      title: '练习分析',
      requiresAuth: false,
      category: RouteCategory.feature,
    ),
    tools: RouteMetadata(
      title: '工具',
      requiresAuth: false,
      category: RouteCategory.feature,
    ),
    settings: RouteMetadata(
      title: '设置',
      requiresAuth: false,
      category: RouteCategory.settings,
    ),
  };

  /// 获取所有路由名称
  static List<String> getAllRouteNames() {
    return routes.keys.toList();
  }

  /// 根据分类获取路由
  static List<String> getRoutesByCategory(RouteCategory category) {
    return routeMetadata.entries
        .where((entry) => entry.value.category == category)
        .map((entry) => entry.key)
        .toList();
  }

  /// 检查路由是否需要认证
  static bool requiresAuthentication(String routeName) {
    return routeMetadata[routeName]?.requiresAuth ?? false;
  }

  /// 获取路由标题
  static String? getRouteTitle(String routeName) {
    return routeMetadata[routeName]?.title;
  }
}

/// 路由元数据类
///
/// 定义路由的附加信息
class RouteMetadata {
  const RouteMetadata({
    required this.title,
    required this.requiresAuth,
    required this.category,
    this.description,
    this.icon,
  });

  /// 路由标题
  final String title;

  /// 是否需要认证
  final bool requiresAuth;

  /// 路由分类
  final RouteCategory category;

  /// 路由描述
  final String? description;

  /// 路由图标
  final IconData? icon;
}

/// 路由分类枚举
enum RouteCategory {
  /// 核心页面
  core,

  /// 功能模块
  feature,

  /// 设置相关
  settings,

  /// 错误页面
  error,

  /// 认证相关
  auth,
}

// ==================== 错误页面组件 ====================

/// 404页面
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404 - 页面未找到',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '您访问的页面不存在',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 网络错误页面
class _NetworkErrorPage extends StatelessWidget {
  const _NetworkErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络错误'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '网络连接失败',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '请检查您的网络连接',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 服务器错误页面
class _ServerErrorPage extends StatelessWidget {
  const _ServerErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器错误'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              '服务器错误',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '服务器暂时无法响应，请稍后重试',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
