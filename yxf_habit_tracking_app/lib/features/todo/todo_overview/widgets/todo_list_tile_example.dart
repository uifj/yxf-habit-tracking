import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';
import 'todo_list_tile.dart';

/// TodoListTile 优化示例
///
/// 展示如何正确使用优化后的 TodoListTile，
/// 包括父待办和子待办的独立回调处理
class TodoListTileExample extends StatefulWidget {
  const TodoListTileExample({super.key});

  @override
  State<TodoListTileExample> createState() => _TodoListTileExampleState();
}

class _TodoListTileExampleState extends State<TodoListTileExample> {
  List<Todo> todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoListTile 优化示例'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoListTile(
            todo: todo,
            // 父待办回调方法
            onToggleCompleted: (isCompleted) =>
                _handleParentToggle(todo, isCompleted),
            onDismissed: (_) => _handleParentDelete(todo),
            onTap: () => _handleParentTap(todo),
            onLongPress: () => _handleParentLongPress(todo),
            onAddSubTodo: () => _handleAddSubTodo(todo),

            // 子待办专用回调方法 - 独立处理子待办逻辑
            onSubtodoToggleCompleted: _handleSubtodoToggle,
            onSubtodoDismissed: _handleSubtodoDelete,
            onSubtodoTap: _handleSubtodoTap,
            onSubtodoLongPress: _handleSubtodoLongPress,
          );
        },
      ),
    );
  }

  // ========== 父待办处理方法 ==========

  /// 处理父待办完成状态切换
  void _handleParentToggle(Todo parentTodo, bool isCompleted) {
    debugPrint('父待办状态切换: ${parentTodo.title} -> $isCompleted');
    // 父待办状态变更逻辑
    // 可以选择是否同时更新所有子待办状态
    _updateTodoStatus(parentTodo, isCompleted, cascadeToChildren: true);
  }

  /// 处理父待办删除
  void _handleParentDelete(Todo parentTodo) {
    debugPrint('删除父待办: ${parentTodo.title}');
    // 删除父待办及其所有子待办
    _deleteTodoWithChildren(parentTodo);
  }

  /// 处理父待办点击（展开/折叠子待办）
  void _handleParentTap(Todo parentTodo) {
    debugPrint('切换父待办展开状态: ${parentTodo.title}');
    _toggleSubtodosExpanded(parentTodo);
  }

  /// 处理父待办长按（编辑）
  void _handleParentLongPress(Todo parentTodo) {
    debugPrint('编辑父待办: ${parentTodo.title}');
    _editTodo(parentTodo);
  }

  /// 处理添加子待办
  void _handleAddSubTodo(Todo parentTodo) {
    debugPrint('为父待办添加子待办: ${parentTodo.title}');
    _addSubTodo(parentTodo);
  }

  // ========== 子待办处理方法 ==========

  /// 处理子待办完成状态切换
  void _handleSubtodoToggle(Todo subtodo) {
    debugPrint('子待办状态切换: ${subtodo.title} -> ${subtodo.isCompleted}');
    // 子待办状态变更逻辑
    // 可以检查是否需要更新父待办状态
    _updateSubtodoStatus(subtodo);
  }

  /// 处理子待办删除
  void _handleSubtodoDelete(Todo subtodo) {
    debugPrint('删除子待办: ${subtodo.title}');
    // 只删除子待办，不影响父待办
    _deleteSubtodo(subtodo);
  }

  /// 处理子待办点击（如果子待办也有子项）
  void _handleSubtodoTap(Todo subtodo) {
    debugPrint('子待办点击: ${subtodo.title}');
    // 子待办的展开/折叠逻辑
    _toggleSubtodosExpanded(subtodo);
  }

  /// 处理子待办长按（编辑）
  void _handleSubtodoLongPress(Todo subtodo) {
    debugPrint('编辑子待办: ${subtodo.title}');
    _editTodo(subtodo);
  }

  // ========== 业务逻辑实现 ==========

  /// 更新待办状态（可选择是否级联到子待办）
  void _updateTodoStatus(Todo todo, bool isCompleted,
      {bool cascadeToChildren = false}) {
    // 实现状态更新逻辑
    if (cascadeToChildren && todo.subtodos.isNotEmpty) {
      // 同时更新所有子待办状态
      for (final subtodo in todo.subtodos) {
        _updateTodoStatus(subtodo, isCompleted);
      }
    }
  }

  /// 更新子待办状态（可选择是否影响父待办）
  void _updateSubtodoStatus(Todo subtodo) {
    // 实现子待办状态更新逻辑
    // 检查是否需要更新父待办状态
    _checkParentTodoStatus(subtodo.parentTodoId);
  }

  /// 检查并更新父待办状态
  void _checkParentTodoStatus(String? parentTodoId) {
    if (parentTodoId == null) return;

    // 查找父待办
    final parentTodo = todos.firstWhere((todo) => todo.id == parentTodoId);

    // 检查所有子待办是否都已完成
    final allSubtodosCompleted =
        parentTodo.subtodos.every((subtodo) => subtodo.isCompleted);

    if (allSubtodosCompleted && !parentTodo.isCompleted) {
      // 如果所有子待办都完成了，自动完成父待办
      _updateTodoStatus(parentTodo, true);
    } else if (!allSubtodosCompleted && parentTodo.isCompleted) {
      // 如果有子待办未完成，取消父待办完成状态
      _updateTodoStatus(parentTodo, false);
    }
  }

  /// 删除待办及其所有子待办
  void _deleteTodoWithChildren(Todo todo) {
    // 实现删除逻辑
  }

  /// 删除单个子待办
  void _deleteSubtodo(Todo subtodo) {
    // 实现子待办删除逻辑
  }

  /// 切换子待办展开状态
  void _toggleSubtodosExpanded(Todo todo) {
    // 实现展开/折叠逻辑
  }

  /// 编辑待办
  void _editTodo(Todo todo) {
    // 实现编辑逻辑
  }

  /// 添加子待办
  void _addSubTodo(Todo parentTodo) {
    // 实现添加子待办逻辑
  }
}

/// 优化要点说明：
///
/// 1. **独立回调处理**：
///    - 父待办和子待办使用不同的回调方法
///    - 避免了操作混乱和数据不一致问题
///
/// 2. **清晰的职责分离**：
///    - 父待办回调处理父级逻辑
///    - 子待办回调处理子级逻辑
///    - 各自独立，互不干扰
///
/// 3. **灵活的状态管理**：
///    - 可以选择是否级联更新子待办状态
///    - 可以根据子待办状态自动更新父待办
///    - 支持复杂的业务逻辑
///
/// 4. **更好的用户体验**：
///    - 操作更加精确和可预期
///    - 减少意外的状态变更
///    - 支持更复杂的交互逻辑
///
/// 5. **易于维护和扩展**：
///    - 代码结构清晰
///    - 易于添加新的业务逻辑
///    - 便于单元测试
