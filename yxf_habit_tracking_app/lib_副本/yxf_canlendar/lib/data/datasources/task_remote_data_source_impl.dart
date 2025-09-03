// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../../core/error/exceptions.dart';
// import '../../core/network/network_info.dart';
// import '../../domain/entities/task_entity.dart';
// import '../models/task_model.dart';
// import 'task_remote_data_source.dart';

// /// 任务远程数据源实现
// /// 负责与远程服务器进行任务数据的同步和交互
// class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
//   final http.Client client;
//   final NetworkInfo networkInfo;
//   final String baseUrl;

//   TaskRemoteDataSourceImpl({
//     required this.client,
//     required this.networkInfo,
//     this.baseUrl = 'https://api.example.com/v1',
//   });

//   @override
//   Future<List<TaskModel>> getAllTasks() async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.get(
//         Uri.parse('$baseUrl/tasks'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = json.decode(response.body);
//         return jsonList.map((json) => TaskModel.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message: '获取任务失败: ${response.statusCode}',
//           code: 'GET_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '获取任务时发生错误: ${e.toString()}',
//         code: 'GET_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<TaskModel> getTaskById(String id) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.get(
//         Uri.parse('$baseUrl/tasks/$id'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         return TaskModel.fromJson(json);
//       } else if (response.statusCode == 404) {
//         throw const ServerException(
//           message: '任务不存在',
//           code: 'TASK_NOT_FOUND',
//         );
//       } else {
//         throw ServerException(
//           message: '获取任务失败: ${response.statusCode}',
//           code: 'GET_TASK_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '获取任务时发生错误: ${e.toString()}',
//         code: 'GET_TASK_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<TaskModel> createTask(TaskModel task) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.post(
//         Uri.parse('$baseUrl/tasks'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(task.toJson()),
//       );

//       if (response.statusCode == 201) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         return TaskModel.fromJson(json);
//       } else {
//         throw ServerException(
//           message: '创建任务失败: ${response.statusCode}',
//           code: 'CREATE_TASK_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '创建任务时发生错误: ${e.toString()}',
//         code: 'CREATE_TASK_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<TaskModel> updateTask(TaskModel task) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.put(
//         Uri.parse('$baseUrl/tasks/${task.id}'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(task.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         return TaskModel.fromJson(json);
//       } else if (response.statusCode == 404) {
//         throw const ServerException(
//           message: '任务不存在',
//           code: 'TASK_NOT_FOUND',
//         );
//       } else {
//         throw ServerException(
//           message: '更新任务失败: ${response.statusCode}',
//           code: 'UPDATE_TASK_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '更新任务时发生错误: ${e.toString()}',
//         code: 'UPDATE_TASK_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<void> deleteTask(String id) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.delete(
//         Uri.parse('$baseUrl/tasks/$id'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 204) {
//         return;
//       } else if (response.statusCode == 404) {
//         throw const ServerException(
//           message: '任务不存在',
//           code: 'TASK_NOT_FOUND',
//         );
//       } else {
//         throw ServerException(
//           message: '删除任务失败: ${response.statusCode}',
//           code: 'DELETE_TASK_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '删除任务时发生错误: ${e.toString()}',
//         code: 'DELETE_TASK_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> syncTasks(List<TaskModel> localTasks) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.post(
//         Uri.parse('$baseUrl/tasks/sync'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'tasks': localTasks.map((task) => task.toJson()).toList(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final List<dynamic> tasksJson = responseData['tasks'] ?? [];
//         return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message: '同步任务失败: ${response.statusCode}',
//           code: 'SYNC_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '同步任务时发生错误: ${e.toString()}',
//         code: 'SYNC_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> getTasksByDateRange(
//       DateTime startDate, DateTime endDate) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.get(
//         Uri.parse(
//             '$baseUrl/tasks/range?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = json.decode(response.body);
//         return jsonList.map((json) => TaskModel.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message: '获取日期范围任务失败: ${response.statusCode}',
//           code: 'GET_TASKS_BY_DATE_RANGE_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '获取日期范围任务时发生错误: ${e.toString()}',
//         code: 'GET_TASKS_BY_DATE_RANGE_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<List<TaskModel>> searchTasks(String query) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.get(
//         Uri.parse('$baseUrl/tasks/search?q=${Uri.encodeComponent(query)}'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = json.decode(response.body);
//         return jsonList.map((json) => TaskModel.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message: '搜索任务失败: ${response.statusCode}',
//           code: 'SEARCH_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '搜索任务时发生错误: ${e.toString()}',
//         code: 'SEARCH_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<void> batchCreateTasks(List<TaskModel> tasks) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.post(
//         Uri.parse('$baseUrl/tasks/batch'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'tasks': tasks.map((task) => task.toJson()).toList(),
//         }),
//       );

//       if (response.statusCode != 201) {
//         throw ServerException(
//           message: '批量创建任务失败: ${response.statusCode}',
//           code: 'BATCH_CREATE_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '批量创建任务时发生错误: ${e.toString()}',
//         code: 'BATCH_CREATE_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<void> batchUpdateTasks(List<TaskModel> tasks) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.put(
//         Uri.parse('$baseUrl/tasks/batch'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'tasks': tasks.map((task) => task.toJson()).toList(),
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw ServerException(
//           message: '批量更新任务失败: ${response.statusCode}',
//           code: 'BATCH_UPDATE_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '批量更新任务时发生错误: ${e.toString()}',
//         code: 'BATCH_UPDATE_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<void> batchDeleteTasks(List<String> taskIds) async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.delete(
//         Uri.parse('$baseUrl/tasks/batch'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'taskIds': taskIds,
//         }),
//       );

//       if (response.statusCode != 204) {
//         throw ServerException(
//           message: '批量删除任务失败: ${response.statusCode}',
//           code: 'BATCH_DELETE_TASKS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '批量删除任务时发生错误: ${e.toString()}',
//         code: 'BATCH_DELETE_TASKS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> getServerStatus() async {
//     if (!await networkInfo.isConnected) {
//       throw const NetworkException(
//         message: '网络连接不可用',
//         code: 'NO_NETWORK',
//       );
//     }

//     try {
//       final response = await client.get(
//         Uri.parse('$baseUrl/status'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw ServerException(
//           message: '获取服务器状态失败: ${response.statusCode}',
//           code: 'GET_SERVER_STATUS_FAILED',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: '获取服务器状态时发生错误: ${e.toString()}',
//         code: 'GET_SERVER_STATUS_ERROR',
//         originalError: e,
//       );
//     }
//   }

//   @override
//   Future<bool> testConnection() async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return false;
//       }

//       final response = await client.get(
//         Uri.parse('$baseUrl/ping'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 5));

//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }
// }
