import '../models/task_model.dart';

/// 任务远程数据源抽象接口
/// 定义与远程服务器交互的契约
abstract class TaskRemoteDataSource {
  /// 获取所有任务
  Future<List<TaskModel>> getTasks();
  
  /// 根据ID获取任务
  Future<TaskModel?> getTaskById(String remoteId);
  
  /// 根据用户ID获取任务
  Future<List<TaskModel>> getTasksByUserId(String userId);
  
  /// 根据日期获取任务
  Future<List<TaskModel>> getTasksByDate(DateTime date);
  
  /// 根据日期范围获取任务
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// 搜索任务
  Future<List<TaskModel>> searchTasks(String query);
  
  /// 添加任务
  Future<TaskModel> addTask(TaskModel task);
  
  /// 更新任务
  Future<TaskModel> updateTask(TaskModel task);
  
  /// 删除任务
  Future<void> deleteTask(String remoteId);
  
  /// 批量添加任务
  Future<List<TaskModel>> addTasks(List<TaskModel> tasks);
  
  /// 批量更新任务
  Future<List<TaskModel>> updateTasks(List<TaskModel> tasks);
  
  /// 批量删除任务
  Future<void> deleteTasks(List<String> remoteIds);
  
  /// 同步任务数据
  /// 返回服务器上的最新任务列表
  Future<List<TaskModel>> syncTasks({
    DateTime? lastSyncTime,
    List<TaskModel>? localTasks,
  });
  
  /// 获取服务器时间
  Future<DateTime> getServerTime();
  
  /// 检查网络连接
  Future<bool> checkConnection();
  
  /// 上传任务附件
  Future<String> uploadAttachment(String filePath);
  
  /// 下载任务附件
  Future<String> downloadAttachment(String attachmentUrl, String savePath);
  
  /// 删除任务附件
  Future<void> deleteAttachment(String attachmentUrl);
  
  /// 获取用户配置
  Future<Map<String, dynamic>> getUserSettings();
  
  /// 更新用户配置
  Future<void> updateUserSettings(Map<String, dynamic> settings);
  
  /// 获取任务统计信息
  Future<Map<String, dynamic>> getTaskStatistics();
  
  /// 获取任务变更历史
  Future<List<Map<String, dynamic>>> getTaskHistory(String remoteId);
  
  /// 恢复已删除的任务
  Future<TaskModel> restoreTask(String remoteId);
  
  /// 永久删除任务
  Future<void> permanentlyDeleteTask(String remoteId);
  
  /// 分享任务
  Future<String> shareTask(String remoteId, List<String> userIds);
  
  /// 取消分享任务
  Future<void> unshareTask(String remoteId, List<String> userIds);
  
  /// 获取分享的任务
  Future<List<TaskModel>> getSharedTasks();
  
  /// 接受分享的任务
  Future<TaskModel> acceptSharedTask(String shareId);
  
  /// 拒绝分享的任务
  Future<void> rejectSharedTask(String shareId);
  
  /// 获取任务评论
  Future<List<Map<String, dynamic>>> getTaskComments(String remoteId);
  
  /// 添加任务评论
  Future<Map<String, dynamic>> addTaskComment(String remoteId, String comment);
  
  /// 删除任务评论
  Future<void> deleteTaskComment(String commentId);
  
  /// 获取任务标签
  Future<List<String>> getTaskTags();
  
  /// 创建任务标签
  Future<String> createTaskTag(String tagName, String color);
  
  /// 删除任务标签
  Future<void> deleteTaskTag(String tagId);
  
  /// 获取任务模板
  Future<List<TaskModel>> getTaskTemplates();
  
  /// 创建任务模板
  Future<TaskModel> createTaskTemplate(TaskModel template);
  
  /// 删除任务模板
  Future<void> deleteTaskTemplate(String templateId);
  
  /// 从模板创建任务
  Future<TaskModel> createTaskFromTemplate(String templateId, Map<String, dynamic> overrides);
  
  /// 导出任务数据
  Future<String> exportTasks({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'json', // json, csv, pdf
  });
  
  /// 导入任务数据
  Future<List<TaskModel>> importTasks(String data, String format);
  
  /// 获取API版本信息
  Future<Map<String, dynamic>> getApiVersion();
  
  /// 检查更新
  Future<Map<String, dynamic>> checkForUpdates();
  
  /// 发送反馈
  Future<void> sendFeedback(String feedback, String category);
  
  /// 报告错误
  Future<void> reportError(String error, Map<String, dynamic> context);
  
  /// 获取使用统计
  Future<Map<String, dynamic>> getUsageStatistics();
  
  /// 上传使用统计
  Future<void> uploadUsageStatistics(Map<String, dynamic> statistics);
  
  /// 获取通知设置
  Future<Map<String, dynamic>> getNotificationSettings();
  
  /// 更新通知设置
  Future<void> updateNotificationSettings(Map<String, dynamic> settings);
  
  /// 注册推送通知
  Future<void> registerPushNotification(String deviceToken);
  
  /// 取消注册推送通知
  Future<void> unregisterPushNotification(String deviceToken);
  
  /// 发送测试通知
  Future<void> sendTestNotification();
  
  /// 获取服务器状态
  Future<Map<String, dynamic>> getServerStatus();
  
  /// 心跳检测
  Future<bool> heartbeat();
}