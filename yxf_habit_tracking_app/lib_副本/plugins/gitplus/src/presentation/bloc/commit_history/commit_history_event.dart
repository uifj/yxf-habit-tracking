import 'package:equatable/equatable.dart';

/// 提交历史事件基类
abstract class CommitHistoryEvent extends Equatable {
  const CommitHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// 加载提交历史事件
class LoadCommitHistory extends CommitHistoryEvent {
  final String repoPath;
  final int? limit;
  final int? offset;
  final String? branch;
  final String? filePath;

  const LoadCommitHistory(
    this.repoPath, {
    this.limit,
    this.offset,
    this.branch,
    this.filePath,
  });

  @override
  List<Object?> get props => [repoPath, limit, offset, branch, filePath];
}

/// 刷新提交历史事件
class RefreshCommitHistory extends CommitHistoryEvent {
  final String repoPath;
  final String? branch;
  final String? filePath;

  const RefreshCommitHistory(
    this.repoPath, {
    this.branch,
    this.filePath,
  });

  @override
  List<Object?> get props => [repoPath, branch, filePath];
}

/// 加载更多提交历史事件
class LoadMoreCommitHistory extends CommitHistoryEvent {
  final String repoPath;
  final int limit;
  final String? branch;
  final String? filePath;

  const LoadMoreCommitHistory(
    this.repoPath, {
    this.limit = 20,
    this.branch,
    this.filePath,
  });

  @override
  List<Object?> get props => [repoPath, limit, branch, filePath];
}

/// 获取最近提交事件
class LoadRecentCommits extends CommitHistoryEvent {
  final String repoPath;
  final int count;
  final String? branch;

  const LoadRecentCommits(
    this.repoPath, {
    this.count = 10,
    this.branch,
  });

  @override
  List<Object?> get props => [repoPath, count, branch];
}

/// 搜索提交历史事件
class SearchCommitHistory extends CommitHistoryEvent {
  final String repoPath;
  final String query;
  final String? author;
  final DateTime? since;
  final DateTime? until;
  final String? branch;

  const SearchCommitHistory(
    this.repoPath,
    this.query, {
    this.author,
    this.since,
    this.until,
    this.branch,
  });

  @override
  List<Object?> get props => [repoPath, query, author, since, until, branch];
}

/// 清除搜索结果事件
class ClearCommitHistorySearch extends CommitHistoryEvent {
  const ClearCommitHistorySearch();
}

/// 选择提交事件
class SelectCommit extends CommitHistoryEvent {
  final String commitSha;

  const SelectCommit(this.commitSha);

  @override
  List<Object?> get props => [commitSha];
}

/// 取消选择提交事件
class DeselectCommit extends CommitHistoryEvent {
  const DeselectCommit();
}

/// 切换提交选择状态事件
class ToggleCommitSelection extends CommitHistoryEvent {
  final String commitSha;

  const ToggleCommitSelection(this.commitSha);

  @override
  List<Object?> get props => [commitSha];
}

/// 设置分支过滤器事件
class SetBranchFilter extends CommitHistoryEvent {
  final String? branch;

  const SetBranchFilter(this.branch);

  @override
  List<Object?> get props => [branch];
}

/// 设置文件路径过滤器事件
class SetFilePathFilter extends CommitHistoryEvent {
  final String? filePath;

  const SetFilePathFilter(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// 设置作者过滤器事件
class SetAuthorFilter extends CommitHistoryEvent {
  final String? author;

  const SetAuthorFilter(this.author);

  @override
  List<Object?> get props => [author];
}

/// 设置日期范围过滤器事件
class SetDateRangeFilter extends CommitHistoryEvent {
  final DateTime? since;
  final DateTime? until;

  const SetDateRangeFilter({
    this.since,
    this.until,
  });

  @override
  List<Object?> get props => [since, until];
}

/// 清除所有过滤器事件
class ClearAllFilters extends CommitHistoryEvent {
  const ClearAllFilters();
}
