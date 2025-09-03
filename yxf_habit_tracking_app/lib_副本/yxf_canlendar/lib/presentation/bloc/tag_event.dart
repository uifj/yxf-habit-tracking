import 'package:equatable/equatable.dart';
import '../../data/models/custom_tag.dart';

/// 自定义标签事件基类
sealed class TagEvent extends Equatable {
  const TagEvent();
  
  @override
  List<Object?> get props => [];
}

/// 初始化标签事件
class InitializeTagEvent extends TagEvent {
  const InitializeTagEvent();
}

/// 加载标签事件
class LoadTagsEvent extends TagEvent {
  final bool forceRefresh;
  
  const LoadTagsEvent({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

/// 添加标签事件
class AddTagEvent extends TagEvent {
  final CustomTag tag;
  
  const AddTagEvent({required this.tag});
  
  @override
  List<Object?> get props => [tag];
}

/// 更新标签事件
class UpdateTagEvent extends TagEvent {
  final CustomTag tag;
  
  const UpdateTagEvent({required this.tag});
  
  @override
  List<Object?> get props => [tag];
}

/// 删除标签事件
class DeleteTagEvent extends TagEvent {
  final String tagId;
  
  const DeleteTagEvent({required this.tagId});
  
  @override
  List<Object?> get props => [tagId];
}

/// 搜索标签事件
class SearchTagsEvent extends TagEvent {
  final String query;
  
  const SearchTagsEvent({required this.query});
  
  @override
  List<Object?> get props => [query];
}

/// 切换标签激活状态事件
class ToggleTagActiveEvent extends TagEvent {
  final String tagId;
  
  const ToggleTagActiveEvent({required this.tagId});
  
  @override
  List<Object?> get props => [tagId];
}

/// 增加标签使用次数事件
class IncrementTagUsageEvent extends TagEvent {
  final String tagId;
  
  const IncrementTagUsageEvent({required this.tagId});
  
  @override
  List<Object?> get props => [tagId];
}

/// 减少标签使用次数事件
class DecrementTagUsageEvent extends TagEvent {
  final String tagId;
  
  const DecrementTagUsageEvent({required this.tagId});
  
  @override
  List<Object?> get props => [tagId];
}

/// 批量导入标签事件
class BulkImportTagsEvent extends TagEvent {
  final List<CustomTag> tags;
  
  const BulkImportTagsEvent({required this.tags});
  
  @override
  List<Object?> get props => [tags];
}

/// 同步标签事件
class SyncTagsEvent extends TagEvent {
  const SyncTagsEvent();
}

/// 刷新标签事件
class RefreshTagsEvent extends TagEvent {
  const RefreshTagsEvent();
}

/// 获取标签统计事件
class GetTagStatsEvent extends TagEvent {
  const GetTagStatsEvent();
}

/// 清理未使用标签事件
class CleanupUnusedTagsEvent extends TagEvent {
  final int minUsageCount;
  
  const CleanupUnusedTagsEvent({this.minUsageCount = 1});
  
  @override
  List<Object?> get props => [minUsageCount];
}

/// 导出标签事件
class ExportTagsEvent extends TagEvent {
  final String format; // 'json', 'csv'
  
  const ExportTagsEvent({required this.format});
  
  @override
  List<Object?> get props => [format];
}

/// 重置标签使用统计事件
class ResetTagUsageStatsEvent extends TagEvent {
  const ResetTagUsageStatsEvent();
}