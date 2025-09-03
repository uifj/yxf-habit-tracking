import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';
import '../../data/models/task.dart';
import '../error/exceptions.dart';

/// SharedPreferences数据库帮助类
/// 负责管理基于SharedPreferences的数据存储和基本操作
class SharedPrefsHelper {
  static SharedPreferences? _prefs;
  static const String _tasksKey = 'hunnu_tasks';
  static const String _nextIdKey = 'hunnu_tasks_next_id';

  /// 初始化SharedPreferences
  static Future<void> initDb() async {
    if (_prefs != null) {
      return;
    }
    try {
      _prefs = await SharedPreferences.getInstance();
      log('SharedPreferences initialized successfully');
    } catch (e) {
      log('Error initializing SharedPreferences: $e');
      throw const DatabaseException(
        message: 'Failed to initialize SharedPreferences',
      );
    }
  }

  /// 获取下一个可用的ID
  static Future<int> _getNextId() async {
    await initDb();
    if (_prefs == null) {
      throw const DatabaseException(
        message: 'SharedPreferences not initialized',
      );
    }

    int nextId = _prefs!.getInt(_nextIdKey) ?? 1;
    await _prefs!.setInt(_nextIdKey, nextId + 1);
    return nextId;
  }

  /// 获取所有任务
  static Future<List<Task>> _getAllTasks() async {
    await initDb();
    if (_prefs == null) {
      throw const DatabaseException(
        message: 'SharedPreferences not initialized',
      );
    }

    final tasksJson = _prefs!.getString(_tasksKey);
    if (tasksJson == null || tasksJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> tasksList = json.decode(tasksJson);
      return tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      log('Error parsing tasks from SharedPreferences: $e');
      return [];
    }
  }

  /// 保存所有任务
  static Future<void> _saveAllTasks(List<Task> tasks) async {
    await initDb();
    if (_prefs == null) {
      throw const DatabaseException(
        message: 'SharedPreferences not initialized',
      );
    }

    try {
      final tasksJson =
          json.encode(tasks.map((task) => task.toJson()).toList());
      await _prefs!.setString(_tasksKey, tasksJson);
    } catch (e) {
      log('Error saving tasks to SharedPreferences: $e');
      throw const DatabaseException(
        message: 'Failed to save tasks',
      );
    }
  }

  /// 插入单个任务
  static Future<int> insert(Task task) async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      final tasks = await _getAllTasks();
      final newId = await _getNextId();

      final newTask = task.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      tasks.add(newTask);
      await _saveAllTasks(tasks);

      log('Task inserted with ID: $newId');
      return newId;
    } catch (e) {
      log('Error inserting task: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to insert task',
      );
    }
  }

  /// 查询所有任务
  static Future<List<Map<String, dynamic>>> query() async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      final tasks = await _getAllTasks();
      // 按创建时间降序排列
      tasks.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      final result = tasks.map((task) => task.toJson()).toList();
      log('Retrieved ${result.length} tasks from SharedPreferences');
      return result;
    } catch (e) {
      log('Error querying tasks: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to query tasks',
      );
    }
  }

  /// 根据条件查询任务
  static Future<List<Map<String, dynamic>>> queryWhere({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      final tasks = await _getAllTasks();
      List<Task> filteredTasks = tasks;

      // 简单的where条件处理（仅支持基本的等值查询）
      if (where != null && whereArgs != null) {
        if (where.contains('id = ?') && whereArgs.isNotEmpty) {
          final id = whereArgs[0];
          filteredTasks = tasks.where((task) => task.id == id).toList();
        } else if (where.contains('userId = ?') && whereArgs.isNotEmpty) {
          final userId = whereArgs[0];
          filteredTasks = tasks.where((task) => task.userId == userId).toList();
        } else if (where.contains('isCompleted = ?') && whereArgs.isNotEmpty) {
          final isCompleted = whereArgs[0];
          filteredTasks =
              tasks.where((task) => task.isCompleted == isCompleted).toList();
        } else if (where.contains('date = ?') && whereArgs.isNotEmpty) {
          final date = whereArgs[0];
          filteredTasks = tasks.where((task) => task.date == date).toList();
        }
      }

      // 排序处理
      if (orderBy != null) {
        if (orderBy.contains('createdAt DESC')) {
          filteredTasks.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
        } else if (orderBy.contains('createdAt ASC')) {
          filteredTasks.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return a.createdAt!.compareTo(b.createdAt!);
          });
        }
      } else {
        // 默认按创建时间降序
        filteredTasks.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      }

      // 限制结果数量
      if (limit != null && limit > 0) {
        filteredTasks = filteredTasks.take(limit).toList();
      }

      final result = filteredTasks.map((task) => task.toJson()).toList();
      log('Retrieved ${result.length} tasks with conditions');
      return result;
    } catch (e) {
      log('Error querying tasks with conditions: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to query tasks with conditions',
      );
    }
  }

  /// 删除任务
  static Future<int> delete(Task task) async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      if (task.id == null) {
        throw const DatabaseException(
          message: 'Task ID cannot be null for deletion',
        );
      }

      final tasks = await _getAllTasks();
      final initialLength = tasks.length;
      tasks.removeWhere((t) => t.id == task.id);

      if (tasks.length == initialLength) {
        // 没有找到要删除的任务
        return 0;
      }

      await _saveAllTasks(tasks);
      log('Deleted task with ID: ${task.id}');
      return 1;
    } catch (e) {
      log('Error deleting task: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to delete task',
      );
    }
  }

  /// 更新任务
  static Future<int> update(Task task) async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      if (task.id == null) {
        throw const DatabaseException(
          message: 'Task ID cannot be null for update',
        );
      }

      final tasks = await _getAllTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);

      if (index == -1) {
        // 没有找到要更新的任务
        return 0;
      }

      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      tasks[index] = updatedTask;
      await _saveAllTasks(tasks);

      log('Updated task with ID: ${task.id}');
      return 1;
    } catch (e) {
      log('Error updating task: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to update task',
      );
    }
  }

  /// 批量插入任务
  static Future<int> insertBatch(List<Task> tasks) async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      if (tasks.isEmpty) {
        log('No tasks to insert');
        return 0;
      }

      final existingTasks = await _getAllTasks();
      final now = DateTime.now();

      for (var task in tasks) {
        final newId = await _getNextId();
        final newTask = task.copyWith(
          id: newId,
          createdAt: now,
          updatedAt: now,
        );
        existingTasks.add(newTask);
      }

      await _saveAllTasks(existingTasks);
      log('Batch inserted ${tasks.length} tasks');
      return tasks.length;
    } catch (e) {
      log('Error batch inserting tasks: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to batch insert tasks',
      );
    }
  }

  /// 删除所有任务
  static Future<void> deleteAllTasks() async {
    try {
      await initDb();
      if (_prefs == null) {
        throw const DatabaseException(
          message: 'SharedPreferences not initialized',
        );
      }

      await _prefs!.remove(_tasksKey);
      await _prefs!.remove(_nextIdKey);
      log('All tasks deleted from SharedPreferences');
    } catch (e) {
      log('Error deleting all tasks: $e');
      if (e is DatabaseException) rethrow;
      throw const DatabaseException(
        message: 'Failed to delete all tasks',
      );
    }
  }

  /// 清空所有任务（deleteAllTasks的别名）
  static Future<void> clearAllTasks() async {
    await deleteAllTasks();
  }

  /// 关闭数据库连接（SharedPreferences不需要关闭，但保持接口一致性）
  static Future<void> close() async {
    try {
      // SharedPreferences不需要显式关闭
      _prefs = null;
      log('SharedPreferences connection closed');
    } catch (e) {
      log('Error closing SharedPreferences: $e');
    }
  }

  /// 获取SharedPreferences实例（仅用于测试）
  static SharedPreferences? get preferences => _prefs;

  /// 检查SharedPreferences是否已初始化
  static bool get isInitialized => _prefs != null;

  /// 获取存储的任务数量
  static Future<int> getTaskCount() async {
    try {
      final tasks = await _getAllTasks();
      return tasks.length;
    } catch (e) {
      log('Error getting task count: $e');
      return 0;
    }
  }

  /// 根据ID查找任务
  static Future<Task?> findTaskById(int id) async {
    try {
      final tasks = await _getAllTasks();
      final task = tasks.where((t) => t.id == id).firstOrNull;
      return task;
    } catch (e) {
      log('Error finding task by ID: $e');
      return null;
    }
  }

  /// 检查任务是否存在
  static Future<bool> taskExists(int id) async {
    try {
      final task = await findTaskById(id);
      return task != null;
    } catch (e) {
      log('Error checking if task exists: $e');
      return false;
    }
  }
}
