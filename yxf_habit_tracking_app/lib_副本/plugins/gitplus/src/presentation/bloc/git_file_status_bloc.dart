import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/git_file_status_entity.dart';
import '../../domain/repositories/git_repository.dart';

// Events
abstract class GitFileStatusEvent extends Equatable {
  const GitFileStatusEvent();

  @override
  List<Object?> get props => [];
}

class GetFileStatusesEvent extends GitFileStatusEvent {
  final String repositoryPath;

  const GetFileStatusesEvent(this.repositoryPath);

  @override
  List<Object?> get props => [repositoryPath];
}

class StageFileEvent extends GitFileStatusEvent {
  final String repositoryPath;
  final String filePath;

  const StageFileEvent(this.repositoryPath, this.filePath);

  @override
  List<Object?> get props => [repositoryPath, filePath];
}

class UnstageFileEvent extends GitFileStatusEvent {
  final String repositoryPath;
  final String filePath;

  const UnstageFileEvent(this.repositoryPath, this.filePath);

  @override
  List<Object?> get props => [repositoryPath, filePath];
}

class StageAllFilesEvent extends GitFileStatusEvent {
  final String repositoryPath;

  const StageAllFilesEvent(this.repositoryPath);

  @override
  List<Object?> get props => [repositoryPath];
}

class UnstageAllFilesEvent extends GitFileStatusEvent {
  final String repositoryPath;

  const UnstageAllFilesEvent(this.repositoryPath);

  @override
  List<Object?> get props => [repositoryPath];
}

class DiscardFileChangesEvent extends GitFileStatusEvent {
  final String repositoryPath;
  final String filePath;

  const DiscardFileChangesEvent(this.repositoryPath, this.filePath);

  @override
  List<Object?> get props => [repositoryPath, filePath];
}

// States
abstract class GitFileStatusState extends Equatable {
  const GitFileStatusState();

  @override
  List<Object?> get props => [];
}

class GitFileStatusInitial extends GitFileStatusState {}

class GitFileStatusLoading extends GitFileStatusState {}

class GitFileStatusLoaded extends GitFileStatusState {
  final List<GitFileStatusEntity> fileStatuses;

  const GitFileStatusLoaded(this.fileStatuses);

  @override
  List<Object?> get props => [fileStatuses];
}

class GitFileStatusError extends GitFileStatusState {
  final String message;

  const GitFileStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GitFileStatusBloc extends Bloc<GitFileStatusEvent, GitFileStatusState> {
  final GitRepository _gitRepository;

  GitFileStatusBloc(this._gitRepository) : super(GitFileStatusInitial()) {
    on<GetFileStatusesEvent>(_onGetFileStatuses);
    on<StageFileEvent>(_onStageFile);
    on<UnstageFileEvent>(_onUnstageFile);
    on<StageAllFilesEvent>(_onStageAllFiles);
    on<UnstageAllFilesEvent>(_onUnstageAllFiles);
    on<DiscardFileChangesEvent>(_onDiscardFileChanges);
  }

  Future<void> _onGetFileStatuses(
    GetFileStatusesEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    emit(GitFileStatusLoading());
    try {
      final fileStatuses =
          await _gitRepository.getFileStatuses(event.repositoryPath);
      emit(GitFileStatusLoaded(fileStatuses));
    } catch (e) {
      emit(GitFileStatusError('获取文件状态失败: ${e.toString()}'));
    }
  }

  Future<void> _onStageFile(
    StageFileEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    try {
      await _gitRepository.stageFile(event.repositoryPath, event.filePath);
      // 重新获取文件状态
      add(GetFileStatusesEvent(event.repositoryPath));
    } catch (e) {
      emit(GitFileStatusError('暂存文件失败: ${e.toString()}'));
    }
  }

  Future<void> _onUnstageFile(
    UnstageFileEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    try {
      await _gitRepository.unstageFile(event.repositoryPath, event.filePath);
      // 重新获取文件状态
      add(GetFileStatusesEvent(event.repositoryPath));
    } catch (e) {
      emit(GitFileStatusError('取消暂存文件失败: ${e.toString()}'));
    }
  }

  Future<void> _onStageAllFiles(
    StageAllFilesEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    try {
      await _gitRepository.stageAllFiles(event.repositoryPath);
      // 重新获取文件状态
      add(GetFileStatusesEvent(event.repositoryPath));
    } catch (e) {
      emit(GitFileStatusError('暂存所有文件失败: ${e.toString()}'));
    }
  }

  Future<void> _onUnstageAllFiles(
    UnstageAllFilesEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    try {
      await _gitRepository.unstageAllFiles(event.repositoryPath);
      // 重新获取文件状态
      add(GetFileStatusesEvent(event.repositoryPath));
    } catch (e) {
      emit(GitFileStatusError('取消暂存所有文件失败: ${e.toString()}'));
    }
  }

  Future<void> _onDiscardFileChanges(
    DiscardFileChangesEvent event,
    Emitter<GitFileStatusState> emit,
  ) async {
    try {
      await _gitRepository.discardFileChanges(
          event.repositoryPath, event.filePath);
      // 重新获取文件状态
      add(GetFileStatusesEvent(event.repositoryPath));
    } catch (e) {
      emit(GitFileStatusError('丢弃文件更改失败: ${e.toString()}'));
    }
  }
}
