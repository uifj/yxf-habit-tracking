import '../../../domain/entities/setting/user_settings.dart';
import '../../../domain/entities/typing/dictionary.dart';

/// 音频本地数据源抽象接口
abstract class AudioLocalDataSource {
  // ========== 初始化和配置 ==========

  /// 初始化音频系统
  Future<void> initialize();

  /// 释放音频资源
  Future<void> dispose();

  /// 检查音频系统是否已初始化
  Future<bool> isInitialized();

  // ========== 键盘音效管理 ==========

  /// 播放键盘音效
  Future<void> playKeySound(KeySoundType soundType, {double? volume});

  /// 停止键盘音效
  Future<void> stopKeySound();

  /// 预加载键盘音效
  Future<void> preloadKeySound(KeySoundType soundType);

  /// 检查键盘音效是否可用
  Future<bool> isKeySoundAvailable(KeySoundType soundType);

  /// 获取键盘音效文件路径
  Future<String?> getKeySoundPath(KeySoundType soundType);

  /// 缓存键盘音效文件
  Future<void> cacheKeySoundFile(KeySoundType soundType, String filePath);

  // ========== 单词发音管理 ==========

  /// 播放单词发音
  Future<void> playWordPronunciation(
    String word,
    PronunciationType pronunciationType, {
    double? volume,
  });

  /// 停止单词发音
  Future<void> stopWordPronunciation();

  /// 预加载单词发音
  Future<void> preloadWordPronunciation(
    String word,
    PronunciationType pronunciationType,
  );

  /// 检查单词发音是否可用
  Future<bool> isWordPronunciationAvailable(
    String word,
    PronunciationType pronunciationType,
  );

  /// 获取单词发音文件路径
  Future<String?> getWordPronunciationPath(
    String word,
    PronunciationType pronunciationType,
  );

  /// 缓存单词发音文件
  Future<void> cacheWordPronunciationFile(
    String word,
    PronunciationType pronunciationType,
    String filePath,
  );

  /// 删除单词发音缓存
  Future<void> deleteWordPronunciationCache(
    String word,
    PronunciationType pronunciationType,
  );

  // ========== 系统音效管理 ==========

  /// 播放系统音效
  Future<void> playSystemSound(String soundName, {double? volume});

  /// 停止系统音效
  Future<void> stopSystemSound();

  /// 预加载系统音效
  Future<void> preloadSystemSound(String soundName);

  /// 检查系统音效是否可用
  Future<bool> isSystemSoundAvailable(String soundName);

  /// 获取系统音效文件路径
  Future<String?> getSystemSoundPath(String soundName);

  // ========== 音量控制 ==========

  /// 设置全局音量
  Future<void> setGlobalVolume(double volume);

  /// 获取全局音量
  Future<double> getGlobalVolume();

  /// 设置键盘音效音量
  Future<void> setKeySoundVolume(double volume);

  /// 获取键盘音效音量
  Future<double> getKeySoundVolume();

  /// 设置发音音量
  Future<void> setPronunciationVolume(double volume);

  /// 获取发音音量
  Future<double> getPronunciationVolume();

  /// 设置静音状态
  Future<void> setMuted(bool muted);

  /// 获取静音状态
  Future<bool> isMuted();

  // ========== 音频播放控制 ==========

  /// 停止所有音频播放
  Future<void> stopAllSounds();

  /// 暂停所有音频播放
  Future<void> pauseAllSounds();

  /// 恢复所有音频播放
  Future<void> resumeAllSounds();

  /// 检查是否有音频正在播放
  Future<bool> isAnyAudioPlaying();

  /// 获取当前播放的音频信息
  Future<Map<String, dynamic>?> getCurrentPlayingAudio();

  // ========== 缓存管理 ==========

  /// 清理音频缓存
  Future<void> clearAudioCache();

  /// 清理过期音频缓存
  Future<void> clearExpiredAudioCache(Duration maxAge);

  /// 获取音频缓存大小
  Future<int> getAudioCacheSize();

  /// 获取音频缓存文件数量
  Future<int> getAudioCacheFileCount();

  /// 压缩音频缓存
  Future<void> compressAudioCache();

  /// 验证音频缓存完整性
  Future<bool> validateAudioCacheIntegrity();

  /// 修复损坏的音频缓存
  Future<void> repairCorruptedAudioCache();

  // ========== 音频文件管理 ==========

  /// 下载音频文件
  Future<void> downloadAudioFile(String url, String localPath);

  /// 获取音频下载进度
  Stream<double> getAudioDownloadProgress(String audioPath);

  /// 取消音频下载
  Future<void> cancelAudioDownload(String audioPath);

  /// 检查音频文件是否存在
  Future<bool> audioFileExists(String filePath);

  /// 获取音频文件大小
  Future<int> getAudioFileSize(String filePath);

  /// 获取音频文件信息
  Future<Map<String, dynamic>> getAudioFileInfo(String filePath);

  /// 删除音频文件
  Future<void> deleteAudioFile(String filePath);

  /// 移动音频文件
  Future<void> moveAudioFile(String fromPath, String toPath);

  /// 复制音频文件
  Future<void> copyAudioFile(String fromPath, String toPath);

  // ========== 权限和设备信息 ==========

  /// 检查音频权限
  Future<bool> checkAudioPermission();

  /// 请求音频权限
  Future<bool> requestAudioPermission();

  /// 获取音频设备信息
  Future<Map<String, dynamic>> getAudioDeviceInfo();

  /// 检查音频设备可用性
  Future<bool> isAudioDeviceAvailable();

  /// 测试音频播放功能
  Future<bool> testAudioPlayback();

  // ========== 配置和设置 ==========

  /// 保存音频配置
  Future<void> saveAudioConfig(Map<String, dynamic> config);

  /// 加载音频配置
  Future<Map<String, dynamic>> loadAudioConfig();

  /// 重置音频配置
  Future<void> resetAudioConfig();

  /// 获取默认音频配置
  Future<Map<String, dynamic>> getDefaultAudioConfig();

  // ========== 统计和诊断 ==========

  /// 获取音频使用统计
  Future<Map<String, dynamic>> getAudioUsageStats();

  /// 记录音频播放事件
  Future<void> recordAudioPlayEvent(
    String audioType,
    String audioName,
    Duration duration,
  );

  /// 获取音频系统诊断信息
  Future<Map<String, dynamic>> getAudioSystemDiagnostics();

  /// 获取音频错误日志
  Future<List<Map<String, dynamic>>> getAudioErrorLogs();

  /// 清理音频错误日志
  Future<void> clearAudioErrorLogs();

  // ========== 备份和恢复 ==========

  /// 备份音频数据
  Future<Map<String, dynamic>> backupAudioData();

  /// 恢复音频数据
  Future<void> restoreAudioData(Map<String, dynamic> backupData);

  /// 导出音频设置
  Future<Map<String, dynamic>> exportAudioSettings();

  /// 导入音频设置
  Future<void> importAudioSettings(Map<String, dynamic> settings);
}
