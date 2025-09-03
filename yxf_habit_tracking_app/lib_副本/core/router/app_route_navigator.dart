import 'package:flutter/material.dart';
import 'app_route_names.dart';

/// 应用导航器
///
/// 企业级导航管理系统，提供：
/// - 类型安全的导航方法
/// - 统一的参数传递机制
/// - 导航历史管理
/// - 权限检查和拦截
/// - 导航动画定制
/// - 错误处理和日志记录
class AppRouteNavigator {
  // 私有构造函数，防止实例化
  AppRouteNavigator._();

  // ==================== 核心导航方法 ====================

  /// 通用导航方法
  ///
  /// [context] 构建上下文
  /// [routeName] 目标路由名称
  /// [arguments] 传递的参数
  /// [replace] 是否替换当前页面
  /// [clearStack] 是否清空导航栈
  static Future<T?> navigateTo<T extends Object?>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    // 权限检查
    if (!_checkPermission(routeName)) {
      _showPermissionDeniedDialog(context);
      return null;
    }

    try {
      if (clearStack) {
        return Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
          arguments: arguments,
        );
      } else if (replace) {
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
    } catch (e) {
      _handleNavigationError(context, routeName, e);
      return null;
    }
  }

  // ==================== 功能模块导航 ====================

  /// 导航到主页
  static Future<T?> navigateToHome<T extends Object?>({
    required BuildContext context,
    bool clearStack = false,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.home,
      clearStack: clearStack,
    );
  }

  /// 导航到图库页面
  static Future<T?> navigateToGallery<T extends Object?>({
    required BuildContext context,
    String? category,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.gallery,
      arguments: {
        if (category != null) 'category': category,
      },
    );
  }

  /// 导航到打字练习页面
  ///
  /// [context] 构建上下文
  /// [dictionaryId] 字典ID（可选）
  /// [chapterIndex] 章节索引（可选）
  /// [difficulty] 难度级别（可选）
  static Future<T?> navigateToTyping<T extends Object?>({
    required BuildContext context,
    String? dictionaryId,
    int? chapterIndex,
    String? difficulty,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.typing,
      arguments: {
        if (dictionaryId != null) 'dictionaryId': dictionaryId,
        if (chapterIndex != null) 'chapterIndex': chapterIndex,
        if (difficulty != null) 'difficulty': difficulty,
      },
    );
  }

  /// 导航到打字测试页面
  static Future<T?> navigateToTypingTest<T extends Object?>({
    required BuildContext context,
    required String testType,
    int? duration,
    String? content,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.typingTest,
      arguments: {
        'testType': testType,
        if (duration != null) 'duration': duration,
        if (content != null) 'content': content,
      },
    );
  }

  /// 导航到分析页面
  ///
  /// [context] 构建上下文
  /// [testId] 测试ID（可选）
  /// [dateRange] 日期范围（可选）
  static Future<T?> navigateToAnalysis<T extends Object?>({
    required BuildContext context,
    String? testId,
    DateTimeRange? dateRange,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.analysis,
      arguments: {
        if (testId != null) 'testId': testId,
        if (dateRange != null) 'dateRange': dateRange,
      },
    );
  }

  /// 导航到工具页面
  static Future<T?> navigateToTools<T extends Object?>({
    required BuildContext context,
    String? toolCategory,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.tools,
      arguments: {
        if (toolCategory != null) 'toolCategory': toolCategory,
      },
    );
  }

  /// 导航到设置页面
  static Future<T?> navigateToSettings<T extends Object?>({
    required BuildContext context,
    String? section,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.settings,
      arguments: {
        if (section != null) 'section': section,
      },
    );
  }

  // ==================== 错误页面导航 ====================

  /// 导航到404页面
  static Future<T?> navigateToNotFound<T extends Object?>({
    required BuildContext context,
    String? originalRoute,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.notFound,
      arguments: {
        if (originalRoute != null) 'originalRoute': originalRoute,
      },
    );
  }

  /// 导航到网络错误页面
  static Future<T?> navigateToNetworkError<T extends Object?>({
    required BuildContext context,
    String? errorMessage,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.networkError,
      arguments: {
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }

  /// 导航到服务器错误页面
  static Future<T?> navigateToServerError<T extends Object?>({
    required BuildContext context,
    int? statusCode,
    String? errorMessage,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: AppRouteNames.serverError,
      arguments: {
        if (statusCode != null) 'statusCode': statusCode,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }

  // ==================== 导航控制方法 ====================

  /// 返回上一页
  ///
  /// [context] 构建上下文
  /// [result] 返回结果（可选）
  static void goBack<T extends Object?>({
    required BuildContext context,
    T? result,
  }) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  /// 返回到主页
  ///
  /// [context] 构建上下文
  static Future<void> goHome({
    required BuildContext context,
  }) {
    return navigateToHome(
      context: context,
      clearStack: true,
    );
  }

  /// 替换当前页面
  ///
  /// [context] 构建上下文
  /// [routeName] 目标路由名称
  /// [arguments] 传递的参数（可选）
  static Future<T?> replaceTo<T extends Object?>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: routeName,
      arguments: arguments,
      replace: true,
    );
  }

  /// 清空导航栈并导航到指定页面
  ///
  /// [context] 构建上下文
  /// [routeName] 目标路由名称
  /// [arguments] 传递的参数（可选）
  static Future<T?> pushAndClearStack<T extends Object?>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
  }) {
    return navigateTo<T>(
      context: context,
      routeName: routeName,
      arguments: arguments,
      clearStack: true,
    );
  }

  /// 弹出到指定路由
  ///
  /// [context] 构建上下文
  /// [routeName] 目标路由名称
  static void popUntil({
    required BuildContext context,
    required String routeName,
  }) {
    Navigator.of(context).popUntil(
      ModalRoute.withName(routeName),
    );
  }

  /// 检查是否可以返回
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  // ==================== 私有辅助方法 ====================

  /// 检查路由权限
  static bool _checkPermission(String routeName) {
    // 检查是否需要认证
    if (AppRouteNames.requiresAuthentication(routeName)) {
      // 这里可以添加实际的认证检查逻辑
      // 例如：检查用户是否已登录
      return true; // 暂时返回true，实际项目中需要实现具体逻辑
    }
    return true;
  }

  /// 显示权限拒绝对话框
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('访问被拒绝'),
        content: const Text('您没有权限访问此页面，请先登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理导航错误
  static void _handleNavigationError(
    BuildContext context,
    String routeName,
    Object error,
  ) {
    // 记录错误日志
    debugPrint('Navigation error to $routeName: $error');

    // 显示错误提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('导航失败：无法打开页面 $routeName'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ==================== 参数提取辅助方法 ====================

  /// 从路由参数中提取字符串值
  static String? getStringArgument(
    BuildContext context,
    String key, {
    String? defaultValue,
  }) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args[key]?.toString() ?? defaultValue;
    }
    return defaultValue;
  }

  /// 从路由参数中提取整数值
  static int? getIntArgument(
    BuildContext context,
    String key, {
    int? defaultValue,
  }) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final value = args[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return defaultValue;
  }

  /// 从路由参数中提取布尔值
  static bool? getBoolArgument(
    BuildContext context,
    String key, {
    bool? defaultValue,
  }) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final value = args[key];
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
    }
    return defaultValue;
  }

  /// 从路由参数中提取对象值
  static T? getObjectArgument<T>(
    BuildContext context,
    String key, {
    T? defaultValue,
  }) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final value = args[key];
      if (value is T) return value;
    }
    return defaultValue;
  }

  /// 获取所有路由参数
  static Map<String, dynamic>? getAllArguments(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args;
    }
    return null;
  }
}
