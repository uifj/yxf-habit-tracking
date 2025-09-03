import 'package:equatable/equatable.dart';

/// 单词记录
class WordRecord extends Equatable {
  /// 记录ID
  final int? id;

  /// 单词
  final String word;

  /// 时间戳
  final DateTime timestamp;

  /// 词典ID
  final String dictionaryId;

  /// 章节索引
  final int chapterIndex;

  /// 错误次数
  final int wrongCount;

  /// 字母计时数组
  final List<int> letterTiming;

  /// 字母错误统计
  final Map<String, int> letterMistakes;

  const WordRecord({
    this.id,
    required this.word,
    required this.timestamp,
    required this.dictionaryId,
    required this.chapterIndex,
    required this.wrongCount,
    required this.letterTiming,
    required this.letterMistakes,
  });

  /// 是否完美（无错误）
  bool get isPerfect => wrongCount == 0;

  /// 平均打字速度（毫秒/字符）
  double get averageSpeed {
    if (letterTiming.isEmpty) return 0.0;
    return letterTiming.reduce((a, b) => a + b) / letterTiming.length;
  }

  /// 最慢的字符时间
  int get slowestCharTime {
    if (letterTiming.isEmpty) return 0;
    return letterTiming.reduce((a, b) => a > b ? a : b);
  }

  /// 最快的字符时间
  int get fastestCharTime {
    if (letterTiming.isEmpty) return 0;
    return letterTiming.reduce((a, b) => a < b ? a : b);
  }

  @override
  List<Object?> get props => [
        id,
        word,
        timestamp,
        dictionaryId,
        chapterIndex,
        wrongCount,
        letterTiming,
        letterMistakes,
      ];
}

/// 章节记录
class ChapterRecord extends Equatable {
  /// 记录ID
  final int? id;

  /// 时间戳
  final DateTime timestamp;

  /// 词典ID
  final String dictionaryId;

  /// 章节索引
  final int chapterIndex;

  /// 用时（毫秒）
  final int duration;

  /// 正确字符数
  final int correctCount;

  /// 错误字符数
  final int wrongCount;

  /// 单词总数
  final int wordCount;

  /// 正确单词索引列表
  final List<int> correctWordIndexes;

  /// 章节单词总数
  final int chapterWordCount;

  /// 单词记录ID列表
  final List<int> wordRecordIds;

  const ChapterRecord({
    this.id,
    required this.timestamp,
    required this.dictionaryId,
    required this.chapterIndex,
    required this.duration,
    required this.correctCount,
    required this.wrongCount,
    required this.wordCount,
    required this.correctWordIndexes,
    required this.chapterWordCount,
    required this.wordRecordIds,
  });

  /// 总字符数
  int get totalChars => correctCount + wrongCount;

  /// 准确率
  double get accuracy {
    return totalChars > 0 ? (correctCount / totalChars) * 100 : 0.0;
  }

  /// WPM（每分钟单词数）
  double get wpm {
    if (duration == 0) return 0.0;
    final minutes = duration / 60000.0;
    return (correctCount / 5.0) / minutes;
  }

  /// 完成率
  double get completionRate {
    return chapterWordCount > 0 ? (wordCount / chapterWordCount) * 100 : 0.0;
  }

  /// 持续时间
  Duration get durationTime => Duration(milliseconds: duration);

  @override
  List<Object?> get props => [
        id,
        timestamp,
        dictionaryId,
        chapterIndex,
        duration,
        correctCount,
        wrongCount,
        wordCount,
        correctWordIndexes,
        chapterWordCount,
        wordRecordIds,
      ];
}

/// 复习记录
class ReviewRecord extends Equatable {
  /// 记录ID
  final int? id;

  /// 词典ID
  final String dictionaryId;

  /// 创建时间
  final DateTime createTime;

  /// 是否完成
  final bool isFinished;

  /// 完成时间
  final DateTime? finishTime;

  /// 错误单词列表
  final List<String> errorWords;

  /// 复习次数
  final int reviewCount;

  const ReviewRecord({
    this.id,
    required this.dictionaryId,
    required this.createTime,
    this.isFinished = false,
    this.finishTime,
    this.errorWords = const [],
    this.reviewCount = 0,
  });

  /// 复习持续时间
  Duration? get reviewDuration {
    if (finishTime != null) {
      return finishTime!.difference(createTime);
    }
    return null;
  }

  /// 错误单词数量
  int get errorWordCount => errorWords.length;

  @override
  List<Object?> get props => [
        id,
        dictionaryId,
        createTime,
        isFinished,
        finishTime,
        errorWords,
        reviewCount,
      ];
}

/// 学习统计
class LearningStatistics extends Equatable {
  /// 总学习时间（毫秒）
  final int totalStudyTime;

  /// 总打字字符数
  final int totalChars;

  /// 总正确字符数
  final int totalCorrectChars;

  /// 总错误字符数
  final int totalWrongChars;

  /// 完成的章节数
  final int completedChapters;

  /// 学习的词典数
  final int studiedDictionaries;

  /// 掌握的单词数
  final int masteredWords;

  /// 最高WPM
  final double maxWPM;

  /// 平均WPM
  final double averageWPM;

  /// 最高准确率
  final double maxAccuracy;

  /// 平均准确率
  final double averageAccuracy;

  /// 连续学习天数
  final int streakDays;

  /// 最后学习时间
  final DateTime? lastStudyTime;

  const LearningStatistics({
    this.totalStudyTime = 0,
    this.totalChars = 0,
    this.totalCorrectChars = 0,
    this.totalWrongChars = 0,
    this.completedChapters = 0,
    this.studiedDictionaries = 0,
    this.masteredWords = 0,
    this.maxWPM = 0.0,
    this.averageWPM = 0.0,
    this.maxAccuracy = 0.0,
    this.averageAccuracy = 0.0,
    this.streakDays = 0,
    this.lastStudyTime,
  });

  /// 总准确率
  double get totalAccuracy {
    return totalChars > 0 ? (totalCorrectChars / totalChars) * 100 : 0.0;
  }

  /// 总学习时长
  Duration get totalStudyDuration => Duration(milliseconds: totalStudyTime);

  /// 是否今天学习过
  bool get studiedToday {
    if (lastStudyTime == null) return false;
    final now = DateTime.now();
    final lastStudy = lastStudyTime!;
    return now.year == lastStudy.year &&
        now.month == lastStudy.month &&
        now.day == lastStudy.day;
  }

  @override
  List<Object?> get props => [
        totalStudyTime,
        totalChars,
        totalCorrectChars,
        totalWrongChars,
        completedChapters,
        studiedDictionaries,
        masteredWords,
        maxWPM,
        averageWPM,
        maxAccuracy,
        averageAccuracy,
        streakDays,
        lastStudyTime,
      ];
}
