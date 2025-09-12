part of 'settings_cubit.dart';

/// 设置页面状态
class SettingsState extends Equatable {
  const SettingsState({
    this.user = const UserModel(),
    this.isLoading = false,
  });

  /// 当前用户
  final UserModel user;

  /// 是否正在加载
  final bool isLoading;

  /// 复制状态
  SettingsState copyWith({
    UserModel? user,
    bool? isLoading,
  }) {
    return SettingsState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [user, isLoading];
}
