import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';

/// 通知类型枚举
enum NotificationType {
  system('系统通知'),
  message('消息通知'),
  announcement('公告通知'),
  activity('活动通知'),
  academic('学术通知'),
  other('其他通知');

  const NotificationType(this.displayName);
  final String displayName;
}

/// 通知优先级枚举
enum NotificationPriority {
  low('低'),
  normal('普通'),
  high('高'),
  urgent('紧急');

  const NotificationPriority(this.displayName);
  final String displayName;

  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }
}

/// 通知模型
class NotificationModel {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

/// 通知页面
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationsPage());
  }

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends TencentCloudChatState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  NotificationType? _selectedType;
  bool _showOnlyUnread = false;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('通知消息'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: '筛选',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('全部标记为已读'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('清空所有通知'),
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
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNotificationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshNotifications,
        tooltip: '刷新',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索通知...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('仅未读'),
            selected: _showOnlyUnread,
            onSelected: (selected) {
              setState(() {
                _showOnlyUnread = selected;
              });
              _filterNotifications();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('全部'),
            selected: _selectedType == null,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = null;
                });
                _filterNotifications();
              }
            },
          ),
          const SizedBox(width: 8),
          ...NotificationType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type.displayName),
                selected: _selectedType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                  _filterNotifications();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通知列表
  Widget _buildNotificationsList() {
    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无通知',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '当有新通知时会显示在这里',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  /// 构建通知卡片
  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildPriorityBadge(notification.priority),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.content,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatDateTime(notification.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                            ),
                            const Spacer(),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleNotificationAction(notification, value),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value:
                            notification.isRead ? 'mark_unread' : 'mark_read',
                        child: Row(
                          children: [
                            Icon(notification.isRead
                                ? Icons.mark_email_unread
                                : Icons.mark_email_read),
                            const SizedBox(width: 8),
                            Text(notification.isRead ? '标记为未读' : '标记为已读'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建通知图标
  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.system:
        iconData = Icons.settings;
        iconColor = Colors.blue;
        break;
      case NotificationType.message:
        iconData = Icons.message;
        iconColor = Colors.green;
        break;
      case NotificationType.announcement:
        iconData = Icons.campaign;
        iconColor = Colors.orange;
        break;
      case NotificationType.activity:
        iconData = Icons.event;
        iconColor = Colors.purple;
        break;
      case NotificationType.academic:
        iconData = Icons.school;
        iconColor = Colors.indigo;
        break;
      case NotificationType.other:
        iconData = Icons.info;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  /// 构建优先级标签
  Widget _buildPriorityBadge(NotificationPriority priority) {
    if (priority == NotificationPriority.normal) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: priority.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          fontSize: 10,
          color: priority.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
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

  /// 搜索变化处理
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterNotifications();
  }

  /// 清除搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _filterNotifications();
  }

  /// 筛选通知
  void _filterNotifications() {
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        // 搜索筛选
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!notification.title.toLowerCase().contains(query) &&
              !notification.content.toLowerCase().contains(query)) {
            return false;
          }
        }

        // 类型筛选
        if (_selectedType != null && notification.type != _selectedType) {
          return false;
        }

        // 未读筛选
        if (_showOnlyUnread && notification.isRead) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  /// 处理通知点击
  void _handleNotificationTap(NotificationModel notification) {
    // 标记为已读
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // 显示详情
    _showNotificationDetail(notification);
  }

  /// 显示通知详情
  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          if (notification.actionUrl != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 处理操作URL
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
              child: const Text('查看详情'),
            ),
        ],
      ),
    );
  }

  /// 处理通知操作
  void _handleNotificationAction(
      NotificationModel notification, String action) {
    switch (action) {
      case 'mark_read':
        _markAsRead(notification);
        break;
      case 'mark_unread':
        _markAsUnread(notification);
        break;
      case 'delete':
        _deleteNotification(notification);
        break;
    }
  }

  /// 标记为已读
  void _markAsRead(NotificationModel notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
    _filterNotifications();
    HapticFeedback.lightImpact();
  }

  /// 标记为未读
  void _markAsUnread(NotificationModel notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: false);
      }
    });
    _filterNotifications();
    HapticFeedback.lightImpact();
  }

  /// 删除通知
  void _deleteNotification(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除通知'),
        content: const Text('确定要删除这条通知吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.removeWhere((n) => n.id == notification.id);
              });
              _filterNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '筛选选项',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('仅显示未读'),
              value: _showOnlyUnread,
              onChanged: (value) {
                setState(() {
                  _showOnlyUnread = value;
                });
                _filterNotifications();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...NotificationType.values.map(
              (type) => RadioListTile<NotificationType?>(
                title: Text(type.displayName),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _filterNotifications();
                  Navigator.pop(context);
                },
              ),
            ),
            RadioListTile<NotificationType?>(
              title: const Text('全部类型'),
              value: null,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
                _filterNotifications();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _clearAllNotifications();
        break;
      case 'settings':
        _openNotificationSettings();
        break;
    }
  }

  /// 全部标记为已读
  void _markAllAsRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    _filterNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已全部标记为已读')),
    );
  }

  /// 清空所有通知
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空通知'),
        content: const Text('确定要清空所有通知吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              _filterNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清空所有通知')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中')),
    );
  }

  /// 加载通知数据
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟加载数据
    await Future.delayed(const Duration(seconds: 1));

    // 生成示例数据
    final now = DateTime.now();
    _notifications = [
      NotificationModel(
        id: '1',
        title: '系统维护通知',
        content: '系统将于今晚22:00-24:00进行维护，期间可能影响部分功能使用。',
        type: NotificationType.system,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: '新消息提醒',
        content: '您有3条未读消息，请及时查看。',
        type: NotificationType.message,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: '重要公告',
        content: '关于2024年春季学期选课安排的通知，请所有学生注意查看。',
        type: NotificationType.announcement,
        priority: NotificationPriority.urgent,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        title: '活动提醒',
        content: '明天下午2点将举行学术讲座，欢迎参加。',
        type: NotificationType.activity,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: '学术通知',
        content: '研究生论文答辩安排已发布，请相关同学查看详情。',
        type: NotificationType.academic,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: false,
      ),
    ];

    setState(() {
      _isLoading = false;
    });

    _filterNotifications();
  }

  /// 刷新通知
  Future<void> _refreshNotifications() async {
    await _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('刷新完成')),
    );
  }
}
