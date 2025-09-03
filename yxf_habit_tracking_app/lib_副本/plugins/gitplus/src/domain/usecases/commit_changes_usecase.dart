import '../repositories/git_repository.dart';

/// 提交更改用例
class CommitChangesUseCase {
  final GitRepository _repository;

  const CommitChangesUseCase(this._repository);

  /// 执行提交更改
  ///
  /// [repoPath] 仓库路径
  /// [message] 提交消息
  /// [files] 要提交的文件列表，如果为null则提交所有已暂存的文件
  ///
  /// 返回提交的SHA值
  Future<String> call({
    required String repoPath,
    required String message,
    List<String>? files,
  }) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Commit message cannot be empty');
    }

    return await _repository.commit(repoPath, message, files: files);
  }
}
