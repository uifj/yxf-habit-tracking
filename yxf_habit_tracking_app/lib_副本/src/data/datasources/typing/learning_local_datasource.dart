import '../../../domain/entities/typing/learning_record.dart';

/// 学习记录本地数据源抽象接口
abstract class LearningLocalDataSource {
  // ========== WordRecord 相关方法 ==========

  /// 保存单词记录
  Future<void> saveWordRecord(WordRecord record);

  /// 批量保存单词记录
  Future<void> saveWordRecords(List<WordRecord> records);

  /// 获取单词记录
  Future<WordRecord?> getWordRecord(String dictionaryId, String word);

  /// 获取字典的所有单词记录
  Future<List<WordRecord>> getWordRecords(String dictionaryId);

  /// 获取错误单词记录
  Future<List<WordRecord>> getErrorWords(
    String dictionaryId, {
    int? limit,
    int minWrongCount = 1,
  });

  /// 获取需要复习的单词
  Future<List<WordRecord>> getWordsForReview(
    String dictionaryId, {
    int? limit,
    Duration? reviewInterval,
  });

  /// 更新单词记录
  Future<void> updateWordRecord(WordRecord record);

  /// 删除单词记录
  Future<void> deleteWordRecord(String dictionaryId, String word);

  /// 删除字典的所有单词记录
  Future<void> deleteWordRecords(String dictionaryId);

  // ========== ChapterRecord 相关方法 ==========

  /// 保存章节记录
  Future<void> saveChapterRecord(ChapterRecord record);

  /// 获取章节记录
  Future<ChapterRecord?> getChapterRecord(String dictionaryId, int chapter);

  /// 获取字典的所有章节记录
  Future<List<ChapterRecord>> getChapterRecords(String dictionaryId);

  /// 获取最近的章节记录
  Future<List<ChapterRecord>> getRecentChapterRecords({
    int limit = 10,
    String? dictionaryId,
  });

  /// 更新章节记录
  Future<void> updateChapterRecord(ChapterRecord record);

  /// 删除章节记录
  Future<void> deleteChapterRecord(String dictionaryId, int chapter);

  /// 删除字典的所有章节记录
  Future<void> deleteChapterRecords(String dictionaryId);

  // ========== ReviewRecord 相关方法 ==========

  /// 保存复习记录
  Future<void> saveReviewRecord(ReviewRecord record);

  /// 获取复习记录
  Future<List<ReviewRecord>> getReviewRecords(
    String dictionaryId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取最近的复习记录
  Future<List<ReviewRecord>> getRecentReviewRecords({int limit = 10});

  /// 删除复习记录
  Future<void> deleteReviewRecord(String id);

  /// 删除字典的所有复习记录
  Future<void> deleteReviewRecords(String dictionaryId);

  // ========== LearningStatistics 相关方法 ==========

  /// 获取学习统计
  Future<LearningStatistics> getLearningStatistics();

  /// 更新学习统计
  Future<void> updateLearningStatistics(LearningStatistics statistics);

  /// 获取每日学习统计
  Future<Map<DateTime, LearningStatistics>> getDailyLearningStats(
    DateTime startDate,
    DateTime endDate,
  );

  /// 获取学习趋势数据
  Future<List<Map<String, dynamic>>> getLearningTrends(
    DateTime startDate,
    DateTime endDate,
    String metric, // 'wpm', 'accuracy', 'studyTime'
  );

  /// 获取WPM历史记录
  Future<List<Map<String, dynamic>>> getWpmHistory(
    DateTime startDate,
    DateTime endDate, {
    String? dictionaryId,
  });

  /// 获取准确率历史记录
  Future<List<Map<String, dynamic>>> getAccuracyHistory(
    DateTime startDate,
    DateTime endDate, {
    String? dictionaryId,
  });

  /// 获取字符错误统计
  Future<Map<String, int>> getCharacterMistakeStats({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取学习排行榜数据
  Future<List<Map<String, dynamic>>> getLeaderboardData(
      String metric, // 'wpm', 'accuracy', 'studyTime'
      String period, // 'daily', 'weekly', 'monthly', 'all'
      {int limit = 10});

  /// 获取个人最佳记录
  Future<Map<String, dynamic>> getPersonalBestRecords();

  /// 获取学习成就数据
  Future<List<Map<String, dynamic>>> getAchievements();

  /// 更新学习成就
  Future<void> updateAchievement(String achievementId, bool unlocked);

  // ========== 数据管理方法 ==========

  /// 删除所有学习数据
  Future<void> clearAllLearningData();

  /// 删除指定日期范围的数据
  Future<void> deleteLearningDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 导出学习数据
  Future<Map<String, dynamic>> exportLearningData({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 导入学习数据
  Future<void> importLearningData(Map<String, dynamic> data);

  /// 备份学习数据
  Future<Map<String, dynamic>> backupLearningData();

  /// 恢复学习数据
  Future<void> restoreLearningData(Map<String, dynamic> backupData);

  /// 获取数据库大小
  Future<int> getDatabaseSize();

  /// 压缩数据库
  Future<void> compactDatabase();

  /// 修复数据库
  Future<void> repairDatabase();

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getDatabaseStats();

  /// 清理过期数据
  Future<void> cleanupExpiredData(Duration retentionPeriod);

  /// 优化数据库性能
  Future<void> optimizeDatabase();
}
