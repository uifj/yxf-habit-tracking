import '../../../domain/entities/setting/user_settings.dart';
import '../../../domain/repositories/setting/settings_repository.dart';
import '../../datasources/setting/settings_local_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

/// 设置仓库实现
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<UserSettings> getUserSettings() async {
    try {
      return await localDataSource.getSettings();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      await localDataSource.saveSettings(settings);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> resetToDefault() async {
    try {
      await localDataSource.resetSettings();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      await localDataSource.importSettings(settingsData);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      return await localDataSource.exportSettings();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Stream<UserSettings> watchUserSettings() {
    try {
      return localDataSource.watchSettings();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<bool> validateSettings(UserSettings settings) async {
    try {
      return await localDataSource.validateSettings(settings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<String> backupSettings() async {
    try {
      final settings = await localDataSource.exportSettings();
      return settings.toString();
    } on FileException catch (e) {
      throw FileFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> restoreSettings(String backupData) async {
    try {
      // Parse backup data and restore
      // This is a simplified implementation
      await localDataSource.resetSettings();
    } on FileException catch (e) {
      throw FileFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      await localDataSource.updateThemeMode(themeMode);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateFontSize(FontSize fontSize) async {
    try {
      await localDataSource.updateFontSize(fontSize);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateKeySoundEnabled(bool enabled) async {
    try {
      await localDataSource.updateKeySoundEnabled(enabled);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updatePronunciationEnabled(bool enabled) async {
    try {
      await localDataSource.updatePronunciationEnabled(enabled);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateDictationMode(DictationMode mode) async {
    try {
      await localDataSource.updateDictationMode(mode);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    try {
      // This is a simplified implementation - would need proper key mapping
      return null;
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> saveSetting<T>(String key, T value) async {
    try {
      // This is a simplified implementation - would need proper key mapping
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> deleteSetting(String key) async {
    try {
      // This is a simplified implementation - would need proper key mapping
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<List<String>> getAllSettingKeys() async {
    try {
      // This is a simplified implementation - would return all available setting keys
      return [];
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> clearAllSettings() async {
    try {
      await localDataSource.resetSettings();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Stream<T?> watchSetting<T>(String key) {
    try {
      // This is a simplified implementation - would need proper key mapping
      return Stream.value(null);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<int> getSettingsVersion() async {
    try {
      // This is a simplified implementation - would return actual version
      return 1;
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<bool> hasSetting(String key) async {
    try {
      // This is a simplified implementation - would check if key exists
      return false;
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  // Additional methods that match the datasource interface

  @override
  Future<void> updateKeySoundType(KeySoundType soundType) async {
    try {
      await localDataSource.updateKeySoundType(soundType);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateKeySoundVolume(double volume) async {
    try {
      await localDataSource.updateKeySoundVolume(volume);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updatePronunciationVolume(double volume) async {
    try {
      await localDataSource.updatePronunciationVolume(volume);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateShowPhonetic(bool show) async {
    try {
      await localDataSource.updateShowPhonetic(show);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateShowTranslation(bool show) async {
    try {
      await localDataSource.updateShowTranslation(show);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateAutoSave(bool autoSave) async {
    try {
      await localDataSource.updateAutoSave(autoSave);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateAutoSaveInterval(int intervalMinutes) async {
    try {
      await localDataSource.updateAutoSaveInterval(intervalMinutes);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> updateEyeProtectionMode(bool enabled) async {
    try {
      await localDataSource.updateEyeProtectionMode(enabled);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> migrateSettings(int fromVersion, int toVersion) async {
    try {
      await localDataSource.migrateSettings(fromVersion, toVersion);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }

  @override
  Future<void> clearSettingsCache() async {
    try {
      await localDataSource.clearSettingsCache();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}
