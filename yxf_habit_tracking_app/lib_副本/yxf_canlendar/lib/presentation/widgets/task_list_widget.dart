import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../../data/models/habit.dart';
import '../../data/models/custom_tag.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import 'task_tile.dart';
import 'habit_tile.dart';
import 'package:flutter/services.dart';

/// 任务列表组件
/// 基于priospace-main的现代化设计风格，支持子任务管理和从习惯创建任务
class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final List<Habit> habits;
  final List<CustomTag> customTags;
  final DateTime selectedDate;
  final bool darkMode;
  final Function(Task) onToggleTask;
  final Function(Task) onDeleteTask;
  final Function(Task) onTaskClick;
  final Function(Task) onAddSubtask;
  final Function(Task, Subtask) onToggleSubtask;
  final Function(Task, Subtask) onDeleteSubtask;
  final Function(Task, Subtask) onEditSubtask;
  final Function(Task) onToggleTaskExpanded;
  final Function(Habit, DateTime, String, String) onCreateTaskFromHabit;

  const TaskListWidget({
    Key? key,
    required this.tasks,
    required this.habits,
    required this.customTags,
    required this.selectedDate,
    this.darkMode = false,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onTaskClick,
    required this.onAddSubtask,
    required this.onToggleSubtask,
    required this.onDeleteSubtask,
    required this.onEditSubtask,
    required this.onToggleTaskExpanded,
    required this.onCreateTaskFromHabit,
  }) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final String _selectedFilter = 'all';
  String _searchQuery = '';
  final Map<int, bool> _expandedTasks = {};

  // 音效控制
  final bool _soundEnabled = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExpandedStates();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _staggerController.forward();
  }

  void _loadExpandedStates() {
    // 从任务数据中加载展开状态
    for (final task in widget.tasks) {
      if (task.id != null) {
        _expandedTasks[task.id!] = task.isExpanded;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    List<Task> filtered = widget.tasks;

    // 应用搜索过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.note.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 应用状态过滤
    switch (_selectedFilter) {
      case 'completed':
        filtered = filtered.where((task) => task.isCompleted == 1).toList();
        break;
      case 'pending':
        filtered = filtered.where((task) => task.isCompleted == 0).toList();
        break;
      case 'high':
        filtered = filtered.where((task) => task.priority == 'High').toList();
        break;
      default:
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.darkMode
                    ? Colors.grey[900]?.withOpacity(0.8)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.darkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.darkMode
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.darkMode
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernHeader(),
                  Flexible(
                    flex: 0,
                    child: _buildHabitsSection(),
                  ),
                  Flexible(
                    flex: 0,
                    child: _buildEnhancedFilterBar(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildModernTaskList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader() {
    final isToday = DateFormat('yyyy-MM-dd').format(widget.selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final completedCount =
        _filteredTasks.where((t) => t.isCompleted == 1).length;
    final totalCount = _filteredTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isToday
                              ? '今日任务'
                              : _formatTaskDate(widget.selectedDate),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color:
                                widget.darkMode ? Colors.white : Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: progress == 1.0
                                ? Colors.green.withOpacity(0.1)
                                : const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: progress == 1.0
                                  ? Colors.green.withOpacity(0.3)
                                  : const Color(0xFF3B82F6).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                progress == 1.0
                                    ? Icons.check_circle
                                    : Icons.schedule,
                                size: 14,
                                color: progress == 1.0
                                    ? Colors.green
                                    : const Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$completedCount/$totalCount 已完成',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: progress == 1.0
                                      ? Colors.green
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildProgressIndicator(),
            ],
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 16),
            _buildProgressBar(progress),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final total = _filteredTasks.length;
    final completed = _filteredTasks.where((t) => t.isCompleted == 1).length;
    final progress = total > 0 ? completed / total : 0.0;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: widget.darkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.darkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: widget.darkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? Colors.green : const Color(0xFF3B82F6),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 搜索框
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: widget.darkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: '搜索任务...',
                hintStyle: TextStyle(
                  color: widget.darkMode ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: widget.darkMode ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 过滤按钮
          Row(
            children: [
              _buildFilterChip('all', '全部'),
              const SizedBox(width: 8),
              _buildFilterChip('pending', '待完成'),
              const SizedBox(width: 8),
              _buildFilterChip('completed', '已完成'),
              const SizedBox(width: 8),
              _buildFilterChip('high', '高优先级'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (widget.darkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : (widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (widget.darkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 搜索框
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: widget.darkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: '搜索任务...',
                hintStyle: TextStyle(
                  color: widget.darkMode ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: widget.darkMode ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 过滤按钮
          Row(
            children: [
              _buildFilterChip('all', '全部'),
              const SizedBox(width: 8),
              _buildFilterChip('pending', '待完成'),
              const SizedBox(width: 8),
              _buildFilterChip('completed', '已完成'),
              const SizedBox(width: 8),
              _buildFilterChip('high', '高优先级'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModernTaskList() {
    if (_filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: _filteredTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return _buildTaskItem(task, index);
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        return _buildTaskItem(task, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: widget.darkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '未找到匹配的任务' : '暂无任务',
            style: TextStyle(
              fontSize: 16,
              color: widget.darkMode ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? '尝试调整搜索条件' : '点击右下角按钮添加任务',
            style: TextStyle(
              fontSize: 14,
              color: widget.darkMode ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task, int index) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final slideOffset = Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ));

        final fadeValue = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ));

        return SlideTransition(
          position: slideOffset,
          child: FadeTransition(
            opacity: fadeValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  // 使用TaskTile组件显示主任务
                  TaskTile(
                    task,
                    darkMode: widget.darkMode,
                    showActions: true,
                    isExpanded: task.isExpanded,
                    margin: const EdgeInsets.only(bottom: 8),
                    onTap: () => widget.onTaskClick(task),
                    onToggleComplete: () => widget.onToggleTask(task),
                    onEdit: () => widget.onTaskClick(task),
                    onDelete: () => widget.onDeleteTask(task),
                    onToggleExpanded: () => widget.onToggleTaskExpanded(task),
                  ),
                  // 子任务展开/收起按钮
                  if (task.subtasks.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => widget.onToggleTaskExpanded(task),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.darkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 16,
                                    color: widget.darkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.subtasks.length} 个子任务',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 子任务列表
                  if (task.isExpanded && task.subtasks.isNotEmpty)
                    _buildSubtasksList(task),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtasksList(Task task) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...task.subtasks.map((subtask) => _buildSubtaskItem(task, subtask)),
          const SizedBox(height: 8),
          _buildAddSubtaskButton(task),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(Task parentTask, Subtask subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          _buildSubtaskCheckbox(parentTask, subtask),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSubtaskContent(subtask),
          ),
          _buildSubtaskActions(parentTask, subtask),
        ],
      ),
    );
  }

  Widget _buildSubtaskCheckbox(Task parentTask, Subtask subtask) {
    return GestureDetector(
      onTap: () => widget.onToggleSubtask(parentTask, subtask),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: subtask.isCompleted
              ? const Color(0xFF10B981)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: subtask.isCompleted
                ? const Color(0xFF10B981)
                : (widget.darkMode ? Colors.white30 : Colors.black26),
            width: 1.5,
          ),
        ),
        child: subtask.isCompleted
            ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildSubtaskContent(Subtask subtask) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtask.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtask.isCompleted
                ? (widget.darkMode ? Colors.white54 : Colors.black54)
                : (widget.darkMode ? Colors.white : Colors.black87),
            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        if (subtask.createdAt != null) ...[
          const SizedBox(height: 2),
          Text(
            DateFormat('MM/dd HH:mm').format(subtask.createdAt!),
            style: TextStyle(
              fontSize: 11,
              color: widget.darkMode ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtaskActions(Task parentTask, Subtask subtask) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        size: 16,
        color: widget.darkMode ? Colors.white38 : Colors.black38,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditSubtaskDialog(parentTask, subtask);
            break;
          case 'delete':
            _showDeleteSubtaskConfirmation(parentTask, subtask);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 14),
              SizedBox(width: 6),
              Text('编辑', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 14, color: Colors.red),
              SizedBox(width: 6),
              Text('删除', style: TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSubtaskButton(Task task) {
    return GestureDetector(
      onTap: () => _showAddSubtaskDialog(task),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.darkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: widget.darkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              '添加子任务',
              style: TextStyle(
                fontSize: 12,
                color: widget.darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubtaskDialog(Task task) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加子任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入子任务标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final subtask = Subtask(
                  title: controller.text.trim(),
                  isCompleted: false,
                  createdAt: DateTime.now(),
                );
                Navigator.of(context).pop();
                context.read<TodoBloc>().add(AddSubtaskEvent(
                      task.id!,
                      subtask,
                    ));
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditSubtaskDialog(Task parentTask, Subtask subtask) {
    final TextEditingController controller =
        TextEditingController(text: subtask.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑子任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入子任务标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final updatedSubtask = subtask.copyWith(
                  title: controller.text.trim(),
                );
                Navigator.of(context).pop();
                context.read<TodoBloc>().add(UpdateSubtaskEvent(
                      parentTask.id!,
                      updatedSubtask,
                    ));
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSubtaskConfirmation(Task parentTask, Subtask subtask) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除子任务"${subtask.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TodoBloc>().add(DeleteSubtaskEvent(
                    parentTask.id!,
                    subtask.id!,
                  ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务"${task.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteTask(task);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示从习惯创建任务的对话框
  void _showCreateTaskFromHabitDialog() {
    if (widget.habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用习惯')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CreateTaskFromHabitDialog(
        habits: widget.habits,
        selectedDate: widget.selectedDate,
        darkMode: widget.darkMode,
        onCreateTask: widget.onCreateTaskFromHabit,
      ),
    );
  }

  /// 格式化任务日期显示
  String _formatTaskDate(DateTime date) {
    try {
      return DateFormat('M月d日 任务', 'zh_CN').format(date);
    } catch (e) {
      // 如果本地化数据未初始化，使用基础格式
      try {
        return '${DateFormat('M/d').format(date)} 任务';
      } catch (e2) {
        // 最后的降级处理
        return '${date.month}月${date.day}日 任务';
      }
    }
  }

  // 习惯展示区域 - 企业级优化版本
  Widget _buildHabitsSection() {
    if (widget.habits.isEmpty) {
      return const SizedBox.shrink();
    }

    // 过滤出今日的活跃习惯
    final activeHabits =
        widget.habits.where((habit) => habit.isActive).toList();

    if (activeHabits.isEmpty) {
      return _buildEmptyHabitsState();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHabitsHeader(activeHabits),
          const SizedBox(height: 12),
          _buildHabitsGrid(activeHabits),
        ],
      ),
    );
  }

  /// 构建习惯区域标题
  Widget _buildHabitsHeader(List<Habit> activeHabits) {
    final completedCount = activeHabits
        .where((habit) => habit.completedDates
            .contains(DateFormat('yyyy-MM-dd').format(widget.selectedDate)))
        .length;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '今日习惯',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.darkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$completedCount/${activeHabits.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '${activeHabits.length}个习惯',
          style: TextStyle(
            fontSize: 12,
            color: widget.darkMode ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  /// 构建响应式习惯网格
  Widget _buildHabitsGrid(List<Habit> activeHabits) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 响应式计算卡片宽度
        final screenWidth = constraints.maxWidth;
        final cardWidth = _calculateOptimalCardWidth(screenWidth);
        final crossAxisCount = (screenWidth / cardWidth).floor().clamp(1, 4);

        // 如果只有少量习惯，使用水平滚动
        if (activeHabits.length <= 2) {
          return _buildHorizontalHabitsList(activeHabits, cardWidth);
        }

        // 多个习惯使用网格布局
        return _buildHabitsGridView(activeHabits, crossAxisCount);
      },
    );
  }

  /// 计算最优卡片宽度
  double _calculateOptimalCardWidth(double screenWidth) {
    if (screenWidth < 600) return 180; // 手机
    if (screenWidth < 900) return 200; // 平板竖屏
    return 220; // 平板横屏/桌面
  }

  /// 水平滚动习惯列表
  Widget _buildHorizontalHabitsList(
      List<Habit> activeHabits, double cardWidth) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 160,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: activeHabits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;
            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(
                right: index < activeHabits.length - 1 ? 12 : 0,
              ),
              child: _buildOptimizedHabitTile(habit),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 网格布局习惯视图
  Widget _buildHabitsGridView(List<Habit> activeHabits, int crossAxisCount) {
    const itemHeight = 140.0;
    final gridHeight =
        ((activeHabits.length / crossAxisCount).ceil() * itemHeight)
            .clamp(itemHeight, itemHeight * 2); // 最多显示2行

    return SizedBox(
      height: gridHeight,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: activeHabits.length,
        itemBuilder: (context, index) {
          return _buildOptimizedHabitTile(activeHabits[index]);
        },
      ),
    );
  }

  /// 优化的习惯卡片
  Widget _buildOptimizedHabitTile(Habit habit) {
    return HabitTile(
      habit,
      selectedDate: widget.selectedDate,
      darkMode: widget.darkMode,
      showActions: true,
      margin: EdgeInsets.zero,
      onTap: () => _handleHabitTap(habit),
      onToggleComplete: () => _toggleHabitCompletion(habit),
      onAddToDaily: () => _addHabitToDaily(habit),
    );
  }

  /// 空状态显示
  Widget _buildEmptyHabitsState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.track_changes_outlined,
            size: 48,
            color: widget.darkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无活跃习惯',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.darkMode ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '添加一些习惯来开始追踪吧',
            style: TextStyle(
              fontSize: 12,
              color: widget.darkMode
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  // 处理习惯点击
  void _handleHabitTap(Habit habit) {
    // 可以添加习惯详情查看逻辑
  }

  // 切换习惯完成状态
  void _toggleHabitCompletion(Habit habit) {
    final today = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final completedDates = List<String>.from(habit.completedDates ?? []);

    if (completedDates.contains(today)) {
      completedDates.remove(today);
    } else {
      completedDates.add(today);
    }

    final updatedHabit = habit.copyWith(
      completedDates: completedDates,
      totalCompletions: completedDates.length,
      updatedAt: DateTime.now(),
    );

    context.read<HabitBloc>().add(UpdateHabitEvent(updatedHabit));
  }

  // 将习惯添加到今日任务
  void _addHabitToDaily(Habit habit) {
    _showCreateSingleTaskFromHabitDialog(habit);
  }

  // 显示从单个习惯创建任务的对话框
  void _showCreateSingleTaskFromHabitDialog(Habit habit) {
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            widget.darkMode ? const Color(0xFF2D3748) : Colors.white,
        title: Text(
          '从习惯创建任务',
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '将习惯"${habit.name}"添加到今日任务',
              style: TextStyle(
                color: widget.darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: startTimeController,
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: '开始时间 (可选)',
                hintText: '09:00',
                labelStyle: TextStyle(
                  color: widget.darkMode ? Colors.white60 : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: widget.darkMode ? Colors.white38 : Colors.black38,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.darkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.darkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF10B981)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: '结束时间 (可选)',
                hintText: '10:00',
                labelStyle: TextStyle(
                  color: widget.darkMode ? Colors.white60 : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: widget.darkMode ? Colors.white38 : Colors.black38,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.darkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.darkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF10B981)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: widget.darkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCreateTaskFromHabit(
                habit,
                widget.selectedDate,
                startTimeController.text.trim(),
                endTimeController.text.trim(),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('创建任务'),
          ),
        ],
      ),
    );
  }
}

/// 从习惯创建任务的对话框
class _CreateTaskFromHabitDialog extends StatefulWidget {
  final List<Habit> habits;
  final DateTime selectedDate;
  final bool darkMode;
  final Function(Habit, DateTime, String, String) onCreateTask;

  const _CreateTaskFromHabitDialog({
    required this.habits,
    required this.selectedDate,
    required this.darkMode,
    required this.onCreateTask,
  });

  @override
  State<_CreateTaskFromHabitDialog> createState() =>
      _CreateTaskFromHabitDialogState();
}

class _CreateTaskFromHabitDialogState
    extends State<_CreateTaskFromHabitDialog> {
  Habit? selectedHabit;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF22c55e); // 默认绿色
    } catch (e) {
      return const Color(0xFF22c55e); // 默认绿色
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('从习惯创建任务'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择习惯:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.darkMode
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Habit>(
                  value: selectedHabit,
                  hint: const Text('请选择习惯'),
                  isExpanded: true,
                  items: widget.habits.map((habit) {
                    return DropdownMenuItem<Habit>(
                      value: habit,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(habit.color),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              habit.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (habit) {
                    setState(() {
                      selectedHabit = habit;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('时间设置:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    '开始时间',
                    startTime,
                    (time) => setState(() => startTime = time),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    '结束时间',
                    endTime,
                    (time) => setState(() => endTime = time),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: selectedHabit == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onCreateTask(
                    selectedHabit!,
                    widget.selectedDate,
                    _formatTimeOfDay(startTime),
                    _formatTimeOfDay(endTime),
                  );
                },
          child: const Text('创建任务'),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.darkMode
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: widget.darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTimeOfDay(time),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
