import '../entities/git_file_status_entity.dart';
import '../repositories/git_repository.dart';

/// 获取文件状态列表用例
class GetFileStatusesUseCase {
  final GitRepository _repository;

  const GetFileStatusesUseCase(this._repository);

  /// 执行获取文件状态列表
  Future<List<GitFileStatusEntity>> call(String repoPath) async {
    return await _repository.getFileStatuses(repoPath);
  }
}
