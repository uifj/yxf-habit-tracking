import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';

/// 任务本地数据源抽象接口
/// 定义本地数据存储操作的契约
abstract class TaskLocalDataSource {
  /// 获取所有任务
  Future<List<TaskModel>> getTasks();
  
  /// 根据ID获取任务
  Future<TaskModel?> getTaskById(String id);
  
  /// 根据日期获取任务
  Future<List<TaskModel>> getTasksByDate(DateTime date);
  
  /// 根据日期范围获取任务
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// 根据优先级获取任务
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority);
  
  /// 根据完成状态获取任务
  Future<List<TaskModel>> getTasksByStatus(bool isCompleted);
  
  /// 搜索任务
  Future<List<TaskModel>> searchTasks(String query);
  
  /// 添加任务
  Future<void> addTask(TaskModel task);
  
  /// 更新任务
  Future<void> updateTask(TaskModel task);
  
  /// 删除任务
  Future<void> deleteTask(String id);
  
  /// 批量添加任务
  Future<void> addTasks(List<TaskModel> tasks);
  
  /// 批量更新任务
  Future<void> updateTasks(List<TaskModel> tasks);
  
  /// 批量删除任务
  Future<void> deleteTasks(List<String> ids);
  
  /// 标记任务完成
  Future<void> markTaskCompleted(String taskId);
  
  /// 标记任务未完成
  Future<void> markTaskIncomplete(String taskId);
  
  /// 清空所有任务
  Future<void> clearAllTasks();
  
  /// 获取任务统计信息
  Future<Map<String, dynamic>> getTaskStatistics();
  
  /// 监听任务变化
  Stream<List<TaskEntity>> watchTasks();
  
  /// 监听特定日期的任务变化
  Stream<List<TaskEntity>> watchTasksByDate(DateTime date);
  
  /// 获取最后同步时间
  Future<DateTime?> getLastSyncTime();
  
  /// 设置最后同步时间
  Future<void> setLastSyncTime(DateTime syncTime);
  
  /// 获取未同步的任务
  Future<List<TaskModel>> getUnsyncedTasks();
  
  /// 标记任务为已同步
  Future<void> markTaskAsSynced(int taskId, String remoteId);
  
  /// 批量标记任务为已同步
  Future<void> markTasksAsSynced(Map<int, String> taskIdToRemoteId);
  
  /// 获取数据库版本
  Future<int> getDatabaseVersion();
  
  /// 初始化数据库
  Future<void> initializeDatabase();
  
  /// 关闭数据库连接
  Future<void> closeDatabase();
  
  /// 备份数据
  Future<void> backupData();
  
  /// 恢复数据
  Future<void> restoreData(Map<String, dynamic> data);
  
  /// 清理过期数据
  Future<void> cleanupExpiredData();
  
  /// 压缩数据库
  Future<void> compactDatabase();
  
  /// 获取数据库大小
  Future<int> getDatabaseSize();
  
  /// 验证数据完整性
  Future<bool> validateDataIntegrity();
  
  /// 修复数据
  Future<void> repairData();
}