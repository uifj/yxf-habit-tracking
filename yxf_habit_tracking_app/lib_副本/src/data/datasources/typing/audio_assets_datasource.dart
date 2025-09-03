import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../domain/entities/setting/user_settings.dart';

/// 扩展KeySoundType以添加音频文件名映射
extension KeySoundTypeExtension on KeySoundType {
  String get filename {
    switch (this) {
      case KeySoundType.none:
        return '';
      case KeySoundType.default_:
        return 'Default.wav';
      case KeySoundType.alpacas:
        return 'Alpacas.mp3';
      case KeySoundType.cherryMxBlues:
        return 'Cherry MX Blues.mp3';
      case KeySoundType.cherryMxBrowns:
        return 'Cherry MX Browns.mp3';
      case KeySoundType.cherryMxReds:
        return 'Cherry MX Blacks.mp3'; // 修正文件名
      case KeySoundType.gateron:
        return 'Gateron Red Inks.mp3'; // 修正文件名
      case KeySoundType.kailhBox:
        return 'Kailh Box Navies.mp3'; // 修正文件名
      case KeySoundType.typewriter:
        return 'Buckling Spring.mp3'; // 修正文件名
    }
  }
}

/// 音频Assets数据源实现类
class AudioAssetsDataSource {
  static const String _keySoundsPath = 'sounds/key-sound';
  static const String _generalSoundsPath = 'sounds';

  final Map<KeySoundType, AudioPlayer> _keySoundPlayers = {};
  final AudioPlayer _wordPronunciationPlayer = AudioPlayer();
  final AudioPlayer _generalSoundPlayer = AudioPlayer();

  bool _isInitialized = false;

  /// 初始化音频系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 预加载默认键盘音效
      await preloadKeySound(KeySoundType.default_);

      _isInitialized = true;
    } catch (e) {
      throw AudioException('Failed to initialize audio system: $e');
    }
  }

  /// 释放音频资源
  Future<void> dispose() async {
    try {
      // 停止所有播放器
      for (final player in _keySoundPlayers.values) {
        await player.stop();
        await player.dispose();
      }
      _keySoundPlayers.clear();

      await _wordPronunciationPlayer.stop();
      await _wordPronunciationPlayer.dispose();

      await _generalSoundPlayer.stop();
      await _generalSoundPlayer.dispose();

      _isInitialized = false;
    } catch (e) {
      throw AudioException('Failed to dispose audio resources: $e');
    }
  }

  /// 检查音频系统是否已初始化
  bool get isInitialized => _isInitialized;

  /// 播放键盘音效
  Future<void> playKeySound(KeySoundType soundType, {double? volume}) async {
    if (soundType == KeySoundType.none) {
      return; // 无音效类型不播放
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 确保音效已预加载
      if (!_keySoundPlayers.containsKey(soundType)) {
        await preloadKeySound(soundType);
      }

      final player = _keySoundPlayers[soundType];
      if (player != null) {
        // 设置音量
        if (volume != null) {
          await player.setVolume(volume.clamp(0.0, 1.0));
        }

        // 停止当前播放并重新开始
        await player.stop();
        await player.resume();
      } else {
        // 如果播放器不存在，尝试使用默认音效
        if (soundType != KeySoundType.default_) {
          await playKeySound(KeySoundType.default_, volume: volume);
        }
      }
    } catch (e) {
      // 音频播放失败时不抛出异常，只记录日志
      print('Warning: Failed to play key sound ${soundType.displayName}: $e');
    }
  }

  /// 停止键盘音效
  Future<void> stopKeySound() async {
    try {
      for (final player in _keySoundPlayers.values) {
        await player.stop();
      }
    } catch (e) {
      throw AudioException('Failed to stop key sound: $e');
    }
  }

  /// 预加载键盘音效
  Future<void> preloadKeySound(KeySoundType soundType) async {
    if (_keySoundPlayers.containsKey(soundType)) {
      return; // 已经预加载
    }

    if (soundType == KeySoundType.none) {
      return; // 无音效类型不需要预加载
    }

    try {
      final player = AudioPlayer();
      final soundPath = '$_keySoundsPath/${soundType.filename}';

      // 检查文件是否存在
      try {
        await rootBundle.load('assets/$soundPath');
      } catch (e) {
        // 如果文件不存在，尝试使用默认音效
        if (soundType != KeySoundType.default_) {
          print(
              'Warning: Audio file not found for ${soundType.displayName}, falling back to default');
          await preloadKeySound(KeySoundType.default_);
          return;
        } else {
          throw AudioException('Default audio file not found: $soundPath');
        }
      }

      // 设置音频源
      await player.setSource(AssetSource(soundPath));

      _keySoundPlayers[soundType] = player;
    } catch (e) {
      throw AudioException(
          'Failed to preload key sound ${soundType.displayName}: $e');
    }
  }

  /// 检查键盘音效是否可用
  Future<bool> isKeySoundAvailable(KeySoundType soundType) async {
    try {
      final soundPath = '$_keySoundsPath/${soundType.filename}';
      await rootBundle.load('assets/$soundPath');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取键盘音效文件路径
  String getKeySoundPath(KeySoundType soundType) {
    return 'assets/$_keySoundsPath/${soundType.filename}';
  }

  /// 播放通用音效（如正确、错误提示音）
  Future<void> playGeneralSound(String soundName, {double? volume}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final soundPath = '$_generalSoundsPath/$soundName';

      // 检查文件是否存在
      await rootBundle.load('assets/$soundPath');

      // 设置音量
      if (volume != null) {
        await _generalSoundPlayer.setVolume(volume.clamp(0.0, 1.0));
      }

      // 停止当前播放并播放新音效
      await _generalSoundPlayer.stop();
      await _generalSoundPlayer.setSource(AssetSource(soundPath));
      await _generalSoundPlayer.resume();
    } catch (e) {
      throw AudioException('Failed to play general sound: $e');
    }
  }

  /// 播放正确音效
  Future<void> playCorrectSound({double? volume}) async {
    await playGeneralSound('correct.wav', volume: volume);
  }

  /// 播放错误音效
  Future<void> playErrorSound({double? volume}) async {
    await playGeneralSound('beep.wav', volume: volume);
  }

  /// 播放点击音效
  Future<void> playClickSound({double? volume}) async {
    await playGeneralSound('click.wav', volume: volume);
  }

  /// 停止所有音效
  Future<void> stopAllSounds() async {
    try {
      await stopKeySound();
      await _wordPronunciationPlayer.stop();
      await _generalSoundPlayer.stop();
    } catch (e) {
      throw AudioException('Failed to stop all sounds: $e');
    }
  }

  /// 设置全局音量
  Future<void> setGlobalVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);

      for (final player in _keySoundPlayers.values) {
        await player.setVolume(clampedVolume);
      }

      await _wordPronunciationPlayer.setVolume(clampedVolume);
      await _generalSoundPlayer.setVolume(clampedVolume);
    } catch (e) {
      throw AudioException('Failed to set global volume: $e');
    }
  }

  /// 获取所有可用的键盘音效类型
  Future<List<KeySoundType>> getAvailableKeySounds() async {
    final availableSounds = <KeySoundType>[];

    for (final soundType in KeySoundType.values) {
      if (await isKeySoundAvailable(soundType)) {
        availableSounds.add(soundType);
      }
    }

    return availableSounds;
  }

  /// 预加载所有可用的键盘音效
  Future<void> preloadAllKeySounds() async {
    final availableSounds = await getAvailableKeySounds();

    for (final soundType in availableSounds) {
      try {
        await preloadKeySound(soundType);
      } catch (e) {
        // 忽略单个音效加载失败，继续加载其他音效
        print('Failed to preload ${soundType.displayName}: $e');
      }
    }
  }
}

/// 音频异常类
class AudioException implements Exception {
  final String message;

  const AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}
