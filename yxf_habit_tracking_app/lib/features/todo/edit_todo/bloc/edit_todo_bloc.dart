import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_event.dart';
part 'edit_todo_state.dart';

class EditTodoBloc extends Bloc<EditTodoEvent, EditTodoState> {
  EditTodoBloc({
    required TodosRepository todosRepository,
    required Todo? initialTodo,
    DateTime? defaultCreatedAt,
    String? parentTodoId,
  })  : _todosRepository = todosRepository,
        super(
          EditTodoState(
            initialTodo: initialTodo,
            title: initialTodo?.title ?? '',
            description: initialTodo?.description ?? '',
            focusTime: initialTodo?.focusTime ?? 0,
            createdAt: initialTodo?.createdAt ?? defaultCreatedAt ?? DateTime.now(),
            parentTodoId: parentTodoId,
          ),
        ) {
    on<EditTodoTitleChanged>(_onTitleChanged);
    on<EditTodoDescriptionChanged>(_onDescriptionChanged);
    on<EditTodoFocusTimeChanged>(_onFocusTimeChanged);
    on<EditTodoCreatedAtChanged>(_onCreatedAtChanged);
    on<EditTodoSubmitted>(_onSubmitted);
  }

  final TodosRepository _todosRepository;

  void _onTitleChanged(
    EditTodoTitleChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditTodoDescriptionChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onFocusTimeChanged(
    EditTodoFocusTimeChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(focusTime: event.focusTime));
  }

  void _onCreatedAtChanged(
    EditTodoCreatedAtChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(createdAt: event.createdAt));
  }

  Future<void> _onSubmitted(
    EditTodoSubmitted event,
    Emitter<EditTodoState> emit,
  ) async {
    emit(state.copyWith(status: EditTodoStatus.loading));
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      title: state.title,
      description: state.description,
      focusTime: state.focusTime,
      createdAt: state.createdAt,
      parentTodoId: state.parentTodoId,
    );

    try {
      await _todosRepository.saveTodo(todo);
      emit(state.copyWith(status: EditTodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditTodoStatus.failure));
    }
  }
}
