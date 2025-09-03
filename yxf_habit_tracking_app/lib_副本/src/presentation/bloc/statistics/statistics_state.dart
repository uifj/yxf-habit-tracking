import 'package:equatable/equatable.dart';
import 'statistics_event.dart';

/// 统计分析状态基类
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// 加载中状态
class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

/// 加载成功状态
class StatisticsLoaded extends StatisticsState {
  final StatisticsData data;
  final StatisticsTimeRange timeRange;

  const StatisticsLoaded({
    required this.data,
    required this.timeRange,
  });

  @override
  List<Object?> get props => [data, timeRange];
}

/// 空数据状态
class StatisticsEmpty extends StatisticsState {
  final String message;

  const StatisticsEmpty({
    this.message = '暂无练习数据',
  });

  @override
  List<Object?> get props => [message];
}

/// 错误状态
class StatisticsError extends StatisticsState {
  final String message;
  final Exception? exception;

  const StatisticsError({
    required this.message,
    this.exception,
  });

  @override
  List<Object?> get props => [message, exception];
}

/// 导出中状态
class StatisticsExporting extends StatisticsState {
  final StatisticsExportFormat format;
  final double progress;

  const StatisticsExporting({
    required this.format,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [format, progress];
}

/// 导出完成状态
class StatisticsExported extends StatisticsState {
  final String filePath;
  final StatisticsExportFormat format;

  const StatisticsExported({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

/// 统计数据类
class StatisticsData extends Equatable {
  /// 总体统计
  final OverallStatistics overall;
  
  /// 每日统计数据
  final List<DailyStatistics> dailyStats;
  
  /// WPM历史数据
  final List<WPMDataPoint> wpmHistory;
  
  /// 准确率历史数据
  final List<AccuracyDataPoint> accuracyHistory;
  
  /// 键盘热力图数据
  final Map<String, KeyboardKeyData> keyboardHeatmap;
  
  /// 最常错误的字母
  final List<MistakeData> topMistakes;
  
  /// 词典统计
  final List<DictionaryStatistics> dictionaryStats;
  
  /// 学习进度
  final LearningProgress progress;

  const StatisticsData({
    required this.overall,
    required this.dailyStats,
    required this.wpmHistory,
    required this.accuracyHistory,
    required this.keyboardHeatmap,
    required this.topMistakes,
    required this.dictionaryStats,
    required this.progress,
  });

  @override
  List<Object?> get props => [
        overall,
        dailyStats,
        wpmHistory,
        accuracyHistory,
        keyboardHeatmap,
        topMistakes,
        dictionaryStats,
        progress,
      ];
}

/// 总体统计数据
class OverallStatistics extends Equatable {
  /// 总练习时间（分钟）
  final int totalMinutes;
  
  /// 总单词数
  final int totalWords;
  
  /// 正确单词数
  final int correctWords;
  
  /// 错误单词数
  final int wrongWords;
  
  /// 平均WPM
  final double averageWPM;
  
  /// 最高WPM
  final double maxWPM;
  
  /// 平均准确率
  final double averageAccuracy;
  
  /// 最高准确率
  final double maxAccuracy;
  
  /// 总练习次数
  final int totalSessions;
  
  /// 连续练习天数
  final int streakDays;
  
  /// 总字符数
  final int totalCharacters;
  
  /// 正确字符数
  final int correctCharacters;

  const OverallStatistics({
    required this.totalMinutes,
    required this.totalWords,
    required this.correctWords,
    required this.wrongWords,
    required this.averageWPM,
    required this.maxWPM,
    required this.averageAccuracy,
    required this.maxAccuracy,
    required this.totalSessions,
    required this.streakDays,
    required this.totalCharacters,
    required this.correctCharacters,
  });

  /// 总准确率
  double get overallAccuracy {
    if (totalWords == 0) return 0.0;
    return (correctWords / totalWords) * 100.0;
  }

  /// 字符准确率
  double get characterAccuracy {
    if (totalCharacters == 0) return 0.0;
    return (correctCharacters / totalCharacters) * 100.0;
  }

  @override
  List<Object?> get props => [
        totalMinutes,
        totalWords,
        correctWords,
        wrongWords,
        averageWPM,
        maxWPM,
        averageAccuracy,
        maxAccuracy,
        totalSessions,
        streakDays,
        totalCharacters,
        correctCharacters,
      ];
}

/// 每日统计数据
class DailyStatistics extends Equatable {
  final DateTime date;
  final int sessions;
  final int words;
  final int minutes;
  final double averageWPM;
  final double averageAccuracy;

  const DailyStatistics({
    required this.date,
    required this.sessions,
    required this.words,
    required this.minutes,
    required this.averageWPM,
    required this.averageAccuracy,
  });

  @override
  List<Object?> get props => [
        date,
        sessions,
        words,
        minutes,
        averageWPM,
        averageAccuracy,
      ];
}

/// WPM数据点
class WPMDataPoint extends Equatable {
  final DateTime date;
  final double wpm;
  final String? sessionId;

  const WPMDataPoint({
    required this.date,
    required this.wpm,
    this.sessionId,
  });

  @override
  List<Object?> get props => [date, wpm, sessionId];
}

/// 准确率数据点
class AccuracyDataPoint extends Equatable {
  final DateTime date;
  final double accuracy;
  final String? sessionId;

  const AccuracyDataPoint({
    required this.date,
    required this.accuracy,
    this.sessionId,
  });

  @override
  List<Object?> get props => [date, accuracy, sessionId];
}

/// 键盘按键数据
class KeyboardKeyData extends Equatable {
  final String key;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final int totalPresses;

  const KeyboardKeyData({
    required this.key,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.totalPresses,
  });

  /// 错误率
  double get errorRate => 100.0 - accuracy;

  @override
  List<Object?> get props => [
        key,
        correctCount,
        wrongCount,
        accuracy,
        totalPresses,
      ];
}

/// 错误数据
class MistakeData extends Equatable {
  final String character;
  final int count;
  final double percentage;

  const MistakeData({
    required this.character,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [character, count, percentage];
}

/// 词典统计
class DictionaryStatistics extends Equatable {
  final String dictionaryId;
  final String name;
  final int totalWords;
  final int completedWords;
  final int sessions;
  final double averageWPM;
  final double averageAccuracy;
  final Duration totalTime;

  const DictionaryStatistics({
    required this.dictionaryId,
    required this.name,
    required this.totalWords,
    required this.completedWords,
    required this.sessions,
    required this.averageWPM,
    required this.averageAccuracy,
    required this.totalTime,
  });

  /// 完成进度
  double get completionProgress {
    if (totalWords == 0) return 0.0;
    return (completedWords / totalWords) * 100.0;
  }

  @override
  List<Object?> get props => [
        dictionaryId,
        name,
        totalWords,
        completedWords,
        sessions,
        averageWPM,
        averageAccuracy,
        totalTime,
      ];
}

/// 学习进度
class LearningProgress extends Equatable {
  final int currentLevel;
  final int totalLevels;
  final double currentLevelProgress;
  final int experiencePoints;
  final int nextLevelXP;
  final List<Achievement> achievements;
  final List<Badge> badges;

  const LearningProgress({
    required this.currentLevel,
    required this.totalLevels,
    required this.currentLevelProgress,
    required this.experiencePoints,
    required this.nextLevelXP,
    required this.achievements,
    required this.badges,
  });

  @override
  List<Object?> get props => [
        currentLevel,
        totalLevels,
        currentLevelProgress,
        experiencePoints,
        nextLevelXP,
        achievements,
        badges,
      ];
}

/// 成就
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final DateTime unlockedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.unlockedAt,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconPath,
        unlockedAt,
        isUnlocked,
      ];
}

/// 徽章
class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final BadgeRarity rarity;
  final DateTime earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.rarity,
    required this.earnedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconPath,
        rarity,
        earnedAt,
      ];
}

/// 徽章稀有度
enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}