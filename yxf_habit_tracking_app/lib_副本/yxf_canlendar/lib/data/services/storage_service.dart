import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/custom_tag.dart';
import '../models/timer_session.dart';

/// 数据存储服务
/// 负责JSON数据的保存、加载和导出
class StorageService {
  static const String _tasksKey = 'daily_tasks';
  static const String _habitsKey = 'habits';
  static const String _tagsKey = 'custom_tags';
  static const String _timerSessionsKey = 'timer_sessions';
  static const String _settingsKey = 'app_settings';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  /// 保存任务数据
  Future<void> saveTasks(Map<String, List<Task>> dailyTasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> tasksJson = {};
      
      dailyTasks.forEach((dateKey, tasks) {
        tasksJson[dateKey] = tasks.map((task) => task.toJson()).toList();
      });
      
      await prefs.setString(_tasksKey, jsonEncode(tasksJson));
    } catch (e) {
      throw Exception('保存任务数据失败: $e');
    }
  }

  /// 加载任务数据
  Future<Map<String, List<Task>>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksString = prefs.getString(_tasksKey);
      
      if (tasksString == null) return {};
      
      final Map<String, dynamic> tasksJson = jsonDecode(tasksString);
      final Map<String, List<Task>> dailyTasks = {};
      
      tasksJson.forEach((dateKey, tasksList) {
        dailyTasks[dateKey] = (tasksList as List)
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();
      });
      
      return dailyTasks;
    } catch (e) {
      throw Exception('加载任务数据失败: $e');
    }
  }

  /// 保存习惯数据
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> habitsJson = 
          habits.map((habit) => habit.toJson()).toList();
      
      await prefs.setString(_habitsKey, jsonEncode(habitsJson));
    } catch (e) {
      throw Exception('保存习惯数据失败: $e');
    }
  }

  /// 加载习惯数据
  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? habitsString = prefs.getString(_habitsKey);
      
      if (habitsString == null) return [];
      
      final List<dynamic> habitsJson = jsonDecode(habitsString);
      return habitsJson.map((habitJson) => Habit.fromJson(habitJson)).toList();
    } catch (e) {
      throw Exception('加载习惯数据失败: $e');
    }
  }

  /// 保存标签数据
  Future<void> saveTags(List<CustomTag> tags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> tagsJson = 
          tags.map((tag) => tag.toJson()).toList();
      
      await prefs.setString(_tagsKey, jsonEncode(tagsJson));
    } catch (e) {
      throw Exception('保存标签数据失败: $e');
    }
  }

  /// 加载标签数据
  Future<List<CustomTag>> loadTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tagsString = prefs.getString(_tagsKey);
      
      if (tagsString == null) return [];
      
      final List<dynamic> tagsJson = jsonDecode(tagsString);
      return tagsJson.map((tagJson) => CustomTag.fromJson(tagJson)).toList();
    } catch (e) {
      throw Exception('加载标签数据失败: $e');
    }
  }

  /// 保存计时器会话数据
  Future<void> saveTimerSessions(List<TimerSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> sessionsJson = 
          sessions.map((session) => session.toJson()).toList();
      
      await prefs.setString(_timerSessionsKey, jsonEncode(sessionsJson));
    } catch (e) {
      throw Exception('保存计时器会话数据失败: $e');
    }
  }

  /// 加载计时器会话数据
  Future<List<TimerSession>> loadTimerSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionsString = prefs.getString(_timerSessionsKey);
      
      if (sessionsString == null) return [];
      
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      return sessionsJson.map((sessionJson) => TimerSession.fromJson(sessionJson)).toList();
    } catch (e) {
      throw Exception('加载计时器会话数据失败: $e');
    }
  }

  /// 保存应用设置
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      throw Exception('保存应用设置失败: $e');
    }
  }

  /// 加载应用设置
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsString = prefs.getString(_settingsKey);
      
      if (settingsString == null) return {};
      
      return jsonDecode(settingsString);
    } catch (e) {
      throw Exception('加载应用设置失败: $e');
    }
  }

  /// 导出所有数据到JSON文件
  Future<String> exportAllData() async {
    try {
      final tasks = await loadTasks();
      final habits = await loadHabits();
      final tags = await loadTags();
      final sessions = await loadTimerSessions();
      final settings = await loadSettings();
      
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'data': {
          'tasks': tasks.map((key, value) => MapEntry(key, value.map((task) => task.toJson()).toList())),
          'habits': habits.map((habit) => habit.toJson()).toList(),
          'tags': tags.map((tag) => tag.toJson()).toList(),
          'timerSessions': sessions.map((session) => session.toJson()).toList(),
          'settings': settings,
        }
      };
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'priospace_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonEncode(exportData));
      return file.path;
    } catch (e) {
      throw Exception('导出数据失败: $e');
    }
  }

  /// 从JSON文件导入数据
  Future<void> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }
      
      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString);
      
      if (importData['data'] == null) {
        throw Exception('无效的备份文件格式');
      }
      
      final data = importData['data'];
      
      // 导入任务数据
      if (data['tasks'] != null) {
        final Map<String, List<Task>> tasks = {};
        (data['tasks'] as Map<String, dynamic>).forEach((key, value) {
          tasks[key] = (value as List).map((taskJson) => Task.fromJson(taskJson)).toList();
        });
        await saveTasks(tasks);
      }
      
      // 导入习惯数据
      if (data['habits'] != null) {
        final habits = (data['habits'] as List)
            .map((habitJson) => Habit.fromJson(habitJson))
            .toList();
        await saveHabits(habits);
      }
      
      // 导入标签数据
      if (data['tags'] != null) {
        final tags = (data['tags'] as List)
            .map((tagJson) => CustomTag.fromJson(tagJson))
            .toList();
        await saveTags(tags);
      }
      
      // 导入计时器会话数据
      if (data['timerSessions'] != null) {
        final sessions = (data['timerSessions'] as List)
            .map((sessionJson) => TimerSession.fromJson(sessionJson))
            .toList();
        await saveTimerSessions(sessions);
      }
      
      // 导入设置数据
      if (data['settings'] != null) {
        await saveSettings(data['settings']);
      }
    } catch (e) {
      throw Exception('导入数据失败: $e');
    }
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
      await prefs.remove(_habitsKey);
      await prefs.remove(_tagsKey);
      await prefs.remove(_timerSessionsKey);
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw Exception('清除数据失败: $e');
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final tasks = await loadTasks();
      final habits = await loadHabits();
      final tags = await loadTags();
      final sessions = await loadTimerSessions();
      
      int totalTasks = 0;
      tasks.values.forEach((taskList) {
        totalTasks += taskList.length;
      });
      
      return {
        'totalTasks': totalTasks,
        'totalHabits': habits.length,
        'totalTags': tags.length,
        'totalSessions': sessions.length,
        'daysWithTasks': tasks.keys.length,
      };
    } catch (e) {
      throw Exception('获取存储统计失败: $e');
    }
  }
}

/// 日期格式化工具
class DateFormat {
  final String pattern;
  
  DateFormat(this.pattern);
  
  String format(DateTime date) {
    return pattern
        .replaceAll('yyyy', date.year.toString())
        .replaceAll('MM', date.month.toString().padLeft(2, '0'))
        .replaceAll('dd', date.day.toString().padLeft(2, '0'))
        .replaceAll('HH', date.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', date.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', date.second.toString().padLeft(2, '0'));
  }
}