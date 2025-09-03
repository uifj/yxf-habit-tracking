import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task.dart';
import '../../data/models/custom_tag.dart';

/// 添加任务模态窗口
/// 基于priospace-main的设计风格
class AddTaskModal extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onClose;
  final Function(Task) onAddTask;
  final List<CustomTag> customTags;
  final Function(CustomTag) onAddCustomTag;

  const AddTaskModal({
    Key? key,
    required this.selectedDate,
    required this.onClose,
    required this.onAddTask,
    required this.customTags,
    required this.onAddCustomTag,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _priority = 'Medium';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _repeat = 'None';
  int _remind = 0;
  List<String> _selectedTags = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildModalContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 20),
                    _buildNoteField(),
                    const SizedBox(height: 20),
                    _buildPrioritySelector(),
                    const SizedBox(height: 20),
                    _buildTimeSelector(),
                    const SizedBox(height: 20),
                    _buildRepeatSelector(),
                    const SizedBox(height: 20),
                    _buildRemindSelector(),
                    const SizedBox(height: 20),
                    _buildTagSelector(),
                  ],
                ),
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_task,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '添加新任务',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: _closeModal,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务标题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '输入任务标题...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入任务标题';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '输入任务描述...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '优先级',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityChip('High', '高', const Color(0xFFEF4444)),
            const SizedBox(width: 8),
            _buildPriorityChip('Medium', '中', const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            _buildPriorityChip('Low', '低', const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _priority == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeField('开始时间', _startTime, (time) {
                setState(() {
                  _startTime = time;
                });
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeField('结束时间', _endTime, (time) {
                setState(() {
                  _endTime = time;
                });
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '重复',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _repeat,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'None', child: Text('不重复')),
                DropdownMenuItem(value: 'Daily', child: Text('每天')),
                DropdownMenuItem(value: 'Weekly', child: Text('每周')),
                DropdownMenuItem(value: 'Monthly', child: Text('每月')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _repeat = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemindSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '提醒',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _remind,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 0, child: Text('不提醒')),
                DropdownMenuItem(value: 5, child: Text('5分钟前')),
                DropdownMenuItem(value: 10, child: Text('10分钟前')),
                DropdownMenuItem(value: 15, child: Text('15分钟前')),
                DropdownMenuItem(value: 30, child: Text('30分钟前')),
                DropdownMenuItem(value: 60, child: Text('1小时前')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _remind = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.customTags.map((tag) => _buildTagChip(tag)),
            _buildAddTagButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(CustomTag tag) {
    final isSelected = _selectedTags.contains(tag.name);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag.name);
          } else {
            _selectedTags.add(tag.name);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(int.parse(tag.color.replaceFirst('#', '0xFF')))
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Color(int.parse(tag.color.replaceFirst('#', '0xFF')))
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          tag.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTagButton() {
    return GestureDetector(
      onTap: _showAddTagDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.black54),
            SizedBox(width: 4),
            Text(
              '添加标签',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _closeModal,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '添加任务',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        remind: _remind,
        repeat: _repeat,
        color: 0,
        isCompleted: 0,
        priority: _priority,
      );
      
      widget.onAddTask(task);
    }
  }

  /// 格式化时间为24小时制格式
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAddTagDialog() {
    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF3B82F6);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加新标签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '标签名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('选择颜色:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  const Color(0xFF3B82F6),
                  const Color(0xFFEF4444),
                  const Color(0xFF10B981),
                  const Color(0xFFF59E0B),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                ].map((color) => GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final tag = CustomTag(
                    name: nameController.text.trim(),
                    color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                    isActive: true,
                    usageCount: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  widget.onAddCustomTag(tag);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}