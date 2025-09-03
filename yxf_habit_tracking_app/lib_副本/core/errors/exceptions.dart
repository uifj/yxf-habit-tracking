/// 基础异常类
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(String message, {int? code})
      : super(message, code: code);
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

/// 数据库异常
class DatabaseException extends AppException {
  const DatabaseException(String message) : super(message);
}

/// 文件操作异常
class FileException extends AppException {
  const FileException(String message) : super(message);
}

/// 音频播放异常
class AudioException extends AppException {
  const AudioException(String message) : super(message);
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException(String message) : super(message);
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

/// 词典异常
class DictionaryException extends AppException {
  const DictionaryException(String message) : super(message);
}

/// 打字练习异常
class TypingException extends AppException {
  const TypingException(String message) : super(message);
}

/// 统计数据异常
class StatisticsException extends AppException {
  const StatisticsException(String message) : super(message);
}

/// JSON解析异常
class JsonParsingException extends AppException {
  const JsonParsingException(String message) : super(message);
}

/// 配置异常
class ConfigurationException extends AppException {
  const ConfigurationException(String message) : super(message);
}
