part of 'todo_bloc.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

// 初始化事件
class InitializeTodoEvent extends TodoEvent {
  const InitializeTodoEvent();
}

// 加载任务事件
class LoadTasksEvent extends TodoEvent {
  final bool forceRefresh;

  const LoadTasksEvent({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

// 添加任务事件
class AddTaskEvent extends TodoEvent {
  final Task task;

  const AddTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

// 更新任务事件
class UpdateTaskEvent extends TodoEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

// 删除任务事件
class DeleteTaskEvent extends TodoEvent {
  final int taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

// 标记任务完成事件
class MarkTaskCompletedEvent extends TodoEvent {
  final Task task;

  const MarkTaskCompletedEvent(this.task);

  @override
  List<Object> get props => [task];
}

// 同步数据事件
class SyncDataEvent extends TodoEvent {
  const SyncDataEvent();
}

// 按日期过滤任务事件
class FilterTasksByDateEvent extends TodoEvent {
  final DateTime date;

  const FilterTasksByDateEvent(this.date);

  @override
  List<Object> get props => [date];
}

// 按优先级过滤任务事件
class FilterTasksByPriorityEvent extends TodoEvent {
  final String? priority;

  const FilterTasksByPriorityEvent(this.priority);

  @override
  List<Object> get props => [priority ?? ''];
}

// 清除所有任务事件
class ClearAllTasksEvent extends TodoEvent {
  const ClearAllTasksEvent();
}

// 批量插入任务事件
class BulkInsertTasksEvent extends TodoEvent {
  final List<Task> tasks;

  const BulkInsertTasksEvent(this.tasks);

  @override
  List<Object> get props => [tasks];
}

// 刷新任务事件
class RefreshTasksEvent extends TodoEvent {
  const RefreshTasksEvent();
}

// 搜索任务事件
class SearchTasksEvent extends TodoEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object> get props => [query];
}

// 添加子任务事件
class AddSubtaskEvent extends TodoEvent {
  final int parentTaskId;
  final Subtask subtask;

  const AddSubtaskEvent(this.parentTaskId, this.subtask);

  @override
  List<Object> get props => [parentTaskId, subtask];
}

// 更新子任务事件
class UpdateSubtaskEvent extends TodoEvent {
  final int parentTaskId;
  final Subtask subtask;

  const UpdateSubtaskEvent(this.parentTaskId, this.subtask);

  @override
  List<Object> get props => [parentTaskId, subtask];
}

// 删除子任务事件
class DeleteSubtaskEvent extends TodoEvent {
  final int parentTaskId;
  final int subtaskId;

  const DeleteSubtaskEvent(this.parentTaskId, this.subtaskId);

  @override
  List<Object> get props => [parentTaskId, subtaskId];
}

// 切换任务展开状态事件
class ToggleTaskExpandedEvent extends TodoEvent {
  final int taskId;

  const ToggleTaskExpandedEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

// 从习惯创建任务列表事件
class CreateTasksFromHabitEvent extends TodoEvent {
  final Habit habit;
  final DateTime date;
  final String startTime;
  final String endTime;

  const CreateTasksFromHabitEvent({
    required this.habit,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [habit, date, startTime, endTime];
}
