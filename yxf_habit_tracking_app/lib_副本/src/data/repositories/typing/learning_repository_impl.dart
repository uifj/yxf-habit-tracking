import '../../../domain/entities/typing/learning_record.dart';
import '../../../domain/repositories/typing/learning_repository.dart';
import '../../datasources/typing/learning_local_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

/// 学习记录仓库实现类
class LearningRepositoryImpl implements LearningRepository {
  final LearningLocalDataSource localDataSource;

  LearningRepositoryImpl({
    required this.localDataSource,
  });

  // ========== WordRecord 相关方法 ==========

  @override
  Future<int> saveWordRecord(WordRecord record) async {
    try {
      await localDataSource.saveWordRecord(record);
      return 1; // Return success indicator
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<WordRecord?> getWordRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID lookup
      throw UnimplementedError('getWordRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<WordRecord>> getAllWordRecords({
    String? dictionaryId,
    int? chapterIndex,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      if (dictionaryId != null) {
        return await localDataSource.getWordRecords(dictionaryId);
      }
      // Placeholder for more complex queries
      throw UnimplementedError(
          'getAllWordRecords with complex filters not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<ChapterRecord>> getAllChapterRecords({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      if (dictionaryId != null) {
        return await localDataSource.getChapterRecords(dictionaryId);
      }
      throw UnimplementedError(
          'getAllChapterRecords with complex filters not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<ReviewRecord>> getAllReviewRecords({
    String? dictionaryId,
    bool? isFinished,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      throw UnimplementedError('getAllReviewRecords not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<WordRecord>> getWordRecordsByDictionary(
      String dictionaryId) async {
    try {
      return await localDataSource.getWordRecords(dictionaryId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<WordRecord>> getWordRecordsByChapter(
      String dictionaryId, int chapterIndex) async {
    try {
      // Placeholder implementation
      throw UnimplementedError('getWordRecordsByChapter not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<WordRecord>> getWordRecordsByWord(String word) async {
    try {
      // Placeholder implementation
      throw UnimplementedError('getWordRecordsByWord not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<String>> getErrorWords(String dictionaryId, {int? limit}) async {
    try {
      final records = await localDataSource.getErrorWords(
        dictionaryId,
        limit: limit,
        minWrongCount: 1,
      );
      return records.map((record) => record.word).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<String>> getWordsForReview(String dictionaryId) async {
    try {
      final records = await localDataSource.getWordsForReview(
        dictionaryId,
        limit: null,
        reviewInterval: null,
      );
      return records.map((record) => record.word).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> updateWordRecord(WordRecord record) async {
    try {
      await localDataSource.updateWordRecord(record);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> deleteWordRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID-based deletion
      throw UnimplementedError('deleteWordRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  // ========== ChapterRecord 相关方法 ==========

  @override
  Future<int> saveChapterRecord(ChapterRecord record) async {
    try {
      await localDataSource.saveChapterRecord(record);
      return 1; // Return success indicator
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<ChapterRecord?> getChapterRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID lookup
      throw UnimplementedError('getChapterRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> updateChapterRecord(ChapterRecord record) async {
    try {
      await localDataSource.updateChapterRecord(record);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> deleteChapterRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID-based deletion
      throw UnimplementedError('deleteChapterRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  // ========== ReviewRecord 相关方法 ==========

  @override
  Future<int> saveReviewRecord(ReviewRecord record) async {
    try {
      await localDataSource.saveReviewRecord(record);
      return 1; // Return success indicator
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<ReviewRecord?> getReviewRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID lookup
      throw UnimplementedError('getReviewRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> updateReviewRecord(ReviewRecord record) async {
    try {
      // Placeholder implementation - would need to add updateReviewRecord to datasource
      throw UnimplementedError('updateReviewRecord not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> deleteReviewRecord(int id) async {
    try {
      // Placeholder implementation - would need to modify datasource to support ID-based deletion
      throw UnimplementedError('deleteReviewRecord by ID not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  // ========== LearningStatistics 相关方法 ==========

  @override
  Future<LearningStatistics> getLearningStatistics({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await localDataSource.getLearningStatistics();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<Map<DateTime, LearningStatistics>> getDailyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      return await localDataSource.getDailyLearningStats(start, end);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<Map<int, LearningStatistics>> getWeeklyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Placeholder implementation
      throw UnimplementedError('getWeeklyStatistics not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<Map<int, LearningStatistics>> getMonthlyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Placeholder implementation
      throw UnimplementedError('getMonthlyStatistics not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLearningTrends({
    String period = 'week',
    int count = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: count));
      return await localDataSource.getLearningTrends(
        startDate,
        endDate,
        period,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWPMHistory({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      return await localDataSource.getWpmHistory(
        start,
        end,
        dictionaryId: dictionaryId,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAccuracyHistory({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      return await localDataSource.getAccuracyHistory(
        start,
        end,
        dictionaryId: dictionaryId,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<Map<String, int>> getCharacterMistakeStats({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await localDataSource.getCharacterMistakeStats(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String type = 'wpm',
    String period = 'week',
    int limit = 10,
  }) async {
    try {
      // Placeholder implementation
      throw UnimplementedError('getLeaderboard not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  // ========== 数据管理方法 ==========

  @override
  Future<void> deleteRecordsByDictionary(String dictionaryId) async {
    try {
      await localDataSource.deleteWordRecords(dictionaryId);
      await localDataSource.deleteChapterRecords(dictionaryId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> deleteRecordsBefore(DateTime date) async {
    try {
      await localDataSource.deleteLearningDataByDateRange(
        DateTime(1970),
        date,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> clearAllRecords() async {
    try {
      await localDataSource.clearAllLearningData();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> exportLearningData({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await localDataSource.exportLearningData(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> importLearningData(Map<String, dynamic> data) async {
    try {
      await localDataSource.importLearningData(data);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<int> getDatabaseSize() async {
    try {
      return await localDataSource.getDatabaseSize();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> compactDatabase() async {
    try {
      await localDataSource.compactDatabase();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<String> backupData() async {
    try {
      final data = await localDataSource.backupLearningData();
      return data.toString(); // Convert to string representation
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }

  @override
  Future<void> restoreData(String backupPath) async {
    try {
      // Placeholder implementation - would need to parse the backup data
      throw UnimplementedError('restoreData not implemented yet');
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}
