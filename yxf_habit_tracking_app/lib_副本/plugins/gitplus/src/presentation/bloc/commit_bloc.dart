import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/git_commit_entity.dart';
import '../../domain/repositories/git_repository.dart';

// Events
abstract class CommitEvent extends Equatable {
  const CommitEvent();

  @override
  List<Object?> get props => [];
}

class CommitChangesEvent extends CommitEvent {
  final String repoPath;
  final String message;
  final String? author;
  final String? email;

  const CommitChangesEvent({
    required this.repoPath,
    required this.message,
    this.author,
    this.email,
  });

  @override
  List<Object?> get props => [repoPath, message, author, email];
}

class GetCommitHistoryEvent extends CommitEvent {
  final String repoPath;
  final int? limit;
  final int? offset;

  const GetCommitHistoryEvent({
    required this.repoPath,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [repoPath, limit, offset];
}

class GetCommitEvent extends CommitEvent {
  final String repoPath;
  final String commitSha;

  const GetCommitEvent({
    required this.repoPath,
    required this.commitSha,
  });

  @override
  List<Object?> get props => [repoPath, commitSha];
}

// States
abstract class CommitState extends Equatable {
  const CommitState();

  @override
  List<Object?> get props => [];
}

class CommitInitial extends CommitState {}

class CommitLoading extends CommitState {}

class CommitSuccess extends CommitState {
  final String message;

  const CommitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CommitHistoryLoaded extends CommitState {
  final List<GitCommitEntity> commits;

  const CommitHistoryLoaded(this.commits);

  @override
  List<Object?> get props => [commits];
}

class CommitLoaded extends CommitState {
  final GitCommitEntity commit;

  const CommitLoaded(this.commit);

  @override
  List<Object?> get props => [commit];
}

class CommitError extends CommitState {
  final String message;

  const CommitError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CommitBloc extends Bloc<CommitEvent, CommitState> {
  final GitRepository _gitRepository;

  CommitBloc(this._gitRepository) : super(CommitInitial()) {
    on<CommitChangesEvent>(_onCommitChanges);
    on<GetCommitHistoryEvent>(_onGetCommitHistory);
    on<GetCommitEvent>(_onGetCommit);
  }

  Future<void> _onCommitChanges(
    CommitChangesEvent event,
    Emitter<CommitState> emit,
  ) async {
    emit(CommitLoading());
    try {
      await _gitRepository.commit(
        event.repoPath,
        event.message,
      );
      emit(const CommitSuccess('提交成功'));
    } catch (e) {
      emit(CommitError('提交失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetCommitHistory(
    GetCommitHistoryEvent event,
    Emitter<CommitState> emit,
  ) async {
    emit(CommitLoading());
    try {
      final commits = await _gitRepository.getCommitHistory(
        event.repoPath,
        limit: event.limit,
        skip: event.offset,
      );
      emit(CommitHistoryLoaded(commits));
    } catch (e) {
      emit(CommitError('获取提交历史失败: ${e.toString()}'));
    }
  }

  Future<void> _onGetCommit(
    GetCommitEvent event,
    Emitter<CommitState> emit,
  ) async {
    emit(CommitLoading());
    try {
      final commit = await _gitRepository.getCommit(
        event.repoPath,
        event.commitSha,
      );
      emit(CommitLoaded(commit));
    } catch (e) {
      emit(CommitError('获取提交详情失败: ${e.toString()}'));
    }
  }
}