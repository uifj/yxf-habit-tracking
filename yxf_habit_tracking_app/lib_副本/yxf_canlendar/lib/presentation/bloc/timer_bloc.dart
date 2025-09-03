import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/timer_session.dart';
import '../../data/repositories/timer_repository.dart';
import '../../core/error/failures.dart';
import 'timer_event.dart';
import 'timer_state.dart';

/// 番茄钟计时器BLoC
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository _timerRepository;
  Timer? _timer;
  TimerSession? _currentSession;
  int _remainingSeconds = 0;
  
  TimerBloc({
    required TimerRepository timerRepository,
  }) : _timerRepository = timerRepository,
       super(const TimerInitial()) {
    on<InitializeTimerEvent>(_onInitializeTimer);
    on<StartTimerEvent>(_onStartTimer);
    on<PauseTimerEvent>(_onPauseTimer);
    on<ResumeTimerEvent>(_onResumeTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<ResetTimerEvent>(_onResetTimer);
    on<TimerTickEvent>(_onTimerTick);
    on<CompleteTimerEvent>(_onCompleteTimer);
    on<SkipSessionEvent>(_onSkipSession);
    on<SwitchSessionTypeEvent>(_onSwitchSessionType);
    on<LoadTimerSessionsEvent>(_onLoadTimerSessions);
    on<DeleteTimerSessionEvent>(_onDeleteTimerSession);
    on<UpdateTimerSettingsEvent>(_onUpdateTimerSettings);
    on<GetTimerStatsEvent>(_onGetTimerStats);
    on<SetTimerGoalEvent>(_onSetTimerGoal);
    on<AddOvertimeEvent>(_onAddOvertime);
  }
  
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
  
  /// 初始化计时器
  Future<void> _onInitializeTimer(
    InitializeTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    emit(const TimerLoading());
    try {
      final sessions = await _timerRepository.getAllSessions();
      final stats = await _timerRepository.getTodayStats();
      
      emit(TimerReady(
        settings: const TimerSettings(),
        sessions: sessions,
        stats: TimerStats(
          totalSessions: stats['totalSessions'] ?? 0,
          completedSessions: stats['completedSessions'] ?? 0,
          totalMinutes: stats['totalMinutes'] ?? 0,
          todayMinutes: stats['todayMinutes'] ?? 0,
          completionRate: (stats['completionRate'] ?? 0.0).toDouble(),
        ),
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: failure.message,
      ));
    }
  }
  
  /// 开始计时器
  Future<void> _onStartTimer(
    StartTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerReady && state is! TimerCompleted) return;
    
    final settings = _getSettingsFromState();
    if (settings == null) return;
    
    try {
      // 创建新的计时器会话
      final duration = event.customDuration ?? _getDefaultDuration(event.sessionType, settings);
      _currentSession = TimerSession.workSession(
        taskId: event.taskId,
        durationMinutes: duration,
      ).copyWith(
        type: event.sessionType,
        status: SessionStatus.running,
        startTime: DateTime.now(),
      );
      
      _remainingSeconds = duration * 60;
      
      // 保存会话到数据库
      final sessionId = await _timerRepository.addSession(_currentSession!);
      _currentSession = _currentSession!.copyWith(id: sessionId);
      
      // 开始计时
      _startTicking();
      
      emit(TimerRunning(
        currentSession: _currentSession!,
        settings: settings,
        remainingSeconds: _remainingSeconds,
        progress: 0.0,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '启动计时器失败: ${failure.message}',
      ));
    }
  }
  
  /// 暂停计时器
  Future<void> _onPauseTimer(
    PauseTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning) return;
    
    final currentState = state as TimerRunning;
    _timer?.cancel();
    
    try {
      // 更新会话状态
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.paused,
        elapsedSeconds: _currentSession!.durationMinutes * 60 - _remainingSeconds,
      );
      
      await _timerRepository.updateSession(_currentSession!);
      
      emit(TimerPaused(
        currentSession: _currentSession!,
        settings: currentState.settings,
        remainingSeconds: _remainingSeconds,
        progress: currentState.progress,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '暂停计时器失败: ${failure.message}',
      ));
    }
  }
  
  /// 恢复计时器
  Future<void> _onResumeTimer(
    ResumeTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerPaused) return;
    
    final currentState = state as TimerPaused;
    
    try {
      // 更新会话状态
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.running,
      );
      
      await _timerRepository.updateSession(_currentSession!);
      
      // 恢复计时
      _startTicking();
      
      emit(TimerRunning(
        currentSession: _currentSession!,
        settings: currentState.settings,
        remainingSeconds: _remainingSeconds,
        progress: currentState.progress,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '恢复计时器失败: ${failure.message}',
      ));
    }
  }
  
  /// 停止计时器
  Future<void> _onStopTimer(
    StopTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning && state is! TimerPaused) return;
    
    _timer?.cancel();
    
    try {
      if (event.saveSession && _currentSession != null) {
        // 更新会话状态
        _currentSession = _currentSession!.copyWith(
          status: SessionStatus.cancelled,
          endTime: DateTime.now(),
          elapsedSeconds: _currentSession!.durationMinutes * 60 - _remainingSeconds,
        );
        
        await _timerRepository.updateSession(_currentSession!);
      }
      
      // 重置状态
      _currentSession = null;
      _remainingSeconds = 0;
      
      // 重新加载数据
      add(const InitializeTimerEvent());
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '停止计时器失败: ${failure.message}',
      ));
    }
  }
  
  /// 重置计时器
  Future<void> _onResetTimer(
    ResetTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    _timer?.cancel();
    _currentSession = null;
    _remainingSeconds = 0;
    
    add(const InitializeTimerEvent());
  }
  
  /// 计时器滴答
  Future<void> _onTimerTick(
    TimerTickEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning) return;
    
    final currentState = state as TimerRunning;
    
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      final totalSeconds = _currentSession!.durationMinutes * 60;
      final progress = 1.0 - (_remainingSeconds / totalSeconds);
      
      emit(currentState.copyWith(
        remainingSeconds: _remainingSeconds,
        progress: progress,
      ));
    } else {
      // 计时器完成
      add(const CompleteTimerEvent());
    }
  }
  
  /// 完成计时器
  Future<void> _onCompleteTimer(
    CompleteTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning) return;
    
    final currentState = state as TimerRunning;
    _timer?.cancel();
    
    try {
      // 更新会话状态
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now(),
        elapsedSeconds: _currentSession!.durationMinutes * 60,
        isCompleted: true,
      );
      
      await _timerRepository.updateSession(_currentSession!);
      
      // 计算下一个会话类型
      final nextSessionType = _calculateNextSessionType(
        _currentSession!.type,
        currentState.completedPomodoros + 1,
        currentState.settings,
      );
      
      emit(TimerCompleted(
        completedSession: _currentSession!,
        settings: currentState.settings,
        completedPomodoros: _currentSession!.type == SessionType.work 
            ? currentState.completedPomodoros + 1 
            : currentState.completedPomodoros,
        nextSessionType: nextSessionType,
      ));
      
      // 重置当前会话
      _currentSession = null;
      _remainingSeconds = 0;
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '完成计时器失败: ${failure.message}',
      ));
    }
  }
  
  /// 跳过当前会话
  Future<void> _onSkipSession(
    SkipSessionEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning && state is! TimerPaused) return;
    
    _timer?.cancel();
    
    try {
      if (_currentSession != null) {
        // 标记会话为跳过
        _currentSession = _currentSession!.copyWith(
          status: SessionStatus.cancelled,
          endTime: DateTime.now(),
          elapsedSeconds: _currentSession!.durationMinutes * 60 - _remainingSeconds,
          metadata: {'skipped': true},
        );
        
        await _timerRepository.updateSession(_currentSession!);
      }
      
      // 重置状态
      _currentSession = null;
      _remainingSeconds = 0;
      
      // 重新加载数据
      add(const InitializeTimerEvent());
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '跳过会话失败: ${failure.message}',
      ));
    }
  }
  
  /// 切换会话类型
  Future<void> _onSwitchSessionType(
    SwitchSessionTypeEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerReady && state is! TimerCompleted) return;
    
    // 开始新的会话
    add(StartTimerEvent(sessionType: event.sessionType));
  }
  
  /// 加载计时器会话
  Future<void> _onLoadTimerSessions(
    LoadTimerSessionsEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      List<TimerSession> sessions;
      
      if (event.startDate != null && event.endDate != null) {
        sessions = await _timerRepository.getSessionsByDateRange(
          event.startDate!,
          event.endDate!,
        );
      } else if (event.taskId != null) {
        sessions = await _timerRepository.getSessionsByTaskId(event.taskId!);
      } else {
        sessions = await _timerRepository.getAllSessions();
      }
      
      if (state is TimerReady) {
        final currentState = state as TimerReady;
        emit(currentState.copyWith(sessions: sessions));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '加载计时器会话失败: ${failure.message}',
      ));
    }
  }
  
  /// 删除计时器会话
  Future<void> _onDeleteTimerSession(
    DeleteTimerSessionEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      final success = await _timerRepository.deleteSession(event.sessionId);
      if (success) {
        // 重新加载会话
        add(const LoadTimerSessionsEvent());
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '删除计时器会话失败: ${failure.message}',
      ));
    }
  }
  
  /// 更新计时器设置
  Future<void> _onUpdateTimerSettings(
    UpdateTimerSettingsEvent event,
    Emitter<TimerState> emit,
  ) async {
    final currentSettings = _getSettingsFromState() ?? const TimerSettings();
    
    final newSettings = currentSettings.copyWith(
      workDuration: event.workDuration,
      shortBreakDuration: event.shortBreakDuration,
      longBreakDuration: event.longBreakDuration,
      longBreakInterval: event.longBreakInterval,
      autoStartBreaks: event.autoStartBreaks,
      autoStartPomodoros: event.autoStartPomodoros,
      enableNotifications: event.enableNotifications,
      enableSounds: event.enableSounds,
    );
    
    emit(TimerSettingsUpdated(
      settings: newSettings,
      message: '计时器设置已更新',
    ));
    
    // 如果当前是就绪状态，更新设置
    if (state is TimerReady) {
      final currentState = state as TimerReady;
      emit(currentState.copyWith(settings: newSettings));
    }
  }
  
  /// 获取计时器统计
  Future<void> _onGetTimerStats(
    GetTimerStatsEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      final stats = await _timerRepository.getTimerStats(
        startDate: event.startDate,
        endDate: event.endDate,
        taskId: event.taskId,
      );
      
      final sessions = await _timerRepository.getAllSessions();
      
      emit(TimerStatsLoaded(
        stats: TimerStats(
          totalSessions: stats['totalSessions'] ?? 0,
          completedSessions: stats['completedSessions'] ?? 0,
          totalMinutes: stats['totalMinutes'] ?? 0,
          todayMinutes: stats['todayMinutes'] ?? 0,
          weekMinutes: stats['weekMinutes'] ?? 0,
          completionRate: (stats['completionRate'] ?? 0.0).toDouble(),
          currentStreak: stats['currentStreak'] ?? 0,
          longestStreak: stats['longestStreak'] ?? 0,
        ),
        settings: _getSettingsFromState() ?? const TimerSettings(),
        sessions: sessions,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '获取计时器统计失败: ${failure.message}',
      ));
    }
  }
  
  /// 设置计时器目标
  Future<void> _onSetTimerGoal(
    SetTimerGoalEvent event,
    Emitter<TimerState> emit,
  ) async {
    // TODO: 实现设置计时器目标的逻辑
    // 这里可以保存到本地存储或数据库
  }
  
  /// 添加加时
  Future<void> _onAddOvertime(
    AddOvertimeEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state is! TimerRunning) return;
    
    final currentState = state as TimerRunning;
    _remainingSeconds += event.additionalMinutes * 60;
    
    try {
      // 更新会话的加时信息
      _currentSession = _currentSession!.copyWith(
        overtimeSeconds: _currentSession!.overtimeSeconds + (event.additionalMinutes * 60),
      );
      
      await _timerRepository.updateSession(_currentSession!);
      
      final totalSeconds = _currentSession!.durationMinutes * 60 + _currentSession!.overtimeSeconds;
      final progress = 1.0 - (_remainingSeconds / totalSeconds);
      
      emit(currentState.copyWith(
        currentSession: _currentSession!,
        remainingSeconds: _remainingSeconds,
        progress: progress,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TimerError(
        failure: failure,
        message: '添加加时失败: ${failure.message}',
      ));
    }
  }
  
  /// 开始计时
  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const TimerTickEvent());
    });
  }
  
  /// 获取默认时长
  int _getDefaultDuration(SessionType type, TimerSettings settings) {
    switch (type) {
      case SessionType.work:
        return settings.workDuration;
      case SessionType.shortBreak:
        return settings.shortBreakDuration;
      case SessionType.longBreak:
        return settings.longBreakDuration;
    }
  }
  
  /// 计算下一个会话类型
  SessionType? _calculateNextSessionType(
    SessionType currentType,
    int completedPomodoros,
    TimerSettings settings,
  ) {
    if (currentType == SessionType.work) {
      // 工作会话完成后，判断是短休息还是长休息
      if (completedPomodoros % settings.longBreakInterval == 0) {
        return SessionType.longBreak;
      } else {
        return SessionType.shortBreak;
      }
    } else {
      // 休息会话完成后，开始工作会话
      return SessionType.work;
    }
  }
  
  /// 从状态中获取设置
  TimerSettings? _getSettingsFromState() {
    if (state is TimerReady) {
      return (state as TimerReady).settings;
    } else if (state is TimerRunning) {
      return (state as TimerRunning).settings;
    } else if (state is TimerPaused) {
      return (state as TimerPaused).settings;
    } else if (state is TimerCompleted) {
      return (state as TimerCompleted).settings;
    }
    return null;
  }
  
  /// 将异常映射为失败类型
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }
    return DatabaseFailure(message: exception.toString());
  }
}