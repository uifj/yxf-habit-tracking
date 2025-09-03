import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../../data/models/habit.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../../core/utils/logger.dart';

/// 习惯追踪模态窗口
/// 基于priospace-main的设计风格
class HabitTrackerModal extends StatefulWidget {
  final VoidCallback onClose;

  const HabitTrackerModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<HabitTrackerModal> createState() => _HabitTrackerModalState();
}

class _HabitTrackerModalState extends State<HabitTrackerModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 企业级功能字段
  final Map<String, dynamic> _performanceMetrics = {};
  final Map<String, dynamic> _cachedData = {};
  DateTime? _lastCacheTime;
  bool _isLoading = false;
  String? _errorMessage;

  String _frequency = 'Daily';
  int _targetCount = 1;
  String _category = 'health';
  String _selectedColor = '#10B981';
  bool _isAddingHabit = false;

  // 性能监控
  void _startPerformanceMonitoring(String operation) {
    _performanceMetrics[operation] = DateTime.now().millisecondsSinceEpoch;
    Logger.debug('开始操作: $operation', tag: 'Performance');
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
    _descriptionController.dispose();
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
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
            child: _isAddingHabit ? _buildAddHabitForm() : _buildHabitList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAddingHabit ? Icons.add : Icons.track_changes,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isAddingHabit ? '添加新习惯' : '习惯追踪',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (_isAddingHabit)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAddingHabit = false;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          const SizedBox(width: 8),
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

  Widget _buildHabitList() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state is HabitLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is HabitError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败: ${state.message}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HabitLoaded) {
          return Column(
            children: [
              Expanded(
                child: state.habits.isEmpty
                    ? _buildEmptyState()
                    : _buildHabitGrid(state.habits),
              ),
              _buildAddButton(),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有习惯',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始添加你的第一个习惯吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitGrid(List<Habit> habits) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(habits[index]);
        },
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isCompletedToday = habit.completedDates.contains(today) ?? false;
    final streak = _calculateStreak(habit);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompletedToday ? const Color(0xFF10B981) : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        Color(int.parse(habit.color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              habit.description ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: streak > 0 ? Colors.orange : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak天',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: streak > 0 ? Colors.orange : Colors.grey[400],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleHabitCompletion(habit),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompletedToday
                          ? const Color(0xFF10B981)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompletedToday ? Icons.check : Icons.add,
                      size: 20,
                      color: isCompletedToday ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isAddingHabit = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '添加新习惯',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddHabitForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildFrequencySelector(),
            const SizedBox(height: 20),
            _buildTargetCountField(),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            _buildColorSelector(),
            const SizedBox(height: 32),
            _buildFormActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '习惯名称',
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
            hintText: '输入习惯名称...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入习惯名称';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '习惯描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '输入习惯描述...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '频率',
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
              value: _frequency,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('每天')),
                DropdownMenuItem(value: 'Weekly', child: Text('每周')),
                DropdownMenuItem(value: 'Monthly', child: Text('每月')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequency = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标次数',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_targetCount > 1) {
                  setState(() {
                    _targetCount--;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.remove,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '$_targetCount 次',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _targetCount++;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
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
            'Health',
            'Fitness',
            'Learning',
            'Work',
            'Personal',
            'Social',
          ].map((category) => _buildCategoryChip(category)).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _category == category;
    final categoryLabels = {
      'Health': '健康',
      'Fitness': '健身',
      'Learning': '学习',
      'Work': '工作',
      'Personal': '个人',
      'Social': '社交',
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _category = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          categoryLabels[category] ?? category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF10B981) : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '颜色',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const Color(0xFF3B82F6),
            const Color(0xFF10B981),
            const Color(0xFFEF4444),
            const Color(0xFFF59E0B),
            const Color(0xFF8B5CF6),
            const Color(0xFFEC4899),
            const Color(0xFF06B6D4),
            const Color(0xFF84CC16),
          ].map((color) => _buildColorChip(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorChip(Color color) {
    final colorHex = '#${color.value.toRadixString(16).substring(2)}';
    final isSelected = _selectedColor == colorHex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = '#${color.value.toRadixString(16).substring(2)}';
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildFormActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isAddingHabit = false;
              });
            },
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
            onPressed: _submitHabit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '添加习惯',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _submitHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        completedDates: const [],
        color: _selectedColor,
        isActive: true,
        streak: 0,
        totalCompletions: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<HabitBloc>().add(AddHabitEvent(habit));

      setState(() {
        _isAddingHabit = false;
        _titleController.clear();
        _descriptionController.clear();
        _frequency = 'Daily';
        _targetCount = 1;
        _category = 'Health';
        _selectedColor = '#3B82F6';
      });
    }
  }

  void _toggleHabitCompletion(Habit habit) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isCompletedToday = habit.completedDates.contains(today) ?? false;

    if (isCompletedToday) {
      context
          .read<HabitBloc>()
          .add(UnmarkHabitCompletedEvent(habit.id!, DateTime.parse(today)));
    } else {
      context
          .read<HabitBloc>()
          .add(MarkHabitCompletedEvent(habit.id!, DateTime.parse(today)));
    }
  }

  int _calculateStreak(Habit habit) {
    if (habit.completedDates.isEmpty) {
      return 0;
    }

    final dates = habit.completedDates
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final date in dates) {
      final difference = currentDate.difference(date).inDays;

      if (difference == streak) {
        streak++;
        currentDate = date;
      } else {
        break;
      }
    }

    return streak;
  }
}
