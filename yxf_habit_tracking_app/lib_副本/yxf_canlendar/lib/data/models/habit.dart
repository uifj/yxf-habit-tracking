import 'package:equatable/equatable.dart';

/// 习惯子任务模型
class HabitSubtask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;

  const HabitSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, title, isCompleted, completedAt];

  factory HabitSubtask.fromJson(Map<String, dynamic> json) {
    return HabitSubtask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  HabitSubtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// 习惯模型
class Habit extends Equatable {
  final int? id;
  final String? userId;
  final String name;
  final String? description;
  final List<String> completedDates; // 完成日期列表 (YYYY-MM-DD格式)
  final List<HabitSubtask>? subtasks; // 子任务列表
  final String? tag; // 关联的标签
  final String color; // 习惯颜色
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive; // 是否激活
  final int streak; // 连续完成天数
  final int totalCompletions; // 总完成次数

  const Habit({
    required this.name,
    required this.completedDates,
    required this.createdAt,
    this.id,
    this.userId,
    this.description,
    this.subtasks,
    this.tag,
    this.color = '#22c55e', // 默认绿色
    this.updatedAt,
    this.isActive = true,
    this.streak = 0,
    this.totalCompletions = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        completedDates,
        subtasks,
        tag,
        color,
        createdAt,
        updatedAt,
        isActive,
        streak,
        totalCompletions,
      ];

  /// 从JSON创建Habit对象
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['userId'],
      name: json['name'] ?? '',
      description: json['description'],
      completedDates: List<String>.from(json['completedDates'] ?? []),
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List<dynamic>)
              .map((subtask) => HabitSubtask.fromJson(subtask))
              .toList()
          : null,
      tag: json['tag'],
      color: json['color'] ?? '#22c55e',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      streak: json['streak'] ?? 0,
      totalCompletions: json['totalCompletions'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'completedDates': completedDates,
      'subtasks': subtasks?.map((subtask) => subtask.toJson()).toList() ?? [],
      'tag': tag,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'streak': streak,
      'totalCompletions': totalCompletions,
    };
  }

  /// 创建副本
  Habit copyWith({
    int? id,
    String? userId,
    String? name,
    String? description,
    List<String>? completedDates,
    List<HabitSubtask>? subtasks,
    String? tag,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? streak,
    int? totalCompletions,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      subtasks: subtasks ?? this.subtasks,
      tag: tag ?? this.tag,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      streak: streak ?? this.streak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }

  /// 工厂方法：创建空习惯
  factory Habit.empty() {
    return Habit(
      name: '',
      completedDates: const [],
      createdAt: DateTime.now(),
    );
  }

  /// 检查今天是否已完成
  bool get isCompletedToday {
    final today = DateTime.now().toString().split(' ')[0];
    return completedDates.contains(today);
  }

  /// 检查指定日期是否已完成
  bool isCompletedOnDate(DateTime date) {
    final dateStr = date.toString().split(' ')[0];
    return completedDates.contains(dateStr);
  }

  /// 获取最近30天的完成情况
  List<bool> getLast30DaysCompletion() {
    final List<bool> completions = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      completions.add(isCompletedOnDate(date));
    }

    return completions;
  }

  /// 计算当前连续完成天数
  int calculateCurrentStreak() {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates
        .map((date) => DateTime.parse(date))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 降序排列

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final date in sortedDates) {
      final daysDiff = currentDate.difference(date).inDays;

      if (daysDiff == streak) {
        streak++;
      } else if (daysDiff == streak + 1 && streak == 0) {
        // 如果今天没完成但昨天完成了，从昨天开始计算
        streak++;
        currentDate = date;
      } else {
        break;
      }
    }

    return streak;
  }
}
