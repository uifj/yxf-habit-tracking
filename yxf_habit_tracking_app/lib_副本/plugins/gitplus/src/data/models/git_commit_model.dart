import 'package:equatable/equatable.dart';

/// Git提交模型
class GitCommitModel extends Equatable {
  final String sha;
  final String message;
  final String author;
  final String committer;
  final DateTime date;
  final List<String> parents;
  final List<String> changedFiles;
  final int insertions;
  final int deletions;

  const GitCommitModel({
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

  GitCommitModel copyWith({
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
    return GitCommitModel(
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

  Map<String, dynamic> toJson() {
    return {
      'sha': sha,
      'message': message,
      'author': author,
      'committer': committer,
      'date': date.toIso8601String(),
      'parents': parents,
      'changedFiles': changedFiles,
      'insertions': insertions,
      'deletions': deletions,
    };
  }

  factory GitCommitModel.fromJson(Map<String, dynamic> json) {
    return GitCommitModel(
      sha: json['sha'] as String,
      message: json['message'] as String,
      author: json['author'] as String,
      committer: json['committer'] as String,
      date: DateTime.parse(json['date'] as String),
      parents: List<String>.from(json['parents'] as List),
      changedFiles: List<String>.from(json['changedFiles'] as List),
      insertions: json['insertions'] as int,
      deletions: json['deletions'] as int,
    );
  }

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
}
