import 'package:equatable/equatable.dart';

/// 番茄钟会话类型
enum SessionType {
  work,
  shortBreak,
  longBreak,
}

/// 番茄钟会话状态
enum SessionStatus {
  idle,
  running,
  paused,
  completed,
  cancelled,
}

/// 番茄钟计时器会话模型
class TimerSession extends Equatable {
  final int? id;
  final String? userId;
  final int? taskId; // 关联的任务ID
  final SessionType type;
  final SessionStatus status;
  final int durationMinutes; // 会话时长（分钟）
  final int elapsedSeconds; // 已经过的时间（秒）
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted; // 是否完成
  final int overtimeSeconds; // 超时时间（秒）
  final Map<String, dynamic>? metadata; // 额外数据

  const TimerSession({
    required this.type,
    required this.status,
    required this.durationMinutes,
    required this.startTime,
    required this.createdAt,
    this.id,
    this.userId,
    this.taskId,
    this.elapsedSeconds = 0,
    this.endTime,
    this.updatedAt,
    this.isCompleted = false,
    this.overtimeSeconds = 0,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        taskId,
        type,
        status,
        durationMinutes,
        elapsedSeconds,
        startTime,
        endTime,
        createdAt,
        updatedAt,
        isCompleted,
        overtimeSeconds,
        metadata,
      ];

  /// 从JSON创建TimerSession对象
  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'],
      userId: json['userId'],
      taskId: json['taskId'],
      type: SessionType.values[json['type'] ?? 0],
      status: SessionStatus.values[json['status'] ?? 0],
      durationMinutes: json['durationMinutes'] ?? 25,
      elapsedSeconds: json['elapsedSeconds'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isCompleted: json['isCompleted'] ?? false,
      overtimeSeconds: json['overtimeSeconds'] ?? 0,
      metadata: json['metadata'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'type': type.index,
      'status': status.index,
      'durationMinutes': durationMinutes,
      'elapsedSeconds': elapsedSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'overtimeSeconds': overtimeSeconds,
      'metadata': metadata,
    };
  }

  /// 创建副本
  TimerSession copyWith({
    int? id,
    String? userId,
    int? taskId,
    SessionType? type,
    SessionStatus? status,
    int? durationMinutes,
    int? elapsedSeconds,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    int? overtimeSeconds,
    Map<String, dynamic>? metadata,
  }) {
    return TimerSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      overtimeSeconds: overtimeSeconds ?? this.overtimeSeconds,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 工厂方法：创建工作会话
  factory TimerSession.workSession({
    int? taskId,
    int durationMinutes = 25,
  }) {
    final now = DateTime.now();
    return TimerSession(
      type: SessionType.work,
      status: SessionStatus.idle,
      durationMinutes: durationMinutes,
      taskId: taskId,
      startTime: now,
      createdAt: now,
    );
  }

  /// 工厂方法：创建短休息会话
  factory TimerSession.shortBreakSession() {
    final now = DateTime.now();
    return TimerSession(
      type: SessionType.shortBreak,
      status: SessionStatus.idle,
      durationMinutes: 5,
      startTime: now,
      createdAt: now,
    );
  }

  /// 工厂方法：创建长休息会话
  factory TimerSession.longBreakSession() {
    final now = DateTime.now();
    return TimerSession(
      type: SessionType.longBreak,
      status: SessionStatus.idle,
      durationMinutes: 15,
      startTime: now,
      createdAt: now,
    );
  }

  /// 获取剩余时间（秒）
  int get remainingSeconds {
    final totalSeconds = durationMinutes * 60;
    return (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
  }

  /// 获取总时长（秒）
  int get totalSeconds => durationMinutes * 60;

  /// 获取进度百分比 (0.0 - 1.0)
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// 是否正在运行
  bool get isRunning => status == SessionStatus.running;

  /// 是否已暂停
  bool get isPaused => status == SessionStatus.paused;

  /// 是否处于空闲状态
  bool get isIdle => status == SessionStatus.idle;

  /// 是否已完成
  bool get isSessionCompleted => status == SessionStatus.completed;

  /// 是否已取消
  bool get isCancelled => status == SessionStatus.cancelled;

  /// 是否超时
  bool get isOvertime => elapsedSeconds > totalSeconds;

  /// 获取会话类型显示名称
  String get typeDisplayName {
    switch (type) {
      case SessionType.work:
        return '专注时间';
      case SessionType.shortBreak:
        return '短休息';
      case SessionType.longBreak:
        return '长休息';
    }
  }

  /// 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case SessionStatus.idle:
        return '待开始';
      case SessionStatus.running:
        return '进行中';
      case SessionStatus.paused:
        return '已暂停';
      case SessionStatus.completed:
        return '已完成';
      case SessionStatus.cancelled:
        return '已取消';
    }
  }

  /// 格式化剩余时间显示
  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化已用时间显示
  String get formattedElapsedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}