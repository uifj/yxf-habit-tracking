import 'package:equatable/equatable.dart';

/// 提交事件基类
abstract class CommitEvent extends Equatable {
  const CommitEvent();

  @override
  List<Object?> get props => [];
}

/// 提交更改事件
class CommitChanges extends CommitEvent {
  final String repoPath;
  final String message;
  final String? author;
  final String? email;
  final bool amend;
  final bool signOff;
  final List<String>? filePaths;

  const CommitChanges(
    this.repoPath,
    this.message, {
    this.author,
    this.email,
    this.amend = false,
    this.signOff = false,
    this.filePaths,
  });

  @override
  List<Object?> get props => [
        repoPath,
        message,
        author,
        email,
        amend,
        signOff,
        filePaths,
      ];
}

/// 修改最后一次提交事件
class AmendLastCommit extends CommitEvent {
  final String repoPath;
  final String? newMessage;
  final String? author;
  final String? email;
  final List<String>? filePaths;

  const AmendLastCommit(
    this.repoPath, {
    this.newMessage,
    this.author,
    this.email,
    this.filePaths,
  });

  @override
  List<Object?> get props => [
        repoPath,
        newMessage,
        author,
        email,
        filePaths,
      ];
}

/// 重置提交状态事件
class ResetCommitState extends CommitEvent {
  const ResetCommitState();
}

/// 验证提交消息事件
class ValidateCommitMessage extends CommitEvent {
  final String message;

  const ValidateCommitMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// 设置提交消息事件
class SetCommitMessage extends CommitEvent {
  final String message;

  const SetCommitMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// 设置提交作者事件
class SetCommitAuthor extends CommitEvent {
  final String? author;
  final String? email;

  const SetCommitAuthor({
    this.author,
    this.email,
  });

  @override
  List<Object?> get props => [author, email];
}

/// 切换修改模式事件
class ToggleAmendMode extends CommitEvent {
  const ToggleAmendMode();
}

/// 切换签名模式事件
class ToggleSignOffMode extends CommitEvent {
  const ToggleSignOffMode();
}

/// 加载提交模板事件
class LoadCommitTemplate extends CommitEvent {
  final String repoPath;
  final String? templateName;

  const LoadCommitTemplate(
    this.repoPath, {
    this.templateName,
  });

  @override
  List<Object?> get props => [repoPath, templateName];
}

/// 保存提交模板事件
class SaveCommitTemplate extends CommitEvent {
  final String repoPath;
  final String templateName;
  final String template;

  const SaveCommitTemplate(
    this.repoPath,
    this.templateName,
    this.template,
  );

  @override
  List<Object?> get props => [repoPath, templateName, template];
}

/// 获取提交历史消息事件
class GetCommitHistoryMessages extends CommitEvent {
  final String repoPath;
  final int limit;

  const GetCommitHistoryMessages(
    this.repoPath, {
    this.limit = 10,
  });

  @override
  List<Object?> get props => [repoPath, limit];
}
