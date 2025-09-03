import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import 'dart:developer';

/// 日历状态管理Provider
/// 负责管理日历视图状态、选中日期、任务数据等
class CalendarProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;

  CalendarProvider({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;

  // 日历状态
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // 任务数据
  List<Task> _allTasks = [];
  List<Task> _selectedDayTasks = [];
  final Map<DateTime, List<Task>> _tasksByDate = {};

  // 加载状态
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // 过滤器状态
  String? _selectedPriority;
  bool _showCompletedTasks = true;
  String _searchQuery = '';

  // Getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  RangeSelectionMode get rangeSelectionMode => _rangeSelectionMode;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;

  List<Task> get allTasks => List.unmodifiable(_allTasks);
  List<Task> get selectedDayTasks => List.unmodifiable(_selectedDayTasks);
  Map<DateTime, List<Task>> get tasksByDate => Map.unmodifiable(_tasksByDate);

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  String? get selectedPriority => _selectedPriority;
  bool get showCompletedTasks => _showCompletedTasks;
  String get searchQuery => _searchQuery;

  /// 初始化日历数据
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      // 设置默认选中今天
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();

      // 加载任务数据
      await loadTasks();

      _isInitialized = true;
      log('CalendarProvider initialized successfully');
    } catch (e) {
      _setError('Failed to initialize calendar: ${e.toString()}');
      log('Error initializing CalendarProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载所有任务
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearError();

      _allTasks = await _taskRepository.getTasks();
      _buildTasksByDateMap();
      _updateSelectedDayTasks();

      log('Loaded ${_allTasks.length} tasks');
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
  }

  /// 添加任务
  Future<bool> addTask(Task task) async {
    try {
      _setLoading(true);
      _clearError();

      final addedTask = await _taskRepository.addTask(task);
      _allTasks.add(addedTask);
      _buildTasksByDateMap();
      _updateSelectedDayTasks();

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
      _clearError();

      final updatedTask = await _taskRepository.updateTask(task);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
        _buildTasksByDateMap();
        _updateSelectedDayTasks();
      }

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
      _clearError();

      final taskToDelete = _allTasks.firstWhere((t) => t.id == taskId);
      await _taskRepository.deleteTask(taskToDelete);
      _allTasks.removeWhere((t) => t.id == taskId);
      _buildTasksByDateMap();
      _updateSelectedDayTasks();

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

  /// 标记任务完成
  Future<bool> toggleTaskCompletion(Task task) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedTask = task.copyWith(
        isCompleted: task.isCompleted == 1 ? 0 : 1,
        updatedAt: DateTime.now(),
      );

      final result = await _taskRepository.updateTask(updatedTask);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = result;
        _buildTasksByDateMap();
        _updateSelectedDayTasks();
      }

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

  /// 选择日期
  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;

      _updateSelectedDayTasks();
      notifyListeners();

      log('Day selected: ${selectedDay.toString().split(' ')[0]}');
    }
  }

  /// 选择日期范围
  void selectRange(DateTime? start, DateTime? end, DateTime focusedDay) {
    _selectedDay = null;
    _focusedDay = focusedDay;
    _rangeStart = start;
    _rangeEnd = end;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;

    _updateSelectedDayTasks();
    notifyListeners();

    log('Range selected: ${start?.toString().split(' ')[0]} - ${end?.toString().split(' ')[0]}');
  }

  /// 切换日历格式
  void toggleCalendarFormat() {
    switch (_calendarFormat) {
      case CalendarFormat.month:
        _calendarFormat = CalendarFormat.twoWeeks;
        break;
      case CalendarFormat.twoWeeks:
        _calendarFormat = CalendarFormat.week;
        break;
      case CalendarFormat.week:
        _calendarFormat = CalendarFormat.month;
        break;
    }
    notifyListeners();
    log('Calendar format changed to: $_calendarFormat');
  }

  /// 设置优先级过滤器
  void setPriorityFilter(String? priority) {
    if (_selectedPriority != priority) {
      _selectedPriority = priority;
      _updateSelectedDayTasks();
      notifyListeners();
      log('Priority filter set to: $priority');
    }
  }

  /// 切换显示已完成任务
  void toggleShowCompletedTasks() {
    _showCompletedTasks = !_showCompletedTasks;
    _updateSelectedDayTasks();
    notifyListeners();
    log('Show completed tasks: $_showCompletedTasks');
  }

  /// 设置搜索查询
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _updateSelectedDayTasks();
      notifyListeners();
      log('Search query set to: $query');
    }
  }

  /// 清除所有过滤器
  void clearFilters() {
    _selectedPriority = null;
    _showCompletedTasks = true;
    _searchQuery = '';
    _updateSelectedDayTasks();
    notifyListeners();
    log('All filters cleared');
  }

  /// 获取指定日期的任务
  List<Task> getTasksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _tasksByDate[normalizedDay] ?? [];
  }

  /// 获取日期范围内的任务
  List<Task> getTasksForRange(DateTime start, DateTime end) {
    final tasks = <Task>[];
    for (var day = start;
        day.isBefore(end.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))) {
      tasks.addAll(getTasksForDay(day));
    }
    return tasks;
  }

  /// 构建按日期分组的任务映射
  void _buildTasksByDateMap() {
    _tasksByDate.clear();
    for (final task in _allTasks) {
      try {
        final date = DateTime.parse(task.date);
        final normalizedDate = DateTime(date.year, date.month, date.day);

        if (_tasksByDate[normalizedDate] == null) {
          _tasksByDate[normalizedDate] = [];
        }
        _tasksByDate[normalizedDate]!.add(task);
      } catch (e) {
        log('Error parsing task date: ${task.date}, error: $e');
      }
    }
  }

  /// 更新选中日期的任务列表
  void _updateSelectedDayTasks() {
    List<Task> tasks = [];

    if (_selectedDay != null) {
      tasks = getTasksForDay(_selectedDay!);
    } else if (_rangeStart != null && _rangeEnd != null) {
      tasks = getTasksForRange(_rangeStart!, _rangeEnd!);
    }

    // 应用过滤器
    tasks = _applyFilters(tasks);

    _selectedDayTasks = tasks;
  }

  /// 应用过滤器
  List<Task> _applyFilters(List<Task> tasks) {
    List<Task> filtered = List.from(tasks);

    // 优先级过滤
    if (_selectedPriority != null && _selectedPriority!.isNotEmpty) {
      filtered =
          filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    // 完成状态过滤
    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => task.isCompleted == 0).toList();
    }

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.note.toLowerCase().contains(query);
      }).toList();
    }

    // 按开始时间排序
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

    return filtered;
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
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 清理资源
  @override
  void dispose() {
    log('CalendarProvider disposed');
    super.dispose();
  }
}
