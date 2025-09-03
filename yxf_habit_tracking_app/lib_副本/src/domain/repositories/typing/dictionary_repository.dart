import '../../entities/typing/dictionary.dart';
import '../../entities/typing/word.dart';

/// 词典仓储接口
abstract class DictionaryRepository {
  /// 获取所有词典列表
  Future<List<Dictionary>> getAllDictionaries();

  /// 根据ID获取词典
  Future<Dictionary?> getDictionaryById(String id);

  /// 根据分类获取词典列表
  Future<List<Dictionary>> getDictionariesByCategory(String category);

  /// 根据语言获取词典列表
  Future<List<Dictionary>> getDictionariesByLanguage(LanguageType language);

  /// 搜索词典
  Future<List<Dictionary>> searchDictionaries(String query);

  /// 获取热门词典
  Future<List<Dictionary>> getPopularDictionaries({int limit = 10});

  /// 获取推荐词典
  Future<List<Dictionary>> getRecommendedDictionaries({int limit = 10});

  /// 下载词典
  Future<void> downloadDictionary(String dictionaryId);

  /// 删除已下载的词典
  Future<void> deleteDictionary(String dictionaryId);

  /// 检查词典是否已下载
  Future<bool> isDictionaryDownloaded(String dictionaryId);

  /// 获取已下载的词典列表
  Future<List<Dictionary>> getDownloadedDictionaries();

  /// 更新词典信息
  Future<void> updateDictionary(Dictionary dictionary);

  /// 获取词典的单词列表
  Future<List<Word>> getDictionaryWords(String dictionaryId);

  /// 获取词典的章节单词
  Future<List<Word>> getChapterWords(
      String dictionaryId, int chapterIndex, int wordsPerChapter);

  /// 获取词典的总章节数
  Future<int> getDictionaryChapterCount(
      String dictionaryId, int wordsPerChapter);

  /// 根据单词名称搜索单词
  Future<List<Word>> searchWords(String dictionaryId, String query);

  /// 获取随机单词
  Future<List<Word>> getRandomWords(String dictionaryId, int count);

  /// 获取词典统计信息
  Future<Map<String, dynamic>> getDictionaryStats(String dictionaryId);

  /// 检查词典更新
  Future<bool> checkDictionaryUpdate(String dictionaryId);

  /// 更新词典数据
  Future<void> updateDictionaryData(String dictionaryId);

  /// 获取词典下载进度
  Stream<double> getDictionaryDownloadProgress(String dictionaryId);

  /// 取消词典下载
  Future<void> cancelDictionaryDownload(String dictionaryId);

  /// 清理缓存
  Future<void> clearCache();

  /// 获取缓存大小
  Future<int> getCacheSize();
}
