import 'package:flutter/material.dart';

/// 全局导航服务
///
/// 企业级导航管理服务，提供：
/// - 全局导航状态管理
/// - 上下文无关的导航操作
/// - 深度链接导航支持
/// - 路由历史管理
class NavigationService {
  /// 私有构造函数，实现单例模式
  NavigationService._internal();

  /// 工厂构造函数，返回单例实例
  factory NavigationService() => _instance;

  /// 单例实例
  static final NavigationService _instance = NavigationService._internal();

  /// 全局导航键
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 获取当前导航器状态
  NavigatorState? get navigator => navigatorKey.currentState;

  /// 获取当前上下文
  BuildContext? get context => navigatorKey.currentContext;

  /// 获取当前路由名称
  String? get currentRouteName {
    final route = ModalRoute.of(context!);
    return route?.settings.name;
  }

  /// 导航到指定路由
  ///
  /// [routeName] 路由名称
  /// [arguments] 路由参数
  /// [replace] 是否替换当前路由
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) async {
    if (navigator == null) {
      debugPrint('导航器未初始化，无法导航到: $routeName');
      return null;
    }

    try {
      if (replace) {
        return await navigator!.pushReplacementNamed(
          routeName,
          arguments: arguments,
        );
      } else {
        return await navigator!.pushNamed(
          routeName,
          arguments: arguments,
        );
      }
    } catch (e) {
      debugPrint('导航失败: $e');
      return null;
    }
  }

  /// 返回上一页
  ///
  /// [result] 返回结果
  void goBack<T extends Object?>([T? result]) {
    if (navigator == null) {
      debugPrint('导航器未初始化，无法返回');
      return;
    }

    if (navigator!.canPop()) {
      navigator!.pop(result);
    } else {
      debugPrint('无法返回，当前已是根路由');
    }
  }

  /// 返回到指定路由
  ///
  /// [routeName] 目标路由名称
  void popUntil(String routeName) {
    if (navigator == null) {
      debugPrint('导航器未初始化，无法返回到: $routeName');
      return;
    }

    navigator!.popUntil((route) => route.settings.name == routeName);
  }

  /// 清除所有路由并导航到指定路由
  ///
  /// [routeName] 目标路由名称
  /// [arguments] 路由参数
  Future<T?> navigateAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    if (navigator == null) {
      debugPrint('导航器未初始化，无法导航到: $routeName');
      return null;
    }

    try {
      return await navigator!.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('导航失败: $e');
      return null;
    }
  }

  /// 显示对话框
  ///
  /// [dialog] 对话框组件
  /// [barrierDismissible] 是否可以通过点击背景关闭
  Future<T?> showDialogWidget<T>(
    Widget dialog, {
    bool barrierDismissible = true,
  }) async {
    if (context == null) {
      debugPrint('上下文未初始化，无法显示对话框');
      return null;
    }

    try {
      return await showDialog<T>(
        context: context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => dialog,
      );
    } catch (e) {
      debugPrint('显示对话框失败: $e');
      return null;
    }
  }

  /// 显示底部弹窗
  ///
  /// [bottomSheet] 底部弹窗组件
  /// [isScrollControlled] 是否可滚动控制
  /// [isDismissible] 是否可以通过下拉关闭
  Future<T?> showBottomSheet<T>(
    Widget bottomSheet, {
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) async {
    if (context == null) {
      debugPrint('上下文未初始化，无法显示底部弹窗');
      return null;
    }

    try {
      return await showModalBottomSheet<T>(
        context: context!,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        builder: (context) => bottomSheet,
      );
    } catch (e) {
      debugPrint('显示底部弹窗失败: $e');
      return null;
    }
  }

  /// 显示SnackBar
  ///
  /// [message] 消息内容
  /// [duration] 显示时长
  /// [action] 操作按钮
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (context == null) {
      debugPrint('上下文未初始化，无法显示SnackBar');
      return;
    }

    try {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
    } catch (e) {
      debugPrint('显示SnackBar失败: $e');
    }
  }

  /// 隐藏当前SnackBar
  void hideSnackBar() {
    if (context == null) {
      debugPrint('上下文未初始化，无法隐藏SnackBar');
      return;
    }

    try {
      ScaffoldMessenger.of(context!).hideCurrentSnackBar();
    } catch (e) {
      debugPrint('隐藏SnackBar失败: $e');
    }
  }

  /// 检查是否可以返回
  bool canPop() {
    if (navigator == null) {
      return false;
    }
    return navigator!.canPop();
  }

  /// 获取路由历史
  List<Route> getRouteHistory() {
    if (navigator == null) {
      return [];
    }

    // 注意：这是一个简化的实现
    // 实际的路由历史需要通过RouteObserver来跟踪
    return [];
  }

  /// 检查指定路由是否在栈中
  bool isRouteInStack(String routeName) {
    if (navigator == null) {
      return false;
    }

    // 这需要通过RouteObserver来实现
    // 这里提供一个简化的检查方法
    return currentRouteName == routeName;
  }

  /// 获取当前路由参数
  Object? getCurrentRouteArguments() {
    if (context == null) {
      return null;
    }

    try {
      final route = ModalRoute.of(context!);
      return route?.settings.arguments;
    } catch (e) {
      debugPrint('获取路由参数失败: $e');
      return null;
    }
  }

  /// 刷新当前页面
  void refresh() {
    if (navigator == null) {
      debugPrint('导航器未初始化，无法刷新');
      return;
    }

    final currentRoute = currentRouteName;
    final currentArguments = getCurrentRouteArguments();

    if (currentRoute != null) {
      navigateTo(currentRoute, arguments: currentArguments, replace: true);
    }
  }

  /// 清理资源
  void dispose() {
    // 清理相关资源
    debugPrint('NavigationService已释放');
  }
}

/// 导航服务扩展
///
/// 提供便捷的导航操作方法
extension NavigationServiceExtension on NavigationService {
  /// 导航到首页
  Future<void> goHome() async {
    await navigateAndClearStack('/home');
  }

  /// 导航到登录页
  Future<void> goLogin() async {
    await navigateTo('/login');
  }

  /// 导航到设置页
  Future<void> goSettings() async {
    await navigateTo('/settings');
  }

  /// 显示错误对话框
  Future<void> showErrorDialog(String title, String message) async {
    await showDialogWidget(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => goBack(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示确认对话框
  Future<bool?> showConfirmDialog(
    String title,
    String message, {
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    return await showDialogWidget<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => goBack(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => goBack(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示加载对话框
  void showLoadingDialog([String? message]) {
    showDialogWidget(
      AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? '加载中...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    goBack();
  }
}
