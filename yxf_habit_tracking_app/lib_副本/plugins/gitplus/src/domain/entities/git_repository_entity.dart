import 'package:equatable/equatable.dart';

/// Git仓库实体
class GitRepositoryEntity extends Equatable {
  /// 仓库路径
  final String path;

  /// 仓库名称
  final String name;

  /// 当前分支
  final String? currentBranch;

  /// 工作树是否干净
  final bool isClean;

  /// 提交数量
  final int commitCount;

  /// 分支列表
  final List<String> branches;

  /// 远程仓库列表
  final List<String> remotes;

  /// 最后提交日期
  final DateTime? lastCommitDate;

  /// 最后提交消息
  final String? lastCommitMessage;

  /// 最后提交作者
  final String? lastCommitAuthor;

  const GitRepositoryEntity({
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

  /// 复制并修改属性
  GitRepositoryEntity copyWith({
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
    return GitRepositoryEntity(
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

  @override
  String toString() {
    return 'GitRepositoryEntity(path: $path, name: $name, currentBranch: $currentBranch, isClean: $isClean)';
  }
}
