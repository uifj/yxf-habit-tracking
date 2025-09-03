import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/git_diff_entity.dart';
import '../../domain/repositories/git_repository.dart';

// Events
abstract class DiffEvent extends Equatable {
  const DiffEvent();

  @override
  List<Object?> get props => [];
}

class GetFileDiffEvent extends DiffEvent {
  final String repositoryPath;
  final String filePath;
  final String? fromCommit;
  final String? toCommit;
  final bool staged;

  const GetFileDiffEvent({
    required this.repositoryPath,
    required this.filePath,
    this.fromCommit,
    this.toCommit,
    this.staged = false,
  });

  @override
  List<Object?> get props =>
      [repositoryPath, filePath, fromCommit, toCommit, staged];
}

class GetCommitDiffEvent extends DiffEvent {
  final String repositoryPath;
  final String commitSha;

  const GetCommitDiffEvent({
    required this.repositoryPath,
    required this.commitSha,
  });

  @override
  List<Object?> get props => [repositoryPath, commitSha];
}

// States
abstract class DiffState extends Equatable {
  const DiffState();

  @override
  List<Object?> get props => [];
}

class DiffInitial extends DiffState {}

class DiffLoading extends DiffState {}

class DiffLoaded extends DiffState {
  final GitDiffEntity diff;

  const DiffLoaded(this.diff);

  @override
  List<Object?> get props => [diff];
}

class CommitDiffLoaded extends DiffState {
  final List<GitDiffEntity> diffs;

  const CommitDiffLoaded(this.diffs);

  @override
  List<Object?> get props => [diffs];
}

class DiffError extends DiffState {
  final String message;

  const DiffError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DiffBloc extends Bloc<DiffEvent, DiffState> {
  final GitRepository _gitRepository;

  DiffBloc(this._gitRepository) : super(DiffInitial()) {
    on<GetFileDiffEvent>(_onGetFileDiff);
    on<GetCommitDiffEvent>(_onGetCommitDiff);
  }

  Future<void> _onGetFileDiff(
    GetFileDiffEvent event,
    Emitter<DiffState> emit,
  ) async {
    emit(DiffLoading());
    try {
      final diff = await _gitRepository.getFileDiff(
        event.repositoryPath,
        event.filePath,
        fromCommit: event.fromCommit,
        toCommit: event.toCommit,
        staged: event.staged,
      );
      emit(DiffLoaded(diff));
    } catch (e) {
      emit(DiffError('获取文件差异失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetCommitDiff(
    GetCommitDiffEvent event,
    Emitter<DiffState> emit,
  ) async {
    emit(DiffLoading());
    try {
      final diffs = await _gitRepository.getCommitDiff(
        event.repositoryPath,
        event.commitSha,
      );
      emit(CommitDiffLoaded(diffs));
    } catch (e) {
      emit(DiffError('获取提交差异失败: ${e.toString()}'));
    }
  }
}
