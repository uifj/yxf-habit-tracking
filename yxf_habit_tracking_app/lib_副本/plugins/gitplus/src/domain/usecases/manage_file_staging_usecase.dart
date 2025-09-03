import '../repositories/git_repository.dart';

/// 管理文件暂存用例
class ManageFileStagingUseCase {
  final GitRepository _repository;

  const ManageFileStagingUseCase(this._repository);

  /// 暂存单个文件
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  Future<void> stageFile({
    required String repoPath,
    required String filePath,
  }) async {
    await _repository.stageFile(repoPath, filePath);
  }

  /// 取消暂存单个文件
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  Future<void> unstageFile({
    required String repoPath,
    required String filePath,
  }) async {
    await _repository.unstageFile(repoPath, filePath);
  }

  /// 暂存多个文件
  ///
  /// [repoPath] 仓库路径
  /// [filePaths] 文件路径列表
  Future<void> stageFiles({
    required String repoPath,
    required List<String> filePaths,
  }) async {
    for (final filePath in filePaths) {
      await _repository.stageFile(repoPath, filePath);
    }
  }

  /// 取消暂存多个文件
  ///
  /// [repoPath] 仓库路径
  /// [filePaths] 文件路径列表
  Future<void> unstageFiles({
    required String repoPath,
    required List<String> filePaths,
  }) async {
    for (final filePath in filePaths) {
      await _repository.unstageFile(repoPath, filePath);
    }
  }

  /// 暂存所有文件
  ///
  /// [repoPath] 仓库路径
  Future<void> stageAllFiles({
    required String repoPath,
  }) async {
    await _repository.stageAllFiles(repoPath);
  }

  /// 取消暂存所有文件
  ///
  /// [repoPath] 仓库路径
  Future<void> unstageAllFiles({
    required String repoPath,
  }) async {
    await _repository.unstageAllFiles(repoPath);
  }

  /// 切换文件暂存状态
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  /// [isCurrentlyStaged] 当前是否已暂存
  Future<void> toggleFileStaging({
    required String repoPath,
    required String filePath,
    required bool isCurrentlyStaged,
  }) async {
    if (isCurrentlyStaged) {
      await unstageFile(repoPath: repoPath, filePath: filePath);
    } else {
      await stageFile(repoPath: repoPath, filePath: filePath);
    }
  }

  /// 丢弃文件更改
  ///
  /// [repoPath] 仓库路径
  /// [filePath] 文件路径
  Future<void> discardFileChanges({
    required String repoPath,
    required String filePath,
  }) async {
    await _repository.discardFileChanges(repoPath, filePath);
  }

  /// 丢弃所有更改
  ///
  /// [repoPath] 仓库路径
  Future<void> discardAllChanges({
    required String repoPath,
  }) async {
    await _repository.discardAllChanges(repoPath);
  }
}
