import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

/// 任务数据模型
/// 数据层的任务表示，继承自领域实体，添加数据转换功能
class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    required super.title,
    super.description,
    super.isCompleted = false,
    super.priority = TaskPriority.low,
    super.date,
    super.startTime,
    super.endTime,
    super.color,
    super.remind = false,
    super.repeat = RepeatType.none,
    super.subtasks = const [],
    super.tag,
    super.focusTimeSeconds = 0,
    super.totalTimeMinutes = 0,
    super.isExpanded = false,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
    super.isSynced = false,
    super.remoteId,
  });

  /// 从实体创建模型
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      date: entity.date,
      startTime: entity.startTime,
      endTime: entity.endTime,
      color: entity.color,
      remind: entity.remind,
      repeat: entity.repeat,
      subtasks: entity.subtasks.map((subtask) => SubtaskModel.fromEntity(subtask)).toList(),
      tag: entity.tag,
      focusTimeSeconds: entity.focusTimeSeconds,
      totalTimeMinutes: entity.totalTimeMinutes,
      isExpanded: entity.isExpanded,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
      remoteId: entity.remoteId,
    );
  }

  /// 转换为实体
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority,
      date: date,
      startTime: startTime,
      endTime: endTime,
      color: color,
      remind: remind,
      repeat: repeat,
      subtasks: subtasks.map((subtask) => (subtask as SubtaskModel).toEntity()).toList(),
      tag: tag,
      focusTimeSeconds: focusTimeSeconds,
      totalTimeMinutes: totalTimeMinutes,
      isExpanded: isExpanded,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
      remoteId: remoteId,
    );
  }

  /// 从JSON创建模型
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
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
          .map((subtaskJson) => SubtaskModel.fromJson(subtaskJson as Map<String, dynamic>))
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

  /// 转换为JSON
  @override
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
      'subtasks': subtasks.map((subtask) => (subtask as SubtaskModel).toJson()).toList(),
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

  /// 创建副本
  @override
  TaskModel copyWith({
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
    return TaskModel(
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

  /// 从数据库行创建模型
  factory TaskModel.fromDatabaseRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as int?,
      title: row['title'] as String? ?? '',
      description: row['description'] as String?,
      isCompleted: (row['isCompleted'] as int? ?? 0) == 1,
      priority: TaskPriority.values[row['priority'] as int? ?? 0],
      date: row['date'] != null ? DateTime.parse(row['date'] as String) : null,
      startTime: row['startTime'] != null ? DateTime.parse(row['startTime'] as String) : null,
      endTime: row['endTime'] != null ? DateTime.parse(row['endTime'] as String) : null,
      color: row['color'] as int?,
      remind: (row['remind'] as int? ?? 0) == 1,
      repeat: RepeatType.values[row['repeat'] as int? ?? 0],
      subtasks: [], // 子任务需要单独查询
      tag: row['tag'] as String?,
      focusTimeSeconds: row['focusTimeSeconds'] as int? ?? 0,
      totalTimeMinutes: row['totalTimeMinutes'] as int? ?? 0,
      isExpanded: (row['isExpanded'] as int? ?? 0) == 1,
      metadata: row['metadata'] != null 
          ? Map<String, dynamic>.from(row['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(row['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(row['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      isSynced: (row['isSynced'] as int? ?? 0) == 1,
      remoteId: row['remoteId'] as String?,
    );
  }

  /// 转换为数据库行
  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'date': date?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'color': color,
      'remind': remind ? 1 : 0,
      'repeat': repeat.index,
      'tag': tag,
      'focusTimeSeconds': focusTimeSeconds,
      'totalTimeMinutes': totalTimeMinutes,
      'isExpanded': isExpanded ? 1 : 0,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'remoteId': remoteId,
    };
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

/// 子任务数据模型
class SubtaskModel extends SubtaskEntity {
  const SubtaskModel({
    super.id,
    required super.title,
    super.isCompleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// 从实体创建模型
  factory SubtaskModel.fromEntity(SubtaskEntity entity) {
    return SubtaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// 转换为实体
  SubtaskEntity toEntity() {
    return SubtaskEntity(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 从JSON创建模型
  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  @override
  SubtaskModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 从数据库行创建模型
  factory SubtaskModel.fromDatabaseRow(Map<String, dynamic> row) {
    return SubtaskModel(
      id: row['id'] as int?,
      title: row['title'] as String? ?? '',
      isCompleted: (row['isCompleted'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(row['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为数据库行
  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SubtaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}