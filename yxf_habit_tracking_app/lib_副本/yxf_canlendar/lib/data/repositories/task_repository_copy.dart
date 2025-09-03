// import 'dart:developer';
// import '../models/task.dart';
// import '../../core/db/db_helper.dart';
// // import '../../core/db/shared_prefs_helper.dart';
// import '../../core/error/exceptions.dart';
// import '../services/task_services.dart';
// import '../../../../common/utils/date_util.dart';

// /// 任务仓库抽象类
// /// 定义任务数据操作的接口
// abstract class TaskRepository {
//   /// 获取所有任务
//   Future<List<Task>> getTasks();

//   /// 根据条件获取任务
//   Future<List<Task>> getTasksWhere({
//     String? where,
//     List<Object?>? whereArgs,
//     String? orderBy,
//     int? limit,
//   });

//   /// 根据日期获取任务
//   Future<List<Task>> getTasksByDate(DateTime date);

//   /// 添加任务
//   Future<Task> addTask(Task task);

//   /// 更新任务
//   Future<Task> updateTask(Task task);

//   /// 删除任务
//   Future<void> deleteTask(Task task);

//   /// 标记任务完成
//   Future<Task> markTaskCompleted(Task task);

//   /// 同步数据
//   Future<void> syncData();

//   /// 批量添加任务
//   Future<List<Task>> addTasks(List<Task> tasks);

//   /// 删除所有任务
//   Future<void> deleteAllTasks();

//   /// 清除所有任务（别名方法）
//   Future<void> clearAllTasks();

//   /// 批量插入任务
//   Future<void> bulkInsertTasks(List<Task> tasks);
// }

// /// 任务仓库实现类
// class TaskRepositoryImpl implements TaskRepository {
//   final DBHelper _dbHelper;
//   // final NotifyHelper _notifyHelper;
//   final TaskServices _taskServices;

//   TaskRepositoryImpl({
//     required DBHelper dbHelper,
//     // required NotifyHelper notifyHelper,
//     required TaskServices taskServices,
//   })  : _dbHelper = dbHelper,
//         // _notifyHelper = notifyHelper,
//         _taskServices = taskServices;

//   @override
//   Future<void> initializeDatabase() async {
//     try {
//       await DBHelper.initDb();
//     } catch (e) {
//       log('Error initializing database: $e');
//       throw const DatabaseException(
//         message: 'Failed to initialize database',
//         code: 1001,
//       );
//     }
//   }

//   @override
//   Future<List<Task>> getTasks() async {
//     try {
//       log('Getting all tasks from database');
//       final List<Map<String, dynamic>> maps = await DBHelper.query();
//       final tasks = maps.map((map) => Task.fromJson(map)).toList();
//       log('Retrieved ${tasks.length} tasks');
//       return tasks;
//     } catch (e) {
//       log('Error getting tasks: $e');
//       if (e is DatabaseException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to get tasks from database',
//         code: 2001,
//       );
//     }
//   }

//   @override
//   Future<List<Task>> getTasksWhere({
//     String? where,
//     List<Object?>? whereArgs,
//     String? orderBy,
//     int? limit,
//   }) async {
//     try {
//       log('Getting tasks with conditions: where=$where');
//       final List<Map<String, dynamic>> maps = await DBHelper.queryWhere(
//         where: where,
//         whereArgs: whereArgs,
//         orderBy: orderBy,
//         limit: limit,
//       );
//       final tasks = maps.map((map) => Task.fromJson(map)).toList();
//       log('Retrieved ${tasks.length} tasks with conditions');
//       return tasks;
//     } catch (e) {
//       log('Error getting tasks with conditions: $e');
//       if (e is DatabaseException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to get tasks with conditions',
//         code: 2002,
//       );
//     }
//   }

//   @override
//   Future<List<Task>> getTasksByDate(DateTime date) async {
//     try {
//       final dateString = _formatDate(date);
//       log('Getting tasks for date: $dateString');
//       return await getTasksWhere(
//         where: 'date = ?',
//         whereArgs: [dateString],
//         orderBy: 'startTime ASC',
//       );
//     } catch (e) {
//       log('Error getting tasks by date: $e');
//       if (e is DatabaseException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to get tasks by date',
//         code: 2003,
//       );
//     }
//   }

//   @override
//   Future<Task> addTask(Task task) async {
//     try {
//       log('Adding new task: ${task.title}');

//       // 验证任务数据
//       _validateTask(task);

//       // 添加到本地数据库
//       final taskId = await DBHelper.insert(task);
//       final savedTask = task.copyWith(id: taskId);

//       // 设置提醒通知
//       if (savedTask.remind > 0) {
//         await _scheduleNotification(savedTask);
//       }

//       // 异步同步到服务器（不阻塞主流程）
//       _syncTaskToServer(savedTask).catchError((error) {
//         log('Failed to sync task to server: $error');
//       });

//       log('Task added successfully with ID: $taskId');
//       return savedTask;
//     } catch (e) {
//       log('Error adding task: $e');
//       if (e is DatabaseException || e is AppException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to add task',
//         code: 2004,
//       );
//     }
//   }

//   @override
//   Future<Task> updateTask(Task task) async {
//     try {
//       log('Updating task: ${task.title}');

//       // 验证任务数据
//       _validateTask(task);

//       if (task.id == null) {
//         throw const ValidationException(
//           message: 'Task ID cannot be null for update',
//           code: 2005,
//         );
//       }

//       // 更新本地数据库
//       await DBHelper.update(task);

//       // 重新调度通知
//       if (task.remind > 0) {
//         await _scheduleNotification(task);
//       } else {
//         // await _notifyHelper.cancelNotification(task.id!);
//       }

//       // 异步同步到服务器（不阻塞主流程）
//       _syncTaskToServer(task).catchError((error) {
//         log('Failed to sync updated task to server: $error');
//       });

//       log('Task updated successfully: ${task.id}');
//       return task;
//     } catch (e) {
//       log('Error updating task: $e');
//       if (e is DatabaseException || e is AppException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to update task',
//         code: 2006,
//       );
//     }
//   }

//   @override
//   Future<void> deleteTask(Task task) async {
//     try {
//       log('Deleting task: ${task.title}');

//       if (task.id == null) {
//         throw const ValidationException(
//           message: 'Task ID cannot be null for deletion',
//           code: 2007,
//         );
//       }

//       // 从本地数据库删除
//       await DBHelper.delete(task);

//       // 取消相关通知
//       // await _notifyHelper.cancelNotification(task.id!);

//       // 异步从服务器删除（不阻塞主流程）
//       _deleteTaskFromServer(task.id!).catchError((error) {
//         log('Failed to delete task from server: $error');
//       });

//       log('Task deleted successfully: ${task.id}');
//     } catch (e) {
//       log('Error deleting task: $e');
//       if (e is DatabaseException || e is AppException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to delete task',
//         code: 2008,
//       );
//     }
//   }

//   @override
//   Future<Task> markTaskCompleted(Task task) async {
//     try {
//       log('Marking task as completed: ${task.title}');

//       if (task.id == null) {
//         throw const ValidationException(
//           message: 'Task ID cannot be null for completion',
//           code: 2009,
//         );
//       }

//       final completedTask = task.copyWith(
//         isCompleted: 1,
//         updatedAt: DateTime.now(),
//       );

//       await DBHelper.update(completedTask);

//       // 取消提醒通知（任务已完成）
//       // await _notifyHelper.cancelNotification(task.id!);

//       // 异步同步到服务器（不阻塞主流程）
//       _syncTaskToServer(completedTask).catchError((error) {
//         log('Failed to sync task completion to server: $error');
//       });

//       log('Task marked as completed: ${task.id}');
//       return completedTask;
//     } catch (e) {
//       log('Error marking task as completed: $e');
//       if (e is DatabaseException || e is AppException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to mark task as completed',
//         code: 2010,
//       );
//     }
//   }

//   @override
//   Future<List<Task>> addTasks(List<Task> tasks) async {
//     try {
//       log('Adding ${tasks.length} tasks in batch');

//       if (tasks.isEmpty) {
//         return [];
//       }

//       // 验证所有任务
//       for (final task in tasks) {
//         _validateTask(task);
//       }

//       await DBHelper.insertBatch(tasks);

//       // 为所有任务调度通知
//       for (final task in tasks) {
//         if (task.remind > 0) {
//           await _scheduleNotification(task);
//         }
//       }

//       // 异步同步到服务器（不阻塞主流程）
//       for (final task in tasks) {
//         _syncTaskToServer(task).catchError((error) {
//           log('Failed to sync batch task to server: $error');
//         });
//       }

//       log('Batch added ${tasks.length} tasks successfully');
//       return tasks;
//     } catch (e) {
//       log('Error adding tasks in batch: $e');
//       if (e is DatabaseException || e is AppException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to add tasks in batch',
//         code: 2011,
//       );
//     }
//   }

//   @override
//   Future<void> deleteAllTasks() async {
//     try {
//       log('Deleting all tasks');

//       // 获取所有任务用于取消通知
//       final tasks = await getTasks();

//       // 取消所有任务的通知
//       for (final task in tasks) {
//         if (task.id != null) {
//           // await _notifyHelper.cancelNotification(task.id!);
//         }
//       }

//       // 清空本地数据
//       await DBHelper.clearAllTasks();

//       // 异步同步到服务器（不阻塞主流程）
//       for (final task in tasks) {
//         if (task.id != null) {
//           _deleteTaskFromServer(task.id!).catchError((error) {
//             log('Failed to delete task ${task.id} from server: $error');
//           });
//         }
//       }

//       log('All tasks deleted successfully');
//     } catch (e) {
//       log('Error deleting all tasks: $e');
//       if (e is DatabaseException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to delete all tasks',
//         code: 2012,
//       );
//     }
//   }

//   @override
//   Future<void> syncData() async {
//     try {
//       log('Starting data synchronization');

//       // 获取本地任务
//       final localTasks = await getTasks();

//       // 获取远程任务
//       List<Task> remoteTasks = [];
//       try {
//         remoteTasks = await _taskServices.getTasks();
//       } catch (e) {
//         log('Failed to get remote tasks: $e');
//         // 如果远程获取失败，只同步本地到远程
//         for (final task in localTasks) {
//           _syncTaskToServer(task).catchError((error) {
//             log('Failed to sync local task to server: $error');
//           });
//         }
//         return;
//       }

//       // 比较并同步数据
//       await _synchronizeTasks(localTasks, remoteTasks);

//       log('Data synchronization completed successfully');
//     } catch (e) {
//       log('Error during data synchronization: $e');
//       if (e is DatabaseException || e is NetworkException) rethrow;
//       throw const NetworkException(
//         message: 'Failed to synchronize data',
//         code: 3001,
//       );
//     }
//   }

//   /// 私有辅助方法

//   /// 验证任务数据
//   void _validateTask(Task task) {
//     if (task.title.trim().isEmpty) {
//       throw const ValidationException(
//         message: 'Task title cannot be empty',
//         code: 2013,
//       );
//     }

//     if (task.date.trim().isEmpty) {
//       throw const ValidationException(
//         message: 'Task date cannot be empty',
//         code: 2014,
//       );
//     }

//     if (task.startTime.trim().isEmpty) {
//       throw const ValidationException(
//         message: 'Task start time cannot be empty',
//         code: 2015,
//       );
//     }

//     if (task.endTime.trim().isEmpty) {
//       throw const ValidationException(
//         message: 'Task end time cannot be empty',
//         code: 2016,
//       );
//     }

//     // 验证日期格式
//     try {
//       DateTime.parse(task.date);
//     } catch (e) {
//       throw const ValidationException(
//         message: 'Invalid date format',
//         code: 2017,
//       );
//     }

//     // 验证时间格式
//     if (!_isValidTimeFormat(task.startTime) ||
//         !_isValidTimeFormat(task.endTime)) {
//       throw const ValidationException(
//         message: 'Invalid time format',
//         code: 2018,
//       );
//     }
//   }

//   /// 验证时间格式 (支持HH:mm和AM/PM格式)
//   bool _isValidTimeFormat(String time) {
//     // 使用TimeUtil验证时间格式，支持多种格式
//     return TimeUtil.isValidTimeFormat(time);
//   }

//   /// 格式化日期为字符串
//   String _formatDate(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   /// 为任务调度通知
//   Future<void> _scheduleNotification(Task task) async {
//     try {
//       if (task.remind > 0 && task.id != null) {
//         final notificationTime = _calculateNotificationTime(task);
//         if (notificationTime.isAfter(DateTime.now())) {
//           // await _notifyHelper.scheduledNotification(
//           //   id: task.id!,
//           //   title: 'Task Reminder',
//           //   body: task.title,
//           //   scheduledTime: notificationTime,
//           // );
//           log('Notification scheduled for task ${task.id} at $notificationTime');
//         }
//       }
//     } catch (e) {
//       log('Failed to schedule notification for task ${task.id}: $e');
//       // 通知调度失败不应该影响任务操作
//     }
//   }

//   /// 计算通知时间
//   DateTime _calculateNotificationTime(Task task) {
//     try {
//       // 解析任务日期和时间
//       final taskDateTime = DateTime.parse('${task.date} ${task.startTime}:00');

//       // 根据提醒时间提前通知
//       return taskDateTime.subtract(Duration(minutes: task.remind));
//     } catch (e) {
//       log('Error calculating notification time: $e');
//       // 如果解析失败，返回当前时间加1分钟
//       return DateTime.now().add(const Duration(minutes: 1));
//     }
//   }

//   /// 同步任务到服务器
//   Future<void> _syncTaskToServer(Task task) async {
//     try {
//       await _taskServices.syncTask(task);
//       log('Task synced to server: ${task.id}');
//     } catch (e) {
//       log('Failed to sync task to server: $e');
//       rethrow;
//     }
//   }

//   /// 从服务器删除任务
//   Future<void> _deleteTaskFromServer(int taskId) async {
//     try {
//       await _taskServices.deleteTask(taskId.toString());
//       log('Task deleted from server: $taskId');
//     } catch (e) {
//       log('Failed to delete task from server: $e');
//       rethrow;
//     }
//   }

//   /// 同步本地和远程任务
//   Future<void> _synchronizeTasks(
//       List<Task> localTasks, List<Task> remoteTasks) async {
//     try {
//       log('Synchronizing ${localTasks.length} local tasks with ${remoteTasks.length} remote tasks');

//       // 创建任务映射以便快速查找
//       final localTaskMap = <int, Task>{};
//       for (final task in localTasks) {
//         if (task.id != null) {
//           localTaskMap[task.id!] = task;
//         }
//       }

//       final remoteTaskMap = <int, Task>{};
//       for (final task in remoteTasks) {
//         if (task.id != null) {
//           remoteTaskMap[task.id!] = task;
//         }
//       }

//       // 处理远程任务（添加或更新本地）
//       for (final remoteTask in remoteTasks) {
//         if (remoteTask.id != null) {
//           final localTask = localTaskMap[remoteTask.id!];
//           if (localTask == null) {
//             // 远程任务在本地不存在，添加到本地
//             await DBHelper.insert(remoteTask);
//             log('Added remote task to local: ${remoteTask.id}');
//           } else if (_shouldUpdateLocalTask(localTask, remoteTask)) {
//             // 远程任务更新，更新本地
//             await DBHelper.update(remoteTask);
//             log('Updated local task from remote: ${remoteTask.id}');
//           }
//         }
//       }

//       // 处理本地独有的任务（同步到远程）
//       for (final localTask in localTasks) {
//         if (localTask.id != null && !remoteTaskMap.containsKey(localTask.id!)) {
//           // 本地任务在远程不存在，同步到远程
//           _syncTaskToServer(localTask).catchError((error) {
//             log('Failed to sync local task to remote: $error');
//           });
//         }
//       }

//       log('Task synchronization completed');
//     } catch (e) {
//       log('Error synchronizing tasks: $e');
//       rethrow;
//     }
//   }

//   /// 判断是否应该更新本地任务
//   bool _shouldUpdateLocalTask(Task localTask, Task remoteTask) {
//     // 比较更新时间，如果远程任务更新时间更晚，则更新本地
//     if (remoteTask.updatedAt != null && localTask.updatedAt != null) {
//       try {
//         final remoteTime = remoteTask.updatedAt is DateTime
//             ? remoteTask.updatedAt as DateTime
//             : DateTime.parse(remoteTask.updatedAt.toString());
//         final localTime = localTask.updatedAt is DateTime
//             ? localTask.updatedAt as DateTime
//             : DateTime.parse(localTask.updatedAt.toString());
//         return remoteTime.isAfter(localTime);
//       } catch (e) {
//         log('Error comparing task update times: $e');
//       }
//     }
//     // 如果无法比较时间，默认不更新
//     return false;
//   }

//   @override
//   Future<void> clearAllTasks() async {
//     // clearAllTasks是deleteAllTasks的别名方法
//     await deleteAllTasks();
//   }

//   @override
//   Future<void> bulkInsertTasks(List<Task> tasks) async {
//     try {
//       log('Bulk inserting ${tasks.length} tasks');

//       for (final task in tasks) {
//         await addTask(task);
//       }

//       log('Bulk insert completed successfully');
//     } catch (e) {
//       log('Error bulk inserting tasks: $e');
//       if (e is DatabaseException) rethrow;
//       throw const DatabaseException(
//         message: 'Failed to bulk insert tasks',
//         code: 2013,
//       );
//     }
//   }
// }
