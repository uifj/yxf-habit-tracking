import 'package:equatable/equatable.dart';

/// 任务优先级枚举
enum TaskPriority {
  low,
  medium,
  high,
}

/// 重复类型枚举
enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
}

/// 子任务模型
class Subtask extends Equatable {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const Subtask({
    required this.title,
    this.id,
    this.isCompleted = false,
    this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, title, isCompleted, createdAt, completedAt];

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Subtask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Task extends Equatable {
  final int? id;
  final String? userId;
  final String title;
  final String note;
  final int isCompleted;
  final String priority;
  final String date;
  final String startTime;
  final String endTime;
  final int color;
  final int remind;
  final String repeat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // 新增字段
  final List<Subtask> subtasks; // 子任务列表
  final String? tag; // 关联的标签
  final int focusTimeSeconds; // 专注时间（秒）
  final int totalTimeMinutes; // 总时间（分钟）
  final bool isExpanded; // 是否展开（UI状态）
  final Map<String, dynamic>? metadata; // 额外数据

  const Task({
    required this.title,
    required this.note,
    required this.isCompleted,
    required this.priority,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.remind,
    required this.repeat,
    this.userId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.subtasks = const [],
    this.tag,
    this.focusTimeSeconds = 0,
    this.totalTimeMinutes = 0,
    this.isExpanded = false,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        note,
        isCompleted,
        priority,
        date,
        startTime,
        endTime,
        color,
        remind,
        repeat,
        createdAt,
        updatedAt,
        subtasks,
        tag,
        focusTimeSeconds,
        totalTimeMinutes,
        isExpanded,
        metadata,
      ];

  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        userId = json['userId'] ?? "",
        title = json['title'] ?? '',
        note = json['note'] ?? '',
        isCompleted = json['isCompleted'] ?? 0,
        priority = json['priority'] ?? 'Medium',
        date = json['date'] ?? '',
        startTime = json['startTime'] ?? '',
        endTime = json['endTime'] ?? '',
        color = json['color'] ?? 0,
        remind = json['remind'] ?? 5,
        repeat = json['repeat'] ?? 'None',
        createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt = json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        subtasks = json['subtasks'] != null
            ? (json['subtasks'] as List).map((e) => Subtask.fromJson(e)).toList()
            : [],
        tag = json['tag'],
        focusTimeSeconds = json['focusTimeSeconds'] ?? 0,
        totalTimeMinutes = json['totalTimeMinutes'] ?? 0,
        isExpanded = json['isExpanded'] ?? false,
        metadata = json['metadata'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['title'] = title;
    data['note'] = note;
    data['isCompleted'] = isCompleted;
    data['priority'] = priority;
    data['date'] = date;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['color'] = color;
    data['remind'] = remind;
    data['repeat'] = repeat;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['subtasks'] = subtasks.map((e) => e.toJson()).toList();
    data['tag'] = tag;
    data['focusTimeSeconds'] = focusTimeSeconds;
    data['totalTimeMinutes'] = totalTimeMinutes;
    data['isExpanded'] = isExpanded;
    data['metadata'] = metadata;
    return data;
  }

  /// 创建Task的副本，可选择性地覆盖某些属性
  Task copyWith({
    int? id,
    String? userId,
    String? title,
    String? note,
    int? isCompleted,
    String? priority,
    String? date,
    String? startTime,
    String? endTime,
    int? color,
    int? remind,
    String? repeat,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    String? tag,
    int? focusTimeSeconds,
    int? totalTimeMinutes,
    bool? isExpanded,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      tag: tag ?? this.tag,
      focusTimeSeconds: focusTimeSeconds ?? this.focusTimeSeconds,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      isExpanded: isExpanded ?? this.isExpanded,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 工厂方法：创建空任务
  factory Task.empty() {
    return Task(
      title: '',
      note: '',
      isCompleted: 0,
      priority: 'Medium',
      date: DateTime.now().toString().split(' ')[0],
      startTime: '09:00',
      endTime: '10:00',
      color: 0,
      remind: 5,
      repeat: 'None',
      createdAt: DateTime.now(),
      subtasks: const [],
      focusTimeSeconds: 0,
      totalTimeMinutes: 0,
      isExpanded: false,
    );
  }

  /// 检查任务是否已完成
  bool get isTaskCompleted => isCompleted == 1;

  /// 获取优先级颜色
  // int get priorityColor {
  //   switch (priority.toLowerCase()) {
  //     case 'high':
  //       return 0xFF_FF_00_00; // Red
  //     case 'medium':
  //       return 0xFF_FF_A5_00; // 橙色
  //     case 'low':
  //       return 0xFF_00_80_00; // 绿色
  //     default:
  //       return 0xFF_80_80_80; // 灰色
  //   }
  // }
}
