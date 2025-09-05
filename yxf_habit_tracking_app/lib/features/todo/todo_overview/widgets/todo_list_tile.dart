import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoListTile extends StatelessWidget {
  const TodoListTile(
      {required this.todo,
      super.key,
      this.onToggleCompleted,
      this.onDismissed,
      this.onTap,
      this.onLongPress,
      this.onAddSubTodo,
      this.indentLevel = 0,
      this.onSubtodoToggleCompleted,
      this.onSubtodoDismissed,
      this.onSubtodoTap,
      this.onSubtodoLongPress});

  final Todo todo;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddSubTodo;
  final int indentLevel;

  // 子待办专用回调方法
  final ValueChanged<Todo>? onSubtodoToggleCompleted;
  final ValueChanged<Todo>? onSubtodoDismissed;
  final ValueChanged<Todo>? onSubtodoTap;
  final ValueChanged<Todo>? onSubtodoLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    // 计算子待办完成状态
    final completedSubtodos =
        todo.subtodos.where((subtodo) => subtodo.isCompleted).length;
    final totalSubtodos = todo.subtodos.length;
    final hasSubtodos = totalSubtodos > 0 && todo.parentTodoId == null;

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
              onLongPress: onLongPress,
              onTap: onTap,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
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
                  ),
                  if (hasSubtodos)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: completedSubtodos == totalSubtodos
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: completedSubtodos == totalSubtodos
                              ? Colors.green.withOpacity(0.5)
                              : Colors.orange.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$completedSubtodos/$totalSubtodos',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: completedSubtodos == totalSubtodos
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                ],
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
              trailing: todo.parentTodoId != null
                  ? null
                  : Row(
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
                // 子待办使用专门的回调方法
                onToggleCompleted: (isCompleted) {
                  if (onSubtodoToggleCompleted != null) {
                    onSubtodoToggleCompleted!(
                        subtodo.copyWith(isCompleted: isCompleted));
                  }
                },
                onDismissed: (_) {
                  if (onSubtodoDismissed != null) {
                    onSubtodoDismissed!(subtodo);
                  }
                },
                onTap: () {
                  if (onSubtodoTap != null) {
                    onSubtodoTap!(subtodo);
                  }
                },
                onLongPress: () {
                  if (onSubtodoLongPress != null) {
                    onSubtodoLongPress!(subtodo);
                  }
                },
                // 子待办不显示添加子待办按钮
                onAddSubTodo: null,
                // 传递子待办的回调方法给下一级
                onSubtodoToggleCompleted: onSubtodoToggleCompleted,
                onSubtodoDismissed: onSubtodoDismissed,
                onSubtodoTap: onSubtodoTap,
                onSubtodoLongPress: onSubtodoLongPress,
              ),
            ),
        ],
      ),
    );
  }
}
