import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// 统计分析BLoC
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  static const String _storageKey = 'typing_statistics';
  static const String _sessionsKey = 'typing_sessions';

  final SharedPreferences _prefs;
  List<SessionRecord> _sessions = [];

  StatisticsBloc({
    required SharedPreferences prefs,
  })  : _prefs = prefs,
        super(const StatisticsInitial()) {
    on<StatisticsLoadRequested>(_onLoadRequested);
    on<StatisticsRefreshRequested>(_onRefreshRequested);
    on<StatisticsTimeRangeChanged>(_onTimeRangeChanged);
    on<StatisticsSessionAdded>(_onSessionAdded);
    on<StatisticsClearRequested>(_onClearRequested);
    on<StatisticsExportRequested>(_onExportRequested);
  }

  /// 加载统计数据
  Future<void> _onLoadRequested(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      emit(const StatisticsLoading());

      await _loadSessions();

      if (_sessions.isEmpty) {
        emit(const StatisticsEmpty());
        return;
      }

      final data = await _calculateStatistics(StatisticsTimeRange.all);
      emit(StatisticsLoaded(
        data: data,
        timeRange: StatisticsTimeRange.all,
      ));
    } catch (e) {
      emit(StatisticsError(message: '加载统计数据失败: ${e.toString()}'));
    }
  }

  /// 刷新统计数据
  Future<void> _onRefreshRequested(
    StatisticsRefreshRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentState = state;
    final timeRange = currentState is StatisticsLoaded
        ? currentState.timeRange
        : StatisticsTimeRange.all;

    add(StatisticsTimeRangeChanged(timeRange: timeRange));
  }

  /// 时间范围变更
  Future<void> _onTimeRangeChanged(
    StatisticsTimeRangeChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      emit(const StatisticsLoading());

      await _loadSessions();

      if (_sessions.isEmpty) {
        emit(const StatisticsEmpty());
        return;
      }

      final data = await _calculateStatistics(event.timeRange);
      emit(StatisticsLoaded(
        data: data,
        timeRange: event.timeRange,
      ));
    } catch (e) {
      emit(StatisticsError(message: '加载统计数据失败: ${e.toString()}'));
    }
  }

  /// 添加练习记录
  Future<void> _onSessionAdded(
    StatisticsSessionAdded event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      final session = SessionRecord(
        id: event.sessionId,
        dictionaryId: event.dictionaryId,
        wordsCount: event.wordsCount,
        correctWords: event.correctWords,
        wrongWords: event.wrongWords,
        wpm: event.wpm,
        accuracy: event.accuracy,
        duration: event.duration,
        mistakeCount: event.mistakeCount,
        completedAt: event.completedAt,
      );

      _sessions.add(session);
      await _saveSessions();

      // 刷新当前显示的统计数据
      final currentState = state;
      if (currentState is StatisticsLoaded) {
        add(StatisticsTimeRangeChanged(timeRange: currentState.timeRange));
      } else {
        add(const StatisticsLoadRequested());
      }
    } catch (e) {
      emit(StatisticsError(message: '保存练习记录失败: ${e.toString()}'));
    }
  }

  /// 清除统计数据
  Future<void> _onClearRequested(
    StatisticsClearRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      _sessions.clear();
      await _prefs.remove(_sessionsKey);
      emit(const StatisticsEmpty(message: '统计数据已清除'));
    } catch (e) {
      emit(StatisticsError(message: '清除数据失败: ${e.toString()}'));
    }
  }

  /// 导出统计数据
  Future<void> _onExportRequested(
    StatisticsExportRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      emit(StatisticsExporting(format: event.format));

      // 模拟导出过程
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        emit(StatisticsExporting(format: event.format, progress: i / 100));
      }

      // 生成文件路径（实际应用中应该是真实的文件路径）
      final fileName =
          'typing_statistics_${DateTime.now().millisecondsSinceEpoch}';
      final extension = _getFileExtension(event.format);
      final filePath = '/Documents/$fileName.$extension';

      emit(StatisticsExported(
        filePath: filePath,
        format: event.format,
      ));
    } catch (e) {
      emit(StatisticsError(message: '导出数据失败: ${e.toString()}'));
    }
  }

  /// 从本地存储加载会话记录
  Future<void> _loadSessions() async {
    try {
      final sessionsJson = _prefs.getString(_sessionsKey);
      if (sessionsJson != null) {
        final sessionsList = jsonDecode(sessionsJson) as List;
        _sessions =
            sessionsList.map((json) => SessionRecord.fromJson(json)).toList();
      }
    } catch (e) {
      _sessions = [];
    }
  }

  /// 保存会话记录到本地存储
  Future<void> _saveSessions() async {
    try {
      final sessionsJson = jsonEncode(
        _sessions.map((session) => session.toJson()).toList(),
      );
      await _prefs.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      // 忽略保存错误
    }
  }

  /// 计算统计数据
  Future<StatisticsData> _calculateStatistics(
      StatisticsTimeRange timeRange) async {
    final filteredSessions = _filterSessionsByTimeRange(_sessions, timeRange);

    if (filteredSessions.isEmpty) {
      return _createEmptyStatistics();
    }

    // 计算总体统计
    final overall = _calculateOverallStatistics(filteredSessions);

    // 计算每日统计
    final dailyStats = _calculateDailyStatistics(filteredSessions);

    // 计算WPM历史
    final wpmHistory = _calculateWPMHistory(filteredSessions);

    // 计算准确率历史
    final accuracyHistory = _calculateAccuracyHistory(filteredSessions);

    // 计算键盘热力图
    final keyboardHeatmap = _calculateKeyboardHeatmap(filteredSessions);

    // 计算最常错误
    final topMistakes = _calculateTopMistakes(filteredSessions);

    // 计算词典统计
    final dictionaryStats = _calculateDictionaryStatistics(filteredSessions);

    // 计算学习进度
    final progress = _calculateLearningProgress(filteredSessions);

    return StatisticsData(
      overall: overall,
      dailyStats: dailyStats,
      wpmHistory: wpmHistory,
      accuracyHistory: accuracyHistory,
      keyboardHeatmap: keyboardHeatmap,
      topMistakes: topMistakes,
      dictionaryStats: dictionaryStats,
      progress: progress,
    );
  }

  /// 根据时间范围过滤会话
  List<SessionRecord> _filterSessionsByTimeRange(
    List<SessionRecord> sessions,
    StatisticsTimeRange timeRange,
  ) {
    final startDate = timeRange.startDate;
    if (startDate == null) return sessions;

    return sessions
        .where((session) => session.completedAt.isAfter(startDate))
        .toList();
  }

  /// 计算总体统计
  OverallStatistics _calculateOverallStatistics(List<SessionRecord> sessions) {
    final totalMinutes =
        sessions.map((s) => s.duration.inMinutes).fold(0, (a, b) => a + b);

    final totalWords =
        sessions.map((s) => s.wordsCount).fold(0, (a, b) => a + b);

    final correctWords =
        sessions.map((s) => s.correctWords).fold(0, (a, b) => a + b);

    final wrongWords =
        sessions.map((s) => s.wrongWords).fold(0, (a, b) => a + b);

    final averageWPM = sessions.isNotEmpty
        ? sessions.map((s) => s.wpm).reduce((a, b) => a + b) / sessions.length
        : 0.0;

    final maxWPM =
        sessions.isNotEmpty ? sessions.map((s) => s.wpm).reduce(max) : 0.0;

    final averageAccuracy = sessions.isNotEmpty
        ? sessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
            sessions.length
        : 0.0;

    final maxAccuracy =
        sessions.isNotEmpty ? sessions.map((s) => s.accuracy).reduce(max) : 0.0;

    final streakDays = _calculateStreakDays(sessions);

    return OverallStatistics(
      totalMinutes: totalMinutes,
      totalWords: totalWords,
      correctWords: correctWords,
      wrongWords: wrongWords,
      averageWPM: averageWPM,
      maxWPM: maxWPM,
      averageAccuracy: averageAccuracy,
      maxAccuracy: maxAccuracy,
      totalSessions: sessions.length,
      streakDays: streakDays,
      totalCharacters: totalWords * 5, // 估算字符数
      correctCharacters: correctWords * 5,
    );
  }

  /// 计算连续练习天数
  int _calculateStreakDays(List<SessionRecord> sessions) {
    if (sessions.isEmpty) return 0;

    final sortedSessions = sessions.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final today = DateTime.now();
    var streakDays = 0;
    var currentDate = DateTime(today.year, today.month, today.day);

    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );

      if (sessionDate == currentDate) {
        streakDays++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (sessionDate.isBefore(currentDate)) {
        break;
      }
    }

    return streakDays;
  }

  /// 计算每日统计
  List<DailyStatistics> _calculateDailyStatistics(
      List<SessionRecord> sessions) {
    final dailyMap = <String, List<SessionRecord>>{};

    for (final session in sessions) {
      final dateKey =
          '${session.completedAt.year}-${session.completedAt.month}-${session.completedAt.day}';
      dailyMap.putIfAbsent(dateKey, () => []).add(session);
    }

    return dailyMap.entries.map((entry) {
      final dateParts = entry.key.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final daySessions = entry.value;
      final totalWords =
          daySessions.map((s) => s.wordsCount).fold(0, (a, b) => a + b);
      final totalMinutes =
          daySessions.map((s) => s.duration.inMinutes).fold(0, (a, b) => a + b);
      final avgWPM = daySessions.map((s) => s.wpm).reduce((a, b) => a + b) /
          daySessions.length;
      final avgAccuracy =
          daySessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
              daySessions.length;

      return DailyStatistics(
        date: date,
        sessions: daySessions.length,
        words: totalWords,
        minutes: totalMinutes,
        averageWPM: avgWPM,
        averageAccuracy: avgAccuracy,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 计算WPM历史
  List<WPMDataPoint> _calculateWPMHistory(List<SessionRecord> sessions) {
    return sessions
        .map((session) => WPMDataPoint(
              date: session.completedAt,
              wpm: session.wpm,
              sessionId: session.id,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 计算准确率历史
  List<AccuracyDataPoint> _calculateAccuracyHistory(
      List<SessionRecord> sessions) {
    return sessions
        .map((session) => AccuracyDataPoint(
              date: session.completedAt,
              accuracy: session.accuracy,
              sessionId: session.id,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 计算键盘热力图
  Map<String, KeyboardKeyData> _calculateKeyboardHeatmap(
      List<SessionRecord> sessions) {
    final keyData = <String, KeyboardKeyData>{};
    final allMistakes = <String, int>{};

    // 收集所有错误数据
    for (final session in sessions) {
      session.mistakeCount.forEach((key, count) {
        allMistakes[key] = (allMistakes[key] ?? 0) + count;
      });
    }

    // 生成键盘数据（简化版本）
    const qwertyKeys = 'qwertyuiopasdfghjklzxcvbnm';
    for (final key in qwertyKeys.split('')) {
      final mistakes = allMistakes[key] ?? 0;
      final totalPresses = mistakes + (mistakes * 9); // 假设正确率90%
      final correctPresses = totalPresses - mistakes;
      final accuracy =
          totalPresses > 0 ? (correctPresses / totalPresses) * 100 : 100.0;

      keyData[key] = KeyboardKeyData(
        key: key,
        correctCount: correctPresses,
        wrongCount: mistakes,
        accuracy: accuracy,
        totalPresses: totalPresses,
      );
    }

    return keyData;
  }

  /// 计算最常错误
  List<MistakeData> _calculateTopMistakes(List<SessionRecord> sessions) {
    final allMistakes = <String, int>{};
    var totalMistakes = 0;

    for (final session in sessions) {
      session.mistakeCount.forEach((key, count) {
        allMistakes[key] = (allMistakes[key] ?? 0) + count;
        totalMistakes += count;
      });
    }

    final sortedMistakes = allMistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMistakes.take(10).map((entry) {
      final percentage =
          totalMistakes > 0 ? (entry.value / totalMistakes) * 100 : 0.0;
      return MistakeData(
        character: entry.key,
        count: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  /// 计算词典统计
  List<DictionaryStatistics> _calculateDictionaryStatistics(
      List<SessionRecord> sessions) {
    final dictionaryMap = <String, List<SessionRecord>>{};

    for (final session in sessions) {
      dictionaryMap.putIfAbsent(session.dictionaryId, () => []).add(session);
    }

    return dictionaryMap.entries.map((entry) {
      final dictSessions = entry.value;
      final totalWords =
          dictSessions.map((s) => s.wordsCount).fold(0, (a, b) => a + b);
      final completedWords =
          dictSessions.map((s) => s.correctWords).fold(0, (a, b) => a + b);
      final avgWPM = dictSessions.map((s) => s.wpm).reduce((a, b) => a + b) /
          dictSessions.length;
      final avgAccuracy =
          dictSessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
              dictSessions.length;
      final totalTime = dictSessions
          .map((s) => s.duration)
          .fold(Duration.zero, (a, b) => a + b);

      return DictionaryStatistics(
        dictionaryId: entry.key,
        name: _getDictionaryName(entry.key),
        totalWords: totalWords,
        completedWords: completedWords,
        sessions: dictSessions.length,
        averageWPM: avgWPM,
        averageAccuracy: avgAccuracy,
        totalTime: totalTime,
      );
    }).toList();
  }

  /// 计算学习进度
  LearningProgress _calculateLearningProgress(List<SessionRecord> sessions) {
    final totalWords =
        sessions.map((s) => s.correctWords).fold(0, (a, b) => a + b);
    final experiencePoints = totalWords * 10; // 每个正确单词10经验

    final currentLevel = (experiencePoints / 1000).floor() + 1;
    final nextLevelXP = currentLevel * 1000;
    final currentLevelProgress = ((experiencePoints % 1000) / 1000) * 100;

    return LearningProgress(
      currentLevel: currentLevel,
      totalLevels: 100,
      currentLevelProgress: currentLevelProgress,
      experiencePoints: experiencePoints,
      nextLevelXP: nextLevelXP,
      achievements: _generateAchievements(sessions),
      badges: _generateBadges(sessions),
    );
  }

  /// 生成成就
  List<Achievement> _generateAchievements(List<SessionRecord> sessions) {
    final achievements = <Achievement>[];
    final now = DateTime.now();

    // 首次练习成就
    if (sessions.isNotEmpty) {
      achievements.add(Achievement(
        id: 'first_session',
        name: '初学者',
        description: '完成第一次打字练习',
        iconPath: 'assets/achievements/first_session.svg',
        unlockedAt: sessions.first.completedAt,
        isUnlocked: true,
      ));
    }

    // 速度成就
    final maxWPM =
        sessions.isNotEmpty ? sessions.map((s) => s.wpm).reduce(max) : 0.0;
    if (maxWPM >= 60) {
      achievements.add(Achievement(
        id: 'speed_demon',
        name: '速度恶魔',
        description: '达到60 WPM',
        iconPath: 'assets/achievements/speed_demon.svg',
        unlockedAt: now,
        isUnlocked: true,
      ));
    }

    return achievements;
  }

  /// 生成徽章
  List<Badge> _generateBadges(List<SessionRecord> sessions) {
    final badges = <Badge>[];
    final now = DateTime.now();

    if (sessions.length >= 10) {
      badges.add(Badge(
        id: 'persistent',
        name: '坚持不懈',
        description: '完成10次练习',
        iconPath: 'assets/badges/persistent.svg',
        rarity: BadgeRarity.common,
        earnedAt: now,
      ));
    }

    return badges;
  }

  /// 创建空统计数据
  StatisticsData _createEmptyStatistics() {
    return const StatisticsData(
      overall: OverallStatistics(
        totalMinutes: 0,
        totalWords: 0,
        correctWords: 0,
        wrongWords: 0,
        averageWPM: 0.0,
        maxWPM: 0.0,
        averageAccuracy: 0.0,
        maxAccuracy: 0.0,
        totalSessions: 0,
        streakDays: 0,
        totalCharacters: 0,
        correctCharacters: 0,
      ),
      dailyStats: [],
      wpmHistory: [],
      accuracyHistory: [],
      keyboardHeatmap: {},
      topMistakes: [],
      dictionaryStats: [],
      progress: LearningProgress(
        currentLevel: 1,
        totalLevels: 100,
        currentLevelProgress: 0.0,
        experiencePoints: 0,
        nextLevelXP: 1000,
        achievements: [],
        badges: [],
      ),
    );
  }

  /// 获取词典名称
  String _getDictionaryName(String dictionaryId) {
    switch (dictionaryId) {
      case 'cet4':
        return 'CET-4 核心词汇';
      case 'cet6':
        return 'CET-6 核心词汇';
      case 'toefl':
        return 'TOEFL 词汇';
      case 'ielts':
        return 'IELTS 词汇';
      default:
        return '默认词典';
    }
  }

  /// 获取文件扩展名
  String _getFileExtension(StatisticsExportFormat format) {
    switch (format) {
      case StatisticsExportFormat.json:
        return 'json';
      case StatisticsExportFormat.csv:
        return 'csv';
      case StatisticsExportFormat.pdf:
        return 'pdf';
    }
  }
}

/// 会话记录数据类
class SessionRecord {
  final String id;
  final String dictionaryId;
  final int wordsCount;
  final int correctWords;
  final int wrongWords;
  final double wpm;
  final double accuracy;
  final Duration duration;
  final Map<String, int> mistakeCount;
  final DateTime completedAt;

  const SessionRecord({
    required this.id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dictionaryId': dictionaryId,
      'wordsCount': wordsCount,
      'correctWords': correctWords,
      'wrongWords': wrongWords,
      'wpm': wpm,
      'accuracy': accuracy,
      'duration': duration.inMilliseconds,
      'mistakeCount': mistakeCount,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      id: json['id'],
      dictionaryId: json['dictionaryId'],
      wordsCount: json['wordsCount'],
      correctWords: json['correctWords'],
      wrongWords: json['wrongWords'],
      wpm: json['wpm'].toDouble(),
      accuracy: json['accuracy'].toDouble(),
      duration: Duration(milliseconds: json['duration']),
      mistakeCount: Map<String, int>.from(json['mistakeCount']),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}
