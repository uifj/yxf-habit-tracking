import 'package:flutter/foundation.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../utils/date_util.dart';
import '../utils/toast_util.dart';
import 'dart:developer';

/// 任务管理状态Provider
/// 负责管理任务的CRUD操作、过滤、搜索等功能
class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskProvider({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;

  // 任务数据
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  Task? _selectedTask;

  // 加载状态
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _successMessage;

  // 过滤器状态
  String? _priorityFilter;
  String? _statusFilter; // 'all', 'completed', 'pending'
  String _searchQuery = '';
  DateTime? _dateFilter;

  // 排序状态
  String _sortBy = 'date'; // 'date', 'priority', 'title', 'created'
  bool _sortAscending = true;

  // 统计数据
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _todayTasks = 0;

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get filteredTasks => List.unmodifiable(_filteredTasks);
  Task? get selectedTask => _selectedTask;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String? get priorityFilter => _priorityFilter;
  String? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  DateTime? get dateFilter => _dateFilter;

  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;
  int get pendingTasks => _pendingTasks;
  int get todayTasks => _todayTasks;

  double get completionRate =>
      _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

  /// 初始化任务数据
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearMessages();

      await loadTasks();
      _isInitialized = true;

      log('TaskProvider initialized successfully');
    } catch (e) {
      _setError('Failed to initialize tasks: ${e.toString()}');
      log('Error initializing TaskProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载所有任务
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearMessages();

      _tasks = await _taskRepository.getTasks();
      _applyFiltersAndSort();
      _updateStatistics();

      log('Loaded ${_tasks.length} tasks');
    } catch (e) {
      _setError('Failed to load tasks: ${e.toString()}');
      log('Error loading tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新任务数据
  Future<void> refreshTasks() async {
    await loadTasks();
    ToastUtil.success('任务刷新成功');
  }

  /// 添加任务
  Future<bool> addTask(Task task) async {
    try {
      _setLoading(true);
      _clearMessages();

      final addedTask = await _taskRepository.addTask(task);
      _tasks.add(addedTask);
      _applyFiltersAndSort();
      _updateStatistics();

      ToastUtil.success('任务"${addedTask.title}"添加成功');
      log('Task added successfully: ${addedTask.title}');
      return true;
    } catch (e) {
      _setError('Failed to add task: ${e.toString()}');
      log('Error adding task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新任务
  Future<bool> updateTask(Task task) async {
    try {
      _setLoading(true);
      _clearMessages();

      final updatedTask = await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _applyFiltersAndSort();
        _updateStatistics();
      }

      ToastUtil.success('任务"${updatedTask.title}"更新成功');
      log('Task updated successfully: ${updatedTask.title}');
      return true;
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      log('Error updating task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 删除任务
  Future<bool> deleteTask(int taskId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final taskToDelete = _tasks.firstWhere((t) => t.id == taskId);
      await _taskRepository.deleteTask(taskToDelete);
      _tasks.removeWhere((t) => t.id == taskId);
      _applyFiltersAndSort();
      _updateStatistics();

      // 如果删除的是当前选中的任务，清除选中状态
      if (_selectedTask?.id == taskId) {
        _selectedTask = null;
      }

      ToastUtil.success('任务"${taskToDelete.title}"删除成功');
      log('Task deleted successfully: ID $taskId');
      return true;
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      log('Error deleting task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 批量删除任务
  Future<bool> deleteTasks(List<int> taskIds) async {
    try {
      _setLoading(true);
      _clearMessages();

      for (final taskId in taskIds) {
        final taskToDelete = _tasks.firstWhere((t) => t.id == taskId);
        await _taskRepository.deleteTask(taskToDelete);
      }

      _tasks.removeWhere((t) => taskIds.contains(t.id));
      _applyFiltersAndSort();
      _updateStatistics();

      // 清除选中状态如果被删除
      if (_selectedTask != null && taskIds.contains(_selectedTask!.id)) {
        _selectedTask = null;
      }

      ToastUtil.success('成功删除${taskIds.length}个任务');
      log('${taskIds.length} tasks deleted successfully');
      return true;
    } catch (e) {
      _setError('Failed to delete tasks: ${e.toString()}');
      log('Error deleting tasks: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 标记任务完成/未完成
  Future<bool> toggleTaskCompletion(Task task) async {
    try {
      _setLoading(true);
      _clearMessages();

      final updatedTask = task.copyWith(
        isCompleted: task.isCompleted == 1 ? 0 : 1,
        updatedAt: DateTime.now(),
      );

      final result = await _taskRepository.updateTask(updatedTask);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = result;
        _applyFiltersAndSort();
        _updateStatistics();
      }

      final statusText = result.isCompleted == 1 ? '已完成' : '待完成';
      ToastUtil.success('任务"${result.title}"标记为$statusText');
      log('Task completion toggled: ${result.title}');
      return true;
    } catch (e) {
      _setError('Failed to toggle task completion: ${e.toString()}');
      log('Error toggling task completion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 批量标记任务完成
  Future<bool> markTasksCompleted(List<int> taskIds, bool completed) async {
    try {
      _setLoading(true);
      _clearMessages();

      for (final taskId in taskIds) {
        final task = _tasks.firstWhere((t) => t.id == taskId);
        final updatedTask = task.copyWith(
          isCompleted: completed ? 1 : 0,
          updatedAt: DateTime.now(),
        );

        final result = await _taskRepository.updateTask(updatedTask);
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = result;
        }
      }

      _applyFiltersAndSort();
      _updateStatistics();

      final statusText = completed ? '已完成' : '待完成';
      ToastUtil.success('成功标记${taskIds.length}个任务为$statusText');
      log('${taskIds.length} tasks marked as ${completed ? 'completed' : 'pending'}');
      return true;
    } catch (e) {
      _setError('Failed to update tasks: ${e.toString()}');
      log('Error updating tasks: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 选择任务
  void selectTask(Task? task) {
    if (_selectedTask != task) {
      _selectedTask = task;
      notifyListeners();
      log('Task selected: ${task?.title ?? 'None'}');
    }
  }

  /// 设置优先级过滤器
  void setPriorityFilter(String? priority) {
    if (_priorityFilter != priority) {
      _priorityFilter = priority;
      _applyFiltersAndSort();
      notifyListeners();
      log('Priority filter set to: $priority');
    }
  }

  /// 设置状态过滤器
  void setStatusFilter(String? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      _applyFiltersAndSort();
      notifyListeners();
      log('Status filter set to: $status');
    }
  }

  /// 设置日期过滤器
  void setDateFilter(DateTime? date) {
    if (_dateFilter != date) {
      _dateFilter = date;
      _applyFiltersAndSort();
      notifyListeners();
      log('Date filter set to: ${date?.toString().split(' ')[0]}');
    }
  }

  /// 设置搜索查询
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFiltersAndSort();
      notifyListeners();
      log('Search query set to: $query');
    }
  }

  /// 设置排序方式
  void setSorting(String sortBy, {bool? ascending}) {
    bool changed = false;

    if (_sortBy != sortBy) {
      _sortBy = sortBy;
      changed = true;
    }

    if (ascending != null && _sortAscending != ascending) {
      _sortAscending = ascending;
      changed = true;
    }

    if (changed) {
      _applyFiltersAndSort();
      notifyListeners();
      log('Sorting set to: $sortBy (${_sortAscending ? 'ascending' : 'descending'})');
    }
  }

  /// 切换排序方向
  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    _applyFiltersAndSort();
    notifyListeners();
    log('Sort direction toggled to: ${_sortAscending ? 'ascending' : 'descending'}');
  }

  /// 清除所有过滤器
  void clearFilters() {
    _priorityFilter = null;
    _statusFilter = null;
    _dateFilter = null;
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
    log('All filters cleared');
  }

  /// 获取指定日期的任务
  List<Task> getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _tasks.where((task) {
      try {
        final taskDate = DateTime.parse(task.date);
        final normalizedTaskDate =
            DateTime(taskDate.year, taskDate.month, taskDate.day);
        return normalizedTaskDate.isAtSameMomentAs(normalizedDate);
      } catch (e) {
        log('Error parsing task date: ${task.date}');
        return false;
      }
    }).toList();
  }

  /// 获取指定优先级的任务
  List<Task> getTasksByPriority(String priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  /// 获取已完成的任务
  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted == 1).toList();
  }

  /// 获取待完成的任务
  List<Task> getPendingTasks() {
    return _tasks.where((task) => task.isCompleted == 0).toList();
  }

  /// 获取今天的任务
  List<Task> getTodayTasks() {
    final today = DateTime.now();
    return getTasksForDate(today);
  }

  /// 应用过滤器和排序
  void _applyFiltersAndSort() {
    List<Task> filtered = List.from(_tasks);

    // 应用优先级过滤
    if (_priorityFilter != null && _priorityFilter!.isNotEmpty) {
      filtered =
          filtered.where((task) => task.priority == _priorityFilter).toList();
    }

    // 应用状态过滤
    if (_statusFilter != null) {
      switch (_statusFilter) {
        case 'completed':
          filtered = filtered.where((task) => task.isCompleted == 1).toList();
          break;
        case 'pending':
          filtered = filtered.where((task) => task.isCompleted == 0).toList();
          break;
        // 'all' 或其他值不过滤
      }
    }

    // 应用日期过滤
    if (_dateFilter != null) {
      final normalizedDate =
          DateTime(_dateFilter!.year, _dateFilter!.month, _dateFilter!.day);
      filtered = filtered.where((task) {
        try {
          final taskDate = DateTime.parse(task.date);
          final normalizedTaskDate =
              DateTime(taskDate.year, taskDate.month, taskDate.day);
          return normalizedTaskDate.isAtSameMomentAs(normalizedDate);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // 应用搜索过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.note.toLowerCase().contains(query);
      }).toList();
    }

    // 应用排序
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'priority':
          final priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
          final aPriority = priorityOrder[a.priority] ?? 0;
          final bPriority = priorityOrder[b.priority] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
        case 'created':
          comparison =
              a.createdAt?.compareTo(b.createdAt ?? DateTime.now()) ?? 0;
          break;
        case 'date':
        default:
          try {
            final aDate = DateTime.parse(a.date);
            final bDate = DateTime.parse(b.date);
            comparison = aDate.compareTo(bDate);
          } catch (e) {
            comparison = a.date.compareTo(b.date);
          }
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    _filteredTasks = filtered;
  }

  /// 更新统计数据
  void _updateStatistics() {
    _totalTasks = _tasks.length;
    _completedTasks = _tasks.where((task) => task.isCompleted == 1).length;
    _pendingTasks = _tasks.where((task) => task.isCompleted == 0).length;

    final today = DateTime.now();
    _todayTasks = getTasksForDate(today).length;
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  /// 清除消息
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// 清除消息（公开方法）
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// 清理资源
  @override
  void dispose() {
    log('TaskProvider disposed');
    super.dispose();
  }
}
