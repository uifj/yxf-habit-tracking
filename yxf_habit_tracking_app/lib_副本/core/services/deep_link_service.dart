import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../router/app_route_names.dart';
import 'navigation_service.dart';

/// 深度链接服务
///
/// 企业级深度链接处理服务，提供：
/// - 统一的深度链接解析和处理
/// - 路由映射和参数提取
/// - 错误处理和日志记录
/// - 与原生平台的通信桥梁
class DeepLinkService {
  /// 私有构造函数，实现单例模式
  DeepLinkService._internal();

  /// 工厂构造函数，返回单例实例
  factory DeepLinkService() => _instance;

  /// 单例实例
  static final DeepLinkService _instance = DeepLinkService._internal();

  /// 方法通道，用于与原生平台通信
  static const MethodChannel _channel =
      MethodChannel('com.tencent.flutter.tuikit/native');

  /// 深度链接处理回调
  Function(String url, Map<String, dynamic> params)? _onDeepLinkReceived;

  /// 分享内容处理回调
  Function(String content, String type)? _onSharedContentReceived;

  /// 初始化深度链接服务
  ///
  /// 设置方法通道监听器，处理来自原生平台的深度链接和分享内容
  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// 设置深度链接接收回调
  void setDeepLinkHandler(
      Function(String url, Map<String, dynamic> params) handler) {
    _onDeepLinkReceived = handler;
  }

  /// 设置分享内容接收回调
  void setSharedContentHandler(Function(String content, String type) handler) {
    _onSharedContentReceived = handler;
  }

  /// 处理来自原生平台的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        await _handleDeepLink(call.arguments);
        break;
      case 'onSharedContent':
        await _handleSharedContent(call.arguments);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// 处理深度链接
  Future<void> _handleDeepLink(Map<dynamic, dynamic> arguments) async {
    try {
      final String url = arguments['url'] ?? '';
      final String? scheme = arguments['scheme'];
      final String? host = arguments['host'];
      final String? path = arguments['path'];
      final String? query = arguments['query'];

      // 解析参数
      final Map<String, dynamic> params = {
        'scheme': scheme,
        'host': host,
        'path': path,
        'query': query,
      };

      // 解析查询参数
      if (query != null && query.isNotEmpty) {
        final queryParams = Uri.splitQueryString(query);
        params.addAll(queryParams);
      }

      // 调用回调函数
      _onDeepLinkReceived?.call(url, params);

      // 根据路径导航到相应页面
      await _navigateFromDeepLink(path ?? '', params);
    } catch (e) {
      debugPrint('处理深度链接失败: $e');
    }
  }

  /// 处理分享内容
  Future<void> _handleSharedContent(Map<dynamic, dynamic> arguments) async {
    try {
      final String content = arguments['content'] ?? '';
      final String type = arguments['type'] ?? 'text';

      // 调用回调函数
      _onSharedContentReceived?.call(content, type);

      // 可以根据内容类型导航到相应页面
      // 例如：如果是文本内容，可以导航到编辑页面
    } catch (e) {
      debugPrint('处理分享内容失败: $e');
    }
  }

  /// 根据深度链接路径导航
  Future<void> _navigateFromDeepLink(
      String path, Map<String, dynamic> params) async {
    // 使用NavigationService进行导航
    final navigationService = NavigationService();

    // 路径映射
    String? routeName;
    switch (path) {
      case '/':
      case '/home':
        routeName = AppRouteNames.home;
        break;
      case '/gallery':
        routeName = AppRouteNames.gallery;
        break;
      case '/typing':
        routeName = AppRouteNames.typing;
        break;
      case '/typing/test':
        routeName = AppRouteNames.typingTest;
        break;
      case '/analysis':
        routeName = AppRouteNames.analysis;
        break;
      case '/tools':
        routeName = AppRouteNames.tools;
        break;
      case '/settings':
        routeName = AppRouteNames.settings;
        break;
      default:
        // 未知路径，导航到首页
        routeName = AppRouteNames.home;
        break;
    }

    // 执行导航
    await navigationService.navigateTo(
      routeName,
      arguments: params,
    );
  }

  /// 获取当前上下文
  ///
  /// 通过NavigationService获取当前上下文
  BuildContext? _getCurrentContext() {
    return NavigationService().context;
  }

  /// 生成深度链接URL
  ///
  /// [path] 路径
  /// [params] 查询参数
  String generateDeepLink(String path, {Map<String, String>? params}) {
    final uri = Uri(
      scheme: 'tuikit',
      host: 'app',
      path: path,
      queryParameters: params,
    );
    return uri.toString();
  }

  /// 分享深度链接
  ///
  /// [path] 路径
  /// [params] 查询参数
  /// [title] 分享标题
  Future<void> shareDeepLink(
    String path, {
    Map<String, String>? params,
    String? title,
  }) async {
    try {
      final url = generateDeepLink(path, params: params);
      await _channel.invokeMethod('shareText', {
        'text': url,
        'title': title ?? '分享链接',
      });
    } catch (e) {
      debugPrint('分享深度链接失败: $e');
    }
  }

  /// 打开外部URL
  ///
  /// [url] 要打开的URL
  Future<bool> openUrl(String url) async {
    try {
      final result = await _channel.invokeMethod('openUrl', {'url': url});
      return result == true;
    } catch (e) {
      debugPrint('打开URL失败: $e');
      return false;
    }
  }

  /// 检查权限
  ///
  /// [permission] 权限名称
  Future<bool> checkPermission(String permission) async {
    try {
      final result = await _channel.invokeMethod('checkPermission', {
        'permission': permission,
      });
      return result == true;
    } catch (e) {
      debugPrint('检查权限失败: $e');
      return false;
    }
  }

  /// 请求权限
  ///
  /// [permission] 权限名称
  Future<void> requestPermission(String permission) async {
    try {
      await _channel.invokeMethod('requestPermission', {
        'permission': permission,
      });
    } catch (e) {
      debugPrint('请求权限失败: $e');
    }
  }

  /// 获取设备信息
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('获取设备信息失败: $e');
      return null;
    }
  }

  /// 获取应用版本信息
  Future<Map<String, dynamic>?> getAppVersion() async {
    try {
      final result = await _channel.invokeMethod('getAppVersion');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('获取应用版本失败: $e');
      return null;
    }
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      debugPrint('打开应用设置失败: $e');
    }
  }

  /// 退出应用
  Future<void> exitApp() async {
    try {
      await _channel.invokeMethod('exitApp');
    } catch (e) {
      debugPrint('退出应用失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _onDeepLinkReceived = null;
    _onSharedContentReceived = null;
  }
}

/// 深度链接工具类
///
/// 提供便捷的深度链接操作方法
class DeepLinkUtils {
  /// 私有构造函数，防止实例化
  DeepLinkUtils._();

  /// 解析深度链接URL
  ///
  /// [url] 深度链接URL
  static Map<String, dynamic> parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return {
        'scheme': uri.scheme,
        'host': uri.host,
        'path': uri.path,
        'query': uri.query,
        'queryParameters': uri.queryParameters,
        'fragment': uri.fragment,
      };
    } catch (e) {
      debugPrint('解析深度链接失败: $e');
      return {};
    }
  }

  /// 验证深度链接格式
  ///
  /// [url] 深度链接URL
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 提取路由名称
  ///
  /// [path] URL路径
  static String extractRouteName(String path) {
    if (path.isEmpty || path == '/') {
      return AppRouteNames.home;
    }

    // 移除开头的斜杠
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // 根据路径返回对应的路由名称
    switch (cleanPath) {
      case 'gallery':
        return AppRouteNames.gallery;
      case 'typing':
        return AppRouteNames.typing;
      case 'typing/test':
        return AppRouteNames.typingTest;
      case 'analysis':
        return AppRouteNames.analysis;
      case 'tools':
        return AppRouteNames.tools;
      case 'settings':
        return AppRouteNames.settings;
      default:
        return AppRouteNames.home;
    }
  }
}
