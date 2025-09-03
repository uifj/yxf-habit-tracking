import '../models/git_repository_model.dart';
import '../models/git_commit_model.dart';
import '../models/git_file_status_model.dart';
import '../models/git_diff_model.dart';
import '../models/git_config_model.dart';

/// Git数据源抽象接口
abstract class GitDataSource {
  /// 初始化Git仓库
  Future<GitRepositoryModel> initRepository(String path,
      {String? initialBranch});

  /// 检查是否为Git仓库
  Future<bool> isGitRepository(String path);

  /// 从现有路径获取Git仓库信息
  Future<GitRepositoryModel> getRepository(String path);

  /// 获取仓库状态
  Future<GitRepositoryModel> getRepositoryStatus(String path);

  /// 获取文件状态列表
  Future<List<GitFileStatusModel>> getFileStatuses(String path);

  /// 暂存文件
  Future<void> stageFile(String repoPath, String filePath);

  /// 取消暂存文件
  Future<void> unstageFile(String repoPath, String filePath);

  /// 暂存所有文件
  Future<void> stageAllFiles(String repoPath);

  /// 取消暂存所有文件
  Future<void> unstageAllFiles(String repoPath);

  /// 提交更改
  Future<String> commit(String repoPath, String message, {List<String>? files});

  /// 推送到远程仓库
  Future<void> push(String repoPath, {String? remote, String? branch});

  /// 从远程仓库拉取
  Future<void> pull(String repoPath, {String? remote, String? branch});

  /// 获取提交历史
  Future<List<GitCommitModel>> getCommitHistory(
    String repoPath, {
    String? branch,
    int? limit,
    int? skip,
  });

  /// 获取特定提交信息
  Future<GitCommitModel> getCommit(String repoPath, String sha);

  /// 获取文件差异
  Future<GitDiffModel> getFileDiff(
    String repoPath,
    String filePath, {
    String? fromCommit,
    String? toCommit,
    bool staged = false,
  });

  /// 获取提交差异
  Future<List<GitDiffModel>> getCommitDiff(String repoPath, String sha);

  /// 获取分支列表
  Future<List<String>> getBranches(String repoPath,
      {bool includeRemote = false});

  /// 获取当前分支
  Future<String?> getCurrentBranch(String repoPath);

  /// 创建分支
  Future<void> createBranch(String repoPath, String branchName,
      {String? fromBranch});

  /// 切换分支
  Future<void> checkoutBranch(String repoPath, String branchName);

  /// 删除分支
  Future<void> deleteBranch(String repoPath, String branchName,
      {bool force = false});

  /// 获取远程仓库列表
  Future<Map<String, String>> getRemotes(String repoPath);

  /// 添加远程仓库
  Future<void> addRemote(String repoPath, String name, String url);

  /// 删除远程仓库
  Future<void> removeRemote(String repoPath, String name);

  /// 获取标签列表
  Future<List<String>> getTags(String repoPath);

  /// 创建标签
  Future<void> createTag(String repoPath, String tagName, {String? message});

  /// 删除标签
  Future<void> deleteTag(String repoPath, String tagName);

  /// 丢弃文件更改
  Future<void> discardFileChanges(String repoPath, String filePath);

  /// 丢弃所有更改
  Future<void> discardAllChanges(String repoPath);

  /// 获取子模块列表
  Future<List<String>> getSubmodules(String repoPath);

  /// 初始化子模块
  Future<void> initSubmodules(String repoPath);

  /// 更新子模块
  Future<void> updateSubmodules(String repoPath);

  /// 克隆仓库
  Future<GitRepositoryModel> cloneRepository(
    String url,
    String localPath, {
    String? branch,
    bool recursive = false,
  });

  /// 获取Git配置
  Future<GitConfigModel> getConfig(String repoPath);

  /// 保存Git配置
  Future<void> saveConfig(String repoPath, GitConfigModel config);

  /// 检查工作树是否干净
  Future<bool> isWorkingTreeClean(String repoPath);

  /// 获取提交数量
  Future<int> getCommitCount(String repoPath, {String? branch});

  /// 获取最后一次提交信息
  Future<GitCommitModel?> getLastCommit(String repoPath, {String? branch});

  /// 重置到特定提交
  Future<void> resetToCommit(
    String repoPath,
    String sha, {
    bool hard = false,
  });

  /// 合并分支
  Future<void> mergeBranch(String repoPath, String branchName);

  /// 变基分支
  Future<void> rebaseBranch(String repoPath, String branchName);

  /// 获取冲突文件列表
  Future<List<String>> getConflictFiles(String repoPath);

  /// 解决冲突
  Future<void> resolveConflict(String repoPath, String filePath);

  /// 中止合并
  Future<void> abortMerge(String repoPath);

  /// 继续合并
  Future<void> continueMerge(String repoPath);
}
