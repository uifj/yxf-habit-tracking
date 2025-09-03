import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_repository_status_usecase.dart';
import '../../../domain/repositories/git_repository.dart';
import 'git_repository_event.dart';
import 'git_repository_state.dart';

/// Git仓库BLoC
class GitRepositoryBloc extends Bloc<GitRepositoryEvent, GitRepositoryState> {
  final GitRepository _gitRepository;
  final GetRepositoryStatusUseCase _getRepositoryStatusUseCase;

  GitRepositoryBloc({
    required GitRepository gitRepository,
    required GetRepositoryStatusUseCase getRepositoryStatusUseCase,
  })  : _gitRepository = gitRepository,
        _getRepositoryStatusUseCase = getRepositoryStatusUseCase,
        super(const GitRepositoryInitial()) {
    on<LoadRepositoryStatus>(_onLoadRepositoryStatus);
    on<RefreshRepositoryStatus>(_onRefreshRepositoryStatus);
    on<InitializeRepository>(_onInitializeRepository);
    on<CloneRepository>(_onCloneRepository);
    on<CheckIsGitRepository>(_onCheckIsGitRepository);
    on<GetCommitCount>(_onGetCommitCount);
    on<GetCurrentBranch>(_onGetCurrentBranch);
    on<GetBranches>(_onGetBranches);
    on<GetRemotes>(_onGetRemotes);
    on<CheckWorkingTreeClean>(_onCheckWorkingTreeClean);
  }

  /// 处理加载仓库状态事件
  Future<void> _onLoadRepositoryStatus(
    LoadRepositoryStatus event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(const GitRepositoryLoading());

    try {
      // 首先检查是否为Git仓库
      final isGitRepo = await _gitRepository.isGitRepository(event.repoPath);
      if (!isGitRepo) {
        emit(NotGitRepository(event.repoPath));
        return;
      }

      // 获取仓库状态
      final repository = await _getRepositoryStatusUseCase(event.repoPath);
      emit(GitRepositoryLoaded(repository));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to load repository status: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理刷新仓库状态事件
  Future<void> _onRefreshRepositoryStatus(
    RefreshRepositoryStatus event,
    Emitter<GitRepositoryState> emit,
  ) async {
    // 刷新时不显示加载状态，直接更新
    try {
      final isGitRepo = await _gitRepository.isGitRepository(event.repoPath);
      if (!isGitRepo) {
        emit(NotGitRepository(event.repoPath));
        return;
      }

      final repository = await _getRepositoryStatusUseCase(event.repoPath);
      emit(GitRepositoryLoaded(repository));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to refresh repository status: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理初始化仓库事件
  Future<void> _onInitializeRepository(
    InitializeRepository event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(const GitRepositoryLoading());

    try {
      final repository = await _gitRepository.initRepository(
        event.repoPath,
        initialBranch: event.initialBranch,
      );
      emit(GitRepositoryInitialized(repository));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to initialize repository: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理克隆仓库事件
  Future<void> _onCloneRepository(
    CloneRepository event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(const GitRepositoryLoading());

    try {
      final repository = await _gitRepository.cloneRepository(
        event.url,
        event.localPath,
        branch: event.branch,
        recursive: event.recursive,
      );
      emit(GitRepositoryCloned(repository));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to clone repository: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理检查是否为Git仓库事件
  Future<void> _onCheckIsGitRepository(
    CheckIsGitRepository event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final isGitRepo = await _gitRepository.isGitRepository(event.repoPath);
      if (isGitRepo) {
        // 如果是Git仓库，加载仓库状态
        add(LoadRepositoryStatus(event.repoPath));
      } else {
        emit(NotGitRepository(event.repoPath));
      }
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to check if directory is a Git repository: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理获取提交数量事件
  Future<void> _onGetCommitCount(
    GetCommitCount event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final count = await _gitRepository.getCommitCount(
        event.repoPath,
        branch: event.branch,
      );
      emit(CommitCountLoaded(count, event.repoPath, branch: event.branch));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to get commit count: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理获取当前分支事件
  Future<void> _onGetCurrentBranch(
    GetCurrentBranch event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final branch = await _gitRepository.getCurrentBranch(event.repoPath);
      emit(CurrentBranchLoaded(branch, event.repoPath));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to get current branch: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理获取分支列表事件
  Future<void> _onGetBranches(
    GetBranches event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final branches = await _gitRepository.getBranches(
        event.repoPath,
        includeRemote: event.includeRemote,
      );
      emit(BranchesLoaded(
        branches,
        event.repoPath,
        includeRemote: event.includeRemote,
      ));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to get branches: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理获取远程仓库列表事件
  Future<void> _onGetRemotes(
    GetRemotes event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final remotes = await _gitRepository.getRemotes(event.repoPath);
      emit(RemotesLoaded(remotes, event.repoPath));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to get remotes: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理检查工作树是否干净事件
  Future<void> _onCheckWorkingTreeClean(
    CheckWorkingTreeClean event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final isClean = await _gitRepository.isWorkingTreeClean(event.repoPath);
      emit(WorkingTreeStatusLoaded(isClean, event.repoPath));
    } catch (e) {
      emit(GitRepositoryError(
        'Failed to check working tree status: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }
}
