import '../../entities/typing/learning_record.dart';
import '../../repositories/typing/learning_repository.dart';
import '../../../../core/errors/failures.dart';

/// 保存单词记录用例
class SaveWordRecord {
  final LearningRepository repository;

  SaveWordRecord(this.repository);

  Future<int> call(WordRecord record) async {
    try {
      return await repository.saveWordRecord(record);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 保存章节记录用例
class SaveChapterRecord {
  final LearningRepository repository;

  SaveChapterRecord(this.repository);

  Future<int> call(ChapterRecord record) async {
    try {
      return await repository.saveChapterRecord(record);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 保存复习记录用例
class SaveReviewRecord {
  final LearningRepository repository;

  SaveReviewRecord(this.repository);

  Future<int> call(ReviewRecord record) async {
    try {
      return await repository.saveReviewRecord(record);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取所有单词记录用例
class GetAllWordRecords {
  final LearningRepository repository;

  GetAllWordRecords(this.repository);

  Future<List<WordRecord>> call({
    String? dictionaryId,
    int? chapterIndex,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      return await repository.getAllWordRecords(
        dictionaryId: dictionaryId,
        chapterIndex: chapterIndex,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取所有章节记录用例
class GetAllChapterRecords {
  final LearningRepository repository;

  GetAllChapterRecords(this.repository);

  Future<List<ChapterRecord>> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      return await repository.getAllChapterRecords(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取所有复习记录用例
class GetAllReviewRecords {
  final LearningRepository repository;

  GetAllReviewRecords(this.repository);

  Future<List<ReviewRecord>> call({
    String? dictionaryId,
    bool? isFinished,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      return await repository.getAllReviewRecords(
        dictionaryId: dictionaryId,
        isFinished: isFinished,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取错误单词列表用例
class GetErrorWords {
  final LearningRepository repository;

  GetErrorWords(this.repository);

  Future<List<String>> call(String dictionaryId, {int? limit}) async {
    try {
      return await repository.getErrorWords(dictionaryId, limit: limit);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取需要复习的单词用例
class GetWordsForReview {
  final LearningRepository repository;

  GetWordsForReview(this.repository);

  Future<List<String>> call(String dictionaryId) async {
    try {
      return await repository.getWordsForReview(dictionaryId);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取学习统计用例
class GetLearningStatistics {
  final LearningRepository repository;

  GetLearningStatistics(this.repository);

  Future<LearningStatistics> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getLearningStatistics(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取每日学习统计用例
class GetDailyStatistics {
  final LearningRepository repository;

  GetDailyStatistics(this.repository);

  Future<Map<DateTime, LearningStatistics>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getDailyStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取学习趋势数据用例
class GetLearningTrends {
  final LearningRepository repository;

  GetLearningTrends(this.repository);

  Future<List<Map<String, dynamic>>> call({
    String period = 'week',
    int count = 30,
  }) async {
    try {
      return await repository.getLearningTrends(
        period: period,
        count: count,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取WPM历史数据用例
class GetWPMHistory {
  final LearningRepository repository;

  GetWPMHistory(this.repository);

  Future<List<Map<String, dynamic>>> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getWPMHistory(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取准确率历史数据用例
class GetAccuracyHistory {
  final LearningRepository repository;

  GetAccuracyHistory(this.repository);

  Future<List<Map<String, dynamic>>> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getAccuracyHistory(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取字符错误统计用例
class GetCharacterMistakeStats {
  final LearningRepository repository;

  GetCharacterMistakeStats(this.repository);

  Future<Map<String, int>> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getCharacterMistakeStats(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 获取学习排行榜用例
class GetLeaderboard {
  final LearningRepository repository;

  GetLeaderboard(this.repository);

  Future<List<Map<String, dynamic>>> call({
    String type = 'wpm',
    String period = 'week',
    int limit = 10,
  }) async {
    try {
      return await repository.getLeaderboard(
        type: type,
        period: period,
        limit: limit,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 删除特定词典的所有记录用例
class DeleteRecordsByDictionary {
  final LearningRepository repository;

  DeleteRecordsByDictionary(this.repository);

  Future<void> call(String dictionaryId) async {
    try {
      await repository.deleteRecordsByDictionary(dictionaryId);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 删除指定日期之前的记录用例
class DeleteRecordsBefore {
  final LearningRepository repository;

  DeleteRecordsBefore(this.repository);

  Future<void> call(DateTime date) async {
    try {
      await repository.deleteRecordsBefore(date);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 清空所有记录用例
class ClearAllRecords {
  final LearningRepository repository;

  ClearAllRecords(this.repository);

  Future<void> call() async {
    try {
      await repository.clearAllRecords();
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 导出学习数据用例
class ExportLearningData {
  final LearningRepository repository;

  ExportLearningData(this.repository);

  Future<Map<String, dynamic>> call({
    String? dictionaryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.exportLearningData(
        dictionaryId: dictionaryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 导入学习数据用例
class ImportLearningData {
  final LearningRepository repository;

  ImportLearningData(this.repository);

  Future<void> call(Map<String, dynamic> data) async {
    try {
      await repository.importLearningData(data);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 备份数据用例
class BackupLearningData {
  final LearningRepository repository;

  BackupLearningData(this.repository);

  Future<String> call() async {
    try {
      return await repository.backupData();
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}

/// 恢复数据用例
class RestoreLearningData {
  final LearningRepository repository;

  RestoreLearningData(this.repository);

  Future<void> call(String backupPath) async {
    try {
      await repository.restoreData(backupPath);
    } catch (e) {
      throw StatisticsFailure(e.toString());
    }
  }
}
