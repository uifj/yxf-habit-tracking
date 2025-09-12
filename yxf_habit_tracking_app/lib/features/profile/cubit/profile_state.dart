part of 'profile_cubit.dart';

/// 个人资料页面状态
class ProfileState extends Equatable {
  const ProfileState({
    UserModel? user,
    this.isLoading = false,
    this.loginDays = 0,
    this.messageCount = 0,
    this.error,
  }) : user = user ?? const UserModel();

  /// 创建默认状态
  const ProfileState.initial() : this();

  /// 当前用户
  final UserModel user;

  /// 是否正在加载
  final bool isLoading;

  /// 登录天数
  final int loginDays;

  /// 消息数量
  final int messageCount;

  /// 错误信息
  final String? error;

  /// 复制状态
  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    int? loginDays,
    int? messageCount,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      loginDays: loginDays ?? this.loginDays,
      messageCount: messageCount ?? this.messageCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, loginDays, messageCount, error];
}
