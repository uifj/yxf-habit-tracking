/// 抽象异常类
/// 所有自定义异常的基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException({
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

  @override
  String toString() => 'ServerException: $message (Code: $code)';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({
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

  @override
  String toString() => 'NetworkException: $message (Code: $code)';
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({
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

  @override
  String toString() => 'CacheException: $message (Code: $code)';
}

/// 数据库异常
class DatabaseException extends AppException {
  const DatabaseException({
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

  @override
  String toString() => 'DatabaseException: $message (Code: $code)';
}

/// 验证异常
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'ValidationException: $message (Code: $code)';
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
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

  @override
  String toString() => 'PermissionException: $message (Code: $code)';
}

/// 通知异常
class NotificationException extends AppException {
  const NotificationException({
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

  @override
  String toString() => 'NotificationException: $message (Code: $code)';
}

/// 同步异常
class SyncException extends AppException {
  const SyncException({
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

  @override
  String toString() => 'SyncException: $message (Code: $code)';
}

/// 任务不存在异常
class TaskNotFoundException extends AppException {
  const TaskNotFoundException({
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

  @override
  String toString() => 'TaskNotFoundException: $message (Code: $code)';
}

/// 任务已存在异常
class TaskAlreadyExistsException extends AppException {
  const TaskAlreadyExistsException({
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

  @override
  String toString() => 'TaskAlreadyExistsException: $message (Code: $code)';
}

/// 无效任务数据异常
class InvalidTaskDataException extends AppException {
  const InvalidTaskDataException({
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

  @override
  String toString() => 'InvalidTaskDataException: $message (Code: $code)';
}
