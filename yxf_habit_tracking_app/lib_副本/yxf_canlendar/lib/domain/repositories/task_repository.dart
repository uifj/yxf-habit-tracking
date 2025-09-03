import 'package:equatable/equatable.dart';
import '../entities/task_entity.dart';
import '../../core/error/failures.dart';

/// 任务仓库抽象接口
/// 定义任务数据操作的契约，遵循依赖倒置原则
abstract class TaskRepository {
  /// 获取所有任务
  /// 返回 Either<Failure, List<TaskEntity>>
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  
  /// 根据ID获取任务
  Future<Either<Failure, TaskEntity>> getTaskById(int id);
  
  /// 根据日期获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByDate(DateTime date);
  
  /// 根据日期范围获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// 根据优先级获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority(TaskPriority priority);
  
  /// 根据完成状态获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByStatus(bool isCompleted);
  
  /// 搜索任务
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String query);
  
  /// 添加任务
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);
  
  /// 更新任务
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  
  /// 删除任务
  Future<Either<Failure, void>> deleteTask(int taskId);
  
  /// 批量添加任务
  Future<Either<Failure, List<TaskEntity>>> addTasks(List<TaskEntity> tasks);
  
  /// 批量更新任务
  Future<Either<Failure, List<TaskEntity>>> updateTasks(List<TaskEntity> tasks);
  
  /// 批量删除任务
  Future<Either<Failure, void>> deleteTasks(List<int> taskIds);
  
  /// 标记任务完成
  Future<Either<Failure, TaskEntity>> markTaskCompleted(int taskId);
  
  /// 标记任务未完成
  Future<Either<Failure, TaskEntity>> markTaskIncomplete(int taskId);
  
  /// 清空所有任务
  Future<Either<Failure, void>> clearAllTasks();
  
  /// 同步数据到远程服务器
  Future<Either<Failure, void>> syncToRemote();
  
  /// 从远程服务器同步数据
  Future<Either<Failure, List<TaskEntity>>> syncFromRemote();
  
  /// 获取任务统计信息
  Future<Either<Failure, TaskStatistics>> getTaskStatistics();
  
  /// 监听任务变化
  Stream<List<TaskEntity>> watchTasks();
  
  /// 监听特定日期的任务变化
  Stream<List<TaskEntity>> watchTasksByDate(DateTime date);
}

/// Either 类型定义
/// 用于表示操作结果，要么是失败(Failure)，要么是成功(T)
abstract class Either<L, R> {
  const Either();
  
  /// 创建左值（失败）
  factory Either.left(L value) = Left<L, R>;
  
  /// 创建右值（成功）
  factory Either.right(R value) = Right<L, R>;
  
  /// 是否为左值（失败）
  bool get isLeft;
  
  /// 是否为右值（成功）
  bool get isRight;
  
  /// 获取左值
  L? get left;
  
  /// 获取右值
  R? get right;
  
  /// 折叠操作
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight);
  
  /// 映射右值
  Either<L, T> map<T>(T Function(R right) mapper);
  
  /// 映射左值
  Either<T, R> mapLeft<T>(T Function(L left) mapper);
  
  /// 平铺映射
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper);
}

/// 左值实现（失败）
class Left<L, R> extends Either<L, R> {
  final L _value;
  
  const Left(this._value);
  
  @override
  bool get isLeft => true;
  
  @override
  bool get isRight => false;
  
  @override
  L get left => _value;
  
  @override
  R? get right => null;
  
  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return ifLeft(_value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Left(_value);
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Left(mapper(_value));
  }
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return Left(_value);
  }
  
  @override
  bool operator ==(Object other) {
    return other is Left<L, R> && other._value == _value;
  }
  
  @override
  int get hashCode => _value.hashCode;
  
  @override
  String toString() => 'Left($_value)';
}

/// 右值实现（成功）
class Right<L, R> extends Either<L, R> {
  final R _value;
  
  const Right(this._value);
  
  @override
  bool get isLeft => false;
  
  @override
  bool get isRight => true;
  
  @override
  L? get left => null;
  
  @override
  R get right => _value;
  
  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return ifRight(_value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Right(mapper(_value));
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Right(_value);
  }
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return mapper(_value);
  }
  
  @override
  bool operator ==(Object other) {
    return other is Right<L, R> && other._value == _value;
  }
  
  @override
  int get hashCode => _value.hashCode;
  
  @override
  String toString() => 'Right($_value)';
}

/// 任务统计信息
class TaskStatistics extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final Map<TaskPriority, int> tasksByPriority;
  final Map<DateTime, int> tasksByDate;
  final double completionRate;
  
  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.tasksByPriority,
    required this.tasksByDate,
    required this.completionRate,
  });
  
  @override
  List<Object?> get props => [
    totalTasks,
    completedTasks,
    pendingTasks,
    overdueTasks,
    tasksByPriority,
    tasksByDate,
    completionRate,
  ];
  
  TaskStatistics copyWith({
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    int? overdueTasks,
    Map<TaskPriority, int>? tasksByPriority,
    Map<DateTime, int>? tasksByDate,
    double? completionRate,
  }) {
    return TaskStatistics(
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      tasksByPriority: tasksByPriority ?? this.tasksByPriority,
      tasksByDate: tasksByDate ?? this.tasksByDate,
      completionRate: completionRate ?? this.completionRate,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'tasksByPriority': tasksByPriority.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'tasksByDate': tasksByDate.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
      'completionRate': completionRate,
    };
  }
  
  factory TaskStatistics.fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      tasksByPriority: (json['tasksByPriority'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
                TaskPriority.values.firstWhere(
                  (e) => e.toString() == key,
                  orElse: () => TaskPriority.low,
                ),
                value as int,
              )),
      tasksByDate: (json['tasksByDate'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
                DateTime.parse(key),
                value as int,
              )),
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// TaskPriority 和 RepeatType 已在 task_entity.dart 中定义