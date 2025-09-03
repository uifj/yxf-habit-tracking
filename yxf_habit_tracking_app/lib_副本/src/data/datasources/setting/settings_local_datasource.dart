import '../../../domain/entities/setting/user_settings.dart';

/// 设置本地数据源抽象接口
abstract class SettingsLocalDataSource {
  /// 获取用户设置
  Future<UserSettings> getSettings();

  /// 保存用户设置
  Future<void> saveSettings(UserSettings settings);

  /// 重置设置为默认值
  Future<void> resetSettings();

  /// 获取默认设置
  Future<UserSettings> getDefaultSettings();

  /// 检查设置是否存在
  Future<bool> hasSettings();

  /// 监听设置变化
  Stream<UserSettings> watchSettings();

  // ========== 单项设置方法 ==========

  /// 更新主题模式
  Future<void> updateThemeMode(ThemeMode themeMode);

  /// 更新字体大小
  Future<void> updateFontSize(FontSize fontSize);

  /// 更新键盘音效类型
  Future<void> updateKeySoundType(KeySoundType soundType);

  /// 更新键盘音效开关
  Future<void> updateKeySoundEnabled(bool enabled);

  /// 更新键盘音效音量
  Future<void> updateKeySoundVolume(double volume);

  /// 更新发音开关
  Future<void> updatePronunciationEnabled(bool enabled);

  /// 更新发音音量
  Future<void> updatePronunciationVolume(double volume);

  /// 更新听写模式
  Future<void> updateDictationMode(DictationMode mode);

  /// 更新显示音标开关
  Future<void> updateShowPhonetic(bool show);

  /// 更新显示翻译开关
  Future<void> updateShowTranslation(bool show);

  /// 更新显示词性开关
  Future<void> updateShowWordType(bool show);

  /// 更新显示进度开关
  Future<void> updateShowProgress(bool show);

  /// 更新显示WPM开关
  Future<void> updateShowWpm(bool show);

  /// 更新显示准确率开关
  Future<void> updateShowAccuracy(bool show);

  /// 更新忽略大小写开关
  Future<void> updateIgnoreCase(bool ignore);

  /// 更新忽略标点开关
  Future<void> updateIgnorePunctuation(bool ignore);

  /// 更新随机顺序开关
  Future<void> updateRandomOrder(bool random);

  /// 更新循环次数选项
  Future<void> updateLoopTimes(LoopTimesOption loopTimes);

  /// 更新自动保存开关
  Future<void> updateAutoSave(bool autoSave);

  /// 更新自动保存间隔
  Future<void> updateAutoSaveInterval(int intervalMinutes);

  /// 更新统计收集开关
  Future<void> updateCollectStatistics(bool collect);

  /// 更新匿名统计开关
  Future<void> updateAnonymousStatistics(bool anonymous);

  /// 更新每日提醒开关
  Future<void> updateDailyReminder(bool enabled);

  /// 更新每日提醒时间
  Future<void> updateDailyReminderTime(String time);

  /// 更新休息提醒开关
  Future<void> updateBreakReminder(bool enabled);

  /// 更新休息提醒间隔
  Future<void> updateBreakReminderInterval(int intervalMinutes);

  /// 更新护眼模式开关
  Future<void> updateEyeProtectionMode(bool enabled);

  /// 更新护眼模式开始时间
  Future<void> updateEyeProtectionStartTime(String time);

  /// 更新护眼模式结束时间
  Future<void> updateEyeProtectionEndTime(String time);

  // ========== 设置验证方法 ==========

  /// 验证设置数据
  Future<bool> validateSettings(UserSettings settings);

  /// 验证主题模式
  Future<bool> validateThemeMode(ThemeMode themeMode);

  /// 验证字体大小
  Future<bool> validateFontSize(FontSize fontSize);

  /// 验证音量值
  Future<bool> validateVolume(double volume);

  /// 验证时间格式
  Future<bool> validateTimeFormat(String time);

  /// 验证间隔时间
  Future<bool> validateInterval(int intervalMinutes);

  // ========== 设置迁移方法 ==========

  /// 迁移设置数据
  Future<void> migrateSettings(int fromVersion, int toVersion);

  /// 获取设置版本
  Future<int> getSettingsVersion();

  /// 更新设置版本
  Future<void> updateSettingsVersion(int version);

  /// 检查是否需要迁移
  Future<bool> needsMigration();

  // ========== 设置备份和恢复 ==========

  /// 导出设置数据
  Future<Map<String, dynamic>> exportSettings();

  /// 导入设置数据
  Future<void> importSettings(Map<String, dynamic> data);

  /// 备份设置
  Future<void> backupSettings();

  /// 恢复设置
  Future<void> restoreSettings(Map<String, dynamic> backupData);

  /// 获取备份列表
  Future<List<Map<String, dynamic>>> getBackupList();

  /// 删除备份
  Future<void> deleteBackup(String backupId);

  /// 清理过期备份
  Future<void> cleanupExpiredBackups(Duration retentionPeriod);

  // ========== 缓存和性能 ==========

  /// 清除设置缓存
  Future<void> clearSettingsCache();

  /// 预加载设置
  Future<void> preloadSettings();

  /// 获取缓存大小
  Future<int> getCacheSize();

  /// 优化存储
  Future<void> optimizeStorage();

  // ========== 调试和诊断 ==========

  /// 获取设置诊断信息
  Future<Map<String, dynamic>> getSettingsDiagnostics();

  /// 验证设置完整性
  Future<bool> validateSettingsIntegrity();

  /// 修复损坏的设置
  Future<void> repairCorruptedSettings();

  /// 获取设置统计信息
  Future<Map<String, dynamic>> getSettingsStats();
}
