import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_commit_history_usecase.dart';
import 'commit_history_event.dart';
import 'commit_history_state.dart';

/// 提交历史BLoC
class CommitHistoryBloc extends Bloc<CommitHistoryEvent, CommitHistoryState> {
  final GetCommitHistoryUseCase _getCommitHistoryUseCase;

  static const int _defaultPageSize = 20;

  CommitHistoryBloc({
    required GetCommitHistoryUseCase getCommitHistoryUseCase,
  })  : _getCommitHistoryUseCase = getCommitHistoryUseCase,
        super(const CommitHistoryInitial()) {
    on<LoadCommitHistory>(_onLoadCommitHistory);
    on<RefreshCommitHistory>(_onRefreshCommitHistory);
    on<LoadMoreCommitHistory>(_onLoadMoreCommitHistory);
    on<LoadRecentCommits>(_onLoadRecentCommits);
    on<SearchCommitHistory>(_onSearchCommitHistory);
    on<ClearCommitHistorySearch>(_onClearCommitHistorySearch);
    on<SelectCommit>(_onSelectCommit);
    on<DeselectCommit>(_onDeselectCommit);
    on<ToggleCommitSelection>(_onToggleCommitSelection);
    on<SetBranchFilter>(_onSetBranchFilter);
    on<SetFilePathFilter>(_onSetFilePathFilter);
    on<SetAuthorFilter>(_onSetAuthorFilter);
    on<SetDateRangeFilter>(_onSetDateRangeFilter);
    on<ClearAllFilters>(_onClearAllFilters);
  }

  /// 处理加载提交历史事件
  Future<void> _onLoadCommitHistory(
    LoadCommitHistory event,
    Emitter<CommitHistoryState> emit,
  ) async {
    emit(const CommitHistoryLoading());

    try {
      final limit = event.limit ?? _defaultPageSize;
      final offset = event.offset ?? 0;

      final commits = await _getCommitHistoryUseCase.getPaginatedHistory(
        repoPath: event.repoPath,
        page: offset ~/ limit,
        pageSize: limit,
        branch: event.branch,
      );

      if (commits.isEmpty) {
        emit(CommitHistoryEmpty(
          event.repoPath,
          message: _getEmptyMessage(event.branch, event.filePath),
        ));
        return;
      }

      emit(CommitHistoryLoaded(
        commits,
        event.repoPath,
        hasMore: commits.length >= limit,
        currentOffset: offset + commits.length,
        branchFilter: event.branch,
        filePathFilter: event.filePath,
      ));
    } catch (e) {
      emit(CommitHistoryError(
        'Failed to load commit history: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        repoPath: event.repoPath,
      ));
    }
  }

  /// 处理刷新提交历史事件
  Future<void> _onRefreshCommitHistory(
    RefreshCommitHistory event,
    Emitter<CommitHistoryState> emit,
  ) async {
    final currentState = state;
    String? selectedCommitSha;
    String? branchFilter;
    String? filePathFilter;
    String? authorFilter;
    DateTime? sinceFilter;
    DateTime? untilFilter;
    String? searchQuery;

    // 保持当前的过滤器和选择状态
    if (currentState is CommitHistoryLoaded) {
      selectedCommitSha = currentState.selectedCommitSha;
      branchFilter = event.branch ?? currentState.branchFilter;
      filePathFilter = event.filePath ?? currentState.filePathFilter;
      authorFilter = currentState.authorFilter;
      sinceFilter = currentState.sinceFilter;
      untilFilter = currentState.untilFilter;
      searchQuery = currentState.searchQuery;
    } else {
      branchFilter = event.branch;
      filePathFilter = event.filePath;
    }

    try {
      final commits = await _getCommitHistoryUseCase.getPaginatedHistory(
        repoPath: event.repoPath,
        page: 0,
        pageSize: _defaultPageSize,
        branch: branchFilter,
      );

      if (commits.isEmpty) {
        emit(CommitHistoryEmpty(
          event.repoPath,
          message: _getEmptyMessage(branchFilter, filePathFilter),
        ));
        return;
      }

      // 检查选中的提交是否仍然存在
      if (selectedCommitSha != null &&
          !commits.any((c) => c.sha == selectedCommitSha)) {
        selectedCommitSha = null;
      }

      emit(CommitHistoryLoaded(
        commits,
        event.repoPath,
        hasMore: commits.length >= _defaultPageSize,
        currentOffset: commits.length,
        selectedCommitSha: selectedCommitSha,
        branchFilter: branchFilter,
        filePathFilter: filePathFilter,
        authorFilter: authorFilter,
        sinceFilter: sinceFilter,
        untilFilter: untilFilter,
        searchQuery: searchQuery,
      ));
    } catch (e) {
      emit(CommitHistoryError(
        'Failed to refresh commit history: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        repoPath: event.repoPath,
      ));
    }
  }

  /// 处理加载更多提交历史事件
  Future<void> _onLoadMoreCommitHistory(
    LoadMoreCommitHistory event,
    Emitter<CommitHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommitHistoryLoaded || !currentState.hasMore) {
      return;
    }

    emit(CommitHistoryLoadingMore(
      currentState.commits,
      currentState.repoPath,
      hasMore: currentState.hasMore,
      currentOffset: currentState.currentOffset,
      selectedCommitSha: currentState.selectedCommitSha,
      branchFilter: currentState.branchFilter,
      filePathFilter: currentState.filePathFilter,
      authorFilter: currentState.authorFilter,
      sinceFilter: currentState.sinceFilter,
      untilFilter: currentState.untilFilter,
      searchQuery: currentState.searchQuery,
    ));

    try {
      final newCommits = await _getCommitHistoryUseCase.getPaginatedHistory(
        repoPath: event.repoPath,
        page: currentState.currentOffset ~/ event.limit,
        pageSize: event.limit,
        branch: event.branch ?? currentState.branchFilter,
      );

      final allCommits = [...currentState.commits, ...newCommits];

      emit(CommitHistoryLoaded(
        allCommits,
        event.repoPath,
        hasMore: newCommits.length >= event.limit,
        currentOffset: currentState.currentOffset + newCommits.length,
        selectedCommitSha: currentState.selectedCommitSha,
        branchFilter: currentState.branchFilter,
        filePathFilter: currentState.filePathFilter,
        authorFilter: currentState.authorFilter,
        sinceFilter: currentState.sinceFilter,
        untilFilter: currentState.untilFilter,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      emit(CommitHistoryError(
        'Failed to load more commits: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        repoPath: event.repoPath,
      ));
    }
  }

  /// 处理加载最近提交事件
  Future<void> _onLoadRecentCommits(
    LoadRecentCommits event,
    Emitter<CommitHistoryState> emit,
  ) async {
    emit(const CommitHistoryLoading());

    try {
      final commits = await _getCommitHistoryUseCase.getRecentCommits(
        repoPath: event.repoPath,
        count: event.count,
        branch: event.branch,
      );

      if (commits.isEmpty) {
        emit(CommitHistoryEmpty(
          event.repoPath,
          message: _getEmptyMessage(event.branch, null),
        ));
        return;
      }

      emit(CommitHistoryLoaded(
        commits,
        event.repoPath,
        hasMore: commits.length >= event.count,
        currentOffset: commits.length,
        branchFilter: event.branch,
      ));
    } catch (e) {
      emit(CommitHistoryError(
        'Failed to load recent commits: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        repoPath: event.repoPath,
      ));
    }
  }

  /// 处理搜索提交历史事件
  Future<void> _onSearchCommitHistory(
    SearchCommitHistory event,
    Emitter<CommitHistoryState> emit,
  ) async {
    final currentState = state;

    // 如果当前有加载的状态，显示搜索中状态
    if (currentState is CommitHistoryLoaded) {
      emit(CommitHistorySearching(
        currentState.commits,
        currentState.repoPath,
        hasMore: currentState.hasMore,
        currentOffset: currentState.currentOffset,
        selectedCommitSha: currentState.selectedCommitSha,
        branchFilter: currentState.branchFilter,
        filePathFilter: currentState.filePathFilter,
        authorFilter: currentState.authorFilter,
        sinceFilter: currentState.sinceFilter,
        untilFilter: currentState.untilFilter,
        searchQuery: event.query,
      ));
    } else {
      emit(const CommitHistoryLoading());
    }

    try {
      // 这里应该调用搜索相关的用例方法
      // 由于当前的GetCommitHistoryUseCase没有搜索方法，我们使用基本的分页方法
      final commits = await _getCommitHistoryUseCase.getPaginatedHistory(
        repoPath: event.repoPath,
        page: 0,
        pageSize: _defaultPageSize,
        branch: event.branch,
      );

      // 简单的客户端搜索过滤（实际应该在服务端或Git层面实现）
      final filteredCommits = commits.where((commit) {
        final matchesQuery =
            commit.message.toLowerCase().contains(event.query.toLowerCase()) ||
                commit.sha.toLowerCase().contains(event.query.toLowerCase());

        final matchesAuthor = event.author == null ||
            commit.author.toLowerCase().contains(event.author!.toLowerCase());

        final matchesSince =
            event.since == null || commit.date.isAfter(event.since!);

        final matchesUntil =
            event.until == null || commit.date.isBefore(event.until!);

        return matchesQuery && matchesAuthor && matchesSince && matchesUntil;
      }).toList();

      if (filteredCommits.isEmpty) {
        emit(CommitHistoryEmpty(
          event.repoPath,
          message: 'No commits found matching search criteria',
        ));
        return;
      }

      emit(CommitHistoryLoaded(
        filteredCommits,
        event.repoPath,
        hasMore: false, // 搜索结果不支持分页
        currentOffset: filteredCommits.length,
        branchFilter: event.branch,
        authorFilter: event.author,
        sinceFilter: event.since,
        untilFilter: event.until,
        searchQuery: event.query,
        isSearching: true,
      ));
    } catch (e) {
      emit(CommitHistoryError(
        'Failed to search commit history: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        repoPath: event.repoPath,
      ));
    }
  }

  /// 处理清除搜索结果事件
  Future<void> _onClearCommitHistorySearch(
    ClearCommitHistorySearch event,
    Emitter<CommitHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommitHistoryLoaded && currentState.isSearching) {
      // 重新加载原始数据
      add(RefreshCommitHistory(currentState.repoPath));
    }
  }

  /// 处理选择提交事件
  void _onSelectCommit(
    SelectCommit event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      emit(currentState.copyWith(selectedCommitSha: event.commitSha));
    }
  }

  /// 处理取消选择提交事件
  void _onDeselectCommit(
    DeselectCommit event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      emit(currentState.copyWith(clearSelectedCommit: true));
    }
  }

  /// 处理切换提交选择状态事件
  void _onToggleCommitSelection(
    ToggleCommitSelection event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      final newSelectedSha = currentState.selectedCommitSha == event.commitSha
          ? null
          : event.commitSha;

      emit(currentState.copyWith(
        selectedCommitSha: newSelectedSha,
        clearSelectedCommit: newSelectedSha == null,
      ));
    }
  }

  /// 处理设置分支过滤器事件
  void _onSetBranchFilter(
    SetBranchFilter event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      // 重新加载数据
      add(LoadCommitHistory(
        currentState.repoPath,
        branch: event.branch,
        filePath: currentState.filePathFilter,
      ));
    }
  }

  /// 处理设置文件路径过滤器事件
  void _onSetFilePathFilter(
    SetFilePathFilter event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      // 重新加载数据
      add(LoadCommitHistory(
        currentState.repoPath,
        branch: currentState.branchFilter,
        filePath: event.filePath,
      ));
    }
  }

  /// 处理设置作者过滤器事件
  void _onSetAuthorFilter(
    SetAuthorFilter event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      emit(currentState.copyWith(
        authorFilter: event.author,
        clearAuthorFilter: event.author == null,
      ));
    }
  }

  /// 处理设置日期范围过滤器事件
  void _onSetDateRangeFilter(
    SetDateRangeFilter event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      emit(currentState.copyWith(
        sinceFilter: event.since,
        untilFilter: event.until,
        clearSinceFilter: event.since == null,
        clearUntilFilter: event.until == null,
      ));
    }
  }

  /// 处理清除所有过滤器事件
  void _onClearAllFilters(
    ClearAllFilters event,
    Emitter<CommitHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitHistoryLoaded) {
      // 重新加载原始数据
      add(LoadCommitHistory(currentState.repoPath));
    }
  }

  /// 获取空状态消息
  String _getEmptyMessage(String? branch, String? filePath) {
    if (branch != null && filePath != null) {
      return 'No commits found for file "$filePath" in branch "$branch"';
    } else if (branch != null) {
      return 'No commits found in branch "$branch"';
    } else if (filePath != null) {
      return 'No commits found for file "$filePath"';
    } else {
      return 'No commits found in repository';
    }
  }
}
