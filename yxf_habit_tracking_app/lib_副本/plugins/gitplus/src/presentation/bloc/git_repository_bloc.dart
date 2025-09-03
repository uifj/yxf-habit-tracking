import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/git_repository_entity.dart';
import '../../domain/entities/git_config_entity.dart';
import '../../domain/repositories/git_repository.dart';

// Events
abstract class GitRepositoryEvent extends Equatable {
  const GitRepositoryEvent();

  @override
  List<Object?> get props => [];
}

class InitRepositoryEvent extends GitRepositoryEvent {
  final String repoPath;
  final String? initialBranch;

  const InitRepositoryEvent(this.repoPath, {this.initialBranch});

  @override
  List<Object?> get props => [repoPath, initialBranch];
}

class GetRepositoryEvent extends GitRepositoryEvent {
  final String repoPath;

  const GetRepositoryEvent(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

class GetRepositoryStatusEvent extends GitRepositoryEvent {
  final String repoPath;

  const GetRepositoryStatusEvent(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

class CheckIsGitRepositoryEvent extends GitRepositoryEvent {
  final String repoPath;

  const CheckIsGitRepositoryEvent(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

class CloneRepositoryEvent extends GitRepositoryEvent {
  final String url;
  final String localPath;
  final String? branch;
  final bool recursive;

  const CloneRepositoryEvent({
    required this.url,
    required this.localPath,
    this.branch,
    this.recursive = false,
  });

  @override
  List<Object?> get props => [url, localPath, branch, recursive];
}

class GetConfigEvent extends GitRepositoryEvent {
  final String repoPath;

  const GetConfigEvent(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

class SaveConfigEvent extends GitRepositoryEvent {
  final String repoPath;
  final GitConfigEntity config;

  const SaveConfigEvent(this.repoPath, this.config);

  @override
  List<Object?> get props => [repoPath, config];
}

// States
abstract class GitRepositoryState extends Equatable {
  const GitRepositoryState();

  @override
  List<Object?> get props => [];
}

class GitRepositoryInitial extends GitRepositoryState {}

class GitRepositoryLoading extends GitRepositoryState {}

class GitRepositoryLoaded extends GitRepositoryState {
  final GitRepositoryEntity repository;

  const GitRepositoryLoaded(this.repository);

  @override
  List<Object?> get props => [repository];
}

class GitRepositoryInitialized extends GitRepositoryState {
  final GitRepositoryEntity repository;

  const GitRepositoryInitialized(this.repository);

  @override
  List<Object?> get props => [repository];
}

class GitRepositoryCloned extends GitRepositoryState {
  final String message;

  const GitRepositoryCloned(this.message);

  @override
  List<Object?> get props => [message];
}

class GitRepositoryIsGitRepo extends GitRepositoryState {
  final bool isGitRepo;

  const GitRepositoryIsGitRepo(this.isGitRepo);

  @override
  List<Object?> get props => [isGitRepo];
}

class GitConfigLoaded extends GitRepositoryState {
  final GitConfigEntity config;

  const GitConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class GitConfigSaved extends GitRepositoryState {
  final String message;

  const GitConfigSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class GitRepositoryError extends GitRepositoryState {
  final String message;

  const GitRepositoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GitRepositoryBloc extends Bloc<GitRepositoryEvent, GitRepositoryState> {
  final GitRepository _gitRepository;

  GitRepositoryBloc(this._gitRepository) : super(GitRepositoryInitial()) {
    on<InitRepositoryEvent>(_onInitRepository);
    on<GetRepositoryEvent>(_onGetRepository);
    on<GetRepositoryStatusEvent>(_onGetRepositoryStatus);
    on<CheckIsGitRepositoryEvent>(_onCheckIsGitRepository);
    on<CloneRepositoryEvent>(_onCloneRepository);
    on<GetConfigEvent>(_onGetConfig);
    on<SaveConfigEvent>(_onSaveConfig);
  }

  Future<void> _onInitRepository(
    InitRepositoryEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      final repository = await _gitRepository.initRepository(
        event.repoPath,
        initialBranch: event.initialBranch,
      );
      emit(GitRepositoryInitialized(repository));
    } catch (e) {
      emit(GitRepositoryError('初始化仓库失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetRepository(
    GetRepositoryEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      final repository = await _gitRepository.getRepository(event.repoPath);
      emit(GitRepositoryLoaded(repository));
    } catch (e) {
      emit(GitRepositoryError('获取仓库信息失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetRepositoryStatus(
    GetRepositoryStatusEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      final repository =
          await _gitRepository.getRepositoryStatus(event.repoPath);
      emit(GitRepositoryLoaded(repository));
    } catch (e) {
      emit(GitRepositoryError('获取仓库状态失败: ${e.toString()}'));
    }
  }

  Future<void> _onCheckIsGitRepository(
    CheckIsGitRepositoryEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    try {
      final isGitRepo = await _gitRepository.isGitRepository(event.repoPath);
      emit(GitRepositoryIsGitRepo(isGitRepo));
    } catch (e) {
      emit(GitRepositoryError('检查Git仓库失败: ${e.toString()}'));
    }
  }

  Future<void> _onCloneRepository(
    CloneRepositoryEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      await _gitRepository.cloneRepository(
        event.url,
        event.localPath,
        branch: event.branch,
        recursive: event.recursive,
      );
      emit(const GitRepositoryCloned('仓库克隆成功'));
    } catch (e) {
      emit(GitRepositoryError('克隆仓库失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetConfig(
    GetConfigEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      final config = await _gitRepository.getConfig(event.repoPath);
      emit(GitConfigLoaded(config));
    } catch (e) {
      emit(GitRepositoryError('获取配置失败: ${e.toString()}'));
    }
  }

  Future<void> _onSaveConfig(
    SaveConfigEvent event,
    Emitter<GitRepositoryState> emit,
  ) async {
    emit(GitRepositoryLoading());
    try {
      await _gitRepository.saveConfig(event.repoPath, event.config);
      emit(const GitConfigSaved('配置保存成功'));
    } catch (e) {
      emit(GitRepositoryError('保存配置失败: ${e.toString()}'));
    }
  }
}
