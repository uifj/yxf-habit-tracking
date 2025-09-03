part of 'edit_todo_bloc.dart';

enum EditTodoStatus { initial, loading, success, failure }

extension EditTodoStatusX on EditTodoStatus {
  bool get isLoadingOrSuccess => [
        EditTodoStatus.loading,
        EditTodoStatus.success,
      ].contains(this);
}

final class EditTodoState extends Equatable {
  const EditTodoState({
    this.status = EditTodoStatus.initial,
    this.initialTodo,
    this.title = '',
    this.description = '',
    this.focusTime = 0,
    required this.createdAt,
    this.parentTodoId,
  });

  final EditTodoStatus status;
  final Todo? initialTodo;
  final String title;
  final String description;
  final int focusTime;
  final DateTime createdAt;
  final String? parentTodoId;

  bool get isNewTodo => initialTodo == null;

  EditTodoState copyWith({
    EditTodoStatus? status,
    Todo? initialTodo,
    String? title,
    String? description,
    int? focusTime,
    DateTime? createdAt,
    String? parentTodoId,
  }) {
    return EditTodoState(
      status: status ?? this.status,
      initialTodo: initialTodo ?? this.initialTodo,
      title: title ?? this.title,
      description: description ?? this.description,
      focusTime: focusTime ?? this.focusTime,
      createdAt: createdAt ?? this.createdAt,
      parentTodoId: parentTodoId ?? this.parentTodoId,
    );
  }

  @override
  List<Object?> get props => [status, initialTodo, title, description, focusTime, createdAt, parentTodoId];
}
