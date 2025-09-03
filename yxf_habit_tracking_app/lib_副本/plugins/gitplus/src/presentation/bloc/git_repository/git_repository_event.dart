import 'package:equatable/equatable.dart';

/// Git仓库事件基类
abstract class GitRepositoryEvent extends Equatable {
  const GitRepositoryEvent();

  @override
  List<Object?> get props => [];
}

/// 加载仓库状态事件
class LoadRepositoryStatus extends GitRepositoryEvent {
  final String repoPath;

  const LoadRepositoryStatus(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 刷新仓库状态事件
class RefreshRepositoryStatus extends GitRepositoryEvent {
  final String repoPath;

  const RefreshRepositoryStatus(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 初始化仓库事件
class InitializeRepository extends GitRepositoryEvent {
  final String repoPath;
  final String? initialBranch;

  const InitializeRepository(this.repoPath, {this.initialBranch});

  @override
  List<Object?> get props => [repoPath, initialBranch];
}

/// 克隆仓库事件
class CloneRepository extends GitRepositoryEvent {
  final String url;
  final String localPath;
  final String? branch;
  final bool recursive;

  const CloneRepository(
    this.url,
    this.localPath, {
    this.branch,
    this.recursive = false,
  });

  @override
  List<Object?> get props => [url, localPath, branch, recursive];
}

/// 检查是否为Git仓库事件
class CheckIsGitRepository extends GitRepositoryEvent {
  final String repoPath;

  const CheckIsGitRepository(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 获取提交数量事件
class GetCommitCount extends GitRepositoryEvent {
  final String repoPath;
  final String? branch;

  const GetCommitCount(this.repoPath, {this.branch});

  @override
  List<Object?> get props => [repoPath, branch];
}

/// 获取当前分支事件
class GetCurrentBranch extends GitRepositoryEvent {
  final String repoPath;

  const GetCurrentBranch(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 获取分支列表事件
class GetBranches extends GitRepositoryEvent {
  final String repoPath;
  final bool includeRemote;

  const GetBranches(this.repoPath, {this.includeRemote = false});

  @override
  List<Object?> get props => [repoPath, includeRemote];
}

/// 获取远程仓库列表事件
class GetRemotes extends GitRepositoryEvent {
  final String repoPath;

  const GetRemotes(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 检查工作树是否干净事件
class CheckWorkingTreeClean extends GitRepositoryEvent {
  final String repoPath;

  const CheckWorkingTreeClean(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}
