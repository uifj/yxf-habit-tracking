import 'package:flutter/material.dart';
import '../modal/normal_modal.dart';

/// 使用通用模态窗口组件的示例
/// 展示如何重构现有的设置、计时器和习惯追踪模态窗口

/// 设置模态窗口示例
class SettingsModalExample extends StatelessWidget {
  final VoidCallback onClose;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsModalExample({
    Key? key,
    required this.onClose,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NormalModal(
      title: '设置',
      titleIcon: Icons.settings,
      primaryColor: const Color(0xFF6366F1),
      onClose: onClose,
      maxWidth: 500,
      maxHeight: 700,
      content: ModalContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildTimerSettings(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            // 底部操作按钮
            ModalActionBar(
              alignment: MainAxisAlignment.spaceBetween,
              actions: [
                ModalButton(
                  text: '取消',
                  isOutlined: true,
                  isExpanded: true,
                  onPressed: onClose,
                ),
                ModalButton(
                  text: '保存设置',
                  backgroundColor: const Color(0xFF6366F1),
                  isExpanded: true,
                  onPressed: () {
                    // 保存设置逻辑
                    onClose();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通用设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        // 设置项内容...
      ],
    );
  }

  Widget _buildTimerSettings() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '番茄钟设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // 计时器设置内容...
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通知设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // 通知设置内容...
      ],
    );
  }

  Widget _buildDataSettings() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // 数据管理内容...
      ],
    );
  }
}

/// 计时器模态窗口示例
class TimerModalExample extends StatefulWidget {
  final VoidCallback onClose;

  const TimerModalExample({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<TimerModalExample> createState() => _TimerModalExampleState();
}

class _TimerModalExampleState extends State<TimerModalExample> {
  String _currentMode = 'work';

  final Map<String, Color> _modeColors = {
    'work': const Color(0xFFEF4444),
    'shortBreak': const Color(0xFF10B981),
    'longBreak': const Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    return NormalModal(
      title: '番茄钟计时器',
      titleIcon: Icons.timer,
      primaryColor: _modeColors[_currentMode]!,
      onClose: widget.onClose,
      maxWidth: 400,
      maxHeight: 600,
      content: ModalContentWrapper(
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 32),
            _buildTimerDisplay(),
            const SizedBox(height: 32),
            _buildControls(),
            const SizedBox(height: 24),
            _buildSessionCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        _buildModeChip('work', '专注时间'),
        const SizedBox(width: 8),
        _buildModeChip('shortBreak', '短休息'),
        const SizedBox(width: 8),
        _buildModeChip('longBreak', '长休息'),
      ],
    );
  }

  Widget _buildModeChip(String mode, String label) {
    final isSelected = _currentMode == mode;
    final color = _modeColors[mode]!;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMode = mode;
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[100],
      ),
      child: const Center(
        child: Text(
          '25:00',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(Icons.refresh, Colors.grey[600]!),
        const SizedBox(width: 24),
        _buildControlButton(Icons.play_arrow, _modeColors[_currentMode]!,
            isLarge: true),
        const SizedBox(width: 24),
        _buildControlButton(Icons.skip_next, Colors.grey[600]!),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, Color color,
      {bool isLarge = false}) {
    final size = isLarge ? 80.0 : 56.0;
    final iconSize = isLarge ? 32.0 : 24.0;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isLarge ? color : Colors.grey[100],
          shape: BoxShape.circle,
          border: isLarge ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          icon,
          color: isLarge ? Colors.white : color,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildSessionCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: _modeColors[_currentMode],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '已完成 0 个番茄钟',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// 习惯追踪模态窗口示例
class HabitTrackerModalExample extends StatefulWidget {
  final VoidCallback onClose;

  const HabitTrackerModalExample({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<HabitTrackerModalExample> createState() =>
      _HabitTrackerModalExampleState();
}

class _HabitTrackerModalExampleState extends State<HabitTrackerModalExample> {
  bool _isAddingHabit = false;

  @override
  Widget build(BuildContext context) {
    return NormalModal(
      title: _isAddingHabit ? '添加新习惯' : '习惯追踪',
      titleIcon: _isAddingHabit ? Icons.add : Icons.track_changes,
      primaryColor: const Color(0xFF10B981),
      onClose: widget.onClose,
      maxWidth: 600,
      maxHeight: 700,
      showBackButton: _isAddingHabit,
      onBack: _isAddingHabit
          ? () {
              setState(() {
                _isAddingHabit = false;
              });
            }
          : null,
      content: _isAddingHabit ? _buildAddHabitForm() : _buildHabitList(),
    );
  }

  Widget _buildHabitList() {
    return ModalContentWrapper(
      child: Column(
        children: [
          _buildEmptyState(),
          const SizedBox(height: 24),
          ModalButton(
            text: '添加新习惯',
            icon: Icons.add,
            backgroundColor: const Color(0xFF10B981),
            onPressed: () {
              setState(() {
                _isAddingHabit = true;
              });
            },
          ),
        ],
      ),
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

  Widget _buildAddHabitForm() {
    return ModalContentWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField('习惯名称', '输入习惯名称...'),
          const SizedBox(height: 20),
          _buildFormField('习惯描述', '输入习惯描述...', maxLines: 3),
          const SizedBox(height: 32),
          ModalActionBar(
            alignment: MainAxisAlignment.spaceBetween,
            actions: [
              ModalButton(
                text: '取消',
                isOutlined: true,
                isExpanded: true,
                onPressed: () {
                  setState(() {
                    _isAddingHabit = false;
                  });
                },
              ),
              ModalButton(
                text: '添加习惯',
                backgroundColor: const Color(0xFF10B981),
                isExpanded: true,
                onPressed: () {
                  // 添加习惯逻辑
                  setState(() {
                    _isAddingHabit = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
}
