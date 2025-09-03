import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/habit.dart';
import '../../core/utils/logger.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';

/// 习惯卡片组件
/// 基于现代化设计风格，支持点击、完成状态切换等操作
class HabitTile extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToDaily;
  final bool showActions;
  final EdgeInsets? margin;
  final bool darkMode;
  final DateTime selectedDate;

  const HabitTile(
    this.habit, {
    Key? key,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.onAddToDaily,
    this.showActions = false,
    this.margin,
    this.darkMode = false,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  bool _isExpanded = false;
  final TextEditingController _subtaskController = TextEditingController();
  
  // 性能优化：缓存计算结果
  bool? _cachedIsCompletedToday;
  int? _cachedStreak;
  DateTime? _lastCacheUpdate;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final isCompletedToday = _getCachedIsCompletedToday();
      final streak = _getCachedStreak();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _animationController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _animationController.reverse();
          },
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: widget.margin ?? const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getHabitBGColor(isCompletedToday),
                      _getHabitBGColor(isCompletedToday).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompletedToday
                        ? const Color(0xFF10B981)
                        : (widget.darkMode ? Colors.white12 : Colors.black12),
                    width: isCompletedToday ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.darkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: _isHovered ? 12 : 8,
                      spreadRadius: _isHovered ? 2 : 0,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Semantics(
                      label: '习惯: ${widget.habit.name}',
                      hint: isCompletedToday ? '已完成' : '未完成，点击切换状态',
                      button: true,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          _buildHabitHeader(isCompletedToday),
                          if (widget.habit.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            _buildHabitDescription(),
                          ],
                          const SizedBox(height: 12),
                          _buildHabitStats(streak, isCompletedToday),
                          if ((widget.habit.subtasks?.isNotEmpty == true) || _isExpanded) ...[
                            const SizedBox(height: 12),
                            Flexible(
                              child: _buildSubtasksSection(),
                            ),
                          ],
                          if (widget.showActions) ...[
                            const SizedBox(height: 16),
                            _buildHabitActionButtons(context),
                          ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    } catch (e, stackTrace) {
      Logger.error('Error building HabitTile', error: e, stackTrace: stackTrace);
      return _buildErrorWidget();
    }
  }

  Widget _buildHabitHeader(bool isCompletedToday) {
    return Row(
      children: [
        // 习惯颜色指示器
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(int.parse(widget.habit.color.replaceFirst('#', '0xFF'))),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        // 习惯名称
        Expanded(
          child: Text(
            widget.habit.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getHabitTextColor(),
              decoration: isCompletedToday ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 展开子任务按钮
        if (widget.habit.subtasks?.isNotEmpty == true)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: widget.darkMode ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.darkMode ? Colors.white24 : Colors.black26,
                ),
              ),
              child: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: widget.darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        // 添加子任务按钮
        GestureDetector(
          onTap: _showAddSubtaskDialog,
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ),
        // 完成状态按钮
        Semantics(
          label: isCompletedToday ? '已完成习惯' : '标记为完成',
          button: true,
          child: GestureDetector(
            onTap: () => _handleToggleComplete(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompletedToday
                    ? const Color(0xFF10B981)
                    : (widget.darkMode ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompletedToday
                      ? const Color(0xFF10B981)
                      : (widget.darkMode ? Colors.white24 : Colors.black26),
                ),
              ),
              child: Icon(
                isCompletedToday ? Icons.check : Icons.radio_button_unchecked,
                size: 18,
                color: isCompletedToday
                    ? Colors.white
                    : (widget.darkMode ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitDescription() {
    return Text(
      widget.habit.description ?? '',
      style: TextStyle(
        fontSize: 13,
        color: _getHabitTextColor().withOpacity(0.7),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHabitStats(int streak, bool isCompletedToday) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // 连续天数
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: streak > 0 ? Colors.orange : Colors.grey[400],
          ),
          const SizedBox(width: 6),
          Text(
            '$streak天连续',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: streak > 0 ? Colors.orange : Colors.grey[400],
            ),
          ),
          const Spacer(),
          // 总完成次数
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: _getHabitTextColor().withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            '总计${widget.habit.totalCompletions}次',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getHabitTextColor().withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onAddToDaily != null)
          _buildHabitActionButton(
            icon: Icons.today_rounded,
            onTap: widget.onAddToDaily!,
            color: const Color(0xFF8B5CF6),
            label: '添加到今日',
          ),
        if (widget.onEdit != null)
          _buildHabitActionButton(
            icon: Icons.edit_rounded,
            onTap: widget.onEdit!,
            color: const Color(0xFF3B82F6),
            label: '编辑',
          ),
        if (widget.onDelete != null)
          _buildHabitActionButton(
            icon: Icons.delete_rounded,
            onTap: widget.onDelete!,
            color: const Color(0xFFEF4444),
            label: '删除',
          ),
      ],
    );
  }

  Widget _buildHabitActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 获取习惯背景颜色
  Color _getHabitBGColor(bool isCompleted) {
    if (widget.darkMode) {
      return isCompleted
          ? Colors.green[900]!.withOpacity(0.3)
          : Colors.grey[850]!.withOpacity(0.8);
    } else {
      return isCompleted
          ? Colors.green[50]!
          : Colors.white;
    }
  }

  // 获取习惯文本颜色
  Color _getHabitTextColor() {
    return widget.darkMode ? Colors.white : Colors.black87;
  }

  // 检查今日是否已完成
  bool _isCompletedToday() {
    final today = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    return widget.habit.completedDates?.contains(today) ?? false;
  }

  // 构建子任务区域
  Widget _buildSubtasksSection() {
    if (!_isExpanded && (widget.habit.subtasks?.isEmpty != false)) {
      return const SizedBox.shrink();
    }
    
    final subtasks = widget.habit.subtasks ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 16,
                color: _getHabitTextColor().withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                 '子任务 (${subtasks.where((s) => s.isCompleted).length}/${subtasks.length})',
                 style: TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.w600,
                   color: _getHabitTextColor().withOpacity(0.7),
                 ),
               ),
             ],
           ),
           if (_isExpanded) ...[
             const SizedBox(height: 8),
             ConstrainedBox(
               constraints: const BoxConstraints(maxHeight: 120),
               child: SingleChildScrollView(
                 child: Column(
                   children: subtasks.map((subtask) => _buildSubtaskItem(subtask)).toList(),
                 ),
               ),
             ),
           ],
        ],
      ),
    );
  }

  // 构建子任务项
  Widget _buildSubtaskItem(HabitSubtask subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(subtask),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: subtask.isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? const Color(0xFF10B981)
                      : (widget.darkMode ? Colors.white38 : Colors.black38),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 13,
                color: _getHabitTextColor().withOpacity(0.8),
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _deleteSubtask(subtask),
            child: Icon(
              Icons.close,
              size: 16,
              color: _getHabitTextColor().withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // 显示添加子任务对话框
  void _showAddSubtaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加子任务'),
        content: TextField(
          controller: _subtaskController,
          decoration: const InputDecoration(
            hintText: '输入子任务内容...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: _addSubtask,
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  // 添加子任务
  void _addSubtask() {
    try {
      if (_subtaskController.text.trim().isEmpty) return;
      
      final newSubtask = HabitSubtask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _subtaskController.text.trim(),
      );
      
      final currentSubtasks = widget.habit.subtasks ?? [];
      final updatedSubtasks = [...currentSubtasks, newSubtask];
      
      // 通过BLoC更新习惯数据
      context.read<HabitBloc>().add(
        UpdateHabitEvent(
          widget.habit.copyWith(subtasks: updatedSubtasks),
        ),
      );
      
      setState(() {
        _isExpanded = true;
        _invalidateCache();
      });
      
      _subtaskController.clear();
      Navigator.pop(context);
      
      Logger.info('Added subtask: ${newSubtask.title}');
    } catch (e, stackTrace) {
      Logger.error('Error adding subtask', error: e, stackTrace: stackTrace);
      _showErrorSnackBar('添加子任务失败');
    }
  }

  // 切换子任务完成状态
  void _toggleSubtask(HabitSubtask subtask) {
    try {
      final currentSubtasks = widget.habit.subtasks ?? [];
      final updatedSubtasks = currentSubtasks.map((s) {
        if (s.id == subtask.id) {
          return HabitSubtask(
            id: s.id,
            title: s.title,
            isCompleted: !s.isCompleted,
          );
        }
        return s;
      }).toList();
      
      // 通过BLoC更新子任务状态
      context.read<HabitBloc>().add(
        UpdateHabitEvent(
          widget.habit.copyWith(subtasks: updatedSubtasks),
        ),
      );
      
      setState(() {
        _invalidateCache();
      });
      
      Logger.info('Toggled subtask: ${subtask.title}');
    } catch (e, stackTrace) {
      Logger.error('Error toggling subtask', error: e, stackTrace: stackTrace);
      _showErrorSnackBar('更新子任务失败');
    }
  }

  // 删除子任务
  void _deleteSubtask(HabitSubtask subtask) {
    try {
      final currentSubtasks = widget.habit.subtasks ?? [];
      final updatedSubtasks = currentSubtasks.where((s) => s.id != subtask.id).toList();
      
      // 通过BLoC删除子任务
      context.read<HabitBloc>().add(
        UpdateHabitEvent(
          widget.habit.copyWith(subtasks: updatedSubtasks),
        ),
      );
      
      setState(() {
        _invalidateCache();
      });
      
      Logger.info('Deleted subtask: ${subtask.title}');
    } catch (e, stackTrace) {
      Logger.error('Error deleting subtask', error: e, stackTrace: stackTrace);
      _showErrorSnackBar('删除子任务失败');
    }
  }

  // 计算连续天数
  int _calculateStreak() {
    if (widget.habit.completedDates == null || widget.habit.completedDates!.isEmpty) {
      return 0;
    }

    final sortedDates = widget.habit.completedDates!
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 降序排列

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final date in sortedDates) {
      final daysDifference = currentDate.difference(date).inDays;
      
      if (daysDifference == streak) {
        streak++;
        currentDate = date;
      } else if (daysDifference == streak + 1 && streak == 0) {
        // 允许昨天的记录作为连续的开始
        streak++;
        currentDate = date;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  // 性能优化：缓存方法
  bool _getCachedIsCompletedToday() {
    final now = DateTime.now();
    if (_cachedIsCompletedToday == null || 
        _lastCacheUpdate == null ||
        now.difference(_lastCacheUpdate!).inMinutes > 5) {
      _cachedIsCompletedToday = _isCompletedToday();
      _lastCacheUpdate = now;
    }
    return _cachedIsCompletedToday!;
  }
  
  int _getCachedStreak() {
    final now = DateTime.now();
    if (_cachedStreak == null || 
        _lastCacheUpdate == null ||
        now.difference(_lastCacheUpdate!).inMinutes > 5) {
      _cachedStreak = _calculateStreak();
      _lastCacheUpdate = now;
    }
    return _cachedStreak!;
  }
  
  void _invalidateCache() {
    _cachedIsCompletedToday = null;
    _cachedStreak = null;
    _lastCacheUpdate = null;
  }
  
  // 错误处理
  Widget _buildErrorWidget() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '习惯卡片加载失败',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleToggleComplete() {
    try {
      widget.onToggleComplete?.call();
      setState(() {
        _invalidateCache();
      });
      Logger.info('Toggled habit completion: ${widget.habit.name}');
    } catch (e, stackTrace) {
      Logger.error('Error toggling habit completion', error: e, stackTrace: stackTrace);
      _showErrorSnackBar('更新习惯状态失败');
    }
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
}

/// 简化版习惯卡片，用于日历视图
class CompactHabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final DateTime selectedDate;

  const CompactHabitTile({
    Key? key,
    required this.habit,
    this.onTap,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = _isCompletedToday();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Color(int.parse(habit.color.replaceFirst('#', '0xFF'))).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: isCompletedToday
              ? Border.all(color: const Color(0xFF10B981), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedToday
                    ? const Color(0xFF10B981)
                    : Color(int.parse(habit.color.replaceFirst('#', '0xFF'))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                habit.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  decoration: isCompletedToday
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 12,
              color: isCompletedToday ? const Color(0xFF10B981) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  bool _isCompletedToday() {
    final today = DateFormat('yyyy-MM-dd').format(selectedDate);
    return habit.completedDates?.contains(today) ?? false;
  }
}