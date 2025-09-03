// import '../../core/error/exceptions.dart';
// import '../../core/error/failures.dart';
// import '../../core/network/network_info.dart';
// import '../../domain/entities/task_entity.dart';
// import '../../domain/repositories/task_repository.dart';
// import '../datasources/task_local_data_source.dart';
// import '../datasources/task_remote_data_source.dart';
// import '../models/task_model.dart';

// /// 任务仓库实现类
// /// 实现领域层定义的任务仓库接口，协调本地和远程数据源
// class TaskRepositoryImpl implements TaskRepository {
//   final TaskLocalDataSource localDataSource;
//   final TaskRemoteDataSource remoteDataSource;
//   final NetworkInfo networkInfo;

//   TaskRepositoryImpl({
//     required this.localDataSource,
//     required this.remoteDataSource,
//     required this.networkInfo,
//   });

//   @override
//   Future<Either<Failure, List<TaskEntity>>> getTasks() async {
//     try {
//       final localTasks = await localDataSource.getTasks();
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskEntity>> getTaskById(int id) async {
//     try {
//       final taskModel = await localDataSource.getTaskById(id.toString());
//       if (taskModel == null) {
//         return Either.left(DatabaseFailure.notFound());
//       }
//       return Either.right(taskModel.toEntity());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> getTasksByDate(
//       DateTime date) async {
//     try {
//       final localTasks = await localDataSource.getTasksByDate(date);
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> getTasksByDateRange(
//     DateTime startDate,
//     DateTime endDate,
//   ) async {
//     try {
//       final localTasks =
//           await localDataSource.getTasksByDateRange(startDate, endDate);
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> getTasksByPriority(
//       TaskPriority priority) async {
//     try {
//       final localTasks = await localDataSource.getTasksByPriority(priority);
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> getTasksByStatus(
//       bool isCompleted) async {
//     try {
//       final localTasks = await localDataSource.getTasksByStatus(isCompleted);
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> searchTasks(String query) async {
//     try {
//       final localTasks = await localDataSource.searchTasks(query);
//       final entities = localTasks.map((model) => model.toEntity()).toList();
//       return Either.right(entities);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) async {
//     try {
//       final taskModel = TaskModel.fromEntity(task);
//       await localDataSource.addTask(taskModel);
//       final savedTask = taskModel;

//       // 如果有网络连接，尝试同步到远程
//       if (await networkInfo.isConnected) {
//         try {
//           final remoteTask = await remoteDataSource.addTask(savedTask);
//           final syncedTask = savedTask.copyWith(
//             remoteId: remoteTask.remoteId,
//             isSynced: true,
//           );
//           await localDataSource.updateTask(syncedTask);
//           return Either.right(syncedTask.toEntity());
//         } catch (e) {
//           // 远程同步失败，但本地保存成功
//           return Either.right(savedTask.toEntity());
//         }
//       }

//       return Either.right(savedTask.toEntity());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
//     try {
//       final taskModel = TaskModel.fromEntity(task.copyWith(
//         updatedAt: DateTime.now(),
//       ));
//       await localDataSource.updateTask(taskModel);
//       final updatedTask = taskModel;

//       // 如果有网络连接且任务已同步，尝试更新远程
//       if (await networkInfo.isConnected &&
//           task.isSynced &&
//           task.remoteId != null) {
//         try {
//           await remoteDataSource.updateTask(updatedTask);
//         } catch (e) {
//           // 远程更新失败，标记为未同步
//           final unsyncedTask = updatedTask.copyWith(isSynced: false);
//           await localDataSource.updateTask(unsyncedTask);
//           return Either.right(unsyncedTask.toEntity());
//         }
//       }

//       return Either.right(updatedTask.toEntity());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> deleteTask(int taskId) async {
//     try {
//       final task = await localDataSource.getTaskById(taskId.toString());
//       if (task == null) {
//         return Either.left(DatabaseFailure.notFound());
//       }

//       await localDataSource.deleteTask(taskId.toString());

//       // 如果有网络连接且任务已同步，尝试删除远程
//       if (await networkInfo.isConnected &&
//           task.isSynced &&
//           task.remoteId != null) {
//         try {
//           await remoteDataSource.deleteTask(task.remoteId!);
//         } catch (e) {
//           // 远程删除失败，但本地已删除
//           // 可以考虑记录到待同步删除列表
//         }
//       }

//       return Either.right(null);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> addTasks(
//       List<TaskEntity> tasks) async {
//     try {
//       final taskModels =
//           tasks.map((task) => TaskModel.fromEntity(task)).toList();
//       await localDataSource.addTasks(taskModels);
//       final savedTasks = taskModels;

//       // 如果有网络连接，尝试批量同步到远程
//       if (await networkInfo.isConnected) {
//         try {
//           final remoteTasks = await remoteDataSource.addTasks(savedTasks);
//           final syncedTasks = <TaskModel>[];

//           for (int i = 0; i < savedTasks.length; i++) {
//             final syncedTask = savedTasks[i].copyWith(
//               remoteId: remoteTasks[i].remoteId,
//               isSynced: true,
//             );
//             syncedTasks.add(syncedTask);
//           }

//           await localDataSource.updateTasks(syncedTasks);
//           return Either.right(
//               syncedTasks.map((model) => model.toEntity()).toList());
//         } catch (e) {
//           // 远程同步失败，但本地保存成功
//           return Either.right(
//               savedTasks.map((model) => model.toEntity()).toList());
//         }
//       }

//       return Either.right(savedTasks.map((model) => model.toEntity()).toList());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> updateTasks(
//       List<TaskEntity> tasks) async {
//     try {
//       final taskModels = tasks
//           .map((task) => TaskModel.fromEntity(task.copyWith(
//                 updatedAt: DateTime.now(),
//               )))
//           .toList();
//       await localDataSource.updateTasks(taskModels);
//       final updatedTasks = taskModels;

//       // 如果有网络连接，尝试批量更新远程
//       if (await networkInfo.isConnected) {
//         final syncedTasks = updatedTasks
//             .where((task) => task.isSynced && task.remoteId != null)
//             .toList();
//         if (syncedTasks.isNotEmpty) {
//           try {
//             await remoteDataSource.updateTasks(syncedTasks);
//           } catch (e) {
//             // 远程更新失败，标记为未同步
//             final unsyncedTasks = syncedTasks
//                 .map((task) => task.copyWith(isSynced: false))
//                 .toList();
//             await localDataSource.updateTasks(unsyncedTasks);
//           }
//         }
//       }

//       return Either.right(
//           updatedTasks.map((model) => model.toEntity()).toList());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> deleteTasks(List<int> taskIds) async {
//     try {
//       final tasks = <TaskModel>[];
//       for (final id in taskIds) {
//         final task = await localDataSource.getTaskById(id.toString());
//         if (task != null) {
//           tasks.add(task);
//         }
//       }

//       await localDataSource
//           .deleteTasks(taskIds.map((id) => id.toString()).toList());

//       // 如果有网络连接，尝试批量删除远程
//       if (await networkInfo.isConnected) {
//         final remoteIds = tasks
//             .where((task) => task.isSynced && task.remoteId != null)
//             .map((task) => task.remoteId!)
//             .toList();

//         if (remoteIds.isNotEmpty) {
//           try {
//             await remoteDataSource.deleteTasks(remoteIds);
//           } catch (e) {
//             // 远程删除失败，但本地已删除
//             // 可以考虑记录到待同步删除列表
//           }
//         }
//       }

//       return Either.right(null);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskEntity>> markTaskCompleted(int taskId) async {
//     try {
//       await localDataSource.markTaskCompleted(taskId.toString());
//       final completedTask =
//           await localDataSource.getTaskById(taskId.toString());

//       // 如果有网络连接且任务已同步，尝试更新远程
//       if (await networkInfo.isConnected &&
//           completedTask.isSynced &&
//           completedTask.remoteId != null) {
//         try {
//           await remoteDataSource.updateTask(completedTask);
//         } catch (e) {
//           // 远程更新失败，标记为未同步
//           final unsyncedTask = completedTask.copyWith(isSynced: false);
//           await localDataSource.updateTask(unsyncedTask);
//           return Either.right(unsyncedTask.toEntity());
//         }
//       }

//       return Either.right(completedTask.toEntity());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskEntity>> markTaskIncomplete(int taskId) async {
//     try {
//       await localDataSource.markTaskIncomplete(taskId.toString());
//       final incompleteTask =
//           await localDataSource.getTaskById(taskId.toString());

//       // 如果有网络连接且任务已同步，尝试更新远程
//       if (await networkInfo.isConnected &&
//           incompleteTask.isSynced &&
//           incompleteTask.remoteId != null) {
//         try {
//           await remoteDataSource.updateTask(incompleteTask);
//         } catch (e) {
//           // 远程更新失败，标记为未同步
//           final unsyncedTask = incompleteTask.copyWith(isSynced: false);
//           await localDataSource.updateTask(unsyncedTask);
//           return Either.right(unsyncedTask.toEntity());
//         }
//       }

//       return Either.right(incompleteTask.toEntity());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> clearAllTasks() async {
//     try {
//       await localDataSource.clearAllTasks();
//       return Either.right(null);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> syncToRemote() async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return Either.left(NetworkFailure.noConnection());
//       }

//       final unsyncedTasks = await localDataSource.getUnsyncedTasks();
//       if (unsyncedTasks.isEmpty) {
//         return Either.right(null);
//       }

//       final remoteTasks = await remoteDataSource.addTasks(unsyncedTasks);
//       final syncedTasks = <TaskModel>[];

//       for (int i = 0; i < unsyncedTasks.length; i++) {
//         final syncedTask = unsyncedTasks[i].copyWith(
//           remoteId: remoteTasks[i].remoteId,
//           isSynced: true,
//         );
//         syncedTasks.add(syncedTask);
//       }

//       await localDataSource.updateTasks(syncedTasks);
//       await localDataSource.setLastSyncTime(DateTime.now());

//       return Either.right(null);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TaskEntity>>> syncFromRemote() async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return Either.left(NetworkFailure.noConnection());
//       }

//       final lastSyncTime = await localDataSource.getLastSyncTime();
//       final localTasks = await localDataSource.getTasks();

//       final remoteTasks = await remoteDataSource.syncTasks(
//         lastSyncTime: lastSyncTime,
//         localTasks: localTasks,
//       );

//       // 合并远程任务到本地
//       final mergedTasks = <TaskModel>[];
//       for (final remoteTask in remoteTasks) {
//         final existingTask = localTasks.firstWhere(
//           (task) => task.remoteId == remoteTask.remoteId,
//           orElse: () => TaskModel.fromEntity(TaskEntity(
//             title: '',
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//           )),
//         );

//         if (existingTask.title.isEmpty) {
//           // 新任务，直接添加
//           mergedTasks.add(remoteTask);
//         } else {
//           // 现有任务，比较更新时间
//           if (remoteTask.updatedAt.isAfter(existingTask.updatedAt)) {
//             mergedTasks.add(remoteTask.copyWith(id: existingTask.id));
//           }
//         }
//       }

//       if (mergedTasks.isNotEmpty) {
//         await localDataSource.updateTasks(mergedTasks);
//       }

//       await localDataSource.setLastSyncTime(DateTime.now());

//       return Either.right(
//           mergedTasks.map((model) => model.toEntity()).toList());
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Future<Either<Failure, TaskStatistics>> getTaskStatistics() async {
//     try {
//       final statisticsData = await localDataSource.getTaskStatistics();
//       final statistics = TaskStatistics.fromJson(statisticsData);
//       return Either.right(statistics);
//     } catch (e, stackTrace) {
//       return Either.left(_handleException(e, stackTrace));
//     }
//   }

//   @override
//   Stream<List<TaskEntity>> watchTasks() {
//     return localDataSource.watchTasks().map(
//           (models) => models.map((model) => model.toEntity()).toList(),
//         );
//   }

//   @override
//   Stream<List<TaskEntity>> watchTasksByDate(DateTime date) {
//     return localDataSource.watchTasksByDate(date).map(
//           (models) => models.map((model) => model.toEntity()).toList(),
//         );
//   }

//   /// 处理异常并转换为相应的失败类型
//   Failure _handleException(dynamic exception, StackTrace stackTrace) {
//     if (exception is NetworkException) {
//       return NetworkFailure.fromException(exception, stackTrace);
//     } else if (exception is ServerException) {
//       return ServerFailure.fromException(exception, stackTrace);
//     } else if (exception is CacheException) {
//       return CacheFailure.fromException(exception, stackTrace);
//     } else if (exception is DatabaseException) {
//       return DatabaseFailure.fromException(exception, stackTrace);
//     } else if (exception is ValidationException) {
//       return ValidationFailure(
//         message: exception.message,
//         code: 'VALIDATION_ERROR',
//         fieldErrors: exception.fieldErrors ?? {},
//         originalError: exception,
//         stackTrace: stackTrace,
//       );
//     } else if (exception is PermissionException) {
//       return PermissionFailure(
//         message: exception.message,
//         code: 'PERMISSION_ERROR',
//         originalError: exception,
//         stackTrace: stackTrace,
//       );
//     } else if (exception is SyncException) {
//       return SyncFailure.fromException(exception, stackTrace);
//     } else if (exception is NotificationException) {
//       return NotificationFailure(
//         message: exception.message,
//         code: 'NOTIFICATION_ERROR',
//         originalError: exception,
//         stackTrace: stackTrace,
//       );
//     } else if (exception is Exception) {
//       return UnknownFailure.fromException(exception, stackTrace);
//     } else if (exception is Error) {
//       return UnknownFailure.fromError(exception, stackTrace);
//     } else {
//       return UnknownFailure(
//         message: '未知错误: ${exception.toString()}',
//         code: 'UNKNOWN_ERROR',
//         originalError: exception,
//         stackTrace: stackTrace,
//       );
//     }
//   }
// }
