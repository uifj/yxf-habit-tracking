import '../../../domain/entities/typing/dictionary.dart';
import '../../../domain/entities/typing/word.dart';

/// 字典本地数据源抽象接口
abstract class DictionaryLocalDataSource {
  /// 获取所有本地字典
  Future<List<Dictionary>> getAllDictionaries();

  /// 根据ID获取本地字典
  Future<Dictionary?> getDictionaryById(String id);

  /// 搜索本地字典
  Future<List<Dictionary>> searchDictionaries(String query);

  /// 根据分类获取本地字典
  Future<List<Dictionary>> getDictionariesByCategory(String category);

  /// 根据语言获取本地字典
  Future<List<Dictionary>> getDictionariesByLanguage(LanguageType language);

  /// 获取已下载的字典
  Future<List<Dictionary>> getDownloadedDictionaries();

  /// 缓存字典数据
  Future<void> cacheDictionary(Dictionary dictionary);

  /// 缓存字典列表
  Future<void> cacheDictionaries(List<Dictionary> dictionaries);

  /// 删除字典缓存
  Future<void> deleteDictionary(String id);

  /// 清除所有字典缓存
  Future<void> clearAllDictionaries();

  /// 更新字典信息
  Future<void> updateDictionary(Dictionary dictionary);

  /// 标记字典为已下载
  Future<void> markDictionaryAsDownloaded(String id);

  /// 获取字典的单词列表
  Future<List<Word>> getDictionaryWords(String dictionaryId);

  /// 获取字典的章节单词
  Future<List<Word>> getChapterWords(String dictionaryId, int chapter);

  /// 根据索引范围获取单词
  Future<List<Word>> getWordsByRange(
    String dictionaryId,
    int startIndex,
    int endIndex,
  );

  /// 搜索字典中的单词
  Future<List<Word>> searchWordsInDictionary(
    String dictionaryId,
    String query,
  );

  /// 获取单词详情
  Future<Word?> getWordDetails(String dictionaryId, String wordName);

  /// 缓存字典单词
  Future<void> cacheDictionaryWords(
    String dictionaryId,
    List<Word> words,
  );

  /// 缓存章节单词
  Future<void> cacheChapterWords(
    String dictionaryId,
    int chapter,
    List<Word> words,
  );

  /// 删除字典单词缓存
  Future<void> deleteDictionaryWords(String dictionaryId);

  /// 获取字典缓存大小
  Future<int> getDictionaryCacheSize(String id);

  /// 获取总缓存大小
  Future<int> getTotalCacheSize();

  /// 清理过期缓存
  Future<void> clearExpiredCache();

  /// 检查字典是否已缓存
  Future<bool> isDictionaryCached(String id);

  /// 检查字典单词是否已缓存
  Future<bool> areDictionaryWordsCached(String dictionaryId);

  /// 检查章节单词是否已缓存
  Future<bool> areChapterWordsCached(String dictionaryId, int chapter);

  /// 获取字典最后更新时间
  Future<DateTime?> getDictionaryLastUpdateTime(String id);

  /// 更新字典最后访问时间
  Future<void> updateDictionaryLastAccessTime(String id);

  /// 获取字典访问次数
  Future<int> getDictionaryAccessCount(String id);

  /// 增加字典访问次数
  Future<void> incrementDictionaryAccessCount(String id);

  /// 获取最近使用的字典
  Future<List<Dictionary>> getRecentlyUsedDictionaries({int limit = 10});

  /// 获取最常用的字典
  Future<List<Dictionary>> getMostUsedDictionaries({int limit = 10});

  /// 导出字典数据
  Future<Map<String, dynamic>> exportDictionaryData(String id);

  /// 导入字典数据
  Future<void> importDictionaryData(
    String id,
    Map<String, dynamic> data,
  );

  /// 备份字典数据
  Future<void> backupDictionaryData();

  /// 恢复字典数据
  Future<void> restoreDictionaryData(Map<String, dynamic> backupData);

  /// 压缩数据库
  Future<void> compactDatabase();

  /// 修复数据库
  Future<void> repairDatabase();

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getDatabaseStats();
}
