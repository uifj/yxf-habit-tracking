import '../entities/git_commit_entity.dart';
import '../repositories/git_repository.dart';

/// 获取提交历史用例
class GetCommitHistoryUseCase {
  final GitRepository _repository;

  const GetCommitHistoryUseCase(this._repository);

  /// 执行获取提交历史
  ///
  /// [repoPath] 仓库路径
  /// [branch] 分支名称，默认为null（使用当前分支）
  /// [limit] 限制返回的提交数量，默认为null（不限制）
  /// [skip] 跳过的提交数量，默认为null（不跳过）
  Future<List<GitCommitEntity>> call({
    required String repoPath,
    String? branch,
    int? limit,
    int? skip,
  }) async {
    return await _repository.getCommitHistory(
      repoPath,
      branch: branch,
      limit: limit,
      skip: skip,
    );
  }

  /// 获取分页的提交历史
  ///
  /// [repoPath] 仓库路径
  /// [page] 页码（从0开始）
  /// [pageSize] 每页大小
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<List<GitCommitEntity>> getPaginatedHistory({
    required String repoPath,
    required int page,
    required int pageSize,
    String? branch,
  }) async {
    if (page < 0) {
      throw ArgumentError('Page must be non-negative');
    }
    if (pageSize <= 0) {
      throw ArgumentError('Page size must be positive');
    }

    final skip = page * pageSize;
    return await call(
      repoPath: repoPath,
      branch: branch,
      limit: pageSize,
      skip: skip,
    );
  }

  /// 获取最近的提交
  ///
  /// [repoPath] 仓库路径
  /// [count] 获取的提交数量，默认为10
  /// [branch] 分支名称，默认为null（使用当前分支）
  Future<List<GitCommitEntity>> getRecentCommits({
    required String repoPath,
    int count = 10,
    String? branch,
  }) async {
    if (count <= 0) {
      throw ArgumentError('Count must be positive');
    }

    return await call(
      repoPath: repoPath,
      branch: branch,
      limit: count,
    );
  }
}
