import 'package:equatable/equatable.dart';

/// Git文件状态枚举
enum GitFileStatusType {
  untracked,
  modified,
  added,
  deleted,
  renamed,
  copied,
  unmerged,
  ignored,
}

/// Git文件状态模型
class GitFileStatusModel extends Equatable {
  final String path;
  final String? oldPath; // 用于重命名的情况
  final GitFileStatusType status;
  final bool isStaged;
  final String? diff;
  final int insertions;
  final int deletions;

  const GitFileStatusModel({
    required this.path,
    this.oldPath,
    required this.status,
    required this.isStaged,
    this.diff,
    required this.insertions,
    required this.deletions,
  });

  GitFileStatusModel copyWith({
    String? path,
    String? oldPath,
    GitFileStatusType? status,
    bool? isStaged,
    String? diff,
    int? insertions,
    int? deletions,
  }) {
    return GitFileStatusModel(
      path: path ?? this.path,
      oldPath: oldPath ?? this.oldPath,
      status: status ?? this.status,
      isStaged: isStaged ?? this.isStaged,
      diff: diff ?? this.diff,
      insertions: insertions ?? this.insertions,
      deletions: deletions ?? this.deletions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'oldPath': oldPath,
      'status': status.name,
      'isStaged': isStaged,
      'diff': diff,
      'insertions': insertions,
      'deletions': deletions,
    };
  }

  factory GitFileStatusModel.fromJson(Map<String, dynamic> json) {
    return GitFileStatusModel(
      path: json['path'] as String,
      oldPath: json['oldPath'] as String?,
      status: GitFileStatusType.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      isStaged: json['isStaged'] as bool,
      diff: json['diff'] as String?,
      insertions: json['insertions'] as int,
      deletions: json['deletions'] as int,
    );
  }

  String get statusIcon {
    switch (status) {
      case GitFileStatusType.untracked:
        return '?';
      case GitFileStatusType.modified:
        return 'M';
      case GitFileStatusType.added:
        return 'A';
      case GitFileStatusType.deleted:
        return 'D';
      case GitFileStatusType.renamed:
        return 'R';
      case GitFileStatusType.copied:
        return 'C';
      case GitFileStatusType.unmerged:
        return 'U';
      case GitFileStatusType.ignored:
        return '!';
    }
  }

  String get displayPath {
    if (oldPath != null && status == GitFileStatusType.renamed) {
      return '$oldPath → $path';
    }
    return path;
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
}
