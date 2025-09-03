import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../../data/models/task.dart';
import '../../data/models/habit.dart';
import '../../data/models/custom_tag.dart';
import '../../data/services/storage_service.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/habit_tracker_modal.dart';
import '../widgets/timer_modal.dart';
import '../widgets/settings_modal.dart';
import '../widgets/animated_background.dart';
import '../../core/utils/logger.dart';

/// 主日历页面
/// 基于priospace-main设计的现代化界面
class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week; // 默认周视图
  bool _darkMode = false;
  String _theme = 'default';

  // Modal states
  bool _showAddTask = false;
  bool _showHabits = false;
  bool _showTimer = false;

  // 企业级功能字段
  final Map<String, dynamic> _performanceMetrics = {};
  final Map<String, dynamic> _cachedData = {};
  DateTime? _lastCacheTime;
  bool _isLoading = false;
  String? _errorMessage;

  // 性能监控
  void _startPerformanceMonitoring(String operation) {
    _performanceMetrics[operation] = DateTime.now().millisecondsSinceEpoch;
    Logger.debug('开始操作: $operation', tag: 'CalendarPage');
  }

  void _endPerformanceMonitoring(String operation) {
    if (_performanceMetrics.containsKey(operation)) {
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          _performanceMetrics[operation];
      final duration = Duration(milliseconds: durationMs.toInt());
      Logger.performance(operation, duration);
      _performanceMetrics.remove(operation);
    }
  }

  // 错误处理
  void _handleError(String operation, dynamic error) {
    Logger.error('操作失败: $operation - ${error.toString()}');
    setState(() {
      _errorMessage = '操作失败，请重试';
      _isLoading = false;
    });
    _showErrorSnackBar(error.toString());
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 缓存管理
  bool _isCacheValid(String key) {
    if (_lastCacheTime == null || !_cachedData.containsKey(key)) return false;
    return DateTime.now().difference(_lastCacheTime!).inMinutes < 5;
  }

  void _updateCache(String key, dynamic data) {
    _cachedData[key] = data;
    _lastCacheTime = DateTime.now();
  }

  bool _showSettings = false;
  bool _showEditTask = false;
  Task? _editingTask;

  // 获取指定日期的任务
  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      try {
        final taskDate = DateTime.parse(task.date);
        return isSameDay(taskDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
    _initializeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadSettings() async {
    try {
      final settings = await StorageService.instance.loadSettings();
      setState(() {
        _darkMode = settings['darkMode'] ?? false;
        _theme = settings['theme'] ?? 'default';
      });
    } catch (e) {
      debugPrint('加载设置失败: $e');
    }
  }

  void _initializeData() {
    // 初始化所有BLoC数据
    context.read<TodoBloc>().add(const LoadTasksEvent());
    context.read<TodoBloc>().add(FilterTasksByDateEvent(_selectedDate));
    context.read<HabitBloc>().add(const LoadHabitsEvent());
    context.read<TimerBloc>().add(const LoadTimerSessionsEvent());
    context.read<TagBloc>().add(const LoadTagsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        backgroundColor: _getBackgroundColor(),
        body: Stack(
          children: [
            // 动态背景
            AnimatedBackground(
              isDarkMode: _darkMode,
              child: Container(),
            ),

            // 主要内容
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildWeeklyCalendar(),
                      Expanded(
                        child: _buildTaskList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 浮动操作按钮
            _buildFloatingButtons(),

            // 模态窗口
            _buildModals(),
          ],
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final baseTheme = _darkMode ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: _getBackgroundColor(),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: _darkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_darkMode) {
      return const Color(0xFF0F0F23);
    }

    switch (_theme) {
      case 'nature':
        return const Color(0xFFF0F8F0);
      case 'neo-brutal':
        return const Color(0xFFFFF8DC);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                intl.DateFormat.yMMMM('zh_CN').format(_selectedDate),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoaded) {
                    final todayTasks = state.filteredTasks.where((task) {
                      return task.date ==
                          intl.DateFormat('yyyy-MM-dd').format(_selectedDate);
                    }).toList();

                    final completedTasks = todayTasks
                        .where((task) => task.isCompleted == 1)
                        .length;

                    return Text(
                      '$completedTasks/${todayTasks.length} 任务完成',
                      style: TextStyle(
                        fontSize: 16,
                        color: _darkMode ? Colors.white70 : Colors.black54,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.timer_outlined,
                onTap: () => setState(() => _showTimer = true),
              ),
              const SizedBox(width: 12),
              _buildHeaderButton(
                icon: Icons.track_changes_outlined,
                onTap: () => setState(() => _showHabits = true),
              ),
              const SizedBox(width: 12),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onTap: () => setState(() => _showSettings = true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _darkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _darkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: _darkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _darkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 视图切换按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  intl.DateFormat.yMMMM('zh_CN').format(_focusedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    _buildViewToggleButton(
                      '周',
                      CalendarFormat.week,
                      _calendarFormat == CalendarFormat.week,
                    ),
                    const SizedBox(width: 8),
                    _buildViewToggleButton(
                      '月',
                      CalendarFormat.month,
                      _calendarFormat == CalendarFormat.month,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // TableCalendar组件
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              List<Task> allTasks = [];
              if (state is TodoLoaded) {
                allTasks = state.tasks;
              }

              return TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                calendarFormat: _calendarFormat,
                eventLoader: (day) => _getTasksForDay(day, allTasks),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: _darkMode ? Colors.red[300] : Colors.red[600],
                  ),
                  holidayTextStyle: TextStyle(
                    color: _darkMode ? Colors.red[300] : Colors.red[600],
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: _darkMode ? Colors.white : Colors.black87,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  markerSize: 6.0,
                  markersMaxCount: 3,
                  canMarkersOverflow: true,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: true,
                  rightChevronVisible: true,
                  titleTextStyle: TextStyle(
                    color: _darkMode ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: _darkMode ? Colors.white70 : Colors.black54,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: _darkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: _darkMode ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: _darkMode ? Colors.red[300] : Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                  // 通知TodoBloc按日期过滤任务
                  context
                      .read<TodoBloc>()
                      .add(FilterTasksByDateEvent(selectedDay));
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDate = focusedDay;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(
      String text, CalendarFormat format, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _calendarFormat = format;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (_darkMode ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (_darkMode ? Colors.white70 : Colors.black87),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, todoState) {
          return BlocBuilder<HabitBloc, HabitState>(
            builder: (context, habitState) {
              return BlocBuilder<TagBloc, TagState>(
                builder: (context, tagState) {
                  List<Task> tasks = [];
                  List<Habit> habits = [];
                  List<CustomTag> tags = [];

                  if (todoState is TodoLoaded) {
                    // 使用TodoBloc已经过滤好的任务
                    tasks = todoState.filteredTasks;
                  }

                  if (habitState is HabitLoaded) {
                    habits = habitState.habits;
                  }

                  if (tagState is TagLoaded) {
                    tags = tagState.tags;
                  }

                  return TaskListWidget(
                    tasks: tasks,
                    habits: habits,
                    customTags: tags,
                    selectedDate: _selectedDate,
                    darkMode: _darkMode,
                    onToggleTask: (task) {
                      context
                          .read<TodoBloc>()
                          .add(MarkTaskCompletedEvent(task));
                    },
                    onDeleteTask: (task) {
                      context.read<TodoBloc>().add(DeleteTaskEvent(task.id!));
                    },
                    onTaskClick: (task) {
                      _showEditTaskModal(task);
                    },
                    onAddSubtask: (task) {
                      // 处理添加子任务
                    },
                    onToggleSubtask: (task, subtask) {
                      final updatedSubtask = subtask.copyWith(
                        isCompleted: !subtask.isCompleted,
                      );
                      context.read<TodoBloc>().add(
                            UpdateSubtaskEvent(task.id!, updatedSubtask),
                          );
                    },
                    onDeleteSubtask: (task, subtask) {
                      context.read<TodoBloc>().add(
                            DeleteSubtaskEvent(task.id!, subtask.id!),
                          );
                    },
                    onEditSubtask: (task, subtask) {
                      // 处理编辑子任务
                    },
                    onToggleTaskExpanded: (task) {
                      context.read<TodoBloc>().add(
                            ToggleTaskExpandedEvent(task.id!),
                          );
                    },
                    onCreateTaskFromHabit: (habit, date, startTime, endTime) {
                      context.read<TodoBloc>().add(
                            CreateTasksFromHabitEvent(
                              habit: habit,
                              date: date,
                              startTime: startTime,
                              endTime: endTime,
                            ),
                          );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "add_task",
            onPressed: () => setState(() => _showAddTask = true),
            backgroundColor: const Color(0xFF3B82F6),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildModals() {
    return Stack(
      children: [
        // 添加任务模态窗口
        if (_showAddTask)
          AddTaskModal(
            selectedDate: _selectedDate,
            onClose: () => setState(() => _showAddTask = false),
            onAddTask: (task) {
              context.read<TodoBloc>().add(AddTaskEvent(task));
              setState(() => _showAddTask = false);
            },
            customTags: const [],
            onAddCustomTag: (tag) {
              context.read<TagBloc>().add(AddTagEvent(tag: tag));
            },
          ),

        // 编辑任务模态窗口
        if (_showEditTask && _editingTask != null)
          AddTaskModal(
            selectedDate: _selectedDate,
            onClose: () => setState(() {
              _showEditTask = false;
              _editingTask = null;
            }),
            onAddTask: (task) {
              final updatedTask = task.copyWith(id: _editingTask!.id);
              context.read<TodoBloc>().add(UpdateTaskEvent(updatedTask));
              setState(() {
                _showEditTask = false;
                _editingTask = null;
              });
            },
            customTags: const [],
            onAddCustomTag: (tag) {
              context.read<TagBloc>().add(AddTagEvent(tag: tag));
            },
          ),

        // 习惯追踪模态窗口
        if (_showHabits)
          HabitTrackerModal(
            onClose: () => setState(() => _showHabits = false),
          ),

        // 计时器模态窗口
        if (_showTimer)
          TimerModal(
            onClose: () => setState(() => _showTimer = false),
          ),

        // 设置模态窗口
        if (_showSettings)
          SettingsModal(
            onClose: () => setState(() => _showSettings = false),
            onThemeChanged: (value) {
              setState(() => _darkMode = value);
              _saveSettings();
            },
            isDarkMode: _darkMode,
          ),
      ],
    );
  }

  void _saveSettings() async {
    try {
      await StorageService.instance.saveSettings({
        'darkMode': _darkMode,
        'theme': _theme,
      });
    } catch (e) {
      debugPrint('保存设置失败: $e');
    }
  }

  void _exportData() async {
    try {
      final filePath = await StorageService.instance.exportAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('数据导出成功: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importData() async {
    // 这里应该打开文件选择器
    // 暂时使用固定路径作为示例
    try {
      // final filePath = await FilePicker.getFilePath();
      // await StorageService.instance.importData(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('导入功能需要文件选择器支持'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导入失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditTaskModal(Task task) {
    setState(() {
      _editingTask = task;
      _showEditTask = true;
    });
  }

  void _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await StorageService.instance.clearAllData();
        _initializeData(); // 重新初始化数据
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据清除成功'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
