import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../../core/error/exceptions.dart';

/// 任务服务类
/// 负责与远程服务器进行任务数据的同步
class TaskServices {
  static const String _baseUrl = 'https://api.example.com'; // 替换为实际的API地址
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client;

  TaskServices({http.Client? client}) : _client = client ?? http.Client();

  /// 添加任务到服务器
  Future<Task> addTask(Task task) async {
    try {
      log('Adding task to server: ${task.title}');

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/tasks'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(task.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        log('Task added to server successfully');
        return Task.fromJson(responseData);
      } else {
        throw ServerException(
          message: 'Failed to add task to server: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network request failed',
      );
    } catch (e) {
      log('Error adding task to server: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(
        message: 'Unknown error adding task to server',
      );
    }
  }

  /// 同步任务到服务器（添加或更新）
  Future<Task> syncTask(Task task) async {
    if (task.id == null) {
      return await addTask(task);
    } else {
      return await updateTask(task);
    }
  }

  /// 更新服务器上的任务
  Future<Task> updateTask(Task task) async {
    try {
      log('Updating task on server: ${task.id}');

      if (task.id == null) {
        throw const SyncException(
          message: 'Task ID cannot be null for update',
        );
      }

      final response = await _client
          .put(
            Uri.parse('$_baseUrl/tasks/${task.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(task.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Task updated on server successfully');
        return Task.fromJson(responseData);
      } else {
        throw ServerException(
          message: 'Failed to update task on server: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network request failed',
      );
    } catch (e) {
      log('Error updating task on server: $e');
      if (e is ServerException || e is NetworkException || e is AppException) {
        rethrow;
      }
      throw const ServerException(
        message: 'Unknown error updating task on server',
      );
    }
  }

  /// 从服务器删除任务
  Future<void> deleteTask(String id) async {
    try {
      log('Deleting task from server: $id');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/tasks/$id'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Task deleted from server successfully');
      } else {
        throw ServerException(
          message: 'Failed to delete task from server: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network request failed',
      );
    } catch (e) {
      log('Error deleting task from server: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(
        message: 'Unknown error deleting task from server',
      );
    }
  }

  /// 从服务器获取所有任务
  Future<List<Task>> getTasks() async {
    try {
      log('Fetching tasks from server');

      final response = await _client.get(
        Uri.parse('$_baseUrl/tasks'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final tasks = responseData.map((json) => Task.fromJson(json)).toList();
        log('Fetched ${tasks.length} tasks from server');
        return tasks;
      } else {
        throw ServerException(
          message: 'Failed to fetch tasks from server: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network request failed',
      );
    } catch (e) {
      log('Error fetching tasks from server: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(
        message: 'Unknown error fetching tasks from server',
      );
    }
  }

  /// 获取服务器上的任务ID列表
  Future<List<String>> getTaskIds() async {
    try {
      log('Fetching task IDs from server');

      final response = await _client.get(
        Uri.parse('$_baseUrl/tasks/ids'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final taskIds = responseData.map((id) => id.toString()).toList();
        log('Fetched ${taskIds.length} task IDs from server');
        return taskIds;
      } else {
        throw ServerException(
          message:
              'Failed to fetch task IDs from server: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network request failed',
      );
    } catch (e) {
      log('Error fetching task IDs from server: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(
        message: 'Unknown error fetching task IDs from server',
      );
    }
  }

  /// 检查服务器连接状态
  Future<bool> checkConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/health'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      log('Server connection check failed: $e');
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
