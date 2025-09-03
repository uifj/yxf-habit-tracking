part of 'edit_todo_bloc.dart';

sealed class EditTodoEvent extends Equatable {
  const EditTodoEvent();

  @override
  List<Object> get props => [];
}

final class EditTodoTitleChanged extends EditTodoEvent {
  const EditTodoTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

final class EditTodoDescriptionChanged extends EditTodoEvent {
  const EditTodoDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

final class EditTodoFocusTimeChanged extends EditTodoEvent {
  const EditTodoFocusTimeChanged(this.focusTime);

  final int focusTime;

  @override
  List<Object> get props => [focusTime];
}

final class EditTodoCreatedAtChanged extends EditTodoEvent {
  const EditTodoCreatedAtChanged(this.createdAt);

  final DateTime createdAt;

  @override
  List<Object> get props => [createdAt];
}

final class EditTodoSubmitted extends EditTodoEvent {
  const EditTodoSubmitted();
}
