import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/log/tencent_cloud_chat_log.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat_demo/core/router/app_route_names.dart';

/// 企业级应用路由管理器
///
/// 功能特性：
/// - 单例模式确保全局路由状态一致性
/// - 支持动态路由注册和管理
/// - 完善的错误处理和日志记录
/// - 路由参数类型安全传递
/// - 路由生命周期监听
/// - 未知路由处理机制
class AppRouter {
  /// 私有构造函数，实现单例模式
  AppRouter._internal();

  /// 工厂构造函数，返回单例实例
  factory AppRouter() => _instance;

  /// 单例实例
  static final AppRouter _instance = AppRouter._internal();

  /// 动态注册的路由表
  final Map<String, WidgetBuilder> _dynamicRoutes = {};

  /// 全局路由观察者，用于监听路由变化
  final RouteObserver<Route<dynamic>> routeObserver =
      RouteObserver<Route<dynamic>>();

  /// 路由堆栈历史记录（用于调试和分析）
  final List<String> _routeHistory = [];

  /// 获取路由历史记录
  List<String> get routeHistory => List.unmodifiable(_routeHistory);

  /// 静态路由表 - 用于MaterialApp的routes属性
  ///
  /// 提供应用的基础路由映射，结合动态路由实现完整的路由系统
  static Map<String, WidgetBuilder> get routes => AppRouteNames.routes;

  /// 获取当前注册的所有路由
  Map<String, WidgetBuilder> get registeredRoutes => {
        ...AppRouteNames.routes,
        ..._dynamicRoutes,
      };

  /// 动态注册路由
  ///
  /// [routeName] 路由名称，建议使用常量定义
  /// [builder] 页面构建器函数
  void registerRouter({
    required String routeName,
    required WidgetBuilder builder,
  }) {
    _dynamicRoutes[routeName] = builder;
    _logRouteAction('注册路由', routeName);
  }

  /// 注销动态路由
  void unregisterRouter(String routeName) {
    if (_dynamicRoutes.containsKey(routeName)) {
      _dynamicRoutes.remove(routeName);
      _logRouteAction('注销路由', routeName);
    }
  }

  /// 检查路由是否已注册
  bool isRouteRegistered(String routeName) {
    return registeredRoutes.containsKey(routeName);
  }

  /// 路由生成器
  /// 处理动态路由和参数传递
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';
    final AppRouter instance = AppRouter();

    // 记录路由历史
    instance._addToHistory(routeName);

    // 查找路由构建器
    final WidgetBuilder? builder = instance.registeredRoutes[routeName];

    if (builder != null) {
      instance._logRouteAction('导航到', routeName);
      return _createRoute(builder, settings);
    }

    // 处理未知路由
    instance._logRouteAction('未知路由', routeName);
    return _buildUnknownRoute(settings);
  }

  /// 创建路由页面
  static MaterialPageRoute<dynamic> _createRoute(
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }

  /// 构建未知路由页面
  static Route<dynamic> _buildUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '页面未找到: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(AppRouteNames.home),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }

  /// 静态导航方法 - 用于简单导航
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) {
    final AppRouter instance = AppRouter();

    if (!instance.isRouteRegistered(routeName)) {
      instance._logRouteAction('路由未注册', routeName);
      // 可以选择导航到错误页面或返回null
      return Future.value(null);
    }

    if (replace) {
      return Navigator.of(context).pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } else {
      return Navigator.of(context).pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Retrieves an argument of type [T] from the route's argument map using the given [key].
  ///
  /// This method is useful for retrieving arguments passed during navigation.
  /// Returns the argument value if found, or `null` if the argument is not found or is of the wrong type.
  T? getArgumentFromMap<T>(BuildContext context, String key) {
    var argument = ModalRoute.of(context)!.settings.arguments;
    if (argument == null || argument is! Map) {
      return null;
    }
    Map<String, Object?> argMap = argument as Map<String, Object?>;
    return argMap[key] as T?;
  }

  /// 实例导航方法 - 支持更复杂的导航逻辑
  ///
  /// 导航到指定路由，支持参数传递和错误处理
  /// [context] 构建上下文
  /// [routeName] 目标路由名称
  /// [options] 传递给目标页面的参数
  /// [replace] 是否替换当前页面
  Future<T?>? navigateTo<T extends Object?>({
    required BuildContext context,
    required String routeName,
    dynamic options,
    bool replace = false,
  }) {
    try {
      // 检查路由是否已注册
      if (!isRouteRegistered(routeName)) {
        _logRouteAction('路由未注册', routeName);
        return Future.value(null);
      }

      final WidgetBuilder? builder = registeredRoutes[routeName];
      if (builder == null) {
        _logRouteAction('路由构建器为空', routeName);
        return Future.value(null);
      }

      _addToHistory(routeName);
      _logRouteAction('导航到', routeName);

      final route = MaterialPageRoute<T>(
        builder: builder,
        settings: RouteSettings(
          name: routeName,
          arguments: {'options': options},
        ),
      );

      if (replace) {
        return Navigator.of(context).pushReplacement(route);
      } else {
        return Navigator.of(context).push(route);
      }
    } catch (e, stackTrace) {
      _logError('导航失败', routeName, e, stackTrace);
      return Future.value(null);
    }
  }

  /// 添加路由到历史记录
  void _addToHistory(String routeName) {
    _routeHistory.add(routeName);
    // 限制历史记录长度，避免内存泄漏
    if (_routeHistory.length > 100) {
      _routeHistory.removeAt(0);
    }
  }

  /// 记录路由操作日志
  void _logRouteAction(String action, String routeName) {
    TencentCloudChat.instance.logInstance.console(
      componentName: 'AppRouter',
      logs: '$action: $routeName',
      logLevel: TencentCloudChatLogLevel.info,
    );
  }

  /// 记录路由错误日志
  void _logError(
      String action, String routeName, Object error, StackTrace stackTrace) {
    TencentCloudChat.instance.logInstance.console(
      componentName: 'AppRouter',
      logs: '$action: $routeName - Error: $error\nStackTrace: $stackTrace',
      logLevel: TencentCloudChatLogLevel.error,
    );
  }

  /// 清空路由历史记录
  void clearHistory() {
    _routeHistory.clear();
    _logRouteAction('清空历史记录', '');
  }

  /// 获取路由统计信息
  Map<String, int> getRouteStatistics() {
    final Map<String, int> stats = {};
    for (final route in _routeHistory) {
      stats[route] = (stats[route] ?? 0) + 1;
    }
    return stats;
  }
}
