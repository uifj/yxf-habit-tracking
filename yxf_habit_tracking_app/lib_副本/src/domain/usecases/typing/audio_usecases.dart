import '../../entities/setting/user_settings.dart';
import '../../entities/typing/dictionary.dart';
import '../../repositories/audio_repository.dart';
import '../../../../core/errors/failures.dart';

/// 初始化音频系统用例
class InitializeAudio {
  final AudioRepository repository;

  InitializeAudio(this.repository);

  Future<void> call() async {
    try {
      await repository.initialize();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 播放键盘音效用例
class PlayKeySound {
  final AudioRepository repository;

  PlayKeySound(this.repository);

  Future<void> call(KeySoundType soundType, {double? volume}) async {
    try {
      await repository.playKeySound(soundType, volume: volume);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 播放单词发音用例
class PlayWordPronunciation {
  final AudioRepository repository;

  PlayWordPronunciation(this.repository);

  Future<void> call(
    String word,
    PronunciationType pronunciationType, {
    double? volume,
  }) async {
    try {
      await repository.playWordPronunciation(
        word,
        pronunciationType,
        volume: volume,
      );
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 播放系统音效用例
class PlaySystemSound {
  final AudioRepository repository;

  PlaySystemSound(this.repository);

  Future<void> call(String soundName, {double? volume}) async {
    try {
      await repository.playSystemSound(soundName, volume: volume);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 停止所有音频播放用例
class StopAllSounds {
  final AudioRepository repository;

  StopAllSounds(this.repository);

  Future<void> call() async {
    try {
      await repository.stopAllSounds();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 设置全局音量用例
class SetGlobalVolume {
  final AudioRepository repository;

  SetGlobalVolume(this.repository);

  Future<void> call(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw const AudioFailure('音量必须在0.0到1.0之间');
      }
      await repository.setGlobalVolume(volume);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 设置键盘音效音量用例
class SetKeySoundVolume {
  final AudioRepository repository;

  SetKeySoundVolume(this.repository);

  Future<void> call(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw const AudioFailure('音量必须在0.0到1.0之间');
      }
      await repository.setKeySoundVolume(volume);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 设置发音音量用例
class SetPronunciationVolume {
  final AudioRepository repository;

  SetPronunciationVolume(this.repository);

  Future<void> call(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw const AudioFailure('音量必须在0.0到1.0之间');
      }
      await repository.setPronunciationVolume(volume);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 获取全局音量用例
class GetGlobalVolume {
  final AudioRepository repository;

  GetGlobalVolume(this.repository);

  Future<double> call() async {
    try {
      return await repository.getGlobalVolume();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 静音/取消静音用例
class SetMuted {
  final AudioRepository repository;

  SetMuted(this.repository);

  Future<void> call(bool muted) async {
    try {
      await repository.setMuted(muted);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 检查是否静音用例
class IsMuted {
  final AudioRepository repository;

  IsMuted(this.repository);

  Future<bool> call() async {
    try {
      return await repository.isMuted();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 预加载键盘音效用例
class PreloadKeySound {
  final AudioRepository repository;

  PreloadKeySound(this.repository);

  Future<void> call(KeySoundType soundType) async {
    try {
      await repository.preloadKeySound(soundType);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 预加载单词发音用例
class PreloadWordPronunciation {
  final AudioRepository repository;

  PreloadWordPronunciation(this.repository);

  Future<void> call(
    String word,
    PronunciationType pronunciationType,
  ) async {
    try {
      await repository.preloadWordPronunciation(word, pronunciationType);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 检查键盘音效是否可用用例
class IsKeySoundAvailable {
  final AudioRepository repository;

  IsKeySoundAvailable(this.repository);

  Future<bool> call(KeySoundType soundType) async {
    try {
      return await repository.isKeySoundAvailable(soundType);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 检查单词发音是否可用用例
class IsWordPronunciationAvailable {
  final AudioRepository repository;

  IsWordPronunciationAvailable(this.repository);

  Future<bool> call(
    String word,
    PronunciationType pronunciationType,
  ) async {
    try {
      return await repository.isWordPronunciationAvailable(
        word,
        pronunciationType,
      );
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 下载单词发音用例
class DownloadWordPronunciation {
  final AudioRepository repository;

  DownloadWordPronunciation(this.repository);

  Future<void> call(
    String word,
    PronunciationType pronunciationType,
  ) async {
    try {
      await repository.downloadWordPronunciation(word, pronunciationType);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 获取音频下载进度用例
class GetAudioDownloadProgress {
  final AudioRepository repository;

  GetAudioDownloadProgress(this.repository);

  Stream<double> call(String audioPath) {
    return repository.getAudioDownloadProgress(audioPath);
  }
}

/// 取消音频下载用例
class CancelAudioDownload {
  final AudioRepository repository;

  CancelAudioDownload(this.repository);

  Future<void> call(String audioPath) async {
    try {
      await repository.cancelAudioDownload(audioPath);
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 清理音频缓存用例
class ClearAudioCache {
  final AudioRepository repository;

  ClearAudioCache(this.repository);

  Future<void> call() async {
    try {
      await repository.clearAudioCache();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 获取音频缓存大小用例
class GetAudioCacheSize {
  final AudioRepository repository;

  GetAudioCacheSize(this.repository);

  Future<int> call() async {
    try {
      return await repository.getAudioCacheSize();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 检查音频权限用例
class CheckAudioPermission {
  final AudioRepository repository;

  CheckAudioPermission(this.repository);

  Future<bool> call() async {
    try {
      return await repository.checkAudioPermission();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 请求音频权限用例
class RequestAudioPermission {
  final AudioRepository repository;

  RequestAudioPermission(this.repository);

  Future<bool> call() async {
    try {
      return await repository.requestAudioPermission();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 测试音频播放用例
class TestAudioPlayback {
  final AudioRepository repository;

  TestAudioPlayback(this.repository);

  Future<bool> call() async {
    try {
      return await repository.testAudioPlayback();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}

/// 释放音频资源用例
class DisposeAudio {
  final AudioRepository repository;

  DisposeAudio(this.repository);

  Future<void> call() async {
    try {
      await repository.dispose();
    } catch (e) {
      throw AudioFailure(e.toString());
    }
  }
}
