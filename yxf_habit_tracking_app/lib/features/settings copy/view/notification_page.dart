import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';

/// 通知类型枚举
enum NotificationType {
  school('学校通知', Icons.school_outlined, Color(0xFFF05A2D)),
  chat('聊天消息', Icons.chat_bubble_outline, Color(0xFF46F078)),
  app('应用通知', Icons.notifications_outlined, Color(0xFF2D96F0)),
  system('系统消息', Icons.settings_outlined, Color(0xFFF02D2D));

  const NotificationType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

/// 通知模型
class NotificationModel {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
    );
  }
}

/// 通知页面
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationPage());
  }

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends TencentCloudChatState<NotificationPage> {
  NotificationType _selectedType = NotificationType.school;
  final List<NotificationModel> _notifications = _generateMockNotifications();

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('通知中心'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: '全部已读',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _clearAllNotifications();
                  break;
                case 'settings':
                  _openNotificationSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('清空通知'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('通知设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: _buildQuickActionsPanel(),
        ),
      ),
      body: _buildNotificationList(),
    );
  }

  /// 构建快速操作面板
  Widget _buildQuickActionsPanel() {
    final unreadCounts = _getUnreadCounts();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 统计信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总计', _notifications.length.toString()),
                _buildStatItem('未读',
                    unreadCounts.values.fold(0, (a, b) => a + b).toString()),
                _buildStatItem('今日', _getTodayCount().toString()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 类型选择器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: NotificationType.values.map((type) {
                final isSelected = _selectedType == type;
                final unreadCount = unreadCounts[type] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.icon,
                          size: 16,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(type.label),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer
                .withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// 构建通知列表
  Widget _buildNotificationList() {
    final filteredNotifications = _notifications
        .where((notification) => notification.type == _selectedType)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType.icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无${_selectedType.label}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  /// 构建通知项
  Widget _buildNotificationItem(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取未读数量统计
  Map<NotificationType, int> _getUnreadCounts() {
    final counts = <NotificationType, int>{};
    for (final type in NotificationType.values) {
      counts[type] =
          _notifications.where((n) => n.type == type && !n.isRead).length;
    }
    return counts;
  }

  /// 获取今日通知数量
  int _getTodayCount() {
    final today = DateTime.now();
    return _notifications.where((notification) {
      final notificationDate = notification.createdAt;
      return notificationDate.year == today.year &&
          notificationDate.month == today.month &&
          notificationDate.day == today.day;
    }).length;
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  /// 点击通知
  void _onNotificationTap(NotificationModel notification) {
    // 标记为已读
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    // 显示通知详情
    _showNotificationDetail(notification);
  }

  /// 显示通知详情
  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      notification.type.icon,
                      color: notification.type.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        notification.content,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 全部标记为已读
  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].type == _selectedType) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已将所有${_selectedType.label}标记为已读')),
    );
  }

  /// 清空所有通知
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空通知'),
        content: Text('确定要清空所有${_selectedType.label}吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.removeWhere((n) => n.type == _selectedType);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已清空所有${_selectedType.label}')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 打开通知设置
  void _openNotificationSettings() {
    // TODO: 导航到通知设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中...')),
    );
  }

  /// 生成模拟通知数据
  static List<NotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: '学校重要通知',
        content: '关于2024年春季学期开学安排的通知，请各位同学注意查看相关要求和时间安排。',
        type: NotificationType.school,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: '新消息',
        content: '张三: 明天的课程安排有变动，请注意查看最新通知。',
        type: NotificationType.chat,
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: '应用更新',
        content: '湖南师范大学App有新版本可用，建议您及时更新以获得更好的使用体验。',
        type: NotificationType.app,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: '系统维护通知',
        content: '系统将于今晚23:00-次日1:00进行维护，期间可能影响部分功能使用。',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: '期末考试安排',
        content: '2024年春季学期期末考试安排已发布，请登录教务系统查看详细信息。',
        type: NotificationType.school,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: false,
      ),
    ];
  }
}
