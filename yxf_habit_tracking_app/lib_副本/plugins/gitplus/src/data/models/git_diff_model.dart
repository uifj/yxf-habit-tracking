import 'package:equatable/equatable.dart';

/// Git差异行类型
enum GitDiffLineType {
  context,
  addition,
  deletion,
  header,
  hunk,
}

/// Git差异行模型
class GitDiffLineModel extends Equatable {
  final GitDiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  const GitDiffLineModel({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });

  GitDiffLineModel copyWith({
    GitDiffLineType? type,
    String? content,
    int? oldLineNumber,
    int? newLineNumber,
  }) {
    return GitDiffLineModel(
      type: type ?? this.type,
      content: content ?? this.content,
      oldLineNumber: oldLineNumber ?? this.oldLineNumber,
      newLineNumber: newLineNumber ?? this.newLineNumber,
    );
  }

  @override
  List<Object?> get props => [type, content, oldLineNumber, newLineNumber];
}

/// Git差异块模型
class GitDiffHunkModel extends Equatable {
  final String header;
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final List<GitDiffLineModel> lines;

  const GitDiffHunkModel({
    required this.header,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.lines,
  });

  GitDiffHunkModel copyWith({
    String? header,
    int? oldStart,
    int? oldCount,
    int? newStart,
    int? newCount,
    List<GitDiffLineModel>? lines,
  }) {
    return GitDiffHunkModel(
      header: header ?? this.header,
      oldStart: oldStart ?? this.oldStart,
      oldCount: oldCount ?? this.oldCount,
      newStart: newStart ?? this.newStart,
      newCount: newCount ?? this.newCount,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [
        header,
        oldStart,
        oldCount,
        newStart,
        newCount,
        lines,
      ];
}

/// Git差异模型
class GitDiffModel extends Equatable {
  final String filePath;
  final String? oldFilePath;
  final bool isNewFile;
  final bool isDeletedFile;
  final bool isBinaryFile;
  final int insertions;
  final int deletions;
  final List<GitDiffHunkModel> hunks;
  final String? rawDiff;

  const GitDiffModel({
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

  GitDiffModel copyWith({
    String? filePath,
    String? oldFilePath,
    bool? isNewFile,
    bool? isDeletedFile,
    bool? isBinaryFile,
    int? insertions,
    int? deletions,
    List<GitDiffHunkModel>? hunks,
    String? rawDiff,
  }) {
    return GitDiffModel(
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

  String get displayPath {
    if (oldFilePath != null && oldFilePath != filePath) {
      return '$oldFilePath → $filePath';
    }
    return filePath;
  }

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
}
