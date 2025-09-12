import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hunnu_auth/hunnu_auth.dart';

part 'settings_state.dart';

/// 设置页面状态管理
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const SettingsState()) {
    _loadUserInfo();
  }

  final AuthenticationRepository _authenticationRepository;

  /// 加载用户信息
  void _loadUserInfo() {
    final user = _authenticationRepository.currentUser;
    emit(state.copyWith(user: user));
  }

  /// 刷新用户信息
  void refreshUserInfo() {
    _loadUserInfo();
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      // TODO: 实现缓存清理逻辑
      // 可以清理图片缓存、临时文件等
      emit(state.copyWith(isLoading: true));

      // 模拟清理过程
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _authenticationRepository.logOut();
      emit(state.copyWith(
        isLoading: false,
        user: const UserModel(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 更新用户信息
  void updateUser(UserModel user) {
    emit(state.copyWith(user: user));
  }
}
