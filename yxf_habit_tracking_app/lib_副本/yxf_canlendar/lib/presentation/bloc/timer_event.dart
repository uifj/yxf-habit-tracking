import 'package:equatable/equatable.dart';
import '../../data/models/timer_session.dart';

/// 番茄钟计时器事件基类
sealed class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化计时器事件
class InitializeTimerEvent extends TimerEvent {
  const InitializeTimerEvent();
}

/// 开始计时器事件
class StartTimerEvent extends TimerEvent {
  final SessionType sessionType;
  final int? taskId;
  final int? customDuration; // 自定义时长（分钟）
  
  const StartTimerEvent({
    required this.sessionType,
    this.taskId,
    this.customDuration,
  });
  
  @override
  List<Object?> get props => [sessionType, taskId, customDuration];
}

/// 暂停计时器事件
class PauseTimerEvent extends TimerEvent {
  const PauseTimerEvent();
}

/// 恢复计时器事件
class ResumeTimerEvent extends TimerEvent {
  const ResumeTimerEvent();
}

/// 停止计时器事件
class StopTimerEvent extends TimerEvent {
  final bool saveSession; // 是否保存会话记录
  
  const StopTimerEvent({this.saveSession = true});
  
  @override
  List<Object?> get props => [saveSession];
}

/// 重置计时器事件
class ResetTimerEvent extends TimerEvent {
  const ResetTimerEvent();
}

/// 计时器滴答事件（每秒触发）
class TimerTickEvent extends TimerEvent {
  const TimerTickEvent();
}

/// 完成计时器事件
class CompleteTimerEvent extends TimerEvent {
  const CompleteTimerEvent();
}

/// 跳过当前会话事件
class SkipSessionEvent extends TimerEvent {
  const SkipSessionEvent();
}

/// 切换会话类型事件
class SwitchSessionTypeEvent extends TimerEvent {
  final SessionType sessionType;
  
  const SwitchSessionTypeEvent(this.sessionType);
  
  @override
  List<Object?> get props => [sessionType];
}

/// 加载计时器会话历史事件
class LoadTimerSessionsEvent extends TimerEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? taskId;
  
  const LoadTimerSessionsEvent({
    this.startDate,
    this.endDate,
    this.taskId,
  });
  
  @override
  List<Object?> get props => [startDate, endDate, taskId];
}

/// 删除计时器会话事件
class DeleteTimerSessionEvent extends TimerEvent {
  final int sessionId;
  
  const DeleteTimerSessionEvent(this.sessionId);
  
  @override
  List<Object?> get props => [sessionId];
}

/// 更新计时器设置事件
class UpdateTimerSettingsEvent extends TimerEvent {
  final int? workDuration;
  final int? shortBreakDuration;
  final int? longBreakDuration;
  final int? longBreakInterval;
  final bool? autoStartBreaks;
  final bool? autoStartPomodoros;
  final bool? enableNotifications;
  final bool? enableSounds;
  
  const UpdateTimerSettingsEvent({
    this.workDuration,
    this.shortBreakDuration,
    this.longBreakDuration,
    this.longBreakInterval,
    this.autoStartBreaks,
    this.autoStartPomodoros,
    this.enableNotifications,
    this.enableSounds,
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
}

/// 获取计时器统计事件
class GetTimerStatsEvent extends TimerEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? taskId;
  
  const GetTimerStatsEvent({
    this.startDate,
    this.endDate,
    this.taskId,
  });
  
  @override
  List<Object?> get props => [startDate, endDate, taskId];
}

/// 设置计时器目标事件
class SetTimerGoalEvent extends TimerEvent {
  final int dailyGoalMinutes;
  final int weeklyGoalMinutes;
  
  const SetTimerGoalEvent({
    required this.dailyGoalMinutes,
    required this.weeklyGoalMinutes,
  });
  
  @override
  List<Object?> get props => [dailyGoalMinutes, weeklyGoalMinutes];
}

/// 添加加时事件
class AddOvertimeEvent extends TimerEvent {
  final int additionalMinutes;
  
  const AddOvertimeEvent(this.additionalMinutes);
  
  @override
  List<Object?> get props => [additionalMinutes];
}