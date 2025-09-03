import 'package:equatable/equatable.dart';
import '../../data/models/custom_tag.dart';
import '../../core/error/failures.dart';

/// 标签统计数据
class TagStats extends Equatable {
  final int totalTags;
  final int activeTags;
  final int totalUsage;
  final CustomTag? mostUsedTag;
  final CustomTag? leastUsedTag;
  final List<CustomTag> recentlyUsedTags;
  final Map<String, int> usageByColor;
  
  const TagStats({
    required this.totalTags,
    required this.activeTags,
    required this.totalUsage,
    this.mostUsedTag,
    this.leastUsedTag,
    required this.recentlyUsedTags,
    required this.usageByColor,
  });
  
  @override
  List<Object?> get props => [
    totalTags,
    activeTags,
    totalUsage,
    mostUsedTag,
    leastUsedTag,
    recentlyUsedTags,
    usageByColor,
  ];
  
  TagStats copyWith({
    int? totalTags,
    int? activeTags,
    int? totalUsage,
    CustomTag? mostUsedTag,
    CustomTag? leastUsedTag,
    List<CustomTag>? recentlyUsedTags,
    Map<String, int>? usageByColor,
  }) {
    return TagStats(
      totalTags: totalTags ?? this.totalTags,
      activeTags: activeTags ?? this.activeTags,
      totalUsage: totalUsage ?? this.totalUsage,
      mostUsedTag: mostUsedTag ?? this.mostUsedTag,
      leastUsedTag: leastUsedTag ?? this.leastUsedTag,
      recentlyUsedTags: recentlyUsedTags ?? this.recentlyUsedTags,
      usageByColor: usageByColor ?? this.usageByColor,
    );
  }
}

/// 标签状态基类
sealed class TagState extends Equatable {
  const TagState();
  
  @override
  List<Object?> get props => [];
}

/// 标签初始状态
class TagInitial extends TagState {
  const TagInitial();
}

/// 标签加载中状态
class TagLoading extends TagState {
  const TagLoading();
}

/// 标签已加载状态
class TagLoaded extends TagState {
  final List<CustomTag> tags;
  final List<CustomTag> filteredTags;
  final String searchQuery;
  final TagStats? stats;
  
  const TagLoaded({
    required this.tags,
    required this.filteredTags,
    this.searchQuery = '',
    this.stats,
  });
  
  @override
  List<Object?> get props => [tags, filteredTags, searchQuery, stats];
  
  TagLoaded copyWith({
    List<CustomTag>? tags,
    List<CustomTag>? filteredTags,
    String? searchQuery,
    TagStats? stats,
  }) {
    return TagLoaded(
      tags: tags ?? this.tags,
      filteredTags: filteredTags ?? this.filteredTags,
      searchQuery: searchQuery ?? this.searchQuery,
      stats: stats ?? this.stats,
    );
  }
  
  /// 获取激活的标签
  List<CustomTag> get activeTags => tags.where((tag) => tag.isActive).toList();
  
  /// 获取最常用的标签
  List<CustomTag> get mostUsedTags {
    final sortedTags = List<CustomTag>.from(tags)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sortedTags.take(10).toList();
  }
  
  /// 获取最近创建的标签
  List<CustomTag> get recentTags {
    final sortedTags = List<CustomTag>.from(tags)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedTags.take(5).toList();
  }
  
  /// 按颜色分组的标签
  Map<String, List<CustomTag>> get tagsByColor {
    final Map<String, List<CustomTag>> grouped = {};
    for (final tag in tags) {
      final colorKey = tag.color.toString();
      grouped[colorKey] = (grouped[colorKey] ?? [])..add(tag);
    }
    return grouped;
  }
}

/// 标签错误状态
class TagError extends TagState {
  final Failure failure;
  final String message;
  
  const TagError({
    required this.failure,
    required this.message,
  });
  
  @override
  List<Object?> get props => [failure, message];
}

/// 标签操作成功状态
class TagOperationSuccess extends TagState {
  final String message;
  final CustomTag? tag;
  
  const TagOperationSuccess({
    required this.message,
    this.tag,
  });
  
  @override
  List<Object?> get props => [message, tag];
}

/// 标签同步中状态
class TagSyncing extends TagState {
  final String message;
  
  const TagSyncing({this.message = '正在同步标签...'});
  
  @override
  List<Object?> get props => [message];
}

/// 标签同步完成状态
class TagSyncCompleted extends TagState {
  final String message;
  final int syncedCount;
  
  const TagSyncCompleted({
    required this.message,
    required this.syncedCount,
  });
  
  @override
  List<Object?> get props => [message, syncedCount];
}

/// 标签统计加载中状态
class TagStatsLoading extends TagState {
  const TagStatsLoading();
}

/// 标签统计已加载状态
class TagStatsLoaded extends TagState {
  final TagStats stats;
  final List<CustomTag> tags;
  
  const TagStatsLoaded({
    required this.stats,
    required this.tags,
  });
  
  @override
  List<Object?> get props => [stats, tags];
}

/// 标签导出状态
class TagExported extends TagState {
  final String filePath;
  final String format;
  final int exportedCount;
  
  const TagExported({
    required this.filePath,
    required this.format,
    required this.exportedCount,
  });
  
  @override
  List<Object?> get props => [filePath, format, exportedCount];
}

/// 标签清理完成状态
class TagCleanupCompleted extends TagState {
  final String message;
  final int cleanedCount;
  
  const TagCleanupCompleted({
    required this.message,
    required this.cleanedCount,
  });
  
  @override
  List<Object?> get props => [message, cleanedCount];
}