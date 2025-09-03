import '../../entities/typing/learning_record.dart';

/// 学习记录仓储接口
abstract class LearningRepository {
  /// 保存单词记录
  Future<int> saveWordRecord(WordRecord record);

  /// 保存章节记录
  Future<int> saveChapterRecord(ChapterRecord record);

  /// 保存复习记录
  Future<int> saveReviewRecord(ReviewRecord record);

  /// 获取单词记录
  Future<WordRecord?> getWordRecord(int id);

  /// 获取章节记录
  Future<ChapterRecord?> getChapterRecord(int id);

  /// 获取复习记录
  Future<ReviewRecord?> getReviewRecord(int id);

  /// 获取用户的所有单词记录
  Future<List<WordRecord>> getAllWordRecords({
    String? dictionaryId,
    int? chapterIndex,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// 获取用户的所有章节记录
  Future<List<ChapterRecord>> getAllChapterRecords({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// 获取用户的所有复习记录
  Future<List<ReviewRecord>> getAllReviewRecords({
    String? dictionaryId,
    bool? isFinished,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// 获取特定词典的单词记录
  Future<List<WordRecord>> getWordRecordsByDictionary(String dictionaryId);

  /// 获取特定章节的单词记录
  Future<List<WordRecord>> getWordRecordsByChapter(
      String dictionaryId, int chapterIndex);

  /// 获取特定单词的记录
  Future<List<WordRecord>> getWordRecordsByWord(String word);

  /// 获取错误单词列表
  Future<List<String>> getErrorWords(String dictionaryId, {int? limit});

  /// 获取需要复习的单词
  Future<List<String>> getWordsForReview(String dictionaryId);

  /// 获取学习统计
  Future<LearningStatistics> getLearningStatistics({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取每日学习统计
  Future<Map<DateTime, LearningStatistics>> getDailyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取每周学习统计
  Future<Map<int, LearningStatistics>> getWeeklyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取每月学习统计
  Future<Map<int, LearningStatistics>> getMonthlyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取学习趋势数据
  Future<List<Map<String, dynamic>>> getLearningTrends({
    String period = 'week', // 'day', 'week', 'month'
    int count = 30,
  });

  /// 获取WPM历史数据
  Future<List<Map<String, dynamic>>> getWPMHistory({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取准确率历史数据
  Future<List<Map<String, dynamic>>> getAccuracyHistory({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取字符错误统计
  Future<Map<String, int>> getCharacterMistakeStats({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 获取学习排行榜
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String type = 'wpm', // 'wpm', 'accuracy', 'time'
    String period = 'week', // 'day', 'week', 'month', 'all'
    int limit = 10,
  });

  /// 更新单词记录
  Future<void> updateWordRecord(WordRecord record);

  /// 更新章节记录
  Future<void> updateChapterRecord(ChapterRecord record);

  /// 更新复习记录
  Future<void> updateReviewRecord(ReviewRecord record);

  /// 删除单词记录
  Future<void> deleteWordRecord(int id);

  /// 删除章节记录
  Future<void> deleteChapterRecord(int id);

  /// 删除复习记录
  Future<void> deleteReviewRecord(int id);

  /// 删除特定词典的所有记录
  Future<void> deleteRecordsByDictionary(String dictionaryId);

  /// 删除指定日期之前的记录
  Future<void> deleteRecordsBefore(DateTime date);

  /// 清空所有记录
  Future<void> clearAllRecords();

  /// 导出学习数据
  Future<Map<String, dynamic>> exportLearningData({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 导入学习数据
  Future<void> importLearningData(Map<String, dynamic> data);

  /// 获取数据库大小
  Future<int> getDatabaseSize();

  /// 压缩数据库
  Future<void> compactDatabase();

  /// 备份数据
  Future<String> backupData();

  /// 恢复数据
  Future<void> restoreData(String backupPath);
}
