import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'exceptions.dart';
import 'failures.dart';

/// 错误处理器抽象接口
abstract class ErrorHandler {
  /// 处理异常并转换为失败对象
  Failure handleException(Exception exception);
  
  /// 处理错误并转换为失败对象
  Failure handleError(Object error);
  
  /// 记录错误日志
  void logError(Object error, {StackTrace? stackTrace, String? context});
  
  /// 记录警告日志
  void logWarning(String message, {String? context});
  
  /// 记录信息日志
  void logInfo(String message, {String? context});
  
  /// 上报错误到监控系统
  Future<void> reportError(Object error, {StackTrace? stackTrace, Map<String, dynamic>? context});
}

/// 错误处理器实现类
class ErrorHandlerImpl implements ErrorHandler {
  static const String _tag = 'ErrorHandler';
  
  @override
  Failure handleException(Exception exception) {
    logError(exception, context: 'Exception handled');
    
    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    }
    
    // 处理系统异常
    if (exception is FormatException) {
      return const ValidationFailure(
        message: '数据格式错误',
        code: 'FORMAT_ERROR',
      );
    }
    
    if (exception is ArgumentError) {
      return const ValidationFailure(
        message: '参数错误',
        code: 'ARGUMENT_ERROR',
      );
    }
    
    // 未知异常
    return UnknownFailure(
      message: '未知异常: ${exception.toString()}',
      code: 'UNKNOWN_EXCEPTION',
    );
  }
  
  @override
  Failure handleError(Object error) {
    logError(error, context: 'Error handled');
    
    if (error is Exception) {
      return handleException(error);
    }
    
    // 处理非异常错误
    return UnknownFailure(
      message: '未知错误: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
    );
  }
  
  @override
  void logError(Object error, {StackTrace? stackTrace, String? context}) {
    final message = _formatLogMessage('ERROR', error.toString(), context);
    
    if (kDebugMode) {
      log(message, name: _tag, error: error, stackTrace: stackTrace);
    }
    
    // 在生产环境中，这里可以集成 Crashlytics 或 Sentry
    _reportToMonitoring(error, stackTrace: stackTrace, context: context);
  }
  
  @override
  void logWarning(String message, {String? context}) {
    final formattedMessage = _formatLogMessage('WARNING', message, context);
    
    if (kDebugMode) {
      log(formattedMessage, name: _tag);
    }
  }
  
  @override
  void logInfo(String message, {String? context}) {
    final formattedMessage = _formatLogMessage('INFO', message, context);
    
    if (kDebugMode) {
      log(formattedMessage, name: _tag);
    }
  }
  
  @override
  Future<void> reportError(Object error, {StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    try {
      // 这里可以集成第三方错误监控服务
      // 例如：Firebase Crashlytics, Sentry, Bugsnag 等
      
      logError(error, stackTrace: stackTrace, context: context?.toString());
      
      // 示例：上报到远程服务
      // await _crashlyticsService.recordError(error, stackTrace, context);
    } catch (e) {
      // 确保错误上报本身不会导致应用崩溃
      if (kDebugMode) {
        log('Failed to report error: $e', name: _tag);
      }
    }
  }
  
  /// 将应用异常映射为失败对象
  Failure _mapAppExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        return ServerFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'SERVER_ERROR',
        );
      
      case NetworkException:
        return NetworkFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'NETWORK_ERROR',
        );
      
      case DatabaseException:
        return DatabaseFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'DATABASE_ERROR',
        );
      
      case CacheException:
        return CacheFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'CACHE_ERROR',
        );
      
      case ValidationException:
        return ValidationFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'VALIDATION_ERROR',
        );
      
      case PermissionException:
        return PermissionFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'PERMISSION_ERROR',
        );
      
      case NotificationException:
        return NotificationFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'NOTIFICATION_ERROR',
        );
      
      case SyncException:
        return SyncFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'SYNC_ERROR',
        );
      
      default:
        return UnknownFailure(
          message: exception.message,
          code: exception.code?.toString() ?? 'UNKNOWN_APP_ERROR',
        );
    }
  }
  
  /// 格式化日志消息
  String _formatLogMessage(String level, String message, String? context) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' [$context]' : '';
    return '[$timestamp] [$level]$contextStr $message';
  }
  
  /// 上报到监控系统（内部方法）
  void _reportToMonitoring(Object error, {StackTrace? stackTrace, String? context}) {
    // 这里可以实现具体的监控系统集成
    // 例如：Firebase Crashlytics, Sentry 等
    
    // 示例实现：
    // if (!kDebugMode) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }
}

/// 重试策略接口
abstract class RetryStrategy {
  /// 是否应该重试
  bool shouldRetry(int attemptCount, Exception exception);
  
  /// 获取重试延迟时间
  Duration getRetryDelay(int attemptCount);
  
  /// 最大重试次数
  int get maxRetries;
}

/// 指数退避重试策略
class ExponentialBackoffRetryStrategy implements RetryStrategy {
  final int _maxRetries;
  final Duration _baseDelay;
  final double _multiplier;
  final Duration _maxDelay;
  
  const ExponentialBackoffRetryStrategy({
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 500),
    double multiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 30),
  }) : _maxRetries = maxRetries,
       _baseDelay = baseDelay,
       _multiplier = multiplier,
       _maxDelay = maxDelay;
  
  @override
  bool shouldRetry(int attemptCount, Exception exception) {
    if (attemptCount >= _maxRetries) return false;
    
    // 某些异常不应该重试
    if (exception is ValidationException || 
        exception is PermissionException) {
      return false;
    }
    
    return true;
  }
  
  @override
  Duration getRetryDelay(int attemptCount) {
    final delay = Duration(
      milliseconds: (_baseDelay.inMilliseconds * 
                    (attemptCount * _multiplier)).round(),
    );
    
    return delay > _maxDelay ? _maxDelay : delay;
  }
  
  @override
  int get maxRetries => _maxRetries;
}

/// 重试执行器
class RetryExecutor {
  final RetryStrategy _strategy;
  final ErrorHandler _errorHandler;
  
  const RetryExecutor({
    required RetryStrategy strategy,
    required ErrorHandler errorHandler,
  }) : _strategy = strategy,
       _errorHandler = errorHandler;
  
  /// 执行带重试的操作
  Future<T> execute<T>(Future<T> Function() operation) async {
    int attemptCount = 0;
    Exception? lastException;
    
    while (attemptCount <= _strategy.maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        if (!_strategy.shouldRetry(attemptCount, lastException)) {
          _errorHandler.logError(
            'Operation failed after $attemptCount attempts',
            context: 'RetryExecutor',
          );
          rethrow;
        }
        
        if (attemptCount < _strategy.maxRetries) {
          final delay = _strategy.getRetryDelay(attemptCount);
          _errorHandler.logWarning(
            'Retrying operation in ${delay.inMilliseconds}ms (attempt ${attemptCount + 1}/${_strategy.maxRetries})',
            context: 'RetryExecutor',
          );
          await Future.delayed(delay);
        }
        
        attemptCount++;
      }
    }
    
    // 如果所有重试都失败了，抛出最后一个异常
    throw lastException!;
  }
}