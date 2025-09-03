part of 'todo_bloc.dart';

sealed class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

// 初始状态
final class TodoInitial extends TodoState {}

// 加载状态
final class TodoLoading extends TodoState {}

// 任务加载成功状态
final class TodoLoaded extends TodoState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final DateTime? selectedDate;
  final String? selectedPriority;
  final bool isSyncing;

  const TodoLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.selectedDate,
    this.selectedPriority,
    this.isSyncing = false,
  });

  @override
  List<Object> get props => [
        tasks,
        filteredTasks,
        selectedDate ?? DateTime.now(),
        selectedPriority ?? '',
        isSyncing,
      ];

  TodoLoaded copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    DateTime? selectedDate,
    String? selectedPriority,
    bool? isSyncing,
  }) {
    return TodoLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// 错误状态
final class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}

// 任务操作成功状态
final class TodoOperationSuccess extends TodoState {
  final String message;
  final List<Task> tasks;

  const TodoOperationSuccess({
    required this.message,
    required this.tasks,
  });

  @override
  List<Object> get props => [message, tasks];
}

// 同步状态
final class TodoSyncing extends TodoState {
  final List<Task> tasks;

  const TodoSyncing(this.tasks);

  @override
  List<Object> get props => [tasks];
}

// 同步完成状态
final class TodoSyncCompleted extends TodoState {
  final List<Task> tasks;
  final String message;

  const TodoSyncCompleted({
    required this.tasks,
    required this.message,
  });

  @override
  List<Object> get props => [tasks, message];
}
