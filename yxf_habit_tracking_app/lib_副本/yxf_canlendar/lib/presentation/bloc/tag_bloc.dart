import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/custom_tag.dart';
import '../../data/repositories/tag_repository.dart';
import '../../core/error/failures.dart';
import 'tag_event.dart';
import 'tag_state.dart';

/// 自定义标签BLoC
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;
  
  TagBloc({
    required TagRepository tagRepository,
  }) : _tagRepository = tagRepository,
       super(const TagInitial()) {
    on<InitializeTagEvent>(_onInitializeTag);
    on<LoadTagsEvent>(_onLoadTags);
    on<AddTagEvent>(_onAddTag);
    on<UpdateTagEvent>(_onUpdateTag);
    on<DeleteTagEvent>(_onDeleteTag);
    on<SearchTagsEvent>(_onSearchTags);
    on<ToggleTagActiveEvent>(_onToggleTagActive);
    on<IncrementTagUsageEvent>(_onIncrementTagUsage);
    on<DecrementTagUsageEvent>(_onDecrementTagUsage);
    on<BulkImportTagsEvent>(_onBulkImportTags);
    on<SyncTagsEvent>(_onSyncTags);
    on<RefreshTagsEvent>(_onRefreshTags);
    on<GetTagStatsEvent>(_onGetTagStats);
    on<CleanupUnusedTagsEvent>(_onCleanupUnusedTags);
    on<ExportTagsEvent>(_onExportTags);
    on<ResetTagUsageStatsEvent>(_onResetTagUsageStats);
  }
  
  /// 初始化标签
  Future<void> _onInitializeTag(
    InitializeTagEvent event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagLoading());
    try {
      final tags = await _tagRepository.getAllTags();
      final stats = await _tagRepository.getTagStats();
      
      emit(TagLoaded(
        tags: tags,
        filteredTags: tags,
        stats: TagStats(
          totalTags: stats['totalTags'] ?? 0,
          activeTags: stats['activeTags'] ?? 0,
          totalUsage: stats['totalUsage'] ?? 0,
          mostUsedTag: stats['mostUsedTag'],
          leastUsedTag: stats['leastUsedTag'],
          recentlyUsedTags: List<CustomTag>.from(stats['recentlyUsedTags'] ?? []),
          usageByColor: Map<String, int>.from(stats['usageByColor'] ?? {}),
        ),
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: failure.message,
      ));
    }
  }
  
  /// 加载标签
  Future<void> _onLoadTags(
    LoadTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    if (!event.forceRefresh && state is TagLoaded) {
      return;
    }
    
    emit(const TagLoading());
    try {
      final tags = await _tagRepository.getAllTags();
      
      if (state is TagLoaded) {
        final currentState = state as TagLoaded;
        emit(currentState.copyWith(
          tags: tags,
          filteredTags: _applySearchFilter(tags, currentState.searchQuery),
        ));
      } else {
        emit(TagLoaded(
          tags: tags,
          filteredTags: tags,
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '加载标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 添加标签
  Future<void> _onAddTag(
    AddTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final tagId = await _tagRepository.addTag(event.tag);
      
      emit(TagOperationSuccess(
        message: '标签添加成功',
        tag: event.tag.copyWith(id: int.tryParse(tagId)),
      ));
      
      // 重新加载标签列表
      add(const LoadTagsEvent(forceRefresh: true));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '添加标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 更新标签
  Future<void> _onUpdateTag(
    UpdateTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final success = await _tagRepository.updateTag(event.tag);
      
      if (success) {
        emit(TagOperationSuccess(
          message: '标签更新成功',
          tag: event.tag,
        ));
        
        // 重新加载标签列表
        add(const LoadTagsEvent(forceRefresh: true));
      } else {
        emit(const TagError(
          failure: DatabaseFailure(message: '更新标签失败'),
          message: '更新标签失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '更新标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 删除标签
  Future<void> _onDeleteTag(
    DeleteTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final success = await _tagRepository.deleteTag(event.tagId);
      
      if (success) {
        emit(const TagOperationSuccess(
          message: '标签删除成功',
        ));
        
        // 重新加载标签列表
        add(const LoadTagsEvent(forceRefresh: true));
      } else {
        emit(const TagError(
          failure: DatabaseFailure(message: '删除标签失败'),
          message: '删除标签失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '删除标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 搜索标签
  Future<void> _onSearchTags(
    SearchTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    if (state is! TagLoaded) return;
    
    final currentState = state as TagLoaded;
    final filteredTags = _applySearchFilter(currentState.tags, event.query);
    
    emit(currentState.copyWith(
      filteredTags: filteredTags,
      searchQuery: event.query,
    ));
  }
  
  /// 切换标签激活状态
  Future<void> _onToggleTagActive(
    ToggleTagActiveEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final success = await _tagRepository.toggleTagActive(event.tagId);
      
      if (success) {
        emit(const TagOperationSuccess(
          message: '标签状态切换成功',
        ));
        
        // 重新加载标签列表
        add(const LoadTagsEvent(forceRefresh: true));
      } else {
        emit(const TagError(
          failure: DatabaseFailure(message: '切换标签状态失败'),
          message: '切换标签状态失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '切换标签状态失败: ${failure.message}',
      ));
    }
  }
  
  /// 增加标签使用次数
  Future<void> _onIncrementTagUsage(
    IncrementTagUsageEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      await _tagRepository.incrementTagUsage(event.tagId);
      
      // 静默更新，不显示成功消息
      if (state is TagLoaded) {
        add(const LoadTagsEvent(forceRefresh: true));
      }
    } catch (e) {
      // 静默处理错误，不影响用户体验
      print('增加标签使用次数失败: $e');
    }
  }
  
  /// 减少标签使用次数
  Future<void> _onDecrementTagUsage(
    DecrementTagUsageEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      await _tagRepository.decrementTagUsage(event.tagId);
      
      // 静默更新，不显示成功消息
      if (state is TagLoaded) {
        add(const LoadTagsEvent(forceRefresh: true));
      }
    } catch (e) {
      // 静默处理错误，不影响用户体验
      print('减少标签使用次数失败: $e');
    }
  }
  
  /// 批量导入标签
  Future<void> _onBulkImportTags(
    BulkImportTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final importedCount = await _tagRepository.bulkImportTags(event.tags);
      
      emit(TagOperationSuccess(
        message: '成功导入 $importedCount 个标签',
      ));
      
      // 重新加载标签列表
      add(const LoadTagsEvent(forceRefresh: true));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '批量导入标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 同步标签
  Future<void> _onSyncTags(
    SyncTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagSyncing());
    
    try {
      final success = await _tagRepository.syncTags();
      
      if (success) {
        emit(const TagSyncCompleted(
          message: '标签同步完成',
          syncedCount: 0, // TODO: 获取实际同步数量
        ));
        
        // 重新加载标签列表
        add(const LoadTagsEvent(forceRefresh: true));
      } else {
        emit(const TagError(
          failure: ServerFailure(message: '同步标签失败'),
          message: '同步标签失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '同步标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 刷新标签
  Future<void> _onRefreshTags(
    RefreshTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    add(const LoadTagsEvent(forceRefresh: true));
  }
  
  /// 获取标签统计
  Future<void> _onGetTagStats(
    GetTagStatsEvent event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagStatsLoading());
    
    try {
      final tags = await _tagRepository.getAllTags();
      final statsData = await _tagRepository.getTagStats();
      
      final stats = TagStats(
        totalTags: statsData['totalTags'] ?? 0,
        activeTags: statsData['activeTags'] ?? 0,
        totalUsage: statsData['totalUsage'] ?? 0,
        mostUsedTag: statsData['mostUsedTag'],
        leastUsedTag: statsData['leastUsedTag'],
        recentlyUsedTags: List<CustomTag>.from(statsData['recentlyUsedTags'] ?? []),
        usageByColor: Map<String, int>.from(statsData['usageByColor'] ?? {}),
      );
      
      emit(TagStatsLoaded(
        stats: stats,
        tags: tags,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '获取标签统计失败: ${failure.message}',
      ));
    }
  }
  
  /// 清理未使用的标签
  Future<void> _onCleanupUnusedTags(
    CleanupUnusedTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final cleanedCount = await _tagRepository.cleanupUnusedTags(
        minUsageCount: event.minUsageCount,
      );
      
      emit(TagCleanupCompleted(
        message: '清理完成，删除了 $cleanedCount 个未使用的标签',
        cleanedCount: cleanedCount,
      ));
      
      // 重新加载标签列表
      add(const LoadTagsEvent(forceRefresh: true));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '清理未使用标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 导出标签
  Future<void> _onExportTags(
    ExportTagsEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final filePath = await _tagRepository.exportTags(event.format);
      final tags = await _tagRepository.getAllTags();
      
      emit(TagExported(
        filePath: filePath,
        format: event.format,
        exportedCount: tags.length,
      ));
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '导出标签失败: ${failure.message}',
      ));
    }
  }
  
  /// 重置标签使用统计
  Future<void> _onResetTagUsageStats(
    ResetTagUsageStatsEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      final success = await _tagRepository.resetTagUsageStats();
      
      if (success) {
        emit(const TagOperationSuccess(
          message: '标签使用统计已重置',
        ));
        
        // 重新加载标签列表
        add(const LoadTagsEvent(forceRefresh: true));
      } else {
        emit(const TagError(
          failure: DatabaseFailure(message: '重置标签使用统计失败'),
          message: '重置标签使用统计失败',
        ));
      }
    } catch (e) {
      final failure = _mapExceptionToFailure(e);
      emit(TagError(
        failure: failure,
        message: '重置标签使用统计失败: ${failure.message}',
      ));
    }
  }
  
  /// 应用搜索过滤器
  List<CustomTag> _applySearchFilter(List<CustomTag> tags, String query) {
    if (query.isEmpty) {
      return tags;
    }
    
    final lowerQuery = query.toLowerCase();
    return tags.where((tag) {
      return tag.name.toLowerCase().contains(lowerQuery) ||
             (tag.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
  
  /// 将异常映射为失败类型
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }
    return DatabaseFailure(message: exception.toString());
  }
}