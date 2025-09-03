import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todos_voerview.dart';

class TodosOverviewFilterButton extends StatelessWidget {
  const TodosOverviewFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final activeFilter = context.select(
      (TodosOverviewBloc bloc) => bloc.state.filter,
    );

    return PopupMenuButton<TodosViewFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      tooltip: 'todosOverviewFilterTooltip',
      onSelected: (filter) {
        context.read<TodosOverviewBloc>().add(
              TodosOverviewFilterChanged(filter),
            );
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: TodosViewFilter.all,
            child: Text('todosOverviewFilterAll'),
          ),
          const PopupMenuItem(
            value: TodosViewFilter.activeOnly,
            child: Text('todosOverviewFilterActiveOnly'),
          ),
          const PopupMenuItem(
            value: TodosViewFilter.completedOnly,
            child: Text('todosOverviewFilterCompletedOnly'),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
