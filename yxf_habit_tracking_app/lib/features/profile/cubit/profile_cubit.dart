import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hunnu_auth/hunnu_auth.dart';

part 'profile_state.dart';

/// 个人资料页面状态管理
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ProfileState.initial());

  final AuthenticationRepository _authenticationRepository;

  /// 加载个人资料
  void loadProfile() {
    final user = _authenticationRepository.currentUser;
    emit(state.copyWith(
      user: user,
      loginDays: _calculateLoginDays(),
      messageCount: _getMessageCount(),
    ));
  }

  /// 更新姓名
  Future<void> updateName(String name) async {
    try {
      emit(state.copyWith(isLoading: true));

      // TODO: 调用API更新姓名
      final updatedUser = state.user.copyWith(name: name);

      emit(state.copyWith(
        user: updatedUser,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 更新手机号
  Future<void> updatePhone(String phone) async {
    try {
      emit(state.copyWith(isLoading: true));

      // TODO: 调用API更新手机号
      final updatedUser = state.user.copyWith(phone: phone);

      emit(state.copyWith(
        user: updatedUser,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 更新邮箱
  Future<void> updateEmail(String email) async {
    try {
      emit(state.copyWith(isLoading: true));

      // TODO: 调用API更新邮箱
      final updatedUser = state.user.copyWith(email: email);

      emit(state.copyWith(
        user: updatedUser,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 修改密码
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      emit(state.copyWith(isLoading: true));

      // TODO: 调用API修改密码
      await Future.delayed(const Duration(seconds: 1)); // 模拟API调用

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 计算登录天数
  int _calculateLoginDays() {
    // TODO: 实现真实的登录天数计算逻辑
    return 30;
  }

  /// 获取消息数量
  int _getMessageCount() {
    // TODO: 实现真实的消息数量统计
    return 128;
  }
}
