import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_provider.dart';
import 'task_provider.dart';
import '../../data/repositories/task_repository.dart';
import '../dependency_injection.dart';

/// Provider配置类
/// 负责设置和管理所有Provider的依赖注入
class ProviderSetup {
  /// 创建MultiProvider配置
  static Widget createProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        // TaskProvider
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(
            taskRepository: ServiceLocator.get<TaskRepository>(),
          ),
        ),
        
        // CalendarProvider
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            taskRepository: ServiceLocator.get<TaskRepository>(),
          ),
        ),
        
        // ProxyProvider for cross-provider dependencies
        ChangeNotifierProxyProvider<TaskProvider, CalendarProvider>(
          create: (context) => CalendarProvider(
            taskRepository: ServiceLocator.get<TaskRepository>(),
          ),
          update: (context, taskProvider, calendarProvider) {
            // 当TaskProvider更新时，通知CalendarProvider刷新
            if (calendarProvider != null) {
              // 可以在这里添加跨Provider的数据同步逻辑
              return calendarProvider;
            }
            return CalendarProvider(
              taskRepository: ServiceLocator.get<TaskRepository>(),
            );
          },
        ),
      ],
      child: child,
    );
  }

  /// 初始化所有Provider
  static Future<void> initializeProviders(BuildContext context) async {
    try {
      // 初始化TaskProvider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.initialize();
      
      // 初始化CalendarProvider
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      await calendarProvider.initialize();
      
      debugPrint('All providers initialized successfully');
    } catch (e) {
      debugPrint('Error initializing providers: $e');
      rethrow;
    }
  }

  /// 获取TaskProvider实例
  static TaskProvider getTaskProvider(BuildContext context, {bool listen = true}) {
    return Provider.of<TaskProvider>(context, listen: listen);
  }

  /// 获取CalendarProvider实例
  static CalendarProvider getCalendarProvider(BuildContext context, {bool listen = true}) {
    return Provider.of<CalendarProvider>(context, listen: listen);
  }

  /// 清理所有Provider资源
  static void disposeProviders(BuildContext context) {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      
      taskProvider.dispose();
      calendarProvider.dispose();
      
      debugPrint('All providers disposed successfully');
    } catch (e) {
      debugPrint('Error disposing providers: $e');
    }
  }
}

/// Provider扩展方法
extension ProviderExtensions on BuildContext {
  /// 快速获取TaskProvider
  TaskProvider get taskProvider => Provider.of<TaskProvider>(this, listen: false);
  
  /// 快速获取CalendarProvider
  CalendarProvider get calendarProvider => Provider.of<CalendarProvider>(this, listen: false);
  
  /// 快速监听TaskProvider
  TaskProvider get watchTaskProvider => Provider.of<TaskProvider>(this, listen: true);
  
  /// 快速监听CalendarProvider
  CalendarProvider get watchCalendarProvider => Provider.of<CalendarProvider>(this, listen: true);
}

/// Provider状态管理工具类
class ProviderUtils {
  /// 同步任务数据到日历
  static Future<void> syncTasksToCalendar(BuildContext context) async {
    try {
      final taskProvider = context.taskProvider;
      final calendarProvider = context.calendarProvider;
      
      // 刷新任务数据
      await taskProvider.refreshTasks();
      
      // 刷新日历数据
      await calendarProvider.refreshTasks();
      
      debugPrint('Tasks synced to calendar successfully');
    } catch (e) {
      debugPrint('Error syncing tasks to calendar: $e');
      rethrow;
    }
  }
  
  /// 批量操作任务并同步到日历
  static Future<bool> batchTaskOperation(
    BuildContext context,
    Future<bool> Function(TaskProvider) operation,
  ) async {
    try {
      final taskProvider = context.taskProvider;
      final calendarProvider = context.calendarProvider;
      
      // 执行任务操作
      final success = await operation(taskProvider);
      
      if (success) {
        // 同步到日历
        await calendarProvider.refreshTasks();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error in batch task operation: $e');
      return false;
    }
  }
  
  /// 处理Provider错误
  static void handleProviderError(BuildContext context, String? error) {
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
  
  /// 显示Provider成功消息
  static void showProviderSuccess(BuildContext context, String? message) {
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// 清除所有Provider消息
  static void clearProviderMessages(BuildContext context) {
    context.taskProvider.clearMessages();
    // CalendarProvider没有消息需要清除
  }
}