import '../../entities/setting/user_settings.dart';
import '../../entities/typing/dictionary.dart';
import '../../repositories/setting/settings_repository.dart';
import '../../../../core/errors/failures.dart';

/// 获取用户设置用例
class GetUserSettings {
  final SettingsRepository repository;

  GetUserSettings(this.repository);

  Future<UserSettings> call() async {
    try {
      return await repository.getUserSettings();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 保存用户设置用例
class SaveUserSettings {
  final SettingsRepository repository;

  SaveUserSettings(this.repository);

  Future<void> call(UserSettings settings) async {
    try {
      await repository.saveUserSettings(settings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 重置为默认设置用例
class ResetToDefaultSettings {
  final SettingsRepository repository;

  ResetToDefaultSettings(this.repository);

  Future<void> call() async {
    try {
      await repository.resetToDefault();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 获取特定设置项用例
class GetSetting {
  final SettingsRepository repository;

  GetSetting(this.repository);

  Future<T?> call<T>(String key) async {
    try {
      return await repository.getSetting<T>(key);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 保存特定设置项用例
class SaveSetting {
  final SettingsRepository repository;

  SaveSetting(this.repository);

  Future<void> call<T>(String key, T value) async {
    try {
      await repository.saveSetting<T>(key, value);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 删除特定设置项用例
class DeleteSetting {
  final SettingsRepository repository;

  DeleteSetting(this.repository);

  Future<void> call(String key) async {
    try {
      await repository.deleteSetting(key);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 检查设置项是否存在用例
class HasSetting {
  final SettingsRepository repository;

  HasSetting(this.repository);

  Future<bool> call(String key) async {
    try {
      return await repository.hasSetting(key);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 获取所有设置键用例
class GetAllSettingKeys {
  final SettingsRepository repository;

  GetAllSettingKeys(this.repository);

  Future<List<String>> call() async {
    try {
      return await repository.getAllSettingKeys();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 清空所有设置用例
class ClearAllSettings {
  final SettingsRepository repository;

  ClearAllSettings(this.repository);

  Future<void> call() async {
    try {
      await repository.clearAllSettings();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 导出设置用例
class ExportSettings {
  final SettingsRepository repository;

  ExportSettings(this.repository);

  Future<Map<String, dynamic>> call() async {
    try {
      return await repository.exportSettings();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 导入设置用例
class ImportSettings {
  final SettingsRepository repository;

  ImportSettings(this.repository);

  Future<void> call(Map<String, dynamic> settings) async {
    try {
      await repository.importSettings(settings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 监听设置变化用例
class WatchUserSettings {
  final SettingsRepository repository;

  WatchUserSettings(this.repository);

  Stream<UserSettings> call() {
    return repository.watchUserSettings();
  }
}

/// 监听特定设置项变化用例
class WatchSetting {
  final SettingsRepository repository;

  WatchSetting(this.repository);

  Stream<T?> call<T>(String key) {
    return repository.watchSetting<T>(key);
  }
}

/// 验证设置用例
class ValidateSettings {
  final SettingsRepository repository;

  ValidateSettings(this.repository);

  Future<bool> call(UserSettings settings) async {
    try {
      return await repository.validateSettings(settings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 备份设置用例
class BackupSettings {
  final SettingsRepository repository;

  BackupSettings(this.repository);

  Future<String> call() async {
    try {
      return await repository.backupSettings();
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 恢复设置备份用例
class RestoreSettings {
  final SettingsRepository repository;

  RestoreSettings(this.repository);

  Future<void> call(String backupData) async {
    try {
      await repository.restoreSettings(backupData);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 更新主题模式用例
class UpdateThemeMode {
  final SettingsRepository repository;

  UpdateThemeMode(this.repository);

  Future<void> call(ThemeMode themeMode) async {
    try {
      final currentSettings = await repository.getUserSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await repository.saveUserSettings(updatedSettings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 更新字体大小用例
class UpdateFontSize {
  final SettingsRepository repository;

  UpdateFontSize(this.repository);

  Future<void> call(FontSize fontSize) async {
    try {
      final currentSettings = await repository.getUserSettings();
      final updatedSettings = currentSettings.copyWith(fontSize: fontSize);
      await repository.saveUserSettings(updatedSettings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 更新键盘音效设置用例
class UpdateKeySoundSettings {
  final SettingsRepository repository;

  UpdateKeySoundSettings(this.repository);

  Future<void> call({
    bool? enableKeySound,
    KeySoundType? keySoundType,
    double? soundVolume,
  }) async {
    try {
      final currentSettings = await repository.getUserSettings();
      final updatedSettings = currentSettings.copyWith(
        enableKeySound: enableKeySound,
        keySoundType: keySoundType,
        soundVolume: soundVolume,
      );
      await repository.saveUserSettings(updatedSettings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 更新发音设置用例
class UpdatePronunciationSettings {
  final SettingsRepository repository;

  UpdatePronunciationSettings(this.repository);

  Future<void> call({
    bool? enableWordPronunciation,
    PronunciationType? pronunciationType,
    double? pronunciationVolume,
  }) async {
    try {
      final currentSettings = await repository.getUserSettings();
      final updatedSettings = currentSettings.copyWith(
        enableWordPronunciation: enableWordPronunciation,
        pronunciationType: pronunciationType,
        pronunciationVolume: pronunciationVolume,
      );
      await repository.saveUserSettings(updatedSettings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}

/// 更新学习设置用例
class UpdateLearningSettings {
  final SettingsRepository repository;

  UpdateLearningSettings(this.repository);

  Future<void> call({
    DictationMode? dictationMode,
    bool? showPhonetic,
    bool? showTranslation,
    bool? autoSwitchChapter,
    LoopTimesOption? loopTimes,
    bool? enableRandomMode,
    bool? enableErrorReview,
    int? wordsPerChapter,
  }) async {
    try {
      final currentSettings = await repository.getUserSettings();
      final updatedSettings = currentSettings.copyWith(
        dictationMode: dictationMode,
        showPhonetic: showPhonetic,
        showTranslation: showTranslation,
        autoSwitchChapter: autoSwitchChapter,
        loopTimes: loopTimes,
        enableRandomMode: enableRandomMode,
        enableErrorReview: enableErrorReview,
        wordsPerChapter: wordsPerChapter,
      );
      await repository.saveUserSettings(updatedSettings);
    } catch (e) {
      throw ValidationFailure(e.toString());
    }
  }
}
