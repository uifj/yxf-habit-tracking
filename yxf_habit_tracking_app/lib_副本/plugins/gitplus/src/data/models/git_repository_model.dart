import 'package:equatable/equatable.dart';

/// Git仓库模型
class GitRepositoryModel extends Equatable {
  final String path;
  final String name;
  final String? currentBranch;
  final bool isClean;
  final int commitCount;
  final List<String> branches;
  final List<String> remotes;
  final DateTime? lastCommitDate;
  final String? lastCommitMessage;
  final String? lastCommitAuthor;

  const GitRepositoryModel({
    required this.path,
    required this.name,
    this.currentBranch,
    required this.isClean,
    required this.commitCount,
    required this.branches,
    required this.remotes,
    this.lastCommitDate,
    this.lastCommitMessage,
    this.lastCommitAuthor,
  });

  GitRepositoryModel copyWith({
    String? path,
    String? name,
    String? currentBranch,
    bool? isClean,
    int? commitCount,
    List<String>? branches,
    List<String>? remotes,
    DateTime? lastCommitDate,
    String? lastCommitMessage,
    String? lastCommitAuthor,
  }) {
    return GitRepositoryModel(
      path: path ?? this.path,
      name: name ?? this.name,
      currentBranch: currentBranch ?? this.currentBranch,
      isClean: isClean ?? this.isClean,
      commitCount: commitCount ?? this.commitCount,
      branches: branches ?? this.branches,
      remotes: remotes ?? this.remotes,
      lastCommitDate: lastCommitDate ?? this.lastCommitDate,
      lastCommitMessage: lastCommitMessage ?? this.lastCommitMessage,
      lastCommitAuthor: lastCommitAuthor ?? this.lastCommitAuthor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'currentBranch': currentBranch,
      'isClean': isClean,
      'commitCount': commitCount,
      'branches': branches,
      'remotes': remotes,
      'lastCommitDate': lastCommitDate?.toIso8601String(),
      'lastCommitMessage': lastCommitMessage,
      'lastCommitAuthor': lastCommitAuthor,
    };
  }

  factory GitRepositoryModel.fromJson(Map<String, dynamic> json) {
    return GitRepositoryModel(
      path: json['path'] as String,
      name: json['name'] as String,
      currentBranch: json['currentBranch'] as String?,
      isClean: json['isClean'] as bool,
      commitCount: json['commitCount'] as int,
      branches: List<String>.from(json['branches'] as List),
      remotes: List<String>.from(json['remotes'] as List),
      lastCommitDate: json['lastCommitDate'] != null
          ? DateTime.parse(json['lastCommitDate'] as String)
          : null,
      lastCommitMessage: json['lastCommitMessage'] as String?,
      lastCommitAuthor: json['lastCommitAuthor'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        path,
        name,
        currentBranch,
        isClean,
        commitCount,
        branches,
        remotes,
        lastCommitDate,
        lastCommitMessage,
        lastCommitAuthor,
      ];
}
