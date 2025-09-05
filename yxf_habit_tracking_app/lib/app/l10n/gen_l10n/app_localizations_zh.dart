import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get todosOverviewAppBarTitle => '待办';

  @override
  String get todosOverviewFilterTooltip => '筛选';

  @override
  String get todosOverviewFilterAll => '全部';

  @override
  String get todosOverviewFilterActiveOnly => '仅活跃';

  @override
  String get todosOverviewFilterCompletedOnly => '仅已完成';

  @override
  String get todosOverviewMarkAllCompleteButtonText => '全部标记为完成';

  @override
  String get todosOverviewClearCompletedButtonText => '清除已完成';

  @override
  String get todosOverviewEmptyText => '未找到符合筛选条件的待办事项。';

  @override
  String todosOverviewTodoDeletedSnackbarText(Object todoTitle) {
    return '待办事项 \"$todoTitle\" 已删除。';
  }

  @override
  String get todosOverviewUndoDeletionButtonText => '撤销';

  @override
  String get todosOverviewErrorSnackbarText => '加载待办事项时发生错误。';

  @override
  String get todosOverviewOptionsTooltip => '选项';

  @override
  String get todosOverviewOptionsMarkAllComplete => '全部标记为已完成';

  @override
  String get todosOverviewOptionsMarkAllIncomplete => '全部标记为未完成';

  @override
  String get todosOverviewOptionsClearCompleted => '清除已完成';

  @override
  String get todoDetailsAppBarTitle => '待办详情';

  @override
  String get todoDetailsDeleteButtonTooltip => '删除';

  @override
  String get todoDetailsEditButtonTooltip => '编辑';

  @override
  String get editTodoEditAppBarTitle => '编辑待办';

  @override
  String get editTodoAddAppBarTitle => '添加待办';

  @override
  String get editTodoTitleLabel => '标题';

  @override
  String get editTodoDescriptionLabel => '描述';

  @override
  String get editTodoSaveButtonTooltip => '保存更改';

  @override
  String get statsAppBarTitle => '统计';

  @override
  String get statsCompletedTodoCountLabel => '已完成待办';

  @override
  String get statsActiveTodoCountLabel => '活跃待办';
}
