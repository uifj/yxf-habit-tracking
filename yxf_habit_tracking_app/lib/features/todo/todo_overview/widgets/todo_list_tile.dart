import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoListTile extends StatelessWidget {
  const TodoListTile(
      {required this.todo,
      super.key,
      this.onToggleCompleted,
      this.onDismissed,
      this.onTap,
      this.onAddSubTodo,
      this.indentLevel = 0});

  final Todo todo;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final VoidCallback? onAddSubTodo;
  final int indentLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    return Dismissible(
      key: Key('todoListTile_dismissible_${todo.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: indentLevel * 20.0),
            child: ListTile(
              onTap: onTap,
              title: Text(
                todo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: !todo.isCompleted
                    ? null
                    : TextStyle(
                        color: captionColor,
                        decoration: TextDecoration.lineThrough,
                      ),
              ),
              subtitle: Text(
                todo.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Checkbox(
                shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                value: todo.isCompleted,
                onChanged: onToggleCompleted == null
                    ? null
                    : (value) => onToggleCompleted!(value!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAddSubTodo != null)
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: onAddSubTodo,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      tooltip: '添加子待办',
                    ),
                  if (onTap != null)
                    IconButton(
                      icon: Icon(
                        todo.subtodosExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                      ),
                      onPressed: onTap,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 显示子待办
          if (todo.subtodosExpanded && todo.subtodos.isNotEmpty)
            ...todo.subtodos.map(
              (subtodo) => TodoListTile(
                todo: subtodo,
                indentLevel: indentLevel + 1,
                onToggleCompleted: onToggleCompleted,
                onDismissed: onDismissed,
                onTap: onTap,
                onAddSubTodo: onAddSubTodo,
              ),
            ),
        ],
      ),
    );
  }
}
