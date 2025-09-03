import 'package:equatable/equatable.dart';

/// 失败抽象基类
/// 用于表示应用中的各种错误情况
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const Failure({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  List<Object?> get props => [message, code, originalError];
  
  @override
  String toString() {
    return '$runtimeType(message: $message, code: $code)';
  }
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory ServerFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return ServerFailure(
      message: '服务器错误: ${exception.toString()}',
      code: 'SERVER_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// 网络错误
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: '网络连接不可用，请检查网络设置',
      code: 'NO_CONNECTION',
    );
  }
  
  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: '网络请求超时，请稍后重试',
      code: 'TIMEOUT',
    );
  }
  
  factory NetworkFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return NetworkFailure(
      message: '网络错误: ${exception.toString()}',
      code: 'NETWORK_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory CacheFailure.notFound() {
    return const CacheFailure(
      message: '缓存数据未找到',
      code: 'CACHE_NOT_FOUND',
    );
  }
  
  factory CacheFailure.corrupted() {
    return const CacheFailure(
      message: '缓存数据已损坏',
      code: 'CACHE_CORRUPTED',
    );
  }
  
  factory CacheFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return CacheFailure(
      message: '缓存错误: ${exception.toString()}',
      code: 'CACHE_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// 数据库错误
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory DatabaseFailure.notFound() {
    return const DatabaseFailure(
      message: '数据未找到',
      code: 'DATA_NOT_FOUND',
    );
  }
  
  factory DatabaseFailure.constraintViolation() {
    return const DatabaseFailure(
      message: '数据约束违反',
      code: 'CONSTRAINT_VIOLATION',
    );
  }
  
  factory DatabaseFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return DatabaseFailure(
      message: '数据库错误: ${exception.toString()}',
      code: 'DATABASE_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// 验证错误
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;
  
  const ValidationFailure({
    required String message,
    String? code,
    this.fieldErrors = const {},
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory ValidationFailure.field(String field, String error) {
    return ValidationFailure(
      message: '验证失败: $error',
      code: 'VALIDATION_ERROR',
      fieldErrors: {field: [error]},
    );
  }
  
  factory ValidationFailure.multiple(Map<String, List<String>> errors) {
    final allErrors = errors.values.expand((e) => e).join(', ');
    return ValidationFailure(
      message: '验证失败: $allErrors',
      code: 'VALIDATION_ERROR',
      fieldErrors: errors,
    );
  }
  
  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// 权限错误
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory PermissionFailure.denied(String permission) {
    return PermissionFailure(
      message: '权限被拒绝: $permission',
      code: 'PERMISSION_DENIED',
    );
  }
  
  factory PermissionFailure.notGranted(String permission) {
    return PermissionFailure(
      message: '权限未授予: $permission',
      code: 'PERMISSION_NOT_GRANTED',
    );
  }
}

/// 通知错误
class NotificationFailure extends Failure {
  const NotificationFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory NotificationFailure.permissionDenied() {
    return const NotificationFailure(
      message: '通知权限被拒绝',
      code: 'NOTIFICATION_PERMISSION_DENIED',
    );
  }
  
  factory NotificationFailure.schedulingFailed() {
    return const NotificationFailure(
      message: '通知调度失败',
      code: 'NOTIFICATION_SCHEDULING_FAILED',
    );
  }
}

/// 同步错误
class SyncFailure extends Failure {
  const SyncFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory SyncFailure.conflictDetected() {
    return const SyncFailure(
      message: '数据同步冲突，请手动解决',
      code: 'SYNC_CONFLICT',
    );
  }
  
  factory SyncFailure.versionMismatch() {
    return const SyncFailure(
      message: '数据版本不匹配',
      code: 'VERSION_MISMATCH',
    );
  }
  
  factory SyncFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return SyncFailure(
      message: '同步错误: ${exception.toString()}',
      code: 'SYNC_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// 未知错误
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
  
  factory UnknownFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return UnknownFailure(
      message: '未知错误: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
  
  factory UnknownFailure.fromError(Error error, [StackTrace? stackTrace]) {
    return UnknownFailure(
      message: '系统错误: ${error.toString()}',
      code: 'SYSTEM_ERROR',
      originalError: error,
      stackTrace: stackTrace ?? error.stackTrace,
    );
  }
}