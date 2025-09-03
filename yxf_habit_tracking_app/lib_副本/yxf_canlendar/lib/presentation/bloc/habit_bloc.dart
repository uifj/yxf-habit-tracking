import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
import '../../core/error/failures.dart';
import '../../core/utils/logger.dart';
import 'habit_event.dart';
import 'habit_state.dart';

/// 习惯追踪BLoC - 企业级实现
/// 提供完整的习惯管理功能，包括CRUD操作、统计分析、缓存机制等
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _habitRepository;
  
  // 缓存机制
  static const Duration _cacheTimeout = Duration(minutes: 5);
  DateTime? _lastCacheTime;
  List<Habit>? _cachedHabits;
  
  // 性能监控
  final Map<String, DateTime> _operationStartTimes = {};
  
  HabitBloc({
    required HabitRepository habitRepository,
  }) : _habitRepository = habitRepository,
       super(const HabitInitial()) {
    Logger.info('HabitBloc initialized', tag: 'HabitBloc');
    
    // 注册事件处理器
    on<InitializeHabitEvent>(_onInitializeHabit);
    on<LoadHabitsEvent>(_onLoadHabits);
    on<AddHabitEvent>(_onAddHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<MarkHabitCompletedEvent>(_onMarkHabitCompleted);
    on<UnmarkHabitCompletedEvent>(_onUnmarkHabitCompleted);
    on<FilterHabitsByTagEvent>(_onFilterHabitsByTag);
    on<SearchHabitsEvent>(_onSearchHabits);
    on<ToggleHabitActiveEvent>(_onToggleHabitActive);
    on<GetHabitStatsEvent>(_onGetHabitStats);
    on<BulkImportHabitsEvent>(_onBulkImportHabits);
    on<SyncHabitsEvent>(_onSyncHabits);
    on<RefreshHabitsEvent>(_onRefreshHabits);
  }
  
  /// 开始性能监控
  void _startPerformanceMonitoring(String operation) {
    _operationStartTimes[operation] = DateTime.now();
  }
  
  /// 结束性能监控并记录
  void _endPerformanceMonitoring(String operation, {Map<String, dynamic>? metadata}) {
    final startTime = _operationStartTimes.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      Logger.performance(operation, duration, metadata: metadata);
    }
  }
  
  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_lastCacheTime == null || _cachedHabits == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }
  
  /// 更新缓存
  void _updateCache(List<Habit> habits) {
    _cachedHabits = List.from(habits);
    _lastCacheTime = DateTime.now();
  }
  
  /// 初始化习惯 - 企业级实现
  Future<void> _onInitializeHabit(
    InitializeHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    _startPerformanceMonitoring('initialize_habits');
    Logger.blocEvent('HabitBloc', 'InitializeHabitEvent');
    
    emit(const HabitLoading());
    
    try {
      // 优先使用缓存
      if (_isCacheValid()) {
        Logger.debug('Using cached habits data');
        emit(HabitLoaded(
          habits: _cachedHabits!,
          filteredHabits: _cachedHabits!,
        ));
        _endPerformanceMonitoring('initialize_habits', metadata: {'source': 'cache'});
        return;
      }
      
      final habits = await _habitRepository.getAllHabits();
      _updateCache(habits);
      
      emit(HabitLoaded(
        habits: habits,
        filteredHabits: habits,
      ));
      
      Logger.info('Habits initialized successfully: ${habits.length} habits loaded');
      _endPerformanceMonitoring('initialize_habits', metadata: {
        'source': 'repository',
        'count': habits.length,
      });
    } catch (e, stackTrace) {
      final failure = _mapExceptionToFailure(e);
      Logger.error(
        'Failed to initialize habits: ${failure.message}',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HabitError(
        failure: failure,
        message: failure.message,
      ));
      
      _endPerformanceMonitoring('initialize_habits', metadata: {'error': true});
    }
  }
  
  /// 加载习惯列表 - 企业级实现
  Future<void> _onLoadHabits(
    LoadHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    _startPerformanceMonitoring('load_habits');
    Logger.blocEvent('HabitBloc', 'LoadHabitsEvent', data: {
      'forceRefresh': event.forceRefresh,
    });
    
    // 智能缓存策略
    if (!event.forceRefresh && state is HabitLoaded && _isCacheValid()) {
      Logger.debug('Skipping load - using existing valid cache');
      _endPerformanceMonitoring('load_habits', metadata: {'skipped': true});
      return;
    }
    
    emit(const HabitLoading());
    
    try {
      final habits = await _habitRepository.getAllHabits();
      _updateCache(habits);
      
      emit(HabitLoaded(
        habits: habits,
        filteredHabits: habits,
      ));
      
      Logger.info('Habits loaded successfully: ${habits.length} habits');
      _endPerformanceMonitoring('load_habits', metadata: {
        'count': habits.length,
        'forceRefresh': event.forceRefresh,
      });
    } catch (e, stackTrace) {
      final failure = _mapExceptionToFailure(e);
      Logger.error(
        'Failed to load habits: ${failure.message}',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HabitError(
        failure: failure,
        message: failure.message,
      ));
      
      _endPerformanceMonitoring('load_habits', metadata: {'error': true});
    }
  }
  
  /// 数据验证
  String? _validateHabit(Habit habit) {
    if (habit.name.trim().isEmpty) {
      return '习惯名称不能为空';
    }
    if (habit.name.trim().length < 2) {
      return '习惯名称至少需要2个字符';
    }
    if (habit.name.trim().length > 50) {
      return '习惯名称不能超过50个字符';
    }
    return null;
  }
  
  /// 检查重复习惯
  bool _isDuplicateHabit(String name, List<Habit> existingHabits) {
    return existingHabits.any((habit) => 
      habit.name.trim().toLowerCase() == name.trim().toLowerCase());
  }
  
  /// 添加习惯 - 企业级实现
  Future<void> _onAddHabit(
    AddHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) {
      Logger.warning('Cannot add habit - invalid state: ${state.runtimeType}');
      return;
    }
    
    _startPerformanceMonitoring('add_habit');
     Logger.blocEvent('HabitBloc', 'AddHabitEvent', data: {
       'habitName': event.habit.name,
       'habitTag': event.habit.tag,
     });
    
    final currentState = state as HabitLoaded;
    
    // 数据验证
    final validationError = _validateHabit(event.habit);
    if (validationError != null) {
      Logger.warning('Habit validation failed: $validationError');
      emit(HabitError(
        failure: ValidationFailure(message: validationError),
        message: validationError,
      ));
      _endPerformanceMonitoring('add_habit', metadata: {'validation_error': true});
      return;
    }
    
    // 检查重复
    if (_isDuplicateHabit(event.habit.name, currentState.habits)) {
      const duplicateMessage = '已存在同名习惯';
      Logger.warning('Duplicate habit detected: ${event.habit.name}');
      emit(HabitError(
        failure: const ValidationFailure(message: duplicateMessage),
        message: duplicateMessage,
      ));
      _endPerformanceMonitoring('add_habit', metadata: {'duplicate_error': true});
      return;
    }
    
    try {
      final habitId = await _habitRepository.addHabit(event.habit);
      final newHabit = event.habit.copyWith(
        id: habitId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final updatedHabits = [...currentState.habits, newHabit];
      _updateCache(updatedHabits); // 更新缓存
      
      final newState = currentState.copyWith(
        habits: updatedHabits,
        filteredHabits: _applyFilters(updatedHabits, currentState),
      );
      
      emit(HabitOperationSuccess(
        message: '习惯"${newHabit.name}"添加成功',
        previousState: newState,
      ));
      
      // 返回到加载状态
      emit(newState);
      
      Logger.info('Habit added successfully: ${newHabit.name} (ID: $habitId)');
      _endPerformanceMonitoring('add_habit', metadata: {
        'habitId': habitId,
        'habitName': newHabit.name,
      });
    } catch (e, stackTrace) {
      final failure = _mapExceptionToFailure(e);
      Logger.error(
        'Failed to add habit: ${failure.message}',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HabitError(
        failure: failure,
        message: '添加习惯失败: ${failure.message}',
      ));
      
      _endPerformanceMonitoring('add_habit', metadata: {'error': true});
    }
  }
  
  /// 更新习惯
  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final success = await _habitRepository.updateHabit(event.habit);
      if (success) {
        final updatedHabits = currentState.habits.map((habit) {
          return habit.id == event.habit.id ? event.habit : habit;
        }).toList();
        
        emit(HabitOperationSuccess(
          message: '习惯更新成功',
          previousState: currentState.copyWith(
            habits: updatedHabits,
            filteredHabits: _applyFilters(updatedHabits, currentState),
          ),
        ));
        
        // 返回到加载状态
        emit(currentState.copyWith(
          habits: updatedHabits,
          filteredHabits: _applyFilters(updatedHabits, currentState),
        ));
      } else {
        emit(HabitError(
          failure: const DatabaseFailure(message: '更新失败'),
          message: '更新习惯失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '更新习惯失败: ${failure.message}',
      ));
    }
  }
  
  /// 删除习惯
  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final success = await _habitRepository.deleteHabit(event.habitId);
      if (success) {
        final updatedHabits = currentState.habits
            .where((habit) => habit.id != event.habitId)
            .toList();
        
        emit(HabitOperationSuccess(
          message: '习惯删除成功',
          previousState: currentState.copyWith(
            habits: updatedHabits,
            filteredHabits: _applyFilters(updatedHabits, currentState),
          ),
        ));
        
        // 返回到加载状态
        emit(currentState.copyWith(
          habits: updatedHabits,
          filteredHabits: _applyFilters(updatedHabits, currentState),
        ));
      } else {
        emit(HabitError(
          failure: const DatabaseFailure(message: '删除失败'),
          message: '删除习惯失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '删除习惯失败: ${failure.message}',
      ));
    }
  }
  
  /// 标记习惯完成
  Future<void> _onMarkHabitCompleted(
    MarkHabitCompletedEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final success = await _habitRepository.markHabitCompleted(
        event.habitId,
        event.date,
      );
      
      if (success) {
        // 更新本地状态
        final updatedHabits = currentState.habits.map((habit) {
          if (habit.id == event.habitId) {
            final updatedCompletedDates = [...habit.completedDates];
            final dateString = _formatDate(event.date);
            if (!updatedCompletedDates.contains(dateString)) {
              updatedCompletedDates.add(dateString);
            }
            return habit.copyWith(
              completedDates: updatedCompletedDates,
              totalCompletions: habit.totalCompletions + 1,
            );
          }
          return habit;
        }).toList();
        
        emit(currentState.copyWith(
          habits: updatedHabits,
          filteredHabits: _applyFilters(updatedHabits, currentState),
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '标记习惯完成失败: ${failure.message}',
      ));
    }
  }
  
  /// 取消习惯完成标记
  Future<void> _onUnmarkHabitCompleted(
    UnmarkHabitCompletedEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final success = await _habitRepository.unmarkHabitCompleted(
        event.habitId,
        event.date,
      );
      
      if (success) {
        // 更新本地状态
        final updatedHabits = currentState.habits.map((habit) {
          if (habit.id == event.habitId) {
            final updatedCompletedDates = [...habit.completedDates];
            final dateString = _formatDate(event.date);
            updatedCompletedDates.remove(dateString);
            return habit.copyWith(
              completedDates: updatedCompletedDates,
              totalCompletions: (habit.totalCompletions - 1).clamp(0, double.infinity).toInt(),
            );
          }
          return habit;
        }).toList();
        
        emit(currentState.copyWith(
          habits: updatedHabits,
          filteredHabits: _applyFilters(updatedHabits, currentState),
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '取消习惯完成标记失败: ${failure.message}',
      ));
    }
  }
  
  /// 按标签筛选习惯
  Future<void> _onFilterHabitsByTag(
    FilterHabitsByTagEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    final filteredHabits = event.tag == null
        ? currentState.habits
        : currentState.habits.where((habit) => habit.tag == event.tag).toList();
    
    emit(currentState.copyWith(
      filteredHabits: filteredHabits,
      currentFilter: event.tag,
    ));
  }
  
  /// 搜索习惯
  Future<void> _onSearchHabits(
    SearchHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    if (event.query.isEmpty) {
      emit(currentState.copyWith(
        filteredHabits: currentState.habits,
        searchQuery: null,
      ));
      return;
    }
    
    final filteredHabits = currentState.habits.where((habit) {
      return habit.name.toLowerCase().contains(event.query.toLowerCase()) ||
             (habit.description?.toLowerCase().contains(event.query.toLowerCase()) ?? false);
    }).toList();
    
    emit(currentState.copyWith(
      filteredHabits: filteredHabits,
      searchQuery: event.query,
    ));
  }
  
  /// 切换习惯激活状态
  Future<void> _onToggleHabitActive(
    ToggleHabitActiveEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final success = await _habitRepository.toggleHabitActive(event.habitId);
      if (success) {
        final updatedHabits = currentState.habits.map((habit) {
          if (habit.id == event.habitId) {
            return habit.copyWith(isActive: !habit.isActive);
          }
          return habit;
        }).toList();
        
        emit(currentState.copyWith(
          habits: updatedHabits,
          filteredHabits: _applyFilters(updatedHabits, currentState),
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '切换习惯状态失败: ${failure.message}',
      ));
    }
  }
  
  /// 获取习惯统计
  Future<void> _onGetHabitStats(
    GetHabitStatsEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    emit(HabitStatsLoading(
      currentState: currentState,
      habitId: event.habitId,
    ));
    
    try {
      final stats = await _habitRepository.getHabitStats(
        event.habitId,
        days: event.days,
      );
      
      final updatedStats = Map<int, Map<String, dynamic>>.from(currentState.habitStats);
      updatedStats[event.habitId] = stats;
      
      final updatedState = currentState.copyWith(habitStats: updatedStats);
      
      emit(HabitStatsLoaded(
        updatedState: updatedState,
        habitId: event.habitId,
        stats: stats,
      ));
      
      // 返回到加载状态
      emit(updatedState);
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '获取习惯统计失败: ${failure.message}',
      ));
    }
  }
  
  /// 批量导入习惯
  Future<void> _onBulkImportHabits(
    BulkImportHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    
    try {
      final ids = await _habitRepository.bulkImportHabits(event.habits);
      if (ids.isNotEmpty) {
        // 重新加载习惯列表
        add(const LoadHabitsEvent(forceRefresh: true));
        
        emit(HabitOperationSuccess(
          message: '成功导入 ${ids.length} 个习惯',
          previousState: currentState,
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '批量导入习惯失败: ${failure.message}',
      ));
    }
  }
  
  /// 同步习惯数据
  Future<void> _onSyncHabits(
    SyncHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    if (state is! HabitLoaded) return;
    
    final currentState = state as HabitLoaded;
    emit(HabitSyncing(currentState));
    
    try {
      await _habitRepository.syncHabits();
      
      // 重新加载习惯列表
      final habits = await _habitRepository.getAllHabits();
      final updatedState = currentState.copyWith(
        habits: habits,
        filteredHabits: _applyFilters(habits, currentState),
      );
      
      emit(HabitSyncCompleted(
        updatedState: updatedState,
        message: '习惯数据同步成功',
      ));
      
      // 返回到加载状态
      emit(updatedState);
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(HabitError(
        failure: failure,
        message: '同步习惯数据失败: ${failure.message}',
      ));
    }
  }
  
  /// 刷新习惯
  Future<void> _onRefreshHabits(
    RefreshHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    add(const LoadHabitsEvent(forceRefresh: true));
  }
  
  /// 应用筛选条件
  List<Habit> _applyFilters(List<Habit> habits, HabitLoaded currentState) {
    var filtered = habits;
    
    // 应用标签筛选
    if (currentState.currentFilter != null) {
      filtered = filtered.where((habit) => habit.tag == currentState.currentFilter).toList();
    }
    
    // 应用搜索筛选
    if (currentState.searchQuery != null && currentState.searchQuery!.isNotEmpty) {
      filtered = filtered.where((habit) {
        return habit.name.toLowerCase().contains(currentState.searchQuery!.toLowerCase()) ||
               (habit.description?.toLowerCase().contains(currentState.searchQuery!.toLowerCase()) ?? false);
      }).toList();
    }
    
    return filtered;
  }
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 将异常映射为失败类型
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }
    return DatabaseFailure(message: exception.toString());
  }
}