import 'package:equatable/equatable.dart';
import '../../../domain/entities/git_commit_entity.dart';

/// 提交历史状态基类
abstract class CommitHistoryState extends Equatable {
  const CommitHistoryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class CommitHistoryInitial extends CommitHistoryState {
  const CommitHistoryInitial();
}

/// 加载中状态
class CommitHistoryLoading extends CommitHistoryState {
  const CommitHistoryLoading();
}

/// 加载完成状态
class CommitHistoryLoaded extends CommitHistoryState {
  final List<GitCommitEntity> commits;
  final String repoPath;
  final bool hasMore;
  final int currentOffset;
  final String? selectedCommitSha;
  final String? branchFilter;
  final String? filePathFilter;
  final String? authorFilter;
  final DateTime? sinceFilter;
  final DateTime? untilFilter;
  final String? searchQuery;
  final bool isSearching;

  const CommitHistoryLoaded(
    this.commits,
    this.repoPath, {
    this.hasMore = true,
    this.currentOffset = 0,
    this.selectedCommitSha,
    this.branchFilter,
    this.filePathFilter,
    this.authorFilter,
    this.sinceFilter,
    this.untilFilter,
    this.searchQuery,
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
        commits,
        repoPath,
        hasMore,
        currentOffset,
        selectedCommitSha,
        branchFilter,
        filePathFilter,
        authorFilter,
        sinceFilter,
        untilFilter,
        searchQuery,
        isSearching,
      ];

  /// 获取选中的提交
  GitCommitEntity? get selectedCommit {
    if (selectedCommitSha == null) return null;
    try {
      return commits.firstWhere((commit) => commit.sha == selectedCommitSha);
    } catch (e) {
      return null;
    }
  }

  /// 是否有活动的过滤器
  bool get hasActiveFilters {
    return branchFilter != null ||
        filePathFilter != null ||
        authorFilter != null ||
        sinceFilter != null ||
        untilFilter != null ||
        searchQuery != null;
  }

  /// 获取过滤器描述
  String get filterDescription {
    final filters = <String>[];

    if (branchFilter != null) {
      filters.add('Branch: $branchFilter');
    }
    if (filePathFilter != null) {
      filters.add('File: $filePathFilter');
    }
    if (authorFilter != null) {
      filters.add('Author: $authorFilter');
    }
    if (sinceFilter != null) {
      filters.add('Since: ${sinceFilter!.toLocal().toString().split(' ')[0]}');
    }
    if (untilFilter != null) {
      filters.add('Until: ${untilFilter!.toLocal().toString().split(' ')[0]}');
    }
    if (searchQuery != null) {
      filters.add('Search: "$searchQuery"');
    }

    return filters.join(', ');
  }

  /// 复制状态并更新属性
  CommitHistoryLoaded copyWith({
    List<GitCommitEntity>? commits,
    String? repoPath,
    bool? hasMore,
    int? currentOffset,
    String? selectedCommitSha,
    String? branchFilter,
    String? filePathFilter,
    String? authorFilter,
    DateTime? sinceFilter,
    DateTime? untilFilter,
    String? searchQuery,
    bool? isSearching,
    bool clearSelectedCommit = false,
    bool clearBranchFilter = false,
    bool clearFilePathFilter = false,
    bool clearAuthorFilter = false,
    bool clearSinceFilter = false,
    bool clearUntilFilter = false,
    bool clearSearchQuery = false,
  }) {
    return CommitHistoryLoaded(
      commits ?? this.commits,
      repoPath ?? this.repoPath,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      selectedCommitSha: clearSelectedCommit
          ? null
          : (selectedCommitSha ?? this.selectedCommitSha),
      branchFilter:
          clearBranchFilter ? null : (branchFilter ?? this.branchFilter),
      filePathFilter:
          clearFilePathFilter ? null : (filePathFilter ?? this.filePathFilter),
      authorFilter:
          clearAuthorFilter ? null : (authorFilter ?? this.authorFilter),
      sinceFilter: clearSinceFilter ? null : (sinceFilter ?? this.sinceFilter),
      untilFilter: clearUntilFilter ? null : (untilFilter ?? this.untilFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// 加载更多中状态
class CommitHistoryLoadingMore extends CommitHistoryLoaded {
  const CommitHistoryLoadingMore(
    super.commits,
    super.repoPath, {
    super.hasMore,
    super.currentOffset,
    super.selectedCommitSha,
    super.branchFilter,
    super.filePathFilter,
    super.authorFilter,
    super.sinceFilter,
    super.untilFilter,
    super.searchQuery,
    super.isSearching,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        'loading_more',
      ];
}

/// 搜索中状态
class CommitHistorySearching extends CommitHistoryLoaded {
  const CommitHistorySearching(
    super.commits,
    super.repoPath, {
    super.hasMore,
    super.currentOffset,
    super.selectedCommitSha,
    super.branchFilter,
    super.filePathFilter,
    super.authorFilter,
    super.sinceFilter,
    super.untilFilter,
    super.searchQuery,
  }) : super(isSearching: true);

  @override
  List<Object?> get props => [
        ...super.props,
        'searching',
      ];
}

/// 错误状态
class CommitHistoryError extends CommitHistoryState {
  final String message;
  final Exception? exception;
  final String? repoPath;

  const CommitHistoryError(
    this.message, {
    this.exception,
    this.repoPath,
  });

  @override
  List<Object?> get props => [message, exception, repoPath];
}

/// 空状态（没有提交历史）
class CommitHistoryEmpty extends CommitHistoryState {
  final String repoPath;
  final String message;

  const CommitHistoryEmpty(
    this.repoPath, {
    this.message = 'No commits found',
  });

  @override
  List<Object?> get props => [repoPath, message];
}
