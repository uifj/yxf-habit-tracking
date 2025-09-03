import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// 错误类型枚举
enum ErrorType {
  network,
  fileSystem,
  parsing,
  validation,
  authentication,
  permission,
  unknown,
}

/// 企业级错误处理管理器
/// 统一处理应用中的各种错误情况
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 处理错误并显示用户友好的消息
  static void handleError(
    BuildContext context,
    dynamic error, {
    ErrorType? type,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final errorMessage = _getErrorMessage(error, type, customMessage);
    
    // 在调试模式下打印详细错误信息
    if (kDebugMode) {
      debugPrint('Error occurred: $error');
      if (error is Error) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }

    // 显示错误消息给用户
    _showErrorSnackBar(context, errorMessage, onRetry);
  }

  /// 获取用户友好的错误消息
  static String _getErrorMessage(
    dynamic error,
    ErrorType? type,
    String? customMessage,
  ) {
    if (customMessage != null) {
      return customMessage;
    }

    switch (type) {
      case ErrorType.network:
        return '网络连接失败，请检查网络设置';
      case ErrorType.fileSystem:
        return '文件操作失败，请检查存储权限';
      case ErrorType.parsing:
        return '数据解析失败，请稍后重试';
      case ErrorType.validation:
        return '输入数据不正确，请检查后重试';
      case ErrorType.authentication:
        return '身份验证失败，请重新登录';
      case ErrorType.permission:
        return '权限不足，请检查应用权限设置';
      case ErrorType.unknown:
      default:
        return _parseErrorMessage(error);
    }
  }

  /// 解析具体的错误消息
  static String _parseErrorMessage(dynamic error) {
    if (error == null) {
      return '发生未知错误';
    }

    final errorString = error.toString();
    
    // 常见错误模式匹配
    if (errorString.contains('SocketException') ||
        errorString.contains('NetworkException')) {
      return '网络连接失败';
    }
    
    if (errorString.contains('FileSystemException') ||
        errorString.contains('PathNotFoundException')) {
      return '文件访问失败';
    }
    
    if (errorString.contains('FormatException') ||
        errorString.contains('JsonException')) {
      return '数据格式错误';
    }
    
    if (errorString.contains('TimeoutException')) {
      return '操作超时，请重试';
    }
    
    if (errorString.contains('PermissionException')) {
      return '权限不足';
    }

    // 返回简化的错误消息
    if (errorString.length > 100) {
      return '操作失败，请稍后重试';
    }
    
    return errorString;
  }

  /// 显示错误提示条
  static void _showErrorSnackBar(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// 显示错误对话框
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: const Text('取消'),
              ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('重试'),
              ),
            if (onRetry == null && onCancel == null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
          ],
        );
      },
    );
  }

  /// 显示成功消息
  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示警告消息
  static void showWarning(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示信息消息
  static void showInfo(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}