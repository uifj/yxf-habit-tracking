import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:developer';
import '../../data/models/task.dart';
import '../error/exceptions.dart';

/// 数据库帮助类
/// 负责管理SQLite数据库的创建、升级和基本操作
class DBHelper {
  static sqflite.Database? _db;
  static const int _version = 2; // 增加版本号以支持新字段
  static const String _tableName = 'tasks';
  static const String _dbName = 'hunnu_tasks.db';

  /// 初始化数据库
  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String path = '${await sqflite.getDatabasesPath()}$_dbName';
      log('Initializing database at: $path');

      _db = await sqflite.openDatabase(
        path,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          log('Database opened successfully');
        },
      );
    } catch (e) {
      log('Error initializing database: $e');
      throw const DatabaseException(
        message: 'Failed to initialize database',
      );
    }
  }

  /// 创建数据库表
  static Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
      await db.execute(
        '''
        CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          title TEXT NOT NULL,
          note TEXT,
          date TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          priority TEXT NOT NULL DEFAULT 'Medium',
          remind INTEGER NOT NULL DEFAULT 5,
          repeat TEXT NOT NULL DEFAULT 'None',
          color INTEGER NOT NULL DEFAULT 0,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT,
          updatedAt TEXT
        )
        ''',
      );
      log('Database table created successfully');
    } catch (e) {
      log('Error creating database table: $e');
      throw const DatabaseException(
        message: 'Failed to create database table',
      );
    }
  }

  /// 数据库升级
  static Future<void> _onUpgrade(
      sqflite.Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // 添加新字段
        await db.execute('ALTER TABLE $_tableName ADD COLUMN createdAt TEXT');
        await db.execute('ALTER TABLE $_tableName ADD COLUMN updatedAt TEXT');
        log('Database upgraded from version $oldVersion to $newVersion');
      }
    } catch (e) {
      log('Error upgrading database: $e');
      throw const DatabaseException(
        message: 'Failed to upgrade database',
      );
    }
  }

  /// 插入单个任务
  static Future<int> insert(Task task) async {
    try {
      await initDb();
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      final taskData = task.toJson();
      taskData['createdAt'] = DateTime.now().toIso8601String();
      taskData['updatedAt'] = DateTime.now().toIso8601String();

      final result = await _db!.insert(_tableName, taskData);
      log('Task inserted with ID: $result');
      return result;
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      final result = await _db!.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );
      log('Retrieved ${result.length} tasks from database');
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      final result = await _db!.query(
        _tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy ?? 'createdAt DESC',
        limit: limit,
      );
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      if (task.id == null) {
        throw const DatabaseException(
          message: 'Task ID cannot be null for deletion',
        );
      }

      final result = await _db!.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [task.id],
      );
      log('Deleted task with ID: ${task.id}');
      return result;
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      if (task.id == null) {
        throw const DatabaseException(
          message: 'Task ID cannot be null for update',
        );
      }

      final taskData = task.toJson();
      taskData['updatedAt'] = DateTime.now().toIso8601String();

      final result = await _db!.update(
        _tableName,
        taskData,
        where: 'id = ?',
        whereArgs: [task.id],
      );
      log('Updated task with ID: ${task.id}');
      return result;
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      if (tasks.isEmpty) {
        log('No tasks to insert');
        return 0;
      }

      final batch = _db!.batch();
      final now = DateTime.now().toIso8601String();

      for (var task in tasks) {
        final taskData = task.toJson();
        taskData['createdAt'] = now;
        taskData['updatedAt'] = now;
        batch.insert(_tableName, taskData);
      }

      final results = await batch.commit();
      log('Batch inserted ${results.length} tasks');
      return results.length;
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
      if (_db == null) {
        throw const DatabaseException(
          message: 'Database not initialized',
        );
      }

      await _db!.delete(_tableName);
      log('All tasks deleted from database');
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

  /// 关闭数据库连接
  static Future<void> close() async {
    try {
      if (_db != null) {
        await _db!.close();
        _db = null;
        log('Database connection closed');
      }
    } catch (e) {
      log('Error closing database: $e');
    }
  }

  /// 获取数据库实例（仅用于测试）
  static sqflite.Database? get database => _db;

  /// 检查数据库是否已初始化
  static bool get isInitialized => _db != null;
}
