import 'package:equatable/equatable.dart';

/// Git文件状态类型枚举
enum GitFileStatusType {
  /// 新增文件
  added,

  /// 修改文件
  modified,

  /// 删除文件
  deleted,

  /// 重命名文件
  renamed,

  /// 复制文件
  copied,

  /// 未跟踪文件
  untracked,

  /// 忽略文件
  ignored,

  /// 类型变更
  typeChanged,
}

/// Git文件状态实体
class GitFileStatusEntity extends Equatable {
  /// 文件路径
  final String path;

  /// 旧文件路径（用于重命名）
  final String? oldPath;

  /// 文件状态类型
  final GitFileStatusType status;

  /// 是否已暂存
  final bool isStaged;

  /// 文件差异内容
  final String? diff;

  /// 插入行数
  final int insertions;

  /// 删除行数
  final int deletions;

  const GitFileStatusEntity({
    required this.path,
    this.oldPath,
    required this.status,
    required this.isStaged,
    this.diff,
    required this.insertions,
    required this.deletions,
  });

  /// 复制并修改属性
  GitFileStatusEntity copyWith({
    String? path,
    String? oldPath,
    GitFileStatusType? status,
    bool? isStaged,
    String? diff,
    int? insertions,
    int? deletions,
  }) {
    return GitFileStatusEntity(
      path: path ?? this.path,
      oldPath: oldPath ?? this.oldPath,
      status: status ?? this.status,
      isStaged: isStaged ?? this.isStaged,
      diff: diff ?? this.diff,
      insertions: insertions ?? this.insertions,
      deletions: deletions ?? this.deletions,
    );
  }

  /// 获取状态图标
  String get statusIcon {
    switch (status) {
      case GitFileStatusType.added:
        return '+';
      case GitFileStatusType.modified:
        return 'M';
      case GitFileStatusType.deleted:
        return '-';
      case GitFileStatusType.renamed:
        return 'R';
      case GitFileStatusType.copied:
        return 'C';
      case GitFileStatusType.untracked:
        return '?';
      case GitFileStatusType.ignored:
        return '!';
      case GitFileStatusType.typeChanged:
        return 'T';
    }
  }

  /// 获取显示路径
  String get displayPath {
    if (status == GitFileStatusType.renamed && oldPath != null) {
      return '$oldPath → $path';
    }
    return path;
  }

  /// 获取状态描述
  String get statusDescription {
    switch (status) {
      case GitFileStatusType.added:
        return 'Added';
      case GitFileStatusType.modified:
        return 'Modified';
      case GitFileStatusType.deleted:
        return 'Deleted';
      case GitFileStatusType.renamed:
        return 'Renamed';
      case GitFileStatusType.copied:
        return 'Copied';
      case GitFileStatusType.untracked:
        return 'Untracked';
      case GitFileStatusType.ignored:
        return 'Ignored';
      case GitFileStatusType.typeChanged:
        return 'Type Changed';
    }
  }

  /// 是否可以暂存
  bool get canStage {
    return !isStaged && status != GitFileStatusType.ignored;
  }

  /// 是否可以取消暂存
  bool get canUnstage {
    return isStaged;
  }

  @override
  List<Object?> get props => [
        path,
        oldPath,
        status,
        isStaged,
        diff,
        insertions,
        deletions,
      ];

  @override
  String toString() {
    return 'GitFileStatusEntity(path: $path, status: $status, isStaged: $isStaged)';
  }
}
