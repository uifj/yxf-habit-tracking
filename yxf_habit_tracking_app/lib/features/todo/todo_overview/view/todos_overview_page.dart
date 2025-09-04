import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yxf_habit_tracking_app/app/l10n/l10n.dart';
import '../../edit_todo/edit_todo.dart';
import '../todos_voerview.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatefulWidget {
  const TodosOverviewPage({super.key});

  @override
  State<TodosOverviewPage> createState() => _TodosOverviewPageState();
}

class _TodosOverviewPageState extends State<TodosOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TodosOverviewBloc(todosRepository: context.read<TodosRepository>())
            ..add(const TodosOverviewSubscriptionRequested()),
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.todosOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.todosOverviewTodoDeletedSnackbarText(
                        deletedTodo.title,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.todosOverviewUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context.read<TodosOverviewBloc>().add(
                          const TodosOverviewUndoDeletionRequested(),
                        );
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.todos.isEmpty) {
              if (state.status == TodosOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != TodosOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.todosOverviewEmptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView.builder(
                itemCount: state.filteredTodos.length,
                itemBuilder: (_, index) {
                  final todo = state.filteredTodos.elementAt(index);
                  return TodoListTile(
                    todo: todo,
                    onToggleCompleted: (isCompleted) {
                      context.read<TodosOverviewBloc>().add(
                        TodosOverviewTodoCompletionToggled(
                          todo: todo,
                          isCompleted: isCompleted,
                        ),
                      );
                    },
                    onDismissed: (_) {
                      context.read<TodosOverviewBloc>().add(
                        TodosOverviewTodoDeleted(todo),
                      );
                    },
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(EditTodoPage.route(initialTodo: todo));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
