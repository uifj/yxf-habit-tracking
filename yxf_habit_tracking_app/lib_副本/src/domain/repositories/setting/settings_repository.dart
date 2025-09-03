import '../../entities/setting/user_settings.dart';

/// 设置仓储接口
abstract class SettingsRepository {
  /// 获取用户设置
  Future<UserSettings> getUserSettings();

  /// 保存用户设置
  Future<void> saveUserSettings(UserSettings settings);

  /// 重置为默认设置
  Future<void> resetToDefault();

  /// 获取特定设置项
  Future<T?> getSetting<T>(String key);

  /// 保存特定设置项
  Future<void> saveSetting<T>(String key, T value);

  /// 删除特定设置项
  Future<void> deleteSetting(String key);

  /// 检查设置项是否存在
  Future<bool> hasSetting(String key);

  /// 获取所有设置键
  Future<List<String>> getAllSettingKeys();

  /// 清空所有设置
  Future<void> clearAllSettings();

  /// 导出设置
  Future<Map<String, dynamic>> exportSettings();

  /// 导入设置
  Future<void> importSettings(Map<String, dynamic> settings);

  /// 监听设置变化
  Stream<UserSettings> watchUserSettings();

  /// 监听特定设置项变化
  Stream<T?> watchSetting<T>(String key);

  /// 获取设置版本
  Future<int> getSettingsVersion();

  /// 迁移设置
  Future<void> migrateSettings(int fromVersion, int toVersion);

  /// 验证设置
  Future<bool> validateSettings(UserSettings settings);

  /// 获取设置备份
  Future<String> backupSettings();

  /// 恢复设置备份
  Future<void> restoreSettings(String backupData);
}
