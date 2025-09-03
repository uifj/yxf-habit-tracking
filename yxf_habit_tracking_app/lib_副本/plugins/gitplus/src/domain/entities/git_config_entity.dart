import 'package:equatable/equatable.dart';

/// Git自动同步配置实体
class GitAutoSyncConfigEntity extends Equatable {
  /// 是否启用自动同步
  final bool enabled;

  /// 同步间隔（分钟）
  final int intervalMinutes;

  /// 启动时是否自动拉取
  final bool pullOnStartup;

  /// 启动时是否自动推送
  final bool pushOnStartup;

  /// 是否按计划提交
  final bool commitOnSchedule;

  /// 默认提交消息
  final String defaultCommitMessage;

  const GitAutoSyncConfigEntity({
    required this.enabled,
    required this.intervalMinutes,
    required this.pullOnStartup,
    required this.pushOnStartup,
    required this.commitOnSchedule,
    required this.defaultCommitMessage,
  });

  /// 复制并修改属性
  GitAutoSyncConfigEntity copyWith({
    bool? enabled,
    int? intervalMinutes,
    bool? pullOnStartup,
    bool? pushOnStartup,
    bool? commitOnSchedule,
    String? defaultCommitMessage,
  }) {
    return GitAutoSyncConfigEntity(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      pullOnStartup: pullOnStartup ?? this.pullOnStartup,
      pushOnStartup: pushOnStartup ?? this.pushOnStartup,
      commitOnSchedule: commitOnSchedule ?? this.commitOnSchedule,
      defaultCommitMessage: defaultCommitMessage ?? this.defaultCommitMessage,
    );
  }

  /// 默认配置
  factory GitAutoSyncConfigEntity.defaultConfig() {
    return const GitAutoSyncConfigEntity(
      enabled: false,
      intervalMinutes: 30,
      pullOnStartup: true,
      pushOnStartup: false,
      commitOnSchedule: false,
      defaultCommitMessage: 'Auto commit',
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        intervalMinutes,
        pullOnStartup,
        pushOnStartup,
        commitOnSchedule,
        defaultCommitMessage,
      ];

  @override
  String toString() {
    return 'GitAutoSyncConfigEntity(enabled: $enabled, intervalMinutes: $intervalMinutes)';
  }
}

/// Git配置实体
class GitConfigEntity extends Equatable {
  /// 用户名
  final String? userName;

  /// 用户邮箱
  final String? userEmail;

  /// 自动同步配置
  final GitAutoSyncConfigEntity autoSync;

  /// 是否显示状态栏
  final bool showStatusBar;

  /// 是否显示文件状态图标
  final bool showFileStatusIcons;

  /// 是否显示分支信息
  final bool showBranchInfo;

  /// 忽略的文件模式列表
  final List<String> ignoredFiles;

  /// 远程仓库配置
  final Map<String, String> remotes;

  /// 子模块配置
  final Map<String, String> submodules;

  /// GitHub访问令牌
  final String? githubToken;

  /// GitHub用户名
  final String? githubUsername;

  /// 是否启用GitHub集成
  final bool enableGithubIntegration;

  const GitConfigEntity({
    this.userName,
    this.userEmail,
    required this.autoSync,
    required this.showStatusBar,
    required this.showFileStatusIcons,
    required this.showBranchInfo,
    required this.ignoredFiles,
    required this.remotes,
    required this.submodules,
    this.githubToken,
    this.githubUsername,
    required this.enableGithubIntegration,
  });

  /// 复制并修改属性
  GitConfigEntity copyWith({
    String? userName,
    String? userEmail,
    GitAutoSyncConfigEntity? autoSync,
    bool? showStatusBar,
    bool? showFileStatusIcons,
    bool? showBranchInfo,
    List<String>? ignoredFiles,
    Map<String, String>? remotes,
    Map<String, String>? submodules,
    String? githubToken,
    String? githubUsername,
    bool? enableGithubIntegration,
  }) {
    return GitConfigEntity(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      autoSync: autoSync ?? this.autoSync,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      showFileStatusIcons: showFileStatusIcons ?? this.showFileStatusIcons,
      showBranchInfo: showBranchInfo ?? this.showBranchInfo,
      ignoredFiles: ignoredFiles ?? this.ignoredFiles,
      remotes: remotes ?? this.remotes,
      submodules: submodules ?? this.submodules,
      githubToken: githubToken ?? this.githubToken,
      githubUsername: githubUsername ?? this.githubUsername,
      enableGithubIntegration:
          enableGithubIntegration ?? this.enableGithubIntegration,
    );
  }

  /// 默认配置
  factory GitConfigEntity.defaultConfig() {
    return GitConfigEntity(
      autoSync: GitAutoSyncConfigEntity.defaultConfig(),
      showStatusBar: true,
      showFileStatusIcons: true,
      showBranchInfo: true,
      ignoredFiles: const [],
      remotes: const {},
      submodules: const {},
      enableGithubIntegration: false,
    );
  }

  /// 是否配置了用户信息
  bool get hasUserInfo => userName != null && userEmail != null;

  /// 是否配置了GitHub集成
  bool get hasGithubIntegration =>
      enableGithubIntegration && githubToken != null;

  @override
  List<Object?> get props => [
        userName,
        userEmail,
        autoSync,
        showStatusBar,
        showFileStatusIcons,
        showBranchInfo,
        ignoredFiles,
        remotes,
        submodules,
        githubToken,
        githubUsername,
        enableGithubIntegration,
      ];

  @override
  String toString() {
    return 'GitConfigEntity(userName: $userName, userEmail: $userEmail)';
  }
}
