import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 日志条目类
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final timeStr = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag.padRight(15);
    
    String result = '[$timeStr] $levelStr [$tagStr] $message';
    
    if (error != null) {
      result += '\nError: $error';
    }
    
    if (stackTrace != null && AppConfig.isDebugMode) {
      result += '\nStack trace:\n$stackTrace';
    }
    
    return result;
  }
}

/// 企业级日志管理器
/// 统一管理应用的日志记录和输出
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // 日志缓存
  static final List<LogEntry> _logCache = [];
  static const int _maxCacheSize = 1000;

  /// 调试日志
  static void debug(String message, {String tag = 'DEBUG', dynamic error}) {
    _log(LogLevel.debug, tag, message, error: error);
  }

  /// 信息日志
  static void info(String message, {String tag = 'INFO', dynamic error}) {
    _log(LogLevel.info, tag, message, error: error);
  }

  /// 警告日志
  static void warning(String message, {String tag = 'WARNING', dynamic error}) {
    _log(LogLevel.warning, tag, message, error: error);
  }

  /// 错误日志
  static void error(String message, {String tag = 'ERROR', dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志
  static void fatal(String message, {String tag = 'FATAL', dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, tag, message, error: error, stackTrace: stackTrace);
  }

  /// 网络请求日志
  static void network(String method, String url, {int? statusCode, String? response, dynamic error}) {
    final message = '$method $url${statusCode != null ? ' ($statusCode)' : ''}';
    if (error != null) {
      AppLogger.error(message, tag: 'NETWORK', error: error);
    } else {
      AppLogger.info(message, tag: 'NETWORK');
    }
    
    if (response != null && AppConfig.isDebugMode) {
      AppLogger.debug('Response: $response', tag: 'NETWORK');
    }
  }

  /// 用户行为日志
  static void userAction(String action, {Map<String, dynamic>? parameters}) {
    String message = 'User action: $action';
    if (parameters != null && parameters.isNotEmpty) {
      message += ' with parameters: $parameters';
    }
    AppLogger.info(message, tag: 'USER_ACTION');
  }

  /// 性能日志
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
    String message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    if (metrics != null && metrics.isNotEmpty) {
      message += ' (metrics: $metrics)';
    }
    AppLogger.info(message, tag: 'PERFORMANCE');
  }

  /// 生命周期日志
  static void lifecycle(String component, String event, {Map<String, dynamic>? data}) {
    String message = 'Lifecycle: $component -> $event';
    if (data != null && data.isNotEmpty) {
      message += ' (data: $data)';
    }
    AppLogger.debug(message, tag: 'LIFECYCLE');
  }

  /// 内部日志记录方法
  static void _log(
    LogLevel level,
    String tag,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    // 添加到缓存
    _addToCache(entry);

    // 根据配置决定是否输出
    if (_shouldLog(level)) {
      _outputLog(entry);
    }
  }

  /// 判断是否应该记录日志
  static bool _shouldLog(LogLevel level) {
    if (AppConfig.isReleaseMode) {
      // 生产环境只记录警告及以上级别
      return level.index >= LogLevel.warning.index;
    } else if (AppConfig.isProfileMode) {
      // 性能测试环境记录信息及以上级别
      return level.index >= LogLevel.info.index;
    } else {
      // 调试环境记录所有级别
      return true;
    }
  }

  /// 输出日志
  static void _outputLog(LogEntry entry) {
    final output = entry.toString();
    
    switch (entry.level) {
      case LogLevel.debug:
        debugPrint(output);
        break;
      case LogLevel.info:
        debugPrint(output);
        break;
      case LogLevel.warning:
        debugPrint('⚠️ $output');
        break;
      case LogLevel.error:
        debugPrint('❌ $output');
        break;
      case LogLevel.fatal:
        debugPrint('💀 $output');
        break;
    }
  }

  /// 添加到缓存
  static void _addToCache(LogEntry entry) {
    _logCache.add(entry);
    
    // 限制缓存大小
    if (_logCache.length > _maxCacheSize) {
      _logCache.removeAt(0);
    }
  }

  /// 获取日志缓存
  static List<LogEntry> getLogs({LogLevel? minLevel, String? tag, int? limit}) {
    var logs = _logCache.where((entry) {
      if (minLevel != null && entry.level.index < minLevel.index) {
        return false;
      }
      if (tag != null && entry.tag != tag) {
        return false;
      }
      return true;
    }).toList();

    if (limit != null && logs.length > limit) {
      logs = logs.sublist(logs.length - limit);
    }

    return logs;
  }

  /// 清空日志缓存
  static void clearLogs() {
    _logCache.clear();
    AppLogger.info('Log cache cleared', tag: 'LOGGER');
  }

  /// 导出日志
  static String exportLogs({LogLevel? minLevel, String? tag}) {
    final logs = getLogs(minLevel: minLevel, tag: tag);
    final buffer = StringBuffer();
    
    buffer.writeln('=== ${AppConfig.appName} Log Export ===');
    buffer.writeln('Export Time: ${DateTime.now().toIso8601String()}');
    buffer.writeln('App Version: ${AppConfig.appVersion}');
    buffer.writeln('Platform: ${defaultTargetPlatform.name}');
    buffer.writeln('Debug Mode: ${AppConfig.isDebugMode}');
    buffer.writeln('Total Logs: ${logs.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (final log in logs) {
      buffer.writeln(log.toString());
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  /// 获取日志统计信息
  static Map<String, int> getLogStats() {
    final stats = <String, int>{};
    
    for (final level in LogLevel.values) {
      stats[level.name] = _logCache.where((entry) => entry.level == level).length;
    }
    
    return stats;
  }

  /// 打印日志统计信息
  static void printLogStats() {
    if (AppConfig.isDebugMode) {
      final stats = getLogStats();
      AppLogger.info('Log Statistics: $stats', tag: 'LOGGER');
    }
  }

  /// 初始化日志系统
  static void initialize() {
    AppLogger.info('Logger initialized', tag: 'LOGGER');
    AppLogger.info('App: ${AppConfig.appName} v${AppConfig.appVersion}', tag: 'LOGGER');
    AppLogger.info('Platform: ${defaultTargetPlatform.name}', tag: 'LOGGER');
    AppLogger.info('Debug Mode: ${AppConfig.isDebugMode}', tag: 'LOGGER');
  }
}