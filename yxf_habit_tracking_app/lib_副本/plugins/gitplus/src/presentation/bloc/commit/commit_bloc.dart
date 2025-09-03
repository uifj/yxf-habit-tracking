import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/git_commit_entity.dart';
import '../../../domain/usecases/commit_changes_usecase.dart';
import '../../../domain/usecases/get_commit_history_usecase.dart';
import 'commit_event.dart';
import 'commit_state.dart';

/// 提交BLoC
class CommitBloc extends Bloc<CommitEvent, CommitState> {
  final CommitChangesUseCase _commitChangesUseCase;
  final GetCommitHistoryUseCase _getCommitHistoryUseCase;

  CommitBloc({
    required CommitChangesUseCase commitChangesUseCase,
    required GetCommitHistoryUseCase getCommitHistoryUseCase,
  })  : _commitChangesUseCase = commitChangesUseCase,
        _getCommitHistoryUseCase = getCommitHistoryUseCase,
        super(const CommitInitial()) {
    on<CommitChanges>(_onCommitChanges);
    on<AmendLastCommit>(_onAmendLastCommit);
    on<ResetCommitState>(_onResetCommitState);
    on<ValidateCommitMessage>(_onValidateCommitMessage);
    on<SetCommitMessage>(_onSetCommitMessage);
    on<SetCommitAuthor>(_onSetCommitAuthor);
    on<ToggleAmendMode>(_onToggleAmendMode);
    on<ToggleSignOffMode>(_onToggleSignOffMode);
    on<LoadCommitTemplate>(_onLoadCommitTemplate);
    on<SaveCommitTemplate>(_onSaveCommitTemplate);
    on<GetCommitHistoryMessages>(_onGetCommitHistoryMessages);
  }

  /// 处理提交更改事件
  Future<void> _onCommitChanges(
    CommitChanges event,
    Emitter<CommitState> emit,
  ) async {
    emit(CommitInProgress(
      event.repoPath,
      event.message,
      author: event.author,
      email: event.email,
      amend: event.amend,
      signOff: event.signOff,
      filePaths: event.filePaths,
    ));

    try {
      final commitSha = await _commitChangesUseCase(
        repoPath: event.repoPath,
        message: event.message,
        files: event.filePaths,
      );

      // 创建一个临时的GitCommitEntity用于显示
      // 在实际应用中，应该从仓库获取完整的提交信息
      final commit = GitCommitEntity(
        sha: commitSha,
        message: event.message,
        author: event.author ?? 'Unknown',
        committer: event.author ?? 'Unknown',
        date: DateTime.now(),
        parents: [],
        changedFiles: event.filePaths ?? [],
        insertions: 0,
        deletions: 0,
      );

      emit(CommitSuccess(
        event.repoPath,
        commit,
        event.message,
        wasAmended: event.amend,
      ));
    } catch (e) {
      emit(CommitError(
        event.repoPath,
        'Failed to commit changes: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        commitMessage: event.message,
        wasAmending: event.amend,
      ));
    }
  }

  /// 处理修改最后一次提交事件
  Future<void> _onAmendLastCommit(
    AmendLastCommit event,
    Emitter<CommitState> emit,
  ) async {
    emit(CommitInProgress(
      event.repoPath,
      event.newMessage ?? 'Amending last commit',
      author: event.author,
      email: event.email,
      amend: true,
      filePaths: event.filePaths,
    ));

    try {
      final commitSha = await _commitChangesUseCase(
        repoPath: event.repoPath,
        message: event.newMessage ?? '',
        files: event.filePaths,
      );

      // 创建一个临时的GitCommitEntity用于显示
      // 在实际应用中，应该从仓库获取完整的提交信息
      final commit = GitCommitEntity(
        sha: commitSha,
        message: event.newMessage ?? 'Amended commit',
        author: event.author ?? 'Unknown',
        committer: event.author ?? 'Unknown',
        date: DateTime.now(),
        parents: [],
        changedFiles: event.filePaths ?? [],
        insertions: 0,
        deletions: 0,
      );

      emit(CommitSuccess(
        event.repoPath,
        commit,
        event.newMessage ?? 'Amended commit',
        wasAmended: true,
      ));
    } catch (e) {
      emit(CommitError(
        event.repoPath,
        'Failed to amend commit: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        commitMessage: event.newMessage,
        wasAmending: true,
      ));
    }
  }

  /// 处理重置提交状态事件
  void _onResetCommitState(
    ResetCommitState event,
    Emitter<CommitState> emit,
  ) {
    emit(const CommitInitial());
  }

  /// 处理验证提交消息事件
  void _onValidateCommitMessage(
    ValidateCommitMessage event,
    Emitter<CommitState> emit,
  ) {
    final currentState = state;
    String? repoPath;
    String? author;
    String? email;
    bool amend = false;
    bool signOff = false;
    List<String> recentMessages = [];
    Map<String, String> templates = {};

    if (currentState is CommitReady) {
      repoPath = currentState.repoPath;
      author = currentState.author;
      email = currentState.email;
      amend = currentState.amend;
      signOff = currentState.signOff;
      recentMessages = currentState.recentMessages;
      templates = currentState.templates;
    }

    final validation = _validateMessage(event.message);

    emit(CommitMessageValidated(
      repoPath ?? '',
      message: event.message,
      author: author,
      email: email,
      amend: amend,
      signOff: signOff,
      isMessageValid: validation.isValid,
      messageError: validation.error,
      recentMessages: recentMessages,
      templates: templates,
    ));
  }

  /// 处理设置提交消息事件
  void _onSetCommitMessage(
    SetCommitMessage event,
    Emitter<CommitState> emit,
  ) {
    final currentState = state;
    String? repoPath;
    String? author;
    String? email;
    bool amend = false;
    bool signOff = false;
    List<String> recentMessages = [];
    Map<String, String> templates = {};

    if (currentState is CommitReady) {
      repoPath = currentState.repoPath;
      author = currentState.author;
      email = currentState.email;
      amend = currentState.amend;
      signOff = currentState.signOff;
      recentMessages = currentState.recentMessages;
      templates = currentState.templates;
    }

    final validation = _validateMessage(event.message);

    emit(CommitReady(
      repoPath ?? '',
      message: event.message,
      author: author,
      email: email,
      amend: amend,
      signOff: signOff,
      isMessageValid: validation.isValid,
      messageError: validation.error,
      recentMessages: recentMessages,
      templates: templates,
    ));
  }

  /// 处理设置提交作者事件
  void _onSetCommitAuthor(
    SetCommitAuthor event,
    Emitter<CommitState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitReady) {
      emit(currentState.copyWith(
        author: event.author,
        email: event.email,
        clearAuthor: event.author == null,
        clearEmail: event.email == null,
      ));
    } else {
      emit(CommitReady(
        '',
        author: event.author,
        email: event.email,
      ));
    }
  }

  /// 处理切换修改模式事件
  void _onToggleAmendMode(
    ToggleAmendMode event,
    Emitter<CommitState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitReady) {
      emit(currentState.copyWith(amend: !currentState.amend));
    }
  }

  /// 处理切换签名模式事件
  void _onToggleSignOffMode(
    ToggleSignOffMode event,
    Emitter<CommitState> emit,
  ) {
    final currentState = state;
    if (currentState is CommitReady) {
      emit(currentState.copyWith(signOff: !currentState.signOff));
    }
  }

  /// 处理加载提交模板事件
  Future<void> _onLoadCommitTemplate(
    LoadCommitTemplate event,
    Emitter<CommitState> emit,
  ) async {
    final currentState = state;
    String message = '';
    String? author;
    String? email;
    bool amend = false;
    bool signOff = false;
    List<String> recentMessages = [];
    Map<String, String> templates = {};

    if (currentState is CommitReady) {
      message = currentState.message;
      author = currentState.author;
      email = currentState.email;
      amend = currentState.amend;
      signOff = currentState.signOff;
      recentMessages = currentState.recentMessages;
      templates = Map.from(currentState.templates);
    }

    try {
      // 这里应该从文件系统或配置中加载模板
      // 目前使用默认模板
      final templateName = event.templateName ?? 'default';
      final templateContent = _getDefaultTemplate(templateName);

      templates[templateName] = templateContent;

      emit(CommitTemplateLoaded(
        event.repoPath,
        templateName,
        templateContent,
        message: templateContent,
        author: author,
        email: email,
        amend: amend,
        signOff: signOff,
        isMessageValid: _validateMessage(templateContent).isValid,
        recentMessages: recentMessages,
        templates: templates,
      ));
    } catch (e) {
      emit(CommitError(
        event.repoPath,
        'Failed to load commit template: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理保存提交模板事件
  Future<void> _onSaveCommitTemplate(
    SaveCommitTemplate event,
    Emitter<CommitState> emit,
  ) async {
    final currentState = state;

    try {
      // 这里应该将模板保存到文件系统或配置中
      // 目前只更新内存中的模板

      if (currentState is CommitReady) {
        final updatedTemplates =
            Map<String, String>.from(currentState.templates);
        updatedTemplates[event.templateName] = event.template;

        emit(currentState.copyWith(templates: updatedTemplates));
      }
    } catch (e) {
      emit(CommitError(
        event.repoPath,
        'Failed to save commit template: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理获取提交历史消息事件
  Future<void> _onGetCommitHistoryMessages(
    GetCommitHistoryMessages event,
    Emitter<CommitState> emit,
  ) async {
    final currentState = state;
    String message = '';
    String? author;
    String? email;
    bool amend = false;
    bool signOff = false;
    bool isMessageValid = false;
    String? messageError;
    Map<String, String> templates = {};

    if (currentState is CommitReady) {
      message = currentState.message;
      author = currentState.author;
      email = currentState.email;
      amend = currentState.amend;
      signOff = currentState.signOff;
      isMessageValid = currentState.isMessageValid;
      messageError = currentState.messageError;
      templates = currentState.templates;
    }

    try {
      final commits = await _getCommitHistoryUseCase.getRecentCommits(
        repoPath: event.repoPath,
        count: event.limit,
      );

      final recentMessages = commits
          .map((commit) => commit.message)
          .where((msg) => msg.trim().isNotEmpty)
          .toList();

      emit(CommitHistoryMessagesLoaded(
        event.repoPath,
        message: message,
        author: author,
        email: email,
        amend: amend,
        signOff: signOff,
        isMessageValid: isMessageValid,
        messageError: messageError,
        recentMessages: recentMessages,
        templates: templates,
      ));
    } catch (e) {
      emit(CommitError(
        event.repoPath,
        'Failed to load commit history messages: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 验证提交消息
  ({bool isValid, String? error}) _validateMessage(String message) {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      return (isValid: false, error: 'Commit message cannot be empty');
    }

    if (trimmedMessage.length < 3) {
      return (
        isValid: false,
        error: 'Commit message must be at least 3 characters long'
      );
    }

    if (trimmedMessage.length > 72) {
      return (
        isValid: false,
        error: 'First line should be 72 characters or less'
      );
    }

    // 检查是否只包含空白字符
    if (trimmedMessage.replaceAll(RegExp(r'\s+'), '').isEmpty) {
      return (
        isValid: false,
        error: 'Commit message cannot contain only whitespace'
      );
    }

    return (isValid: true, error: null);
  }

  /// 获取默认模板
  String _getDefaultTemplate(String templateName) {
    switch (templateName.toLowerCase()) {
      case 'feat':
        return 'feat: add new feature';
      case 'fix':
        return 'fix: resolve issue';
      case 'docs':
        return 'docs: update documentation';
      case 'style':
        return 'style: improve code formatting';
      case 'refactor':
        return 'refactor: restructure code';
      case 'test':
        return 'test: add or update tests';
      case 'chore':
        return 'chore: update build process or auxiliary tools';
      default:
        return 'Update: make changes';
    }
  }
}
