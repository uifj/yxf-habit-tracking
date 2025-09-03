import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer';
import '../../data/models/task.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/task_repository.dart';
import '../../core/error/exceptions.dart';
import 'package:intl/intl.dart';

part 'todo_event.dart';
part 'todo_state.dart';

/// Todo业务逻辑组件
/// 负责管理任务的状态和业务逻辑
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TaskRepository _taskRepository;

  /// 当前选择的日期
  DateTime? _selectedDate;

  /// 当前选择的优先级
  String? _selectedPriority;

  /// 是否正在同步
  bool _isSyncing = false;

  TodoBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        _selectedDate = DateTime.now(),
        super(TodoInitial()) {
    // 注册事件处理器
    on<InitializeTodoEvent>(_onInitializeTodo);
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<MarkTaskCompletedEvent>(_onMarkTaskCompleted);
    on<SyncDataEvent>(_onSyncData);
    on<FilterTasksByDateEvent>(_onFilterTasksByDate);
    on<FilterTasksByPriorityEvent>(_onFilterTasksByPriority);
    on<ClearAllTasksEvent>(_onClearAllTasks);
    on<BulkInsertTasksEvent>(_onBulkInsertTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<SearchTasksEvent>(_onSearchTasks);
    // 子任务相关事件处理器
    on<AddSubtaskEvent>(_onAddSubtask);
    on<UpdateSubtaskEvent>(_onUpdateSubtask);
    on<DeleteSubtaskEvent>(_onDeleteSubtask);
    on<ToggleTaskExpandedEvent>(_onToggleTaskExpanded);
    on<CreateTasksFromHabitEvent>(_onCreateTasksFromHabit);
  }

  /// 获取当前选择的日期
  DateTime? get selectedDate => _selectedDate;

  /// 获取当前选择的优先级
  String? get selectedPriority => _selectedPriority;

  /// 获取同步状态
  bool get isSyncing => _isSyncing;

  /// 初始化Todo
  Future<void> _onInitializeTodo(
    InitializeTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Initializing TodoBloc');
      emit(TodoLoading());

      // 初始化选择的日期为今天
      _selectedDate = DateTime.now();
      _selectedPriority = null;
      _isSyncing = false;

      // 加载任务
      final tasks = await _taskRepository.getTasks();

      // 如果没有任务，创建一些示例任务用于测试
      if (tasks.isEmpty) {
        await _createSampleTasks();
        // 重新加载任务
        final updatedTasks = await _taskRepository.getTasks();
        final filteredTasks =
            _applyFilters(updatedTasks, _selectedDate, _selectedPriority);

        emit(TodoLoaded(
          tasks: updatedTasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate!,
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
        log('TodoBloc initialized with ${updatedTasks.length} sample tasks');
      } else {
        final filteredTasks =
            _applyFilters(tasks, _selectedDate, _selectedPriority);

        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate!,
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
        log('TodoBloc initialized successfully with ${tasks.length} tasks');
      }

      // 自动同步功能暂时禁用
      // if (event.autoSync) {
      //   add(const SyncDataEvent());
      // }
    } catch (e) {
      log('Error initializing todo: $e');
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to initialize: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 加载任务
  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Loading tasks');

      // 如果不是强制刷新，且当前状态已经是加载状态，则不重复加载
      if (!event.forceRefresh && state is TodoLoaded) {
        log('Tasks already loaded, skipping');
        return;
      }

      emit(TodoLoading());

      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: _isSyncing,
      ));

      log('Tasks loaded successfully: ${tasks.length} total, ${filteredTasks.length} filtered');
    } catch (e) {
      log('Error loading tasks: $e');
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to load tasks: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 刷新任务
  Future<void> _onRefreshTasks(
    RefreshTasksEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Refreshing tasks');

      final currentState = state;
      if (currentState is TodoLoaded) {
        // 保持当前状态，只更新同步标志
        emit(currentState.copyWith(isSyncing: true));
        _isSyncing = true;
      }

      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      _isSyncing = false;
      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: false,
      ));

      log('Tasks refreshed successfully');
    } catch (e) {
      log('Error refreshing tasks: $e');
      _isSyncing = false;
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to refresh tasks: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 搜索任务
  Future<void> _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      try {
        log('Searching tasks with query: ${event.query}');

        List<Task> searchResults;

        if (event.query.isEmpty) {
          // 如果搜索查询为空，显示所有过滤后的任务
          searchResults = _applyFilters(
              currentState.tasks, _selectedDate, _selectedPriority);
        } else {
          // 在所有任务中搜索
          searchResults = currentState.tasks.where((task) {
            final query = event.query.toLowerCase();
            return task.title.toLowerCase().contains(query) ||
                (task.note.toLowerCase().contains(query) ?? false);
          }).toList();

          // 然后应用其他过滤器
          searchResults =
              _applyFilters(searchResults, _selectedDate, _selectedPriority);
        }

        emit(currentState.copyWith(
          filteredTasks: searchResults,
          // searchQuery: event.query,
        ));

        log('Search completed: ${searchResults.length} results found');
      } catch (e) {
        log('Error searching tasks: $e');
        // 搜索错误不应该影响整体状态，只记录日志
      }
    }
  }

  /// 添加任务
  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Adding task: ${event.task.title}');

      final currentState = state;
      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(isSyncing: true));
        _isSyncing = true;
      }

      // 验证任务数据
      if (event.task.title.trim().isEmpty) {
        throw const ValidationException(
          message: 'Task title cannot be empty',
        );
      }

      await _taskRepository.addTask(event.task);

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      _isSyncing = false;

      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate ?? DateTime.now(),
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
      }

      log('Task added successfully: ${event.task.title}');

      // 发送成功状态（短暂显示）
      emit(TodoOperationSuccess(
        message: 'Task "${event.task.title}" added successfully',
        tasks: tasks,
      ));

      // 延迟后恢复正常状态
      await Future.delayed(const Duration(milliseconds: 500));
      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: false,
      ));
    } catch (e) {
      log('Error adding task: $e');
      _isSyncing = false;
      final errorMessage =
          e is AppException ? e.message : 'Failed to add task: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 更新任务
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Updating task: ${event.task.title}');

      final currentState = state;
      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(isSyncing: true));
        _isSyncing = true;
      }

      // 验证任务数据
      if (event.task.title.trim().isEmpty) {
        throw const ValidationException(
          message: 'Task title cannot be empty',
        );
      }

      if (event.task.id == null) {
        throw const ValidationException(
          message: 'Task ID is required for update',
        );
      }

      await _taskRepository.updateTask(event.task);

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      _isSyncing = false;

      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate ?? DateTime.now(),
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
      }

      log('Task updated successfully: ${event.task.title}');

      // 发送成功状态（短暂显示）
      emit(TodoOperationSuccess(
        message: 'Task "${event.task.title}" updated successfully',
        tasks: tasks,
      ));

      // 延迟后恢复正常状态
      await Future.delayed(const Duration(milliseconds: 500));
      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: false,
      ));
    } catch (e) {
      log('Error updating task: $e');
      _isSyncing = false;
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to update task: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 删除任务
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Deleting task with ID: ${event.taskId}');

      final currentState = state;
      String? taskTitle;

      // 获取要删除的任务标题（用于显示消息）
      if (currentState is TodoLoaded) {
        final taskToDelete = currentState.tasks.firstWhere(
          (task) => task.id == event.taskId,
          orElse: () => Task.empty(),
        );
        taskTitle = taskToDelete.title.isNotEmpty ? taskToDelete.title : null;

        emit(currentState.copyWith(isSyncing: true));
        _isSyncing = true;
      }

      await _taskRepository.deleteTask(Task(
        id: event.taskId,
        title: '',
        note: '',
        date: '',
        startTime: '',
        endTime: '',
        priority: '',
        isCompleted: 0,
        color: 0,
        remind: 0,
        repeat: '',
      ));

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      _isSyncing = false;

      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate ?? DateTime.now(),
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
      }

      log('Task deleted successfully');

      final message = taskTitle != null
          ? 'Task "$taskTitle" deleted successfully'
          : 'Task deleted successfully';

      // 发送成功状态（短暂显示）
      emit(TodoOperationSuccess(
        message: message,
        tasks: tasks,
      ));

      // 延迟后恢复正常状态
      await Future.delayed(const Duration(milliseconds: 500));
      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: false,
      ));
    } catch (e) {
      log('Error deleting task: $e');
      _isSyncing = false;
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to delete task: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 标记任务完成
  Future<void> _onMarkTaskCompleted(
    MarkTaskCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      log('Marking task as completed: ${event.task.title}');

      final currentState = state;
      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(isSyncing: true));
        _isSyncing = true;
      }

      // 验证任务ID
      if (event.task.id == null) {
        throw const ValidationException(
          message: 'Task ID is required to mark as completed',
        );
      }

      await _taskRepository.markTaskCompleted(event.task);

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();
      final filteredTasks =
          _applyFilters(tasks, _selectedDate, _selectedPriority);

      _isSyncing = false;

      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: filteredTasks,
          selectedDate: _selectedDate ?? DateTime.now(),
          selectedPriority: _selectedPriority,
          isSyncing: false,
        ));
      }

      log('Task marked as completed successfully: ${event.task.title}');

      // 发送成功状态（短暂显示）
      emit(TodoOperationSuccess(
        message: 'Task "${event.task.title}" completed',
        tasks: tasks,
      ));

      // 延迟后恢复正常状态
      await Future.delayed(const Duration(milliseconds: 500));
      emit(TodoLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        selectedDate: _selectedDate ?? DateTime.now(),
        selectedPriority: _selectedPriority,
        isSyncing: false,
      ));
    } catch (e) {
      log('Error marking task completed: $e');
      _isSyncing = false;
      final errorMessage = e is AppException
          ? e.message
          : 'Failed to mark task completed: ${e.toString()}';
      emit(TodoError(errorMessage));
    }
  }

  /// 同步数据
  Future<void> _onSyncData(
    SyncDataEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      List<Task> currentTasks = [];

      if (currentState is TodoLoaded) {
        currentTasks = currentState.tasks;
        emit(TodoSyncing(currentTasks));
      } else {
        emit(TodoSyncing(currentTasks));
      }

      await _taskRepository.syncData();

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();

      if (currentState is TodoLoaded) {
        final filteredTasks = _applyFilters(
          tasks,
          currentState.selectedDate,
          currentState.selectedPriority,
        );

        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: tasks,
          selectedDate: DateTime.now(),
        ));
      }

      emit(TodoSyncCompleted(
        tasks: tasks,
        message: 'Data synchronized successfully',
      ));
    } catch (e) {
      log('Error syncing data: $e');
      emit(TodoError('Failed to sync data: ${e.toString()}'));
    }
  }

  /// 按日期过滤任务
  Future<void> _onFilterTasksByDate(
    FilterTasksByDateEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      final filteredTasks = _applyFilters(
        currentState.tasks,
        event.date,
        currentState.selectedPriority,
      );

      emit(currentState.copyWith(
        selectedDate: event.date,
        filteredTasks: filteredTasks,
      ));
    }
  }

  /// 按优先级过滤任务
  Future<void> _onFilterTasksByPriority(
    FilterTasksByPriorityEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      final filteredTasks = _applyFilters(
        currentState.tasks,
        currentState.selectedDate,
        event.priority,
      );

      emit(currentState.copyWith(
        selectedPriority: event.priority,
        filteredTasks: filteredTasks,
      ));
    }
  }

  /// 清除所有任务
  Future<void> _onClearAllTasks(
    ClearAllTasksEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(TodoLoading());

      await _taskRepository.clearAllTasks();

      emit(const TodoLoaded(
        tasks: [],
        filteredTasks: [],
      ));

      emit(const TodoOperationSuccess(
        message: 'All tasks cleared successfully',
        tasks: [],
      ));
    } catch (e) {
      log('Error clearing all tasks: $e');
      emit(TodoError('Failed to clear all tasks: ${e.toString()}'));
    }
  }

  /// 批量插入任务
  Future<void> _onBulkInsertTasks(
    BulkInsertTasksEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        emit(currentState.copyWith(isSyncing: true));
      }

      await _taskRepository.bulkInsertTasks(event.tasks);

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();

      if (currentState is TodoLoaded) {
        final filteredTasks = _applyFilters(
          tasks,
          currentState.selectedDate,
          currentState.selectedPriority,
        );

        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
          isSyncing: false,
        ));
      } else {
        emit(TodoLoaded(
          tasks: tasks,
          filteredTasks: tasks,
          selectedDate: DateTime.now(),
        ));
      }

      emit(TodoOperationSuccess(
        message: '${event.tasks.length} tasks added successfully',
        tasks: tasks,
      ));
    } catch (e) {
      log('Error bulk inserting tasks: $e');
      emit(TodoError('Failed to bulk insert tasks: ${e.toString()}'));
    }
  }

  /// 创建示例任务用于测试
  Future<void> _createSampleTasks() async {
    try {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));

      final sampleTasks = [
        Task(
          title: '完成项目报告',
          note: '准备季度项目总结报告，包含数据分析和建议',
          isCompleted: 0,
          priority: 'High',
          date: _formatDate(today),
          startTime: '09:00',
          endTime: '11:00',
          color: 0xFFFF0000,
          remind: 15,
          repeat: 'None',
        ),
        Task(
          title: '团队会议',
          note: '讨论下周的工作安排和项目进度',
          isCompleted: 0,
          priority: 'Medium',
          date: _formatDate(today),
          startTime: '14:00',
          endTime: '15:30',
          color: 0xFFFFA500,
          remind: 10,
          repeat: 'None',
        ),
        Task(
          title: '代码审查',
          note: '审查新功能的代码实现',
          isCompleted: 1,
          priority: 'Medium',
          date: _formatDate(yesterday),
          startTime: '16:00',
          endTime: '17:00',
          color: 0xFF008000,
          remind: 5,
          repeat: 'None',
        ),
        Task(
          title: '客户演示准备',
          note: '准备明天的客户产品演示材料',
          isCompleted: 0,
          priority: 'High',
          date: _formatDate(tomorrow),
          startTime: '10:00',
          endTime: '12:00',
          color: 0xFFFF0000,
          remind: 30,
          repeat: 'None',
        ),
        Task(
          title: '健身锻炼',
          note: '每日健身计划：跑步30分钟',
          isCompleted: 0,
          priority: 'Low',
          date: _formatDate(today),
          startTime: '18:00',
          endTime: '19:00',
          color: 0xFF008000,
          remind: 5,
          repeat: 'Daily',
        ),
      ];

      for (final task in sampleTasks) {
        await _taskRepository.addTask(task);
      }

      log('Created ${sampleTasks.length} sample tasks');
    } catch (e) {
      log('Error creating sample tasks: $e');
    }
  }

  /// 格式化日期为字符串
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 应用过滤器
  List<Task> _applyFilters(
    List<Task> tasks,
    DateTime? selectedDate,
    String? selectedPriority,
  ) {
    List<Task> filtered = List.from(tasks);

    // 按日期过滤
    if (selectedDate != null) {
      String dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
      filtered = filtered.where((task) => task.date == dateString).toList();
    }

    // 按优先级过滤
    if (selectedPriority != null &&
        selectedPriority.isNotEmpty &&
        selectedPriority != 'All') {
      filtered =
          filtered.where((task) => task.priority == selectedPriority).toList();
    }

    return filtered;
  }

  /// 添加子任务
  Future<void> _onAddSubtask(
    AddSubtaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TodoLoaded) return;

      // 找到父任务
      final parentTaskIndex = currentState.tasks.indexWhere(
        (task) => task.id == event.parentTaskId,
      );

      if (parentTaskIndex == -1) {
        emit(const TodoError('Parent task not found'));
        return;
      }

      final parentTask = currentState.tasks[parentTaskIndex];
      final updatedSubtasks = List<Subtask>.from(parentTask.subtasks)
        ..add(event.subtask.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          createdAt: DateTime.now(),
        ));

      final updatedTask = parentTask.copyWith(
        subtasks: updatedSubtasks,
        updatedAt: DateTime.now(),
      );

      // 更新任务
      await _taskRepository.updateTask(updatedTask);

      // 更新状态
      final updatedTasks = List<Task>.from(currentState.tasks)
        ..[parentTaskIndex] = updatedTask;

      final filteredTasks = _applyFilters(
        updatedTasks,
        _selectedDate,
        _selectedPriority,
      );

      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));

      emit(TodoOperationSuccess(
        message: 'Subtask added successfully',
        tasks: updatedTasks,
      ));
    } catch (e) {
      log('Error adding subtask: $e');
      emit(TodoError('Failed to add subtask: ${e.toString()}'));
    }
  }

  /// 更新子任务
  Future<void> _onUpdateSubtask(
    UpdateSubtaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TodoLoaded) return;

      // 找到父任务
      final parentTaskIndex = currentState.tasks.indexWhere(
        (task) => task.id == event.parentTaskId,
      );

      if (parentTaskIndex == -1) {
        emit(const TodoError('Parent task not found'));
        return;
      }

      final parentTask = currentState.tasks[parentTaskIndex];
      final subtaskIndex = parentTask.subtasks.indexWhere(
        (subtask) => subtask.id == event.subtask.id,
      );

      if (subtaskIndex == -1) {
        emit(const TodoError('Subtask not found'));
        return;
      }

      final updatedSubtasks = List<Subtask>.from(parentTask.subtasks)
        ..[subtaskIndex] = event.subtask;

      final updatedTask = parentTask.copyWith(
        subtasks: updatedSubtasks,
        updatedAt: DateTime.now(),
      );

      // 更新任务
      await _taskRepository.updateTask(updatedTask);

      // 更新状态
      final updatedTasks = List<Task>.from(currentState.tasks)
        ..[parentTaskIndex] = updatedTask;

      final filteredTasks = _applyFilters(
        updatedTasks,
        _selectedDate,
        _selectedPriority,
      );

      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));

      emit(TodoOperationSuccess(
        message: 'Subtask updated successfully',
        tasks: updatedTasks,
      ));
    } catch (e) {
      log('Error updating subtask: $e');
      emit(TodoError('Failed to update subtask: ${e.toString()}'));
    }
  }

  /// 删除子任务
  Future<void> _onDeleteSubtask(
    DeleteSubtaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TodoLoaded) return;

      // 找到父任务
      final parentTaskIndex = currentState.tasks.indexWhere(
        (task) => task.id == event.parentTaskId,
      );

      if (parentTaskIndex == -1) {
        emit(const TodoError('Parent task not found'));
        return;
      }

      final parentTask = currentState.tasks[parentTaskIndex];
      final updatedSubtasks = parentTask.subtasks
          .where((subtask) => subtask.id != event.subtaskId)
          .toList();

      final updatedTask = parentTask.copyWith(
        subtasks: updatedSubtasks,
        updatedAt: DateTime.now(),
      );

      // 更新任务
      await _taskRepository.updateTask(updatedTask);

      // 更新状态
      final updatedTasks = List<Task>.from(currentState.tasks)
        ..[parentTaskIndex] = updatedTask;

      final filteredTasks = _applyFilters(
        updatedTasks,
        _selectedDate,
        _selectedPriority,
      );

      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));

      emit(TodoOperationSuccess(
        message: 'Subtask deleted successfully',
        tasks: updatedTasks,
      ));
    } catch (e) {
      log('Error deleting subtask: $e');
      emit(TodoError('Failed to delete subtask: ${e.toString()}'));
    }
  }

  /// 切换任务展开状态
  Future<void> _onToggleTaskExpanded(
    ToggleTaskExpandedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TodoLoaded) return;

      // 找到任务
      final taskIndex = currentState.tasks.indexWhere(
        (task) => task.id == event.taskId,
      );

      if (taskIndex == -1) {
        emit(const TodoError('Task not found'));
        return;
      }

      final task = currentState.tasks[taskIndex];
      final updatedTask = task.copyWith(
        isExpanded: !task.isExpanded,
      );

      // 更新状态（不需要持久化到数据库，这只是UI状态）
      final updatedTasks = List<Task>.from(currentState.tasks)
        ..[taskIndex] = updatedTask;

      final filteredTasks = _applyFilters(
        updatedTasks,
        _selectedDate,
        _selectedPriority,
      );

      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));
    } catch (e) {
      log('Error toggling task expanded: $e');
      emit(TodoError('Failed to toggle task expanded: ${e.toString()}'));
    }
  }

  /// 从习惯创建任务列表
  Future<void> _onCreateTasksFromHabit(
    CreateTasksFromHabitEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TodoLoaded) return;

      // 创建基于习惯的任务
      final task = Task(
        title: event.habit.name,
        note: event.habit.description ??
            'Generated from habit: ${event.habit.name}',
        isCompleted: 0,
        priority: 'Medium',
        date: DateFormat('yyyy-MM-dd').format(event.date),
        startTime: event.startTime,
        endTime: event.endTime,
        color: 0xFF22c55e, // 使用习惯的绿色
        remind: 5,
        repeat: 'None',
        tag: event.habit.tag,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subtasks: const [],
        focusTimeSeconds: 0,
        totalTimeMinutes: 0,
        isExpanded: false,
        metadata: {
          'source': 'habit',
          'habitId': event.habit.id,
          'habitName': event.habit.name,
        },
      );

      // 添加任务
      await _taskRepository.addTask(task);

      // 重新加载任务
      final tasks = await _taskRepository.getTasks();
      final filteredTasks = _applyFilters(
        tasks,
        _selectedDate,
        _selectedPriority,
      );

      emit(currentState.copyWith(
        tasks: tasks,
        filteredTasks: filteredTasks,
      ));

      emit(TodoOperationSuccess(
        message: 'Task created from habit: ${event.habit.name}',
        tasks: tasks,
      ));
    } catch (e) {
      log('Error creating task from habit: $e');
      emit(TodoError('Failed to create task from habit: ${e.toString()}'));
    }
  }
}
