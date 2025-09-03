import 'package:equatable/equatable.dart';
import '../../data/models/habit.dart';
import '../../core/error/failures.dart';

/// 习惯追踪状态基类
sealed class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class HabitInitial extends HabitState {
  const HabitInitial();
}

/// 加载中状态
class HabitLoading extends HabitState {
  const HabitLoading();
}

/// 加载成功状态
class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final List<Habit> filteredHabits;
  final String? currentFilter;
  final String? searchQuery;
  final Map<int, Map<String, dynamic>> habitStats;
  
  const HabitLoaded({
    required this.habits,
    required this.filteredHabits,
    this.currentFilter,
    this.searchQuery,
    this.habitStats = const {},
  });
  
  @override
  List<Object?> get props => [
    habits,
    filteredHabits,
    currentFilter,
    searchQuery,
    habitStats,
  ];
  
  /// 复制状态并更新部分属性
  HabitLoaded copyWith({
    List<Habit>? habits,
    List<Habit>? filteredHabits,
    String? currentFilter,
    String? searchQuery,
    Map<int, Map<String, dynamic>>? habitStats,
  }) {
    return HabitLoaded(
      habits: habits ?? this.habits,
      filteredHabits: filteredHabits ?? this.filteredHabits,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      habitStats: habitStats ?? this.habitStats,
    );
  }
  
  /// 获取活跃习惯
  List<Habit> get activeHabits => habits.where((h) => h.isActive).toList();
  
  /// 获取今日已完成习惯
  List<Habit> get todayCompletedHabits => habits.where((h) => h.isCompletedToday).toList();
  
  /// 获取今日完成率
  double get todayCompletionRate {
    if (activeHabits.isEmpty) return 0.0;
    return todayCompletedHabits.length / activeHabits.length;
  }
  
  /// 获取总连击数
  int get totalStreaks => habits.fold(0, (sum, habit) => sum + habit.streak);
}

/// 加载失败状态
class HabitError extends HabitState {
  final Failure failure;
  final String message;
  
  const HabitError({
    required this.failure,
    required this.message,
  });
  
  @override
  List<Object?> get props => [failure, message];
}

/// 操作成功状态
class HabitOperationSuccess extends HabitState {
  final String message;
  final HabitLoaded previousState;
  
  const HabitOperationSuccess({
    required this.message,
    required this.previousState,
  });
  
  @override
  List<Object?> get props => [message, previousState];
}

/// 同步中状态
class HabitSyncing extends HabitState {
  final HabitLoaded currentState;
  
  const HabitSyncing(this.currentState);
  
  @override
  List<Object?> get props => [currentState];
}

/// 同步完成状态
class HabitSyncCompleted extends HabitState {
  final HabitLoaded updatedState;
  final String message;
  
  const HabitSyncCompleted({
    required this.updatedState,
    required this.message,
  });
  
  @override
  List<Object?> get props => [updatedState, message];
}

/// 统计加载状态
class HabitStatsLoading extends HabitState {
  final HabitLoaded currentState;
  final int habitId;
  
  const HabitStatsLoading({
    required this.currentState,
    required this.habitId,
  });
  
  @override
  List<Object?> get props => [currentState, habitId];
}

/// 统计加载完成状态
class HabitStatsLoaded extends HabitState {
  final HabitLoaded updatedState;
  final int habitId;
  final Map<String, dynamic> stats;
  
  const HabitStatsLoaded({
    required this.updatedState,
    required this.habitId,
    required this.stats,
  });
  
  @override
  List<Object?> get props => [updatedState, habitId, stats];
}