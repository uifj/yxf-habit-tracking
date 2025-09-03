import 'package:equatable/equatable.dart';
import '../../data/models/habit.dart';

/// 习惯追踪事件基类
sealed class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化习惯事件
class InitializeHabitEvent extends HabitEvent {
  const InitializeHabitEvent();
}

/// 加载习惯列表事件
class LoadHabitsEvent extends HabitEvent {
  final bool forceRefresh;
  
  const LoadHabitsEvent({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

/// 添加习惯事件
class AddHabitEvent extends HabitEvent {
  final Habit habit;
  
  const AddHabitEvent(this.habit);
  
  @override
  List<Object?> get props => [habit];
}

/// 更新习惯事件
class UpdateHabitEvent extends HabitEvent {
  final Habit habit;
  
  const UpdateHabitEvent(this.habit);
  
  @override
  List<Object?> get props => [habit];
}

/// 删除习惯事件
class DeleteHabitEvent extends HabitEvent {
  final int habitId;
  
  const DeleteHabitEvent(this.habitId);
  
  @override
  List<Object?> get props => [habitId];
}

/// 标记习惯完成事件
class MarkHabitCompletedEvent extends HabitEvent {
  final int habitId;
  final DateTime date;
  
  const MarkHabitCompletedEvent(this.habitId, this.date);
  
  @override
  List<Object?> get props => [habitId, date];
}

/// 取消习惯完成事件
class UnmarkHabitCompletedEvent extends HabitEvent {
  final int habitId;
  final DateTime date;
  
  const UnmarkHabitCompletedEvent(this.habitId, this.date);
  
  @override
  List<Object?> get props => [habitId, date];
}

/// 按标签筛选习惯事件
class FilterHabitsByTagEvent extends HabitEvent {
  final String? tag;
  
  const FilterHabitsByTagEvent(this.tag);
  
  @override
  List<Object?> get props => [tag];
}

/// 搜索习惯事件
class SearchHabitsEvent extends HabitEvent {
  final String query;
  
  const SearchHabitsEvent(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// 切换习惯激活状态事件
class ToggleHabitActiveEvent extends HabitEvent {
  final int habitId;
  
  const ToggleHabitActiveEvent(this.habitId);
  
  @override
  List<Object?> get props => [habitId];
}

/// 获取习惯统计事件
class GetHabitStatsEvent extends HabitEvent {
  final int habitId;
  final int days;
  
  const GetHabitStatsEvent(this.habitId, {this.days = 30});
  
  @override
  List<Object?> get props => [habitId, days];
}

/// 批量导入习惯事件
class BulkImportHabitsEvent extends HabitEvent {
  final List<Habit> habits;
  
  const BulkImportHabitsEvent(this.habits);
  
  @override
  List<Object?> get props => [habits];
}

/// 同步习惯数据事件
class SyncHabitsEvent extends HabitEvent {
  const SyncHabitsEvent();
}

/// 刷新习惯事件
class RefreshHabitsEvent extends HabitEvent {
  const RefreshHabitsEvent();
}