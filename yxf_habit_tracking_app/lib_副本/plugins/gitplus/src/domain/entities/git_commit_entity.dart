import 'package:equatable/equatable.dart';

/// Git提交实体
class GitCommitEntity extends Equatable {
  /// 提交SHA
  final String sha;

  /// 提交消息
  final String message;

  /// 作者
  final String author;

  /// 提交者
  final String committer;

  /// 提交日期
  final DateTime date;

  /// 父提交SHA列表
  final List<String> parents;

  /// 变更文件列表
  final List<String> changedFiles;

  /// 插入行数
  final int insertions;

  /// 删除行数
  final int deletions;

  const GitCommitEntity({
    required this.sha,
    required this.message,
    required this.author,
    required this.committer,
    required this.date,
    required this.parents,
    required this.changedFiles,
    required this.insertions,
    required this.deletions,
  });

  /// 复制并修改属性
  GitCommitEntity copyWith({
    String? sha,
    String? message,
    String? author,
    String? committer,
    DateTime? date,
    List<String>? parents,
    List<String>? changedFiles,
    int? insertions,
    int? deletions,
  }) {
    return GitCommitEntity(
      sha: sha ?? this.sha,
      message: message ?? this.message,
      author: author ?? this.author,
      committer: committer ?? this.committer,
      date: date ?? this.date,
      parents: parents ?? this.parents,
      changedFiles: changedFiles ?? this.changedFiles,
      insertions: insertions ?? this.insertions,
      deletions: deletions ?? this.deletions,
    );
  }

  /// 获取短SHA（前7位）
  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;

  /// 获取提交标题（第一行）
  String get title {
    final lines = message.split('\n');
    return lines.isNotEmpty ? lines.first : '';
  }

  /// 获取提交描述（除第一行外的内容）
  String get description {
    final lines = message.split('\n');
    if (lines.length <= 1) return '';
    return lines.skip(1).join('\n').trim();
  }

  /// 是否为合并提交
  bool get isMergeCommit => parents.length > 1;

  @override
  List<Object?> get props => [
        sha,
        message,
        author,
        committer,
        date,
        parents,
        changedFiles,
        insertions,
        deletions,
      ];

  @override
  String toString() {
    return 'GitCommitEntity(sha: $shortSha, message: $title, author: $author)';
  }
}
