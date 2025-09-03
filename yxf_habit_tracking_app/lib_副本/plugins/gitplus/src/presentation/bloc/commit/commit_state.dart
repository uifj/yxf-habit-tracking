import 'package:equatable/equatable.dart';
import '../../../domain/entities/git_commit_entity.dart';

/// 提交状态基类
abstract class CommitState extends Equatable {
  const CommitState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class CommitInitial extends CommitState {
  const CommitInitial();
}

/// 提交准备状态
class CommitReady extends CommitState {
  final String repoPath;
  final String message;
  final String? author;
  final String? email;
  final bool amend;
  final bool signOff;
  final bool isMessageValid;
  final String? messageError;
  final List<String> recentMessages;
  final Map<String, String> templates;

  const CommitReady(
    this.repoPath, {
    this.message = '',
    this.author,
    this.email,
    this.amend = false,
    this.signOff = false,
    this.isMessageValid = false,
    this.messageError,
    this.recentMessages = const [],
    this.templates = const {},
  });

  @override
  List<Object?> get props => [
        repoPath,
        message,
        author,
        email,
        amend,
        signOff,
        isMessageValid,
        messageError,
        recentMessages,
        templates,
      ];

  /// 是否可以提交
  bool get canCommit => isMessageValid && message.trim().isNotEmpty;

  /// 获取提交作者信息
  String get commitAuthor {
    if (author != null && email != null) {
      return '$author <$email>';
    } else if (author != null) {
      return author!;
    } else if (email != null) {
      return email!;
    }
    return '';
  }

  /// 复制状态并更新属性
  CommitReady copyWith({
    String? repoPath,
    String? message,
    String? author,
    String? email,
    bool? amend,
    bool? signOff,
    bool? isMessageValid,
    String? messageError,
    List<String>? recentMessages,
    Map<String, String>? templates,
    bool clearAuthor = false,
    bool clearEmail = false,
    bool clearMessageError = false,
  }) {
    return CommitReady(
      repoPath ?? this.repoPath,
      message: message ?? this.message,
      author: clearAuthor ? null : (author ?? this.author),
      email: clearEmail ? null : (email ?? this.email),
      amend: amend ?? this.amend,
      signOff: signOff ?? this.signOff,
      isMessageValid: isMessageValid ?? this.isMessageValid,
      messageError:
          clearMessageError ? null : (messageError ?? this.messageError),
      recentMessages: recentMessages ?? this.recentMessages,
      templates: templates ?? this.templates,
    );
  }
}

/// 提交中状态
class CommitInProgress extends CommitState {
  final String repoPath;
  final String message;
  final String? author;
  final String? email;
  final bool amend;
  final bool signOff;
  final List<String>? filePaths;

  const CommitInProgress(
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

/// 提交成功状态
class CommitSuccess extends CommitState {
  final String repoPath;
  final GitCommitEntity commit;
  final String message;
  final bool wasAmended;

  const CommitSuccess(
    this.repoPath,
    this.commit,
    this.message, {
    this.wasAmended = false,
  });

  @override
  List<Object?> get props => [repoPath, commit, message, wasAmended];

  /// 获取成功消息
  String get successMessage {
    if (wasAmended) {
      return 'Successfully amended commit ${commit.shortSha}';
    } else {
      return 'Successfully created commit ${commit.shortSha}';
    }
  }
}

/// 提交失败状态
class CommitError extends CommitState {
  final String repoPath;
  final String message;
  final Exception? exception;
  final String? commitMessage;
  final bool wasAmending;

  const CommitError(
    this.repoPath,
    this.message, {
    this.exception,
    this.commitMessage,
    this.wasAmending = false,
  });

  @override
  List<Object?> get props => [
        repoPath,
        message,
        exception,
        commitMessage,
        wasAmending,
      ];

  /// 获取错误类型
  String get errorType {
    if (wasAmending) {
      return 'Amend Failed';
    } else {
      return 'Commit Failed';
    }
  }
}

/// 消息验证状态
class CommitMessageValidated extends CommitReady {
  const CommitMessageValidated(
    super.repoPath, {
    super.message,
    super.author,
    super.email,
    super.amend,
    super.signOff,
    super.isMessageValid,
    super.messageError,
    super.recentMessages,
    super.templates,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        'validated',
      ];
}

/// 模板加载状态
class CommitTemplateLoaded extends CommitReady {
  final String templateName;
  final String templateContent;

  const CommitTemplateLoaded(
    super.repoPath,
    this.templateName,
    this.templateContent, {
    super.message,
    super.author,
    super.email,
    super.amend,
    super.signOff,
    super.isMessageValid,
    super.messageError,
    super.recentMessages,
    super.templates,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        templateName,
        templateContent,
      ];
}

/// 历史消息加载状态
class CommitHistoryMessagesLoaded extends CommitReady {
  const CommitHistoryMessagesLoaded(
    super.repoPath, {
    super.message,
    super.author,
    super.email,
    super.amend,
    super.signOff,
    super.isMessageValid,
    super.messageError,
    required super.recentMessages,
    super.templates,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        'history_loaded',
      ];
}
