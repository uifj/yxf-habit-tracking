import '../entities/setting/user_settings.dart';
import '../entities/typing/dictionary.dart';

/// 音频仓储接口
abstract class AudioRepository {
  /// 初始化音频系统
  Future<void> initialize();

  /// 释放音频资源
  Future<void> dispose();

  /// 播放键盘音效
  Future<void> playKeySound(KeySoundType soundType, {double? volume});

  /// 播放单词发音
  Future<void> playWordPronunciation(
    String word,
    PronunciationType pronunciationType, {
    double? volume,
  });

  /// 播放系统音效
  Future<void> playSystemSound(String soundName, {double? volume});

  /// 停止所有音频播放
  Future<void> stopAllSounds();

  /// 停止键盘音效
  Future<void> stopKeySound();

  /// 停止单词发音
  Future<void> stopWordPronunciation();

  /// 设置全局音量
  Future<void> setGlobalVolume(double volume);

  /// 设置键盘音效音量
  Future<void> setKeySoundVolume(double volume);

  /// 设置发音音量
  Future<void> setPronunciationVolume(double volume);

  /// 获取全局音量
  Future<double> getGlobalVolume();

  /// 获取键盘音效音量
  Future<double> getKeySoundVolume();

  /// 获取发音音量
  Future<double> getPronunciationVolume();

  /// 静音/取消静音
  Future<void> setMuted(bool muted);

  /// 检查是否静音
  Future<bool> isMuted();

  /// 预加载音频资源
  Future<void> preloadAudio(String audioPath);

  /// 预加载键盘音效
  Future<void> preloadKeySound(KeySoundType soundType);

  /// 预加载单词发音
  Future<void> preloadWordPronunciation(
    String word,
    PronunciationType pronunciationType,
  );

  /// 检查音频文件是否存在
  Future<bool> audioExists(String audioPath);

  /// 检查键盘音效是否可用
  Future<bool> isKeySoundAvailable(KeySoundType soundType);

  /// 检查单词发音是否可用
  Future<bool> isWordPronunciationAvailable(
    String word,
    PronunciationType pronunciationType,
  );

  /// 下载音频文件
  Future<void> downloadAudio(String url, String localPath);

  /// 下载单词发音
  Future<void> downloadWordPronunciation(
    String word,
    PronunciationType pronunciationType,
  );

  /// 获取音频下载进度
  Stream<double> getAudioDownloadProgress(String audioPath);

  /// 取消音频下载
  Future<void> cancelAudioDownload(String audioPath);

  /// 清理音频缓存
  Future<void> clearAudioCache();

  /// 获取音频缓存大小
  Future<int> getAudioCacheSize();

  /// 获取音频文件信息
  Future<Map<String, dynamic>> getAudioInfo(String audioPath);

  /// 检查音频权限
  Future<bool> checkAudioPermission();

  /// 请求音频权限
  Future<bool> requestAudioPermission();

  /// 获取音频设备信息
  Future<Map<String, dynamic>> getAudioDeviceInfo();

  /// 设置音频输出设备
  Future<void> setAudioOutputDevice(String deviceId);

  /// 获取支持的音频格式
  Future<List<String>> getSupportedAudioFormats();

  /// 测试音频播放
  Future<bool> testAudioPlayback();

  /// 获取音频播放状态
  Future<Map<String, dynamic>> getAudioPlaybackStatus();
}
