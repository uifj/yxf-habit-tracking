import '../entities/git_diff_entity.dart';
import '../repositories/git_repository.dart';

/// 获取文件差异用例
class GetFileDiffUseCase {
  final GitRepository _repository;

  const GetFileDiffUseCase(this._repository);

  /// 获取文件差异
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  /// [fromCommit] 起始提交SHA，默认为null
  /// [toCommit] 结束提交SHA，默认为null
  /// [staged] 是否获取暂存区差异，默认为false
  Future<GitDiffEntity> call({
    required String repoPath,
    required String filePath,
    String? fromCommit,
    String? toCommit,
    bool staged = false,
  }) async {
    return await _repository.getFileDiff(
      repoPath,
      filePath,
      fromCommit: fromCommit,
      toCommit: toCommit,
      staged: staged,
    );
  }

  /// 获取工作区文件差异（与HEAD比较）
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  Future<GitDiffEntity> getWorkingDiff({
    required String repoPath,
    required String filePath,
  }) async {
    return await call(
      repoPath: repoPath,
      filePath: filePath,
      fromCommit: 'HEAD',
    );
  }

  /// 获取暂存区文件差异（与HEAD比较）
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  Future<GitDiffEntity> getStagedDiff({
    required String repoPath,
    required String filePath,
  }) async {
    return await call(
      repoPath: repoPath,
      filePath: filePath,
      staged: true,
    );
  }

  /// 获取两个提交之间的文件差异
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  /// [fromCommit] 起始提交SHA
  /// [toCommit] 结束提交SHA
  Future<GitDiffEntity> getCommitDiff({
    required String repoPath,
    required String filePath,
    required String fromCommit,
    required String toCommit,
  }) async {
    return await call(
      repoPath: repoPath,
      filePath: filePath,
      fromCommit: fromCommit,
      toCommit: toCommit,
    );
  }

  /// 获取提交的所有文件差异
  ///
  /// [repoPath] 仓库路径
  /// [commitSha] 提交SHA
  Future<List<GitDiffEntity>> getCommitAllDiffs({
    required String repoPath,
    required String commitSha,
  }) async {
    return await _repository.getCommitDiff(repoPath, commitSha);
  }
}
