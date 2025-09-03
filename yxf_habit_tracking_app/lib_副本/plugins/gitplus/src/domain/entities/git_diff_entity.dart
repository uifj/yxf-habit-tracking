import 'package:equatable/equatable.dart';

/// Git差异行类型枚举
enum GitDiffLineType {
  /// 上下文行
  context,

  /// 添加行
  added,

  /// 删除行
  deleted,

  /// 文件头
  header,

  /// 块头
  hunkHeader,
}

/// Git差异行实体
class GitDiffLineEntity extends Equatable {
  /// 行类型
  final GitDiffLineType type;

  /// 行内容
  final String content;

  /// 旧文件行号
  final int? oldLineNumber;

  /// 新文件行号
  final int? newLineNumber;

  const GitDiffLineEntity({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });

  /// 复制并修改属性
  GitDiffLineEntity copyWith({
    GitDiffLineType? type,
    String? content,
    int? oldLineNumber,
    int? newLineNumber,
  }) {
    return GitDiffLineEntity(
      type: type ?? this.type,
      content: content ?? this.content,
      oldLineNumber: oldLineNumber ?? this.oldLineNumber,
      newLineNumber: newLineNumber ?? this.newLineNumber,
    );
  }

  @override
  List<Object?> get props => [type, content, oldLineNumber, newLineNumber];

  @override
  String toString() {
    return 'GitDiffLineEntity(type: $type, content: $content)';
  }
}

/// Git差异块实体
class GitDiffHunkEntity extends Equatable {
  /// 块头信息
  final String header;

  /// 旧文件起始行号
  final int oldStartLine;

  /// 旧文件行数
  final int oldLineCount;

  /// 新文件起始行号
  final int newStartLine;

  /// 新文件行数
  final int newLineCount;

  /// 差异行列表
  final List<GitDiffLineEntity> lines;

  const GitDiffHunkEntity({
    required this.header,
    required this.oldStartLine,
    required this.oldLineCount,
    required this.newStartLine,
    required this.newLineCount,
    required this.lines,
  });

  /// 复制并修改属性
  GitDiffHunkEntity copyWith({
    String? header,
    int? oldStartLine,
    int? oldLineCount,
    int? newStartLine,
    int? newLineCount,
    List<GitDiffLineEntity>? lines,
  }) {
    return GitDiffHunkEntity(
      header: header ?? this.header,
      oldStartLine: oldStartLine ?? this.oldStartLine,
      oldLineCount: oldLineCount ?? this.oldLineCount,
      newStartLine: newStartLine ?? this.newStartLine,
      newLineCount: newLineCount ?? this.newLineCount,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [
        header,
        oldStartLine,
        oldLineCount,
        newStartLine,
        newLineCount,
        lines,
      ];

  @override
  String toString() {
    return 'GitDiffHunkEntity(header: $header, lines: ${lines.length})';
  }
}

/// Git差异实体
class GitDiffEntity extends Equatable {
  /// 文件路径
  final String filePath;

  /// 旧文件路径（用于重命名）
  final String? oldFilePath;

  /// 是否为新文件
  final bool isNewFile;

  /// 是否为删除文件
  final bool isDeletedFile;

  /// 是否为二进制文件
  final bool isBinaryFile;

  /// 插入行数
  final int insertions;

  /// 删除行数
  final int deletions;

  /// 差异块列表
  final List<GitDiffHunkEntity> hunks;

  /// 原始差异内容
  final String? rawDiff;

  const GitDiffEntity({
    required this.filePath,
    this.oldFilePath,
    required this.isNewFile,
    required this.isDeletedFile,
    required this.isBinaryFile,
    required this.insertions,
    required this.deletions,
    required this.hunks,
    this.rawDiff,
  });

  /// 复制并修改属性
  GitDiffEntity copyWith({
    String? filePath,
    String? oldFilePath,
    bool? isNewFile,
    bool? isDeletedFile,
    bool? isBinaryFile,
    int? insertions,
    int? deletions,
    List<GitDiffHunkEntity>? hunks,
    String? rawDiff,
  }) {
    return GitDiffEntity(
      filePath: filePath ?? this.filePath,
      oldFilePath: oldFilePath ?? this.oldFilePath,
      isNewFile: isNewFile ?? this.isNewFile,
      isDeletedFile: isDeletedFile ?? this.isDeletedFile,
      isBinaryFile: isBinaryFile ?? this.isBinaryFile,
      insertions: insertions ?? this.insertions,
      deletions: deletions ?? this.deletions,
      hunks: hunks ?? this.hunks,
      rawDiff: rawDiff ?? this.rawDiff,
    );
  }

  /// 获取显示路径
  String get displayPath {
    if (oldFilePath != null && oldFilePath != filePath) {
      return '$oldFilePath → $filePath';
    }
    return filePath;
  }

  /// 获取文件状态描述
  String get statusDescription {
    if (isNewFile) return 'New file';
    if (isDeletedFile) return 'Deleted file';
    if (isBinaryFile) return 'Binary file';
    if (oldFilePath != null && oldFilePath != filePath) return 'Renamed file';
    return 'Modified file';
  }

  /// 获取总变更行数
  int get totalChanges => insertions + deletions;

  /// 是否有变更
  bool get hasChanges => totalChanges > 0 || isNewFile || isDeletedFile;

  @override
  List<Object?> get props => [
        filePath,
        oldFilePath,
        isNewFile,
        isDeletedFile,
        isBinaryFile,
        insertions,
        deletions,
        hunks,
        rawDiff,
      ];

  @override
  String toString() {
    return 'GitDiffEntity(filePath: $filePath, insertions: $insertions, deletions: $deletions)';
  }
}
