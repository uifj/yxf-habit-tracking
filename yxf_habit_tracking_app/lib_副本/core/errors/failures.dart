import 'package:equatable/equatable.dart';

/// 基础失败类
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

/// 网络连接失败
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// 数据库失败
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

/// 文件操作失败
class FileFailure extends Failure {
  const FileFailure(String message) : super(message);
}

/// 音频播放失败
class AudioFailure extends Failure {
  const AudioFailure(String message) : super(message);
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

/// 验证失败
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// 词典加载失败
class DictionaryFailure extends Failure {
  const DictionaryFailure(String message) : super(message);
}

/// 打字练习失败
class TypingFailure extends Failure {
  const TypingFailure(String message) : super(message);
}

/// 统计数据失败
class StatisticsFailure extends Failure {
  const StatisticsFailure(String message) : super(message);
}
