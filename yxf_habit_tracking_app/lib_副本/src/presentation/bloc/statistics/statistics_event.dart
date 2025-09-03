import 'package:equatable/equatable.dart';

/// 统计分析事件基类
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载统计数据
class StatisticsLoadRequested extends StatisticsEvent {
  const StatisticsLoadRequested();
}

/// 刷新统计数据
class StatisticsRefreshRequested extends StatisticsEvent {
  const StatisticsRefreshRequested();
}

/// 更新时间范围
class StatisticsTimeRangeChanged extends StatisticsEvent {
  final StatisticsTimeRange timeRange;

  const StatisticsTimeRangeChanged({
    required this.timeRange,
  });

  @override
  List<Object?> get props => [timeRange];
}

/// 添加练习记录
class StatisticsSessionAdded extends StatisticsEvent {
  final String sessionId;
  final String dictionaryId;
  final int wordsCount;
  final int correctWords;
  final int wrongWords;
  final double wpm;
  final double accuracy;
  final Duration duration;
  final Map<String, int> mistakeCount;
  final DateTime completedAt;

  const StatisticsSessionAdded({
    required this.sessionId,
    required this.dictionaryId,
    required this.wordsCount,
    required this.correctWords,
    required this.wrongWords,
    required this.wpm,
    required this.accuracy,
    required this.duration,
    required this.mistakeCount,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
        sessionId,
        dictionaryId,
        wordsCount,
        correctWords,
        wrongWords,
        wpm,
        accuracy,
        duration,
        mistakeCount,
        completedAt,
      ];
}

/// 清除统计数据
class StatisticsClearRequested extends StatisticsEvent {
  const StatisticsClearRequested();
}

/// 导出统计数据
class StatisticsExportRequested extends StatisticsEvent {
  final StatisticsExportFormat format;

  const StatisticsExportRequested({
    required this.format,
  });

  @override
  List<Object?> get props => [format];
}

/// 统计时间范围枚举
enum StatisticsTimeRange {
  /// 最近7天
  week,

  /// 最近30天
  month,

  /// 最近90天
  quarter,

  /// 最近一年
  year,

  /// 全部时间
  all,
}

/// 统计导出格式枚举
enum StatisticsExportFormat {
  /// JSON格式
  json,

  /// CSV格式
  csv,

  /// PDF报告
  pdf,
}

/// 时间范围扩展方法
extension StatisticsTimeRangeExtension on StatisticsTimeRange {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case StatisticsTimeRange.week:
        return '最近7天';
      case StatisticsTimeRange.month:
        return '最近30天';
      case StatisticsTimeRange.quarter:
        return '最近90天';
      case StatisticsTimeRange.year:
        return '最近一年';
      case StatisticsTimeRange.all:
        return '全部时间';
    }
  }

  /// 获取天数
  int? get days {
    switch (this) {
      case StatisticsTimeRange.week:
        return 7;
      case StatisticsTimeRange.month:
        return 30;
      case StatisticsTimeRange.quarter:
        return 90;
      case StatisticsTimeRange.year:
        return 365;
      case StatisticsTimeRange.all:
        return null;
    }
  }

  /// 获取开始日期
  DateTime? get startDate {
    final dayCount = days;
    if (dayCount == null) return null;
    return DateTime.now().subtract(Duration(days: dayCount));
  }
}
