import 'package:equatable/equatable.dart';
import '../../../domain/entities/git_repository_entity.dart';

/// Git仓库状态基类
abstract class GitRepositoryState extends Equatable {
  const GitRepositoryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class GitRepositoryInitial extends GitRepositoryState {
  const GitRepositoryInitial();
}

/// 加载中状态
class GitRepositoryLoading extends GitRepositoryState {
  const GitRepositoryLoading();
}

/// 加载成功状态
class GitRepositoryLoaded extends GitRepositoryState {
  final GitRepositoryEntity repository;

  const GitRepositoryLoaded(this.repository);

  @override
  List<Object?> get props => [repository];
}

/// 加载失败状态
class GitRepositoryError extends GitRepositoryState {
  final String message;
  final Exception? exception;

  const GitRepositoryError(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}

/// 仓库不存在状态
class GitRepositoryNotFound extends GitRepositoryState {
  final String repoPath;

  const GitRepositoryNotFound(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 不是Git仓库状态
class NotGitRepository extends GitRepositoryState {
  final String repoPath;

  const NotGitRepository(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 仓库初始化成功状态
class GitRepositoryInitialized extends GitRepositoryState {
  final GitRepositoryEntity repository;

  const GitRepositoryInitialized(this.repository);

  @override
  List<Object?> get props => [repository];
}

/// 仓库克隆成功状态
class GitRepositoryCloned extends GitRepositoryState {
  final GitRepositoryEntity repository;

  const GitRepositoryCloned(this.repository);

  @override
  List<Object?> get props => [repository];
}

/// 提交数量加载成功状态
class CommitCountLoaded extends GitRepositoryState {
  final int count;
  final String repoPath;
  final String? branch;

  const CommitCountLoaded(this.count, this.repoPath, {this.branch});

  @override
  List<Object?> get props => [count, repoPath, branch];
}

/// 当前分支加载成功状态
class CurrentBranchLoaded extends GitRepositoryState {
  final String? branch;
  final String repoPath;

  const CurrentBranchLoaded(this.branch, this.repoPath);

  @override
  List<Object?> get props => [branch, repoPath];
}

/// 分支列表加载成功状态
class BranchesLoaded extends GitRepositoryState {
  final List<String> branches;
  final String repoPath;
  final bool includeRemote;

  const BranchesLoaded(this.branches, this.repoPath,
      {this.includeRemote = false});

  @override
  List<Object?> get props => [branches, repoPath, includeRemote];
}

/// 远程仓库列表加载成功状态
class RemotesLoaded extends GitRepositoryState {
  final Map<String, String> remotes;
  final String repoPath;

  const RemotesLoaded(this.remotes, this.repoPath);

  @override
  List<Object?> get props => [remotes, repoPath];
}

/// 工作树状态检查成功状态
class WorkingTreeStatusLoaded extends GitRepositoryState {
  final bool isClean;
  final String repoPath;

  const WorkingTreeStatusLoaded(this.isClean, this.repoPath);

  @override
  List<Object?> get props => [isClean, repoPath];
}
