import 'package:equatable/equatable.dart';
import '../../data/models/timer_session.dart';
import '../../core/error/failures.dart';

/// 番茄钟计时器设置
class TimerSettings extends Equatable {
  final int workDuration; // 工作时长（分钟）
  final int shortBreakDuration; // 短休息时长（分钟）
  final int longBreakDuration; // 长休息时长（分钟）
  final int longBreakInterval; // 长休息间隔（几个番茄钟后）
  final bool autoStartBreaks; // 自动开始休息
  final bool autoStartPomodoros; // 自动开始番茄钟
  final bool enableNotifications; // 启用通知
  final bool enableSounds; // 启用声音

  const TimerSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.enableNotifications = true,
    this.enableSounds = true,
  });

  @override
  List<Object?> get props => [
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        longBreakInterval,
        autoStartBreaks,
        autoStartPomodoros,
        enableNotifications,
        enableSounds,
      ];

  TimerSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? enableNotifications,
    bool? enableSounds,
  }) {
    return TimerSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSounds: enableSounds ?? this.enableSounds,
    );
  }
}

/// 计时器统计数据
class TimerStats extends Equatable {
  final int totalSessions;
  final int completedSessions;
  final int totalMinutes;
  final int todayMinutes;
  final int weekMinutes;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final Map<SessionType, int> sessionTypeCount;

  const TimerStats({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.totalMinutes = 0,
    this.todayMinutes = 0,
    this.weekMinutes = 0,
    this.completionRate = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.sessionTypeCount = const {},
  });

  @override
  List<Object?> get props => [
        totalSessions,
        completedSessions,
        totalMinutes,
        todayMinutes,
        weekMinutes,
        completionRate,
        currentStreak,
        longestStreak,
        sessionTypeCount,
      ];
}

/// 番茄钟计时器状态基类
sealed class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class TimerInitial extends TimerState {
  const TimerInitial();
}

/// 计时器就绪状态
class TimerReady extends TimerState {
  final TimerSettings settings;
  final List<TimerSession> sessions;
  final TimerStats stats;
  final int completedPomodoros; // 今日已完成的番茄钟数量

  const TimerReady({
    required this.settings,
    this.sessions = const [],
    this.stats = const TimerStats(),
    this.completedPomodoros = 0,
  });

  @override
  List<Object?> get props => [settings, sessions, stats, completedPomodoros];

  TimerReady copyWith({
    TimerSettings? settings,
    List<TimerSession>? sessions,
    TimerStats? stats,
    int? completedPomodoros,
  }) {
    return TimerReady(
      settings: settings ?? this.settings,
      sessions: sessions ?? this.sessions,
      stats: stats ?? this.stats,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }
}

/// 计时器运行状态
class TimerRunning extends TimerState {
  final TimerSession currentSession;
  final TimerSettings settings;
  final List<TimerSession> sessions;
  final TimerStats stats;
  final int completedPomodoros;
  final int remainingSeconds;
  final double progress; // 0.0 - 1.0

  const TimerRunning({
    required this.currentSession,
    required this.settings,
    required this.remainingSeconds,
    required this.progress,
    this.sessions = const [],
    this.stats = const TimerStats(),
    this.completedPomodoros = 0,
  });

  @override
  List<Object?> get props => [
        currentSession,
        settings,
        sessions,
        stats,
        completedPomodoros,
        remainingSeconds,
        progress,
      ];

  TimerRunning copyWith({
    TimerSession? currentSession,
    TimerSettings? settings,
    List<TimerSession>? sessions,
    TimerStats? stats,
    int? completedPomodoros,
    int? remainingSeconds,
    double? progress,
  }) {
    return TimerRunning(
      currentSession: currentSession ?? this.currentSession,
      settings: settings ?? this.settings,
      sessions: sessions ?? this.sessions,
      stats: stats ?? this.stats,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      progress: progress ?? this.progress,
    );
  }

  /// 格式化剩余时间为 MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 计时器暂停状态
class TimerPaused extends TimerState {
  final TimerSession currentSession;
  final TimerSettings settings;
  final List<TimerSession> sessions;
  final TimerStats stats;
  final int completedPomodoros;
  final int remainingSeconds;
  final double progress;

  const TimerPaused({
    required this.currentSession,
    required this.settings,
    required this.remainingSeconds,
    required this.progress,
    this.sessions = const [],
    this.stats = const TimerStats(),
    this.completedPomodoros = 0,
  });

  @override
  List<Object?> get props => [
        currentSession,
        settings,
        sessions,
        stats,
        completedPomodoros,
        remainingSeconds,
        progress,
      ];

  /// 格式化剩余时间为 MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 计时器完成状态
class TimerCompleted extends TimerState {
  final TimerSession completedSession;
  final TimerSettings settings;
  final List<TimerSession> sessions;
  final TimerStats stats;
  final int completedPomodoros;
  final SessionType? nextSessionType; // 建议的下一个会话类型

  const TimerCompleted({
    required this.completedSession,
    required this.settings,
    this.sessions = const [],
    this.stats = const TimerStats(),
    this.completedPomodoros = 0,
    this.nextSessionType,
  });

  @override
  List<Object?> get props => [
        completedSession,
        settings,
        sessions,
        stats,
        completedPomodoros,
        nextSessionType,
      ];
}

/// 计时器加载状态
class TimerLoading extends TimerState {
  const TimerLoading();
}

/// 计时器错误状态
class TimerError extends TimerState {
  final Failure failure;
  final String message;

  const TimerError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

/// 计时器设置更新成功状态
class TimerSettingsUpdated extends TimerState {
  final TimerSettings settings;
  final String message;

  const TimerSettingsUpdated({
    required this.settings,
    required this.message,
  });

  @override
  List<Object?> get props => [settings, message];
}

/// 计时器统计加载完成状态
class TimerStatsLoaded extends TimerState {
  final TimerStats stats;
  final TimerSettings settings;
  final List<TimerSession> sessions;

  const TimerStatsLoaded({
    required this.stats,
    required this.settings,
    this.sessions = const [],
  });

  @override
  List<Object?> get props => [stats, settings, sessions];
}
