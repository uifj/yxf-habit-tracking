import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task.dart';

/// 任务卡片组件
/// 现代化设计风格，支持点击、编辑、删除、完成状态切换等操作
class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;
  final bool showActions;
  final EdgeInsets? margin;
  final bool darkMode;
  final VoidCallback? onAddSubtask;
  final Function(Subtask)? onToggleSubtask;
  final Function(Subtask)? onDeleteSubtask;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const TaskTile(
    this.task, {
    Key? key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
    this.showActions = false,
    this.margin,
    this.darkMode = false,
    this.onAddSubtask,
    this.onToggleSubtask,
    this.onDeleteSubtask,
    this.isExpanded = false,
    this.onToggleExpanded,
  }) : super(key: key);

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      _getModernBGColor(),
                      _getModernBGColor().withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernHeader(context),
                          if (widget.task.note.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildModernNote(),
                          ],
                          if (widget.task.startTime.isNotEmpty &&
                              widget.task.endTime.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildModernTimeInfo(),
                          ],
                          if (widget.task.subtasks.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildSubtaskPreview(),
                          ],
                          // 展开显示子任务列表
                          if (widget.isExpanded &&
                              widget.task.subtasks.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildExpandedSubtasksList(),
                          ],
                          // 添加子任务按钮（当展开时显示）
                          if (widget.isExpanded) ...[
                            const SizedBox(height: 8),
                            _buildAddSubtaskButton(),
                          ],
                          if (widget.showActions) ...[
                            const SizedBox(height: 16),
                            _buildModernActionButtons(context),
                          ],
                        ],
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
  }

  // 现代化背景颜色
  Color _getModernBGColor() {
    if (widget.darkMode) {
      return widget.task.isCompleted == 1
          ? Colors.grey[800]!.withOpacity(0.6)
          : Colors.grey[850]!.withOpacity(0.8);
    }

    if (widget.task.isCompleted == 1) {
      return Colors.grey[50]!;
    }

    switch (widget.task.color) {
      case 0:
        return Colors.red.withOpacity(0.05);
      case 1:
        return Colors.pink.withOpacity(0.05);
      case 2:
        return Colors.orange.withOpacity(0.05);
      case 3:
        return Colors.blue.withOpacity(0.05);
      case 4:
        return Colors.green.withOpacity(0.05);
      case 5:
        return Colors.purple.withOpacity(0.05);
      default:
        return Colors.white;
    }
  }

  Widget _buildModernHeader(BuildContext context) {
    return Row(
      children: [
        // 现代化完成状态指示器
        GestureDetector(
          onTap: widget.onToggleComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.task.isCompleted == 1
                    ? const Color(0xFF10B981)
                    : (widget.darkMode ? Colors.white54 : Colors.grey[400]!),
                width: 2.5,
              ),
              color: widget.task.isCompleted == 1
                  ? const Color(0xFF10B981)
                  : Colors.transparent,
              boxShadow: widget.task.isCompleted == 1
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: widget.task.isCompleted == 1
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),

        // 任务标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _getModernTextColor(),
                  decoration: widget.task.isCompleted == 1
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${widget.task.subtasks.where((s) => s.isCompleted).length}/${widget.task.subtasks.length} 子任务完成',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.darkMode ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 现代化优先级标签
        _buildModernPriorityChip(),
      ],
    );
  }

  // 现代化文本颜色
  Color _getModernTextColor() {
    if (widget.darkMode) {
      return widget.task.isCompleted == 1 ? Colors.white54 : Colors.white;
    }
    return widget.task.isCompleted == 1 ? Colors.black54 : Colors.black87;
  }

  Widget _buildModernPriorityChip() {
    final priorityMap = {
      'High': {'color': const Color(0xFFEF4444), 'label': '高'},
      'Medium': {'color': const Color(0xFFF97316), 'label': '中'},
      'Low': {'color': const Color(0xFF10B981), 'label': '低'},
    };

    final priorityInfo = priorityMap[widget.task.priority];
    if (priorityInfo == null) {
      return const SizedBox.shrink();
    }

    final color = priorityInfo['color'] as Color;
    final label = priorityInfo['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildModernTimeInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: _getModernTextColor().withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            "${widget.task.startTime} - ${widget.task.endTime}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getModernTextColor().withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: _getModernTextColor().withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            widget.task.date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getModernTextColor().withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNote() {
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
      child: Text(
        widget.task.note,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: _getModernTextColor().withOpacity(0.8),
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtaskPreview() {
    final completedCount =
        widget.task.subtasks.where((s) => s.isCompleted).length;
    final totalCount = widget.task.subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return GestureDetector(
      onTap: widget.onToggleExpanded,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 16,
                  color: _getModernTextColor().withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedCount/$totalCount 子任务完成',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getModernTextColor().withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                Icon(
                  widget.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: _getModernTextColor().withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B981),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onEdit != null)
          _buildModernActionButton(
            icon: Icons.edit_rounded,
            onTap: widget.onEdit!,
            color: const Color(0xFF3B82F6),
            label: '编辑',
          ),
        if (widget.onToggleComplete != null)
          _buildModernActionButton(
            icon: widget.task.isCompleted == 1
                ? Icons.undo_rounded
                : Icons.check_circle_rounded,
            onTap: widget.onToggleComplete!,
            color: widget.task.isCompleted == 1
                ? const Color(0xFFF97316)
                : const Color(0xFF10B981),
            label: widget.task.isCompleted == 1 ? '撤销' : '完成',
          ),
        if (widget.onDelete != null)
          _buildModernActionButton(
            icon: Icons.delete_rounded,
            onTap: widget.onDelete!,
            color: const Color(0xFFEF4444),
            label: '删除',
          ),
      ],
    );
  }

  // 展开的子任务列表
  Widget _buildExpandedSubtasksList() {
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
                Icons.list_rounded,
                size: 16,
                color: _getModernTextColor().withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '子任务列表',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _getModernTextColor().withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.task.subtasks.map((subtask) => _buildSubtaskItem(subtask)),
        ],
      ),
    );
  }

  // 单个子任务项
  Widget _buildSubtaskItem(Subtask subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        children: [
          // 子任务完成状态
          GestureDetector(
            onTap: () => widget.onToggleSubtask?.call(subtask),
            child: Container(
              width: 18,
              height: 18,
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
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // 子任务内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subtask.isCompleted
                        ? _getModernTextColor().withOpacity(0.5)
                        : _getModernTextColor(),
                    decoration:
                        subtask.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtask.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MM/dd HH:mm').format(subtask.createdAt!),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getModernTextColor().withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 子任务操作按钮
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              size: 14,
              color: _getModernTextColor().withOpacity(0.4),
            ),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  widget.onDeleteSubtask?.call(subtask);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 12, color: Colors.red),
                    SizedBox(width: 6),
                    Text('删除',
                        style: TextStyle(fontSize: 11, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 添加子任务按钮
  Widget _buildAddSubtaskButton() {
    return GestureDetector(
      onTap: widget.onAddSubtask,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.darkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.darkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: widget.darkMode ? Colors.white60 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              '添加子任务',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.darkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }

  Color _getBGClr(int no) {
    switch (no) {
      case 0:
        return Colors.red.withOpacity(0.1);
      case 1:
        return Colors.pink.withOpacity(0.1);
      case 2:
        return Colors.yellow.withOpacity(0.1);
      case 3:
        return Colors.blue.withOpacity(0.1);
      case 4:
        return Colors.green.withOpacity(0.1);
      case 5:
        return Colors.purple.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (widget.task.color) {
      case 0:
        return Colors.red.shade700;
      case 1:
        return Colors.pink.shade700;
      case 2:
        return Colors.orange.shade700;
      case 3:
        return Colors.blue.shade700;
      case 4:
        return Colors.green.shade700;
      case 5:
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

/// 简化版任务卡片，用于日历视图
class CompactTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const CompactTaskTile({
    Key? key,
    required this.task,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getBGClr(task.color),
          borderRadius: BorderRadius.circular(8),
          border: task.isCompleted == 1
              ? Border.all(color: Colors.green, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted == 1
                    ? Colors.green
                    : _getAccentColor(task.color),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                  decoration: task.isCompleted == 1
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              task.startTime,
              style: TextStyle(
                fontSize: 10,
                color: _getTextColor().withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBGClr(int no) {
    switch (no) {
      case 0:
        return Colors.red.withOpacity(0.1);
      case 1:
        return Colors.pink.withOpacity(0.1);
      case 2:
        return Colors.yellow.withOpacity(0.1);
      case 3:
        return Colors.blue.withOpacity(0.1);
      case 4:
        return Colors.green.withOpacity(0.1);
      case 5:
        return Colors.purple.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getAccentColor(int no) {
    switch (no) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.pink;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    switch (task.color) {
      case 0:
        return Colors.red.shade700;
      case 1:
        return Colors.pink.shade700;
      case 2:
        return Colors.orange.shade700;
      case 3:
        return Colors.blue.shade700;
      case 4:
        return Colors.green.shade700;
      case 5:
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
