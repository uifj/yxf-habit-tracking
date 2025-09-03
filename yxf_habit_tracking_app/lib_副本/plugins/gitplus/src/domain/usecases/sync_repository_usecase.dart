import '../repositories/git_repository.dart';

/// 同步仓库用例
class SyncRepositoryUseCase {
  final GitRepository _repository;

  const SyncRepositoryUseCase(this._repository);

  /// 执行拉取操作
  ///
  /// [repoPath] 仓库路径
  /// [remote] 远程仓库名称，默认为null（使用默认远程仓库）
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<void> pull({
    required String repoPath,
    String? remote,
    String? branch,
  }) async {
    await _repository.pull(repoPath, remote: remote, branch: branch);
  }

  /// 执行推送操作
  ///
  /// [repoPath] 仓库路径
  /// [remote] 远程仓库名称，默认为null（使用默认远程仓库）
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<void> push({
    required String repoPath,
    String? remote,
    String? branch,
  }) async {
    await _repository.push(repoPath, remote: remote, branch: branch);
  }

  /// 执行完整同步（先拉取，再推送）
  ///
  /// [repoPath] 仓库路径
  /// [remote] 远程仓库名称，默认为null（使用默认远程仓库）
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<void> sync({
    required String repoPath,
    String? remote,
    String? branch,
  }) async {
    // 先拉取最新更改
    await pull(repoPath: repoPath, remote: remote, branch: branch);

    // 检查是否有本地更改需要推送
    final isClean = await _repository.isWorkingTreeClean(repoPath);
    if (!isClean) {
      // 如果工作树不干净，说明有未提交的更改
      throw Exception(
          'Working tree is not clean. Please commit or stash your changes first.');
    }

    // 推送本地提交
    await push(repoPath: repoPath, remote: remote, branch: branch);
  }

  /// 执行自动同步（提交 + 拉取 + 推送）
  ///
  /// [repoPath] 仓库路径
  /// [commitMessage] 提交消息
  /// [remote] 远程仓库名称，默认为null（使用默认远程仓库）
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<void> autoSync({
    required String repoPath,
    required String commitMessage,
    String? remote,
    String? branch,
  }) async {
    // 检查是否有更改需要提交
    final isClean = await _repository.isWorkingTreeClean(repoPath);

    if (!isClean) {
      // 暂存所有更改
      await _repository.stageAllFiles(repoPath);

      // 提交更改
      await _repository.commit(repoPath, commitMessage);
    }

    // 执行同步
    await sync(repoPath: repoPath, remote: remote, branch: branch);
  }
}
