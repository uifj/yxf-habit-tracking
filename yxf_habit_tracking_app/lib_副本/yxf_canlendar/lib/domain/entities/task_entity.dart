import 'package:equatable/equatable.dart';

/// 任务实体类
/// 领域层的核心业务对象，包含任务的所有业务属性
class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? color;
  final bool remind;
  final RepeatType repeat;
  final List<SubtaskEntity> subtasks;
  final String? tag;
  final int focusTimeSeconds;
  final int totalTimeMinutes;
  final bool isExpanded;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? remoteId;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.low,
    this.date,
    this.startTime,
    this.endTime,
    this.color,
    this.remind = false,
    this.repeat = RepeatType.none,
    this.subtasks = const [],
    this.tag,
    this.focusTimeSeconds = 0,
    this.totalTimeMinutes = 0,
    this.isExpanded = false,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.remoteId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        priority,
        date,
        startTime,
        endTime,
        color,
        remind,
        repeat,
        subtasks,
        tag,
        focusTimeSeconds,
        totalTimeMinutes,
        isExpanded,
        metadata,
        createdAt,
        updatedAt,
        isSynced,
        remoteId,
      ];

  /// 创建任务副本
  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? color,
    bool? remind,
    RepeatType? repeat,
    List<SubtaskEntity>? subtasks,
    String? tag,
    int? focusTimeSeconds,
    int? totalTimeMinutes,
    bool? isExpanded,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? remoteId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
      subtasks: subtasks ?? this.subtasks,
      tag: tag ?? this.tag,
      focusTimeSeconds: focusTimeSeconds ?? this.focusTimeSeconds,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      isExpanded: isExpanded ?? this.isExpanded,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  /// 标记为完成
  TaskEntity markCompleted() {
    return copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
  }

  /// 标记为未完成
  TaskEntity markIncomplete() {
    return copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  /// 添加子任务
  TaskEntity addSubtask(SubtaskEntity subtask) {
    return copyWith(
      subtasks: [...subtasks, subtask],
      updatedAt: DateTime.now(),
    );
  }

  /// 更新子任务
  TaskEntity updateSubtask(SubtaskEntity updatedSubtask) {
    final updatedSubtasks = subtasks.map((subtask) {
      return subtask.id == updatedSubtask.id ? updatedSubtask : subtask;
    }).toList();
    
    return copyWith(
      subtasks: updatedSubtasks,
      updatedAt: DateTime.now(),
    );
  }

  /// 删除子任务
  TaskEntity removeSubtask(int subtaskId) {
    final updatedSubtasks = subtasks.where((subtask) => subtask.id != subtaskId).toList();
    
    return copyWith(
      subtasks: updatedSubtasks,
      updatedAt: DateTime.now(),
    );
  }

  /// 是否过期
  bool get isOverdue {
    if (date == null || isCompleted) return false;
    return date!.isBefore(DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    ));
  }

  /// 是否今天
  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year &&
           date!.month == now.month &&
           date!.day == now.day;
  }

  /// 是否明天
  bool get isTomorrow {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date!.year == tomorrow.year &&
           date!.month == tomorrow.month &&
           date!.day == tomorrow.day;
  }

  /// 完成进度（基于子任务）
  double get completionProgress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    
    final completedSubtasks = subtasks.where((subtask) => subtask.isCompleted).length;
    return completedSubtasks / subtasks.length;
  }

  /// 是否有提醒
  bool get hasReminder => remind && startTime != null;

  /// 获取提醒时间
  DateTime? get reminderTime {
    if (!hasReminder) return null;
    return startTime;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'date': date?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'color': color,
      'remind': remind,
      'repeat': repeat.index,
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'tag': tag,
      'focusTimeSeconds': focusTimeSeconds,
      'totalTimeMinutes': totalTimeMinutes,
      'isExpanded': isExpanded,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'remoteId': remoteId,
    };
  }

  /// 从JSON创建
  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[json['priority'] as int? ?? 0],
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      color: json['color'] as int?,
      remind: json['remind'] as bool? ?? false,
      repeat: RepeatType.values[json['repeat'] as int? ?? 0],
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((subtaskJson) => SubtaskEntity.fromJson(subtaskJson as Map<String, dynamic>))
          .toList(),
      tag: json['tag'] as String?,
      focusTimeSeconds: json['focusTimeSeconds'] as int? ?? 0,
      totalTimeMinutes: json['totalTimeMinutes'] as int? ?? 0,
      isExpanded: json['isExpanded'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      isSynced: json['isSynced'] as bool? ?? false,
      remoteId: json['remoteId'] as String?,
    );
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

/// 子任务实体类
class SubtaskEntity extends Equatable {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubtaskEntity({
    this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, isCompleted, createdAt, updatedAt];

  SubtaskEntity copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubtaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  SubtaskEntity markCompleted() {
    return copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
  }

  SubtaskEntity markIncomplete() {
    return copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubtaskEntity.fromJson(Map<String, dynamic> json) {
    return SubtaskEntity(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'SubtaskEntity(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}

/// 任务优先级枚举
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// 任务重复类型枚举
enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// 任务优先级扩展
extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      case TaskPriority.urgent:
        return '紧急';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }
}

/// 重复类型扩展
extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.none:
        return '不重复';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekly:
        return '每周';
      case RepeatType.monthly:
        return '每月';
      case RepeatType.yearly:
        return '每年';
      case RepeatType.custom:
        return '自定义';
    }
  }
}