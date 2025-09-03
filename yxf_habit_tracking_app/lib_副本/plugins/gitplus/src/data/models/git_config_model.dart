import 'package:equatable/equatable.dart';

/// Git自动同步配置
class GitAutoSyncConfig extends Equatable {
  final bool enabled;
  final int intervalMinutes;
  final bool pullOnStartup;
  final bool pushAfterCommit;
  final bool commitOnSchedule;
  final String defaultCommitMessage;

  const GitAutoSyncConfig({
    required this.enabled,
    required this.intervalMinutes,
    required this.pullOnStartup,
    required this.pushAfterCommit,
    required this.commitOnSchedule,
    required this.defaultCommitMessage,
  });

  GitAutoSyncConfig copyWith({
    bool? enabled,
    int? intervalMinutes,
    bool? pullOnStartup,
    bool? pushAfterCommit,
    bool? commitOnSchedule,
    String? defaultCommitMessage,
  }) {
    return GitAutoSyncConfig(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      pullOnStartup: pullOnStartup ?? this.pullOnStartup,
      pushAfterCommit: pushAfterCommit ?? this.pushAfterCommit,
      commitOnSchedule: commitOnSchedule ?? this.commitOnSchedule,
      defaultCommitMessage: defaultCommitMessage ?? this.defaultCommitMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'intervalMinutes': intervalMinutes,
      'pullOnStartup': pullOnStartup,
      'pushAfterCommit': pushAfterCommit,
      'commitOnSchedule': commitOnSchedule,
      'defaultCommitMessage': defaultCommitMessage,
    };
  }

  factory GitAutoSyncConfig.fromJson(Map<String, dynamic> json) {
    return GitAutoSyncConfig(
      enabled: json['enabled'] as bool? ?? false,
      intervalMinutes: json['intervalMinutes'] as int? ?? 30,
      pullOnStartup: json['pullOnStartup'] as bool? ?? true,
      pushAfterCommit: json['pushAfterCommit'] as bool? ?? true,
      commitOnSchedule: json['commitOnSchedule'] as bool? ?? true,
      defaultCommitMessage:
          json['defaultCommitMessage'] as String? ?? 'Auto commit',
    );
  }

  factory GitAutoSyncConfig.defaultConfig() {
    return const GitAutoSyncConfig(
      enabled: false,
      intervalMinutes: 30,
      pullOnStartup: true,
      pushAfterCommit: true,
      commitOnSchedule: true,
      defaultCommitMessage: 'Auto commit: {{date}}',
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        intervalMinutes,
        pullOnStartup,
        pushAfterCommit,
        commitOnSchedule,
        defaultCommitMessage,
      ];
}

/// Git配置模型
class GitConfigModel extends Equatable {
  final String? userName;
  final String? userEmail;
  final GitAutoSyncConfig autoSync;
  final bool showAuthor;
  final bool showDate;
  final int maxCommitsToShow;
  final List<String> ignoredFiles;
  final Map<String, String> remotes;
  final bool enableSubmodules;
  final String? githubToken;
  final String? githubUsername;

  const GitConfigModel({
    this.userName,
    this.userEmail,
    required this.autoSync,
    required this.showAuthor,
    required this.showDate,
    required this.maxCommitsToShow,
    required this.ignoredFiles,
    required this.remotes,
    required this.enableSubmodules,
    this.githubToken,
    this.githubUsername,
  });

  GitConfigModel copyWith({
    String? userName,
    String? userEmail,
    GitAutoSyncConfig? autoSync,
    bool? showAuthor,
    bool? showDate,
    int? maxCommitsToShow,
    List<String>? ignoredFiles,
    Map<String, String>? remotes,
    bool? enableSubmodules,
    String? githubToken,
    String? githubUsername,
  }) {
    return GitConfigModel(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      autoSync: autoSync ?? this.autoSync,
      showAuthor: showAuthor ?? this.showAuthor,
      showDate: showDate ?? this.showDate,
      maxCommitsToShow: maxCommitsToShow ?? this.maxCommitsToShow,
      ignoredFiles: ignoredFiles ?? this.ignoredFiles,
      remotes: remotes ?? this.remotes,
      enableSubmodules: enableSubmodules ?? this.enableSubmodules,
      githubToken: githubToken ?? this.githubToken,
      githubUsername: githubUsername ?? this.githubUsername,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'autoSync': autoSync.toJson(),
      'showAuthor': showAuthor,
      'showDate': showDate,
      'maxCommitsToShow': maxCommitsToShow,
      'ignoredFiles': ignoredFiles,
      'remotes': remotes,
      'enableSubmodules': enableSubmodules,
      'githubToken': githubToken,
      'githubUsername': githubUsername,
    };
  }

  factory GitConfigModel.fromJson(Map<String, dynamic> json) {
    return GitConfigModel(
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      autoSync: GitAutoSyncConfig.fromJson(
        json['autoSync'] as Map<String, dynamic>? ?? {},
      ),
      showAuthor: json['showAuthor'] as bool? ?? false,
      showDate: json['showDate'] as bool? ?? false,
      maxCommitsToShow: json['maxCommitsToShow'] as int? ?? 50,
      ignoredFiles: List<String>.from(json['ignoredFiles'] as List? ?? []),
      remotes: Map<String, String>.from(json['remotes'] as Map? ?? {}),
      enableSubmodules: json['enableSubmodules'] as bool? ?? false,
      githubToken: json['githubToken'] as String?,
      githubUsername: json['githubUsername'] as String?,
    );
  }

  factory GitConfigModel.defaultConfig() {
    return GitConfigModel(
      autoSync: GitAutoSyncConfig.defaultConfig(),
      showAuthor: false,
      showDate: false,
      maxCommitsToShow: 50,
      ignoredFiles: const [],
      remotes: const {},
      enableSubmodules: false,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        userEmail,
        autoSync,
        showAuthor,
        showDate,
        maxCommitsToShow,
        ignoredFiles,
        remotes,
        enableSubmodules,
        githubToken,
        githubUsername,
      ];
}
