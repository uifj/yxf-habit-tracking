import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/storage_service.dart';

/// 设置模态窗口
/// 基于priospace-main的设计风格
class SettingsModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsModal({
    Key? key,
    required this.onClose,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  bool _enableSounds = true;
  int _pomodoroMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  String _selectedLanguage = 'zh';
  
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _initializeAnimations();
    _loadSettings();
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

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _enableSounds = prefs.getBool('enableSounds') ?? true;
      _pomodoroMinutes = prefs.getInt('pomodoroMinutes') ?? 25;
      _shortBreakMinutes = prefs.getInt('shortBreakMinutes') ?? 5;
      _longBreakMinutes = prefs.getInt('longBreakMinutes') ?? 15;
      _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
      _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'zh';
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setBool('enableSounds', _enableSounds);
    await prefs.setInt('pomodoroMinutes', _pomodoroMinutes);
    await prefs.setInt('shortBreakMinutes', _shortBreakMinutes);
    await prefs.setInt('longBreakMinutes', _longBreakMinutes);
    await prefs.setBool('autoStartBreaks', _autoStartBreaks);
    await prefs.setBool('autoStartPomodoros', _autoStartPomodoros);
    await prefs.setString('selectedLanguage', _selectedLanguage);
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
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                ],
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
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '设置',
              style: TextStyle(
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

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '通用设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          icon: Icons.dark_mode,
          title: '深色模式',
          subtitle: '切换应用主题',
          trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onThemeChanged(value);
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        _buildSettingItem(
          icon: Icons.language,
          title: '语言',
          subtitle: '选择应用语言',
          trailing: DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'zh', child: Text('中文')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '番茄钟设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimerDurationSetting(
          title: '专注时间',
          value: _pomodoroMinutes,
          onChanged: (value) {
            setState(() {
              _pomodoroMinutes = value;
            });
          },
        ),
        _buildTimerDurationSetting(
          title: '短休息',
          value: _shortBreakMinutes,
          onChanged: (value) {
            setState(() {
              _shortBreakMinutes = value;
            });
          },
        ),
        _buildTimerDurationSetting(
          title: '长休息',
          value: _longBreakMinutes,
          onChanged: (value) {
            setState(() {
              _longBreakMinutes = value;
            });
          },
        ),
        _buildSettingItem(
          icon: Icons.play_arrow,
          title: '自动开始休息',
          subtitle: '专注时间结束后自动开始休息',
          trailing: Switch(
            value: _autoStartBreaks,
            onChanged: (value) {
              setState(() {
                _autoStartBreaks = value;
              });
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        _buildSettingItem(
          icon: Icons.play_arrow,
          title: '自动开始专注',
          subtitle: '休息时间结束后自动开始专注',
          trailing: Switch(
            value: _autoStartPomodoros,
            onChanged: (value) {
              setState(() {
                _autoStartPomodoros = value;
              });
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '通知设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          icon: Icons.notifications,
          title: '启用通知',
          subtitle: '接收任务和计时器提醒',
          trailing: Switch(
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        _buildSettingItem(
          icon: Icons.volume_up,
          title: '启用声音',
          subtitle: '播放提示音',
          trailing: Switch(
            value: _enableSounds,
            onChanged: (value) {
              setState(() {
                _enableSounds = value;
              });
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数据管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.download,
          title: '导出数据',
          subtitle: '导出所有任务和习惯数据',
          onTap: _exportData,
        ),
        _buildActionButton(
          icon: Icons.upload,
          title: '导入数据',
          subtitle: '从文件导入数据',
          onTap: _importData,
        ),
        _buildActionButton(
          icon: Icons.delete_forever,
          title: '清除所有数据',
          subtitle: '删除所有本地数据（不可恢复）',
          onTap: _clearAllData,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTimerDurationSetting({
    required String title,
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 1) {
                    onChanged(value - 1);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '$value 分钟',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (value < 60) {
                    onChanged(value + 1);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red[50]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red[200]!
                : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : const Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red[700]
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDestructive
                          ? Colors.red[600]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
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
              onPressed: _saveAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '保存设置',
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

  void _exportData() async {
    try {
      final storageService = StorageService.instance;
              await storageService.exportAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据导出成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importData() {
    // TODO: 实现数据导入功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据导入功能即将推出'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text('确认删除'),
          ],
        ),
        content: const Text(
          '此操作将删除所有本地数据，包括任务、习惯、标签和计时记录。此操作不可恢复，确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final storageService = StorageService.instance;
                await storageService.clearAllData();
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('所有数据已清除'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('清除失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );
  }

  void _saveAndClose() {
    _saveSettings();
    _closeModal();
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }
}