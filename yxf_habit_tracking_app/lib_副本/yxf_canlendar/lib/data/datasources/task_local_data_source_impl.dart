// import 'dart:convert';
// import 'dart:async';

// import '../../core/error/exceptions.dart';
// import '../../core/utils/shared_prefs_helper.dart';
// import '../../domain/entities/task_entity.dart';
// import '../models/task_model.dart';
// import 'task_local_data_source.dart';

// /// 任务本地数据源实现
// class TaskLocalDataSourceImpl implements TaskLocalDataSource {
//   final SharedPrefsHelper _sharedPrefsHelper;

//   static const String _tasksKey = 'cached_tasks';
//   static const String _lastSyncKey = 'last_sync_time';
//   static const String _userSettingsKey = 'user_settings';

//   // 内存缓存
//   final Map<String, TaskModel> _taskCache = {};
//   final StreamController<List<TaskEntity>> _tasksStreamController =
//       StreamController<List<TaskEntity>>.broadcast();

//   TaskLocalDataSourceImpl({
//     required SharedPrefsHelper sharedPrefsHelper,
//   }) : _sharedPrefsHelper = sharedPrefsHelper;

//   @override
//   Future<List<TaskModel>> getAllTasks() async {
//     try {
//       final tasksJson = _sharedPrefsHelper.getString(_tasksKey);
//       if (tasksJson == null || tasksJson.isEmpty) {
//         return [];
//       }

//       final List<dynamic> tasksList = json.decode(tasksJson);
//       final tasks = tasksList
//           .map((taskJson) =>
//               TaskModel.fromJson(taskJson as Map<String, dynamic>))
//           .toList();

//       // 更新内存缓存
//       _taskCache.clear();
//       for (final task in tasks) {
//         _taskCache[task.id] = task;
//       }

//       return tasks;
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取本地任务失败: ${e.toString()}',
//         code: 'GET_ALL_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<TaskModel?> getTaskById(String id) async {
//     try {
//       // 先从内存缓存查找
//       if (_taskCache.containsKey(id)) {
//         return _taskCache[id];
//       }

//       // 从持久化存储查找
//       final tasks = await getAllTasks();
//       return tasks.firstWhere(
//         (task) => task.id == id,
//         orElse: () => throw TaskNotFoundException(
//           message: '任务不存在: $id',
//           code: 'TASK_NOT_FOUND',
//         ),
//       );
//     } catch (e, stackTrace) {
//       if (e is TaskNotFoundException) {
//         return null;
//       }
//       throw CacheException(
//         message: '获取任务失败: ${e.toString()}',
//         code: 'GET_TASK_BY_ID_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> insertTask(TaskModel task) async {
//     try {
//       final tasks = await getAllTasks();

//       // 检查是否已存在
//       if (tasks.any((t) => t.id == task.id)) {
//         throw TaskAlreadyExistsException(
//           message: '任务已存在: ${task.id}',
//           code: 'TASK_ALREADY_EXISTS',
//         );
//       }

//       tasks.add(task);
//       await _saveTasks(tasks);

//       // 更新内存缓存
//       _taskCache[task.id] = task;

//       // 通知监听者
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       if (e is TaskAlreadyExistsException) {
//         rethrow;
//       }
//       throw CacheException(
//         message: '插入任务失败: ${e.toString()}',
//         code: 'INSERT_TASK_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> updateTask(TaskModel task) async {
//     try {
//       final tasks = await getAllTasks();
//       final index = tasks.indexWhere((t) => t.id == task.id);

//       if (index == -1) {
//         throw TaskNotFoundException(
//           message: '任务不存在: ${task.id}',
//           code: 'TASK_NOT_FOUND',
//         );
//       }

//       tasks[index] = task;
//       await _saveTasks(tasks);

//       // 更新内存缓存
//       _taskCache[task.id] = task;

//       // 通知监听者
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       if (e is TaskNotFoundException) {
//         rethrow;
//       }
//       throw CacheException(
//         message: '更新任务失败: ${e.toString()}',
//         code: 'UPDATE_TASK_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> deleteTask(String id) async {
//     try {
//       final tasks = await getAllTasks();
//       final initialLength = tasks.length;

//       tasks.removeWhere((task) => task.id == id);

//       if (tasks.length == initialLength) {
//         throw TaskNotFoundException(
//           message: '任务不存在: $id',
//           code: 'TASK_NOT_FOUND',
//         );
//       }

//       await _saveTasks(tasks);

//       // 从内存缓存移除
//       _taskCache.remove(id);

//       // 通知监听者
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       if (e is TaskNotFoundException) {
//         rethrow;
//       }
//       throw CacheException(
//         message: '删除任务失败: ${e.toString()}',
//         code: 'DELETE_TASK_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> searchTasks(String query) async {
//     try {
//       final tasks = await getAllTasks();
//       final lowercaseQuery = query.toLowerCase();

//       return tasks.where((task) {
//         return task.title.toLowerCase().contains(lowercaseQuery) ||
//             (task.description?.toLowerCase().contains(lowercaseQuery) ??
//                 false) ||
//             (task.tag?.toLowerCase().contains(lowercaseQuery) ?? false);
//       }).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '搜索任务失败: ${e.toString()}',
//         code: 'SEARCH_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> getTasksByDateRange(
//       DateTime start, DateTime end) async {
//     try {
//       final tasks = await getAllTasks();

//       return tasks.where((task) {
//         final taskDate = task.date;
//         return taskDate != null &&
//             taskDate.isAfter(start.subtract(const Duration(days: 1))) &&
//             taskDate.isBefore(end.add(const Duration(days: 1)));
//       }).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '按日期范围获取任务失败: ${e.toString()}',
//         code: 'GET_TASKS_BY_DATE_RANGE_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> getTasksByStatus(bool isCompleted) async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.where((task) => task.isCompleted == isCompleted).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '按状态获取任务失败: ${e.toString()}',
//         code: 'GET_TASKS_BY_STATUS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.where((task) => task.priority == priority).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '按优先级获取任务失败: ${e.toString()}',
//         code: 'GET_TASKS_BY_PRIORITY_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> insertTasks(List<TaskModel> tasks) async {
//     try {
//       final existingTasks = await getAllTasks();
//       final allTasks = [...existingTasks];

//       for (final task in tasks) {
//         if (!allTasks.any((t) => t.id == task.id)) {
//           allTasks.add(task);
//           _taskCache[task.id] = task;
//         }
//       }

//       await _saveTasks(allTasks);
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '批量插入任务失败: ${e.toString()}',
//         code: 'INSERT_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> updateTasks(List<TaskModel> tasks) async {
//     try {
//       final existingTasks = await getAllTasks();

//       for (final task in tasks) {
//         final index = existingTasks.indexWhere((t) => t.id == task.id);
//         if (index != -1) {
//           existingTasks[index] = task;
//           _taskCache[task.id] = task;
//         }
//       }

//       await _saveTasks(existingTasks);
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '批量更新任务失败: ${e.toString()}',
//         code: 'UPDATE_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> deleteTasks(List<String> ids) async {
//     try {
//       final tasks = await getAllTasks();
//       tasks.removeWhere((task) => ids.contains(task.id));

//       await _saveTasks(tasks);

//       // 从内存缓存移除
//       for (final id in ids) {
//         _taskCache.remove(id);
//       }

//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '批量删除任务失败: ${e.toString()}',
//         code: 'DELETE_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> clearAllTasks() async {
//     try {
//       await _sharedPrefsHelper.remove(_tasksKey);
//       _taskCache.clear();
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '清空所有任务失败: ${e.toString()}',
//         code: 'CLEAR_ALL_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> getTaskStatistics() async {
//     try {
//       final tasks = await getAllTasks();

//       final totalTasks = tasks.length;
//       final completedTasks = tasks.where((task) => task.isCompleted).length;
//       final pendingTasks = totalTasks - completedTasks;

//       final priorityStats = <TaskPriority, int>{};
//       for (final priority in TaskPriority.values) {
//         priorityStats[priority] =
//             tasks.where((task) => task.priority == priority).length;
//       }

//       return {
//         'totalTasks': totalTasks,
//         'completedTasks': completedTasks,
//         'pendingTasks': pendingTasks,
//         'completionRate': totalTasks > 0 ? (completedTasks / totalTasks) : 0.0,
//         'priorityStats':
//             priorityStats.map((key, value) => MapEntry(key.toString(), value)),
//       };
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取任务统计失败: ${e.toString()}',
//         code: 'GET_TASK_STATISTICS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Stream<List<TaskEntity>> watchTasks() {
//     return _tasksStreamController.stream;
//   }

//   @override
//   Future<DateTime?> getLastSyncTime() async {
//     try {
//       final timestamp = _sharedPrefsHelper.getInt(_lastSyncKey);
//       return timestamp != null
//           ? DateTime.fromMillisecondsSinceEpoch(timestamp)
//           : null;
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取最后同步时间失败: ${e.toString()}',
//         code: 'GET_LAST_SYNC_TIME_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> setLastSyncTime(DateTime time) async {
//     try {
//       await _sharedPrefsHelper.setInt(
//           _lastSyncKey, time.millisecondsSinceEpoch);
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '设置最后同步时间失败: ${e.toString()}',
//         code: 'SET_LAST_SYNC_TIME_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<Map<String, dynamic>?> getUserSettings() async {
//     try {
//       final settingsJson = _sharedPrefsHelper.getString(_userSettingsKey);
//       if (settingsJson == null || settingsJson.isEmpty) {
//         return null;
//       }
//       return json.decode(settingsJson) as Map<String, dynamic>;
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取用户设置失败: ${e.toString()}',
//         code: 'GET_USER_SETTINGS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> saveUserSettings(Map<String, dynamic> settings) async {
//     try {
//       await _sharedPrefsHelper.setString(
//           _userSettingsKey, json.encode(settings));
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '保存用户设置失败: ${e.toString()}',
//         code: 'SAVE_USER_SETTINGS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> addTask(TaskModel task) async {
//     await insertTask(task);
//   }

//   @override
//   Future<void> addTasks(List<TaskModel> tasks) async {
//     await insertTasks(tasks);
//   }

//   @override
//   Future<void> markTaskCompleted(String id) async {
//     final task = await getTaskById(id);
//     if (task != null) {
//       final updatedTask = task.copyWith(isCompleted: true);
//       await updateTask(updatedTask);
//     }
//   }

//   @override
//   Future<void> markTaskIncomplete(String id) async {
//     final task = await getTaskById(id);
//     if (task != null) {
//       final updatedTask = task.copyWith(isCompleted: false);
//       await updateTask(updatedTask);
//     }
//   }

//   @override
//   Stream<List<TaskEntity>> watchTasksByDate(DateTime date) {
//     return watchTasks().map((tasks) => tasks.where((task) {
//           final taskDate = (task as TaskModel).date;
//           return taskDate?.year == date.year &&
//               taskDate?.month == date.month &&
//               taskDate?.day == date.day;
//         }).toList());
//   }

//   @override
//   Future<void> backupData() async {
//     // 备份实现可以根据需要添加
//     // 例如：导出到文件或云存储
//   }

//   @override
//   Future<void> restoreData(Map<String, dynamic> data) async {
//     try {
//       if (data.containsKey('tasks')) {
//         final tasksList = data['tasks'] as List<dynamic>;
//         final tasks = tasksList
//             .map((taskJson) =>
//                 TaskModel.fromJson(taskJson as Map<String, dynamic>))
//             .toList();
//         await _saveTasks(tasks);
//         _notifyTasksChanged();
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '恢复数据失败: ${e.toString()}',
//         code: 'RESTORE_DATA_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> cleanupExpiredData() async {
//     try {
//       final tasks = await getAllTasks();
//       final now = DateTime.now();
//       final cutoffDate = now.subtract(const Duration(days: 365)); // 保留一年内的数据

//       final validTasks = tasks
//           .where(
//               (task) => task.createdAt.isAfter(cutoffDate) || !task.isCompleted)
//           .toList();

//       if (validTasks.length != tasks.length) {
//         await _saveTasks(validTasks);
//         _notifyTasksChanged();
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '清理过期数据失败: ${e.toString()}',
//         code: 'CLEANUP_EXPIRED_DATA_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> optimizeStorage() async {
//     try {
//       // 重新组织数据以优化存储
//       final tasks = await getAllTasks();
//       await _saveTasks(tasks);
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '优化存储失败: ${e.toString()}',
//         code: 'OPTIMIZE_STORAGE_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<int> getStorageSize() async {
//     try {
//       final tasksJson = _sharedPrefsHelper.getString(_tasksKey);
//       return tasksJson?.length ?? 0;
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取存储大小失败: ${e.toString()}',
//         code: 'GET_STORAGE_SIZE_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<bool> isHealthy() async {
//     try {
//       // 检查数据源健康状态
//       await getAllTasks();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> getDiagnostics() async {
//     try {
//       final tasks = await getAllTasks();
//       final storageSize = await getStorageSize();
//       final isHealthy = await this.isHealthy();

//       return {
//         'taskCount': tasks.length,
//         'storageSize': storageSize,
//         'isHealthy': isHealthy,
//         'lastAccess': DateTime.now().toIso8601String(),
//       };
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取诊断信息失败: ${e.toString()}',
//         code: 'GET_DIAGNOSTICS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> clearCache() async {
//     _taskCache.clear();
//   }

//   @override
//   Future<void> preloadData() async {
//     await getAllTasks(); // 这会填充缓存
//   }

//   @override
//   Future<void> syncWithRemote(List<TaskModel> remoteTasks) async {
//     try {
//       final localTasks = await getAllTasks();
//       final mergedTasks = <String, TaskModel>{};

//       // 添加本地任务
//       for (final task in localTasks) {
//         mergedTasks[task.id] = task;
//       }

//       // 合并远程任务（远程优先）
//       for (final task in remoteTasks) {
//         mergedTasks[task.id] = task;
//       }

//       await _saveTasks(mergedTasks.values.toList());
//       _notifyTasksChanged();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '与远程同步失败: ${e.toString()}',
//         code: 'SYNC_WITH_REMOTE_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> getUnsyncedTasks() async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.where((task) => !task.isSynced).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '获取未同步任务失败: ${e.toString()}',
//         code: 'GET_UNSYNCED_TASKS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> markTasksSynced(List<String> taskIds) async {
//     try {
//       final tasks = await getAllTasks();
//       bool hasChanges = false;

//       for (int i = 0; i < tasks.length; i++) {
//         if (taskIds.contains(tasks[i].id)) {
//           tasks[i] = tasks[i].copyWith(isSynced: true);
//           _taskCache[tasks[i].id] = tasks[i];
//           hasChanges = true;
//         }
//       }

//       if (hasChanges) {
//         await _saveTasks(tasks);
//         _notifyTasksChanged();
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '标记任务已同步失败: ${e.toString()}',
//         code: 'MARK_TASKS_SYNCED_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> closeDatabase() async {
//     // SharedPreferences不需要显式关闭
//   }

//   @override
//   Future<void> compactDatabase() async {
//     // SharedPreferences不支持压缩，但可以重新保存数据
//     await optimizeStorage();
//   }

//   @override
//   Future<int> getDatabaseSize() async {
//     return await getStorageSize();
//   }

//   @override
//   Future<int> getDatabaseVersion() async {
//     return 1; // SharedPreferences版本
//   }

//   @override
//   Future<void> initializeDatabase() async {
//     await _sharedPrefsHelper.initDb();
//   }

//   @override
//   Future<void> migrateDatabase(String fromVersion, String toVersion) async {
//     // 数据迁移逻辑可以根据需要实现
//   }

//   @override
//   Future<void> repairDatabase() async {
//     try {
//       // 尝试重新加载数据
//       await getAllTasks();
//     } catch (e) {
//       // 如果数据损坏，清空并重新初始化
//       await clearAllTasks();
//     }
//   }

//   @override
//   Future<void> resetDatabase() async {
//     await clearAllTasks();
//     await _sharedPrefsHelper.clear();
//   }

//   @override
//   Future<void> vacuumDatabase() async {
//     // SharedPreferences不支持vacuum操作
//     await optimizeStorage();
//   }

//   @override
//   Future<bool> verifyDatabaseIntegrity() async {
//     try {
//       await getAllTasks();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<void> createIndexes() async {
//     // SharedPreferences不支持索引
//   }

//   @override
//   Future<List<TaskModel>> getTasks() async {
//     return await getAllTasks();
//   }

//   @override
//   Future<List<TaskModel>> getTasksByDate(DateTime date) async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.where((task) {
//         final taskDate = task.date;
//         return taskDate != null &&
//             taskDate.year == date.year &&
//             taskDate.month == date.month &&
//             taskDate.day == date.day;
//       }).toList();
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '按日期获取任务失败: ${e.toString()}',
//         code: 'GET_TASKS_BY_DATE_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> markTaskAsSynced(int taskId, String remoteId) async {
//     try {
//       final task = await getTaskById(taskId.toString());
//       if (task != null) {
//         final updatedTask = task.copyWith(isSynced: true, remoteId: remoteId);
//         await updateTask(updatedTask);
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '标记任务已同步失败: ${e.toString()}',
//         code: 'MARK_TASK_SYNCED_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> markTasksAsSynced(Map<int, String> taskIdToRemoteId) async {
//     try {
//       final tasks = await getAllTasks();
//       bool hasChanges = false;

//       for (int i = 0; i < tasks.length; i++) {
//         final taskIdInt = int.tryParse(tasks[i].id);
//         if (taskIdInt != null && taskIdToRemoteId.containsKey(taskIdInt)) {
//           tasks[i] = tasks[i]
//               .copyWith(isSynced: true, remoteId: taskIdToRemoteId[taskIdInt]!);
//           _taskCache[tasks[i].id] = tasks[i];
//           hasChanges = true;
//         }
//       }

//       if (hasChanges) {
//         await _saveTasks(tasks);
//         _notifyTasksChanged();
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '批量标记任务已同步失败: ${e.toString()}',
//         code: 'MARK_TASKS_SYNCED_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<void> updateTaskSyncStatus(String taskId, bool isSynced) async {
//     try {
//       final task = await getTaskById(taskId);
//       if (task != null) {
//         final updatedTask = task.copyWith(isSynced: isSynced);
//         await updateTask(updatedTask);
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '更新任务同步状态失败: ${e.toString()}',
//         code: 'UPDATE_TASK_SYNC_STATUS_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   @override
//   Future<bool> validateDataIntegrity() async {
//     try {
//       final tasks = await getAllTasks();
//       // 验证每个任务的数据完整性
//       for (final task in tasks) {
//         if (task.id.isEmpty || task.title.isEmpty) {
//           return false;
//         }
//       }
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<void> repairData() async {
//     try {
//       final tasks = await getAllTasks();
//       final validTasks = <TaskModel>[];

//       // 过滤掉无效的任务
//       for (final task in tasks) {
//         if (task.id.isNotEmpty && task.title.isNotEmpty) {
//           validTasks.add(task);
//         }
//       }

//       // 如果有无效任务被移除，保存修复后的数据
//       if (validTasks.length != tasks.length) {
//         await _saveTasks(validTasks);
//         _notifyTasksChanged();
//       }
//     } catch (e, stackTrace) {
//       throw CacheException(
//         message: '修复数据失败: ${e.toString()}',
//         code: 'REPAIR_DATA_FAILED',
//         originalError: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   /// 保存任务到持久化存储
//   Future<void> _saveTasks(List<TaskModel> tasks) async {
//     final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
//     await _sharedPrefsHelper.setString(_tasksKey, tasksJson);
//   }

//   /// 通知任务变更
//   void _notifyTasksChanged() async {
//     try {
//       final tasks = await getAllTasks();
//       final entities = tasks.map((model) => model.toEntity()).toList();
//       _tasksStreamController.add(entities);
//     } catch (e) {
//       _tasksStreamController.addError(e);
//     }
//   }

//   /// 释放资源
//   void dispose() {
//     _tasksStreamController.close();
//   }
// }
