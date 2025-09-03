import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';
import '../../core/error/failures.dart';

/// 任务用例类
/// 包含所有与任务相关的业务逻辑操作
class TaskUseCases {
  final TaskRepository repository;

  TaskUseCases(this.repository);

  /// 获取所有任务
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    return repository.getTasks();
  }

  /// 根据ID获取任务
  Future<Either<Failure, TaskEntity>> getTaskById(int id) {
    return repository.getTaskById(id);
  }

  /// 根据日期获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByDate(DateTime date) {
    return repository.getTasksByDate(date);
  }

  /// 根据日期范围获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    // 业务逻辑验证
    if (startDate.isAfter(endDate)) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '开始日期不能晚于结束日期',
          code: 'INVALID_DATE_RANGE',
        ),
      ));
    }

    // 限制日期范围不超过一年
    final daysDifference = endDate.difference(startDate).inDays;
    if (daysDifference > 365) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '日期范围不能超过一年',
          code: 'DATE_RANGE_TOO_LARGE',
        ),
      ));
    }

    return repository.getTasksByDateRange(startDate, endDate);
  }

  /// 根据优先级获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority(TaskPriority priority) {
    return repository.getTasksByPriority(priority);
  }

  /// 根据完成状态获取任务
  Future<Either<Failure, List<TaskEntity>>> getTasksByStatus(bool isCompleted) {
    return repository.getTasksByStatus(isCompleted);
  }

  /// 搜索任务
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String query) {
    // 业务逻辑验证
    if (query.trim().isEmpty) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '搜索关键词不能为空',
          code: 'EMPTY_SEARCH_QUERY',
        ),
      ));
    }

    if (query.trim().length < 2) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '搜索关键词至少需要2个字符',
          code: 'SEARCH_QUERY_TOO_SHORT',
        ),
      ));
    }

    return repository.searchTasks(query.trim());
  }

  /// 添加任务
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) {
    // 业务逻辑验证
    final validationResult = _validateTask(task);
    if (validationResult != null) {
      return Future.value(Either.left(validationResult));
    }

    // 设置创建和更新时间
    final taskWithTimestamps = task.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return repository.addTask(taskWithTimestamps);
  }

  /// 更新任务
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) {
    // 业务逻辑验证
    final validationResult = _validateTask(task);
    if (validationResult != null) {
      return Future.value(Either.left(validationResult));
    }

    // 更新时间戳
    final taskWithUpdatedTime = task.copyWith(
      updatedAt: DateTime.now(),
    );

    return repository.updateTask(taskWithUpdatedTime);
  }

  /// 删除任务
  Future<Either<Failure, void>> deleteTask(int taskId) {
    if (taskId <= 0) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '无效的任务ID',
          code: 'INVALID_TASK_ID',
        ),
      ));
    }

    return repository.deleteTask(taskId);
  }

  /// 批量添加任务
  Future<Either<Failure, List<TaskEntity>>> addTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '任务列表不能为空',
          code: 'EMPTY_TASK_LIST',
        ),
      ));
    }

    // 验证所有任务
    for (int i = 0; i < tasks.length; i++) {
      final validationResult = _validateTask(tasks[i]);
      if (validationResult != null) {
        return Future.value(Either.left(
          ValidationFailure(
            message: '第${i + 1}个任务验证失败: ${validationResult.message}',
            code: 'BATCH_VALIDATION_FAILED',
          ),
        ));
      }
    }

    // 设置时间戳
    final now = DateTime.now();
    final tasksWithTimestamps = tasks.map((task) => task.copyWith(
      createdAt: now,
      updatedAt: now,
    )).toList();

    return repository.addTasks(tasksWithTimestamps);
  }

  /// 批量更新任务
  Future<Either<Failure, List<TaskEntity>>> updateTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '任务列表不能为空',
          code: 'EMPTY_TASK_LIST',
        ),
      ));
    }

    // 验证所有任务
    for (int i = 0; i < tasks.length; i++) {
      final validationResult = _validateTask(tasks[i]);
      if (validationResult != null) {
        return Future.value(Either.left(
          ValidationFailure(
            message: '第${i + 1}个任务验证失败: ${validationResult.message}',
            code: 'BATCH_VALIDATION_FAILED',
          ),
        ));
      }
    }

    // 更新时间戳
    final now = DateTime.now();
    final tasksWithUpdatedTime = tasks.map((task) => task.copyWith(
      updatedAt: now,
    )).toList();

    return repository.updateTasks(tasksWithUpdatedTime);
  }

  /// 批量删除任务
  Future<Either<Failure, void>> deleteTasks(List<int> taskIds) {
    if (taskIds.isEmpty) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '任务ID列表不能为空',
          code: 'EMPTY_TASK_ID_LIST',
        ),
      ));
    }

    // 验证所有ID
    for (final id in taskIds) {
      if (id <= 0) {
        return Future.value(Either.left(
          ValidationFailure(
            message: '包含无效的任务ID: $id',
            code: 'INVALID_TASK_ID',
          ),
        ));
      }
    }

    return repository.deleteTasks(taskIds);
  }

  /// 标记任务为已完成
  Future<Either<Failure, TaskEntity>> markTaskCompleted(int taskId) {
    if (taskId <= 0) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '无效的任务ID',
          code: 'INVALID_TASK_ID',
        ),
      ));
    }

    return repository.markTaskCompleted(taskId);
  }

  /// 标记任务为未完成
  Future<Either<Failure, TaskEntity>> markTaskIncomplete(int taskId) {
    if (taskId <= 0) {
      return Future.value(Either.left(
        ValidationFailure(
          message: '无效的任务ID',
          code: 'INVALID_TASK_ID',
        ),
      ));
    }

    return repository.markTaskIncomplete(taskId);
  }

  /// 清空所有任务
  Future<Either<Failure, void>> clearAllTasks() {
    return repository.clearAllTasks();
  }

  /// 同步到远程
  Future<Either<Failure, void>> syncToRemote() {
    return repository.syncToRemote();
  }

  /// 从远程同步
  Future<Either<Failure, List<TaskEntity>>> syncFromRemote() {
    return repository.syncFromRemote();
  }

  /// 获取任务统计信息
  Future<Either<Failure, TaskStatistics>> getTaskStatistics() {
    return repository.getTaskStatistics();
  }

  /// 监听任务变化
  Stream<List<TaskEntity>> watchTasks() {
    return repository.watchTasks();
  }

  /// 监听指定日期的任务变化
  Stream<List<TaskEntity>> watchTasksByDate(DateTime date) {
    return repository.watchTasksByDate(date);
  }

  /// 获取今日任务
  Future<Either<Failure, List<TaskEntity>>> getTodayTasks() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return getTasksByDate(startOfDay);
  }

  /// 获取本周任务
  Future<Either<Failure, List<TaskEntity>>> getWeekTasks() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return getTasksByDateRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// 获取本月任务
  Future<Either<Failure, List<TaskEntity>>> getMonthTasks() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getTasksByDateRange(startOfMonth, endOfMonth);
  }

  /// 获取逾期任务
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks() async {
    final result = await getTasks();
    return result.fold(
      (failure) => Either.left(failure),
      (tasks) {
        final now = DateTime.now();
        final overdueTasks = tasks.where((task) {
          return !task.isCompleted && 
                 task.endTime != null && 
                 task.endTime!.isBefore(now);
        }).toList();
        return Either.right(overdueTasks);
      },
    );
  }

  /// 获取即将到期的任务（未来24小时内）
  Future<Either<Failure, List<TaskEntity>>> getUpcomingTasks() async {
    final result = await getTasks();
    return result.fold(
      (failure) => Either.left(failure),
      (tasks) {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(hours: 24));
        final upcomingTasks = tasks.where((task) {
          return !task.isCompleted && 
                 task.endTime != null && 
                 task.endTime!.isAfter(now) &&
                 task.endTime!.isBefore(tomorrow);
        }).toList();
        return Either.right(upcomingTasks);
      },
    );
  }

  /// 切换任务完成状态
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion(int taskId) async {
    final taskResult = await getTaskById(taskId);
    return taskResult.fold(
      (failure) => Either.left(failure),
      (task) {
        if (task.isCompleted) {
          return markTaskIncomplete(taskId);
        } else {
          return markTaskCompleted(taskId);
        }
      },
    );
  }

  /// 复制任务
  Future<Either<Failure, TaskEntity>> duplicateTask(int taskId) async {
    final taskResult = await getTaskById(taskId);
    return taskResult.fold(
      (failure) => Either.left(failure),
      (task) {
        final duplicatedTask = task.copyWith(
          id: null, // 新任务没有ID
          title: '${task.title} (副本)',
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return addTask(duplicatedTask);
      },
    );
  }

  /// 验证任务数据
  ValidationFailure? _validateTask(TaskEntity task) {
    // 标题验证
    if (task.title.trim().isEmpty) {
      return ValidationFailure(
        message: '任务标题不能为空',
        code: 'EMPTY_TITLE',
      );
    }

    if (task.title.trim().length > 200) {
      return ValidationFailure(
        message: '任务标题不能超过200个字符',
        code: 'TITLE_TOO_LONG',
      );
    }

    // 描述验证
    if (task.description != null && task.description!.length > 1000) {
      return ValidationFailure(
        message: '任务描述不能超过1000个字符',
        code: 'DESCRIPTION_TOO_LONG',
      );
    }

    // 日期验证
    if (task.endTime != null && task.startTime != null) {
      if (task.endTime!.isBefore(task.startTime!)) {
        return ValidationFailure(
          message: '结束时间不能早于开始时间',
          code: 'INVALID_TIME_ORDER',
        );
      }
    }

    // 子任务验证
    if (task.subtasks.isNotEmpty) {
      for (int i = 0; i < task.subtasks.length; i++) {
        final subtask = task.subtasks[i];
        if (subtask.title.trim().isEmpty) {
          return ValidationFailure(
            message: '第${i + 1}个子任务标题不能为空',
            code: 'EMPTY_SUBTASK_TITLE',
          );
        }
        if (subtask.title.trim().length > 100) {
          return ValidationFailure(
            message: '第${i + 1}个子任务标题不能超过100个字符',
            code: 'SUBTASK_TITLE_TOO_LONG',
          );
        }
      }
    }

    // 标签验证
    if (task.tag != null && task.tag!.isNotEmpty) {
      if (task.tag!.trim().isEmpty) {
        return ValidationFailure(
          message: '标签不能为空',
          code: 'EMPTY_TAG',
        );
      }
      if (task.tag!.trim().length > 20) {
        return ValidationFailure(
          message: '标签长度不能超过20个字符',
          code: 'TAG_TOO_LONG',
        );
      }
    }

    return null;
  }
}