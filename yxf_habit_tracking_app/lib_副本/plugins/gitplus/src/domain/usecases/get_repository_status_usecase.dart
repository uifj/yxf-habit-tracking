import '../entities/git_repository_entity.dart';
import '../repositories/git_repository.dart';

/// 获取仓库状态用例
class GetRepositoryStatusUseCase {
  final GitRepository _repository;

  const GetRepositoryStatusUseCase(this._repository);

  /// 执行获取仓库状态
  Future<GitRepositoryEntity> call(String repoPath) async {
    return await _repository.getRepositoryStatus(repoPath);
  }
}
