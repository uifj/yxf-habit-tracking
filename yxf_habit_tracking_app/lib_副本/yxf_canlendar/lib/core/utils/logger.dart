import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 企业级日志工具类
/// 提供统一的日志记录接口，支持不同级别的日志输出
class Logger {
  static const String _tag = 'HabitTracker';
  
  /// 调试日志
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 信息日志
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 警告日志
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 错误日志
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 严重错误日志
  static void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1200, // Severe level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// BLoC事件日志
  static void blocEvent(String blocName, String eventName, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final message = 'BLoC Event: $blocName -> $eventName';
      final details = data != null ? ' | Data: $data' : '';
      debug('$message$details', tag: 'BLoC');
    }
  }
  
  /// BLoC状态变化日志
  static void blocTransition(String blocName, String fromState, String toState) {
    if (kDebugMode) {
      debug('BLoC Transition: $blocName | $fromState -> $toState', tag: 'BLoC');
    }
  }
  
  /// 性能监控日志
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    final details = metadata != null ? ' | Metadata: $metadata' : '';
    info('$message$details', tag: 'Performance');
  }
}