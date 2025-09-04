import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Enterprise-grade BLoC observer for comprehensive state management monitoring
/// 企业级BLoC观察者，用于全面的状态管理监控
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver({
    this.enableDetailedLogging = kDebugMode,
    this.enablePerformanceMonitoring = kDebugMode,
    this.logLevel = LogLevel.info,
  });

  /// Whether to enable detailed logging
  /// 是否启用详细日志记录
  final bool enableDetailedLogging;

  /// Whether to enable performance monitoring
  /// 是否启用性能监控
  final bool enablePerformanceMonitoring;

  /// Current log level
  /// 当前日志级别
  final LogLevel logLevel;

  /// Performance tracking map
  /// 性能跟踪映射
  static final Map<String, DateTime> _performanceTracker = {};

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (enableDetailedLogging && _shouldLog(LogLevel.debug)) {
      _logWithLevel(
        LogLevel.debug,
        '🟢 [CREATE] ${bloc.runtimeType}',
        details: 'Bloc instance created successfully',
      );
    }

    if (enablePerformanceMonitoring) {
      _performanceTracker['${bloc.runtimeType}_created'] = DateTime.now();
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    if (_shouldLog(LogLevel.info)) {
      final blocName = bloc.runtimeType.toString();
      final currentState = _formatState(change.currentState);
      final nextState = _formatState(change.nextState);

      if (enableDetailedLogging) {
        _logWithLevel(
          LogLevel.info,
          '🔄 [CHANGE] $blocName',
          details: 'Current: $currentState → → → Next: $nextState',
        );
      } else {
        _logWithLevel(
          LogLevel.info,
          '🔄 [$blocName] $currentState → → → $nextState',
        );
      }
    }

    if (enablePerformanceMonitoring) {
      _trackStateChangePerformance(bloc, change);
    }
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);

    if (_shouldLog(LogLevel.debug)) {
      final blocName = bloc.runtimeType.toString();
      final event = _formatEvent(transition.event);
      final currentState = _formatState(transition.currentState);
      final nextState = _formatState(transition.nextState);

      _logWithLevel(
        LogLevel.debug,
        '⚡ [TRANSITION] $blocName',
        details: 'Event: $event\nCurrent: $currentState → → → Next: $nextState',
      );
    }
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    if (_shouldLog(LogLevel.debug)) {
      final blocName = bloc.runtimeType.toString();
      final eventStr = _formatEvent(event);

      _logWithLevel(
        LogLevel.debug,
        '📨 [EVENT] $blocName',
        details: 'Event: $eventStr',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Always log errors regardless of log level
    // 无论日志级别如何都要记录错误
    final blocName = bloc.runtimeType.toString();
    final errorType = error.runtimeType.toString();

    _logWithLevel(
      LogLevel.error,
      '❌ [ERROR] $blocName',
      details:
          'Error Type: $errorType\nError: $error\nStackTrace: ${_formatStackTrace(stackTrace)}',
      isError: true,
    );

    // Report to crash analytics in production
    // 在生产环境中报告给崩溃分析服务
    if (kReleaseMode) {
      _reportErrorToAnalytics(bloc, error, stackTrace);
    }

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    if (enableDetailedLogging && _shouldLog(LogLevel.debug)) {
      _logWithLevel(
        LogLevel.debug,
        '🔴 [CLOSE] ${bloc.runtimeType}',
        details: 'Bloc instance disposed',
      );
    }

    if (enablePerformanceMonitoring) {
      _logBlocLifecyclePerformance(bloc);
      _cleanupPerformanceTracking(bloc);
    }

    super.onClose(bloc);
  }

  /// Check if should log based on current log level
  /// 根据当前日志级别检查是否应该记录日志
  bool _shouldLog(LogLevel level) {
    return level.priority >= logLevel.priority;
  }

  /// Log with specific level and formatting
  /// 使用特定级别和格式记录日志
  void _logWithLevel(
    LogLevel level,
    String message, {
    String? details,
    bool isError = false,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(5);

    String logMessage = '[$timestamp] [$levelStr] $message';

    if (details != null && enableDetailedLogging) {
      logMessage += '\n  Details: $details';
    }

    if (isError) {
      // Use different logging for errors
      // 对错误使用不同的日志记录方式
      if (kDebugMode) {
        debugPrint(logMessage);
      } else {
        log(logMessage, level: 1000); // Error level
      }
    } else {
      log(logMessage, level: level.logLevel);
    }
  }

  /// Format state object for logging
  /// 格式化状态对象用于日志记录
  String _formatState(dynamic state) {
    if (state == null) return 'null';

    final stateStr = state.toString();
    // Truncate very long state strings
    // 截断过长的状态字符串
    if (stateStr.length > 100 && !enableDetailedLogging) {
      return '${stateStr.substring(0, 97)}...';
    }
    return stateStr;
  }

  /// Format event object for logging
  /// 格式化事件对象用于日志记录
  String _formatEvent(dynamic event) {
    if (event == null) return 'null';

    final eventStr = event.toString();
    // Truncate very long event strings
    // 截断过长的事件字符串
    if (eventStr.length > 100 && !enableDetailedLogging) {
      return '${eventStr.substring(0, 97)}...';
    }
    return eventStr;
  }

  /// Format stack trace for better readability
  /// 格式化堆栈跟踪以提高可读性
  String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    // Show only first 5 lines in non-detailed mode
    // 在非详细模式下只显示前5行
    if (!enableDetailedLogging && lines.length > 5) {
      return '${lines.take(5).join('\n')}\n... (${lines.length - 5} more lines)';
    }
    return stackTrace.toString();
  }

  /// Track state change performance
  /// 跟踪状态变化性能
  void _trackStateChangePerformance(
      BlocBase<dynamic> bloc, Change<dynamic> change) {
    final key = '${bloc.runtimeType}_state_change';
    final now = DateTime.now();

    if (_performanceTracker.containsKey(key)) {
      final duration = now.difference(_performanceTracker[key]!);
      if (duration.inMilliseconds > 100) {
        // Log slow state changes
        _logWithLevel(
          LogLevel.warning,
          '⚠️ [PERFORMANCE] Slow state change in ${bloc.runtimeType}',
          details: 'Duration: ${duration.inMilliseconds}ms',
        );
      }
    }

    _performanceTracker[key] = now;
  }

  /// Log bloc lifecycle performance
  /// 记录Bloc生命周期性能
  void _logBlocLifecyclePerformance(BlocBase<dynamic> bloc) {
    final createdKey = '${bloc.runtimeType}_created';
    if (_performanceTracker.containsKey(createdKey)) {
      final duration =
          DateTime.now().difference(_performanceTracker[createdKey]!);
      _logWithLevel(
        LogLevel.info,
        '📊 [LIFECYCLE] ${bloc.runtimeType} lived for ${duration.inSeconds}s',
      );
    }
  }

  /// Clean up performance tracking for closed bloc
  /// 清理已关闭Bloc的性能跟踪
  void _cleanupPerformanceTracking(BlocBase<dynamic> bloc) {
    final blocType = bloc.runtimeType.toString();
    _performanceTracker.removeWhere((key, _) => key.startsWith(blocType));
  }

  /// Report error to analytics service (placeholder)
  /// 向分析服务报告错误（占位符）
  void _reportErrorToAnalytics(
      BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // TODO: Implement crash analytics reporting
    // 待实现：崩溃分析报告
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

/// Log levels for BLoC observer
/// BLoC观察者的日志级别
enum LogLevel {
  debug(0, 500),
  info(1, 800),
  warning(2, 900),
  error(3, 1000);

  const LogLevel(this.priority, this.logLevel);

  /// Priority level for comparison
  /// 用于比较的优先级
  final int priority;

  /// Corresponding dart:developer log level
  /// 对应的dart:developer日志级别
  final int logLevel;
}
