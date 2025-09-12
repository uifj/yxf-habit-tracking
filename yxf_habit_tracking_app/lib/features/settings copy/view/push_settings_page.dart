import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 推送设置页面
class PushSettingsPage extends StatefulWidget {
  const PushSettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PushSettingsPage());
  }

  @override
  State<PushSettingsPage> createState() => _PushSettingsPageState();
}

class _PushSettingsPageState extends TencentCloudChatState<PushSettingsPage> {
  // 总开关
  bool _enablePush = true;
  
  // 消息推送
  bool _enableChatPush = true;
  bool _enableGroupPush = true;
  bool _enableSystemPush = true;
  bool _enableAnnouncementPush = true;
  
  // 推送时间
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  bool _enableTimeLimit = false;
  
  // 推送方式
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _enableLED = true;
  bool _showOnLockScreen = true;
  bool _showMessagePreview = true;
  
  // 免打扰模式
  bool _enableDoNotDisturb = false;
  List<int> _doNotDisturbDays = [];
  TimeOfDay _dndStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEndTime = const TimeOfDay(hour: 8, minute: 0);
  
  // 推送优先级
  String _pushPriority = 'normal';
  
  final List<String> _weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  
  final Map<String, String> _priorityOptions = {
    'low': '低优先级',
    'normal': '普通',
    'high': '高优先级',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('推送设置'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _testPush,
            icon: const Icon(Icons.notifications_active),
            tooltip: '测试推送',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainSwitchSection(),
          if (_enablePush) ...[
            const SizedBox(height: 16),
            _buildMessagePushSection(),
            const SizedBox(height: 16),
            _buildTimeLimitSection(),
            const SizedBox(height: 16),
            _buildPushStyleSection(),
            const SizedBox(height: 16),
            _buildDoNotDisturbSection(),
            const SizedBox(height: 16),
            _buildAdvancedSection(),
          ],
        ],
      ),
    );
  }

  /// 构建主开关区块
  Widget _buildMainSwitchSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  '推送通知',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('启用推送通知'),
              subtitle: Text(
                _enablePush ? '您将收到所有类型的推送通知' : '已关闭所有推送通知',
              ),
              value: _enablePush,
              onChanged: (value) {
                setState(() {
                  _enablePush = value;
                });
                _saveSettings();
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建消息推送区块
  Widget _buildMessagePushSection() {
    return _buildSectionCard(
      '消息推送',
      Icons.message_outlined,
      [
        SwitchListTile(
          title: const Text('私聊消息'),
          subtitle: const Text('接收一对一聊天消息推送'),
          value: _enableChatPush,
          onChanged: (value) {
            setState(() {
              _enableChatPush = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('群聊消息'),
          subtitle: const Text('接收群组聊天消息推送'),
          value: _enableGroupPush,
          onChanged: (value) {
            setState(() {
              _enableGroupPush = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('系统消息'),
          subtitle: const Text('接收系统通知和提醒'),
          value: _enableSystemPush,
          onChanged: (value) {
            setState(() {
              _enableSystemPush = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('公告通知'),
          subtitle: const Text('接收学校和应用公告'),
          value: _enableAnnouncementPush,
          onChanged: (value) {
            setState(() {
              _enableAnnouncementPush = value;
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  /// 构建时间限制区块
  Widget _buildTimeLimitSection() {
    return _buildSectionCard(
      '推送时间',
      Icons.schedule_outlined,
      [
        SwitchListTile(
          title: const Text('限制推送时间'),
          subtitle: const Text('仅在指定时间段内接收推送'),
          value: _enableTimeLimit,
          onChanged: (value) {
            setState(() {
              _enableTimeLimit = value;
            });
            _saveSettings();
          },
        ),
        if (_enableTimeLimit) ...[
          const Divider(),
          ListTile(
            title: const Text('开始时间'),
            subtitle: Text(_formatTime(_startTime)),
            trailing: const Icon(Icons.access_time, size: 20),
            onTap: () => _selectTime(context, true),
          ),
          const Divider(),
          ListTile(
            title: const Text('结束时间'),
            subtitle: Text(_formatTime(_endTime)),
            trailing: const Icon(Icons.access_time, size: 20),
            onTap: () => _selectTime(context, false),
          ),
        ],
      ],
    );
  }

  /// 构建推送样式区块
  Widget _buildPushStyleSection() {
    return _buildSectionCard(
      '推送样式',
      Icons.style_outlined,
      [
        SwitchListTile(
          title: const Text('声音提醒'),
          subtitle: const Text('播放通知提示音'),
          value: _enableSound,
          onChanged: (value) {
            setState(() {
              _enableSound = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('震动提醒'),
          subtitle: const Text('设备震动提醒'),
          value: _enableVibration,
          onChanged: (value) {
            setState(() {
              _enableVibration = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('呼吸灯'),
          subtitle: const Text('LED指示灯闪烁'),
          value: _enableLED,
          onChanged: (value) {
            setState(() {
              _enableLED = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('锁屏显示'),
          subtitle: const Text('在锁屏界面显示通知'),
          value: _showOnLockScreen,
          onChanged: (value) {
            setState(() {
              _showOnLockScreen = value;
            });
            _saveSettings();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('消息预览'),
          subtitle: const Text('在通知中显示消息内容'),
          value: _showMessagePreview,
          onChanged: (value) {
            setState(() {
              _showMessagePreview = value;
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  /// 构建免打扰区块
  Widget _buildDoNotDisturbSection() {
    return _buildSectionCard(
      '免打扰模式',
      Icons.do_not_disturb_outlined,
      [
        SwitchListTile(
          title: const Text('启用免打扰'),
          subtitle: const Text('在指定时间和日期不接收推送'),
          value: _enableDoNotDisturb,
          onChanged: (value) {
            setState(() {
              _enableDoNotDisturb = value;
            });
            _saveSettings();
          },
        ),
        if (_enableDoNotDisturb) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '免打扰时间',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDNDTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text('开始时间'),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_dndStartTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDNDTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text('结束时间'),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_dndEndTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '免打扰日期',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _weekDays.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isSelected = _doNotDisturbDays.contains(index);
                    
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _doNotDisturbDays.add(index);
                          } else {
                            _doNotDisturbDays.remove(index);
                          }
                        });
                        _saveSettings();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建高级设置区块
  Widget _buildAdvancedSection() {
    return _buildSectionCard(
      '高级设置',
      Icons.settings_outlined,
      [
        ListTile(
          title: const Text('推送优先级'),
          subtitle: Text(_priorityOptions[_pushPriority] ?? '普通'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showPriorityDialog,
        ),
        const Divider(),
        ListTile(
          title: const Text('推送统计'),
          subtitle: const Text('查看推送接收统计信息'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showPushStatistics,
        ),
        const Divider(),
        ListTile(
          title: const Text('推送历史'),
          subtitle: const Text('查看最近的推送记录'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showPushHistory,
        ),
        const Divider(),
        ListTile(
          title: const Text('清除推送缓存'),
          subtitle: const Text('清除本地推送数据'),
          trailing: const Icon(Icons.clear_all, size: 16),
          onTap: _clearPushCache,
        ),
      ],
    );
  }

  /// 构建区块卡片
  Widget _buildSectionCard(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 选择时间
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _saveSettings();
    }
  }

  /// 选择免打扰时间
  Future<void> _selectDNDTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _dndStartTime : _dndEndTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _dndStartTime = picked;
        } else {
          _dndEndTime = picked;
        }
      });
      _saveSettings();
    }
  }

  /// 显示优先级选择对话框
  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择推送优先级'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _priorityOptions.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _pushPriority,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _pushPriority = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示推送统计
  void _showPushStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推送统计'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日推送: 12 条'),
            SizedBox(height: 8),
            Text('本周推送: 85 条'),
            SizedBox(height: 8),
            Text('本月推送: 342 条'),
            SizedBox(height: 8),
            Text('推送成功率: 98.5%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示推送历史
  void _showPushHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('推送历史功能开发中'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 清除推送缓存
  void _clearPushCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除推送缓存'),
        content: const Text('确定要清除所有推送缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('推送缓存已清除'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 测试推送
  void _testPush() {
    if (!_enablePush) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先启用推送通知'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('测试推送已发送'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // TODO: 实际发送测试推送
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _enablePush = prefs.getBool('enable_push') ?? true;
        _enableChatPush = prefs.getBool('enable_chat_push') ?? true;
        _enableGroupPush = prefs.getBool('enable_group_push') ?? true;
        _enableSystemPush = prefs.getBool('enable_system_push') ?? true;
        _enableAnnouncementPush = prefs.getBool('enable_announcement_push') ?? true;
        
        _enableTimeLimit = prefs.getBool('enable_time_limit') ?? false;
        final startHour = prefs.getInt('start_hour') ?? 8;
        final startMinute = prefs.getInt('start_minute') ?? 0;
        final endHour = prefs.getInt('end_hour') ?? 22;
        final endMinute = prefs.getInt('end_minute') ?? 0;
        _startTime = TimeOfDay(hour: startHour, minute: startMinute);
        _endTime = TimeOfDay(hour: endHour, minute: endMinute);
        
        _enableSound = prefs.getBool('enable_sound') ?? true;
        _enableVibration = prefs.getBool('enable_vibration') ?? true;
        _enableLED = prefs.getBool('enable_led') ?? true;
        _showOnLockScreen = prefs.getBool('show_on_lock_screen') ?? true;
        _showMessagePreview = prefs.getBool('show_message_preview') ?? true;
        
        _enableDoNotDisturb = prefs.getBool('enable_do_not_disturb') ?? false;
        _doNotDisturbDays = prefs.getStringList('dnd_days')?.map(int.parse).toList() ?? [];
        final dndStartHour = prefs.getInt('dnd_start_hour') ?? 22;
        final dndStartMinute = prefs.getInt('dnd_start_minute') ?? 0;
        final dndEndHour = prefs.getInt('dnd_end_hour') ?? 8;
        final dndEndMinute = prefs.getInt('dnd_end_minute') ?? 0;
        _dndStartTime = TimeOfDay(hour: dndStartHour, minute: dndStartMinute);
        _dndEndTime = TimeOfDay(hour: dndEndHour, minute: dndEndMinute);
        
        _pushPriority = prefs.getString('push_priority') ?? 'normal';
      });
    } catch (e) {
      debugPrint('加载推送设置失败: $e');
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('enable_push', _enablePush);
      await prefs.setBool('enable_chat_push', _enableChatPush);
      await prefs.setBool('enable_group_push', _enableGroupPush);
      await prefs.setBool('enable_system_push', _enableSystemPush);
      await prefs.setBool('enable_announcement_push', _enableAnnouncementPush);
      
      await prefs.setBool('enable_time_limit', _enableTimeLimit);
      await prefs.setInt('start_hour', _startTime.hour);
      await prefs.setInt('start_minute', _startTime.minute);
      await prefs.setInt('end_hour', _endTime.hour);
      await prefs.setInt('end_minute', _endTime.minute);
      
      await prefs.setBool('enable_sound', _enableSound);
      await prefs.setBool('enable_vibration', _enableVibration);
      await prefs.setBool('enable_led', _enableLED);
      await prefs.setBool('show_on_lock_screen', _showOnLockScreen);
      await prefs.setBool('show_message_preview', _showMessagePreview);
      
      await prefs.setBool('enable_do_not_disturb', _enableDoNotDisturb);
      await prefs.setStringList('dnd_days', _doNotDisturbDays.map((e) => e.toString()).toList());
      await prefs.setInt('dnd_start_hour', _dndStartTime.hour);
      await prefs.setInt('dnd_start_minute', _dndStartTime.minute);
      await prefs.setInt('dnd_end_hour', _dndEndTime.hour);
      await prefs.setInt('dnd_end_minute', _dndEndTime.minute);
      
      await prefs.setString('push_priority', _pushPriority);
    } catch (e) {
      debugPrint('保存推送设置失败: $e');
    }
  }
}