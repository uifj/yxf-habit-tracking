import '../../../domain/entities/typing/dictionary.dart';
import '../../../domain/entities/typing/word.dart';

/// 字典远程数据源抽象接口
abstract class DictionaryRemoteDataSource {
  /// 获取所有字典列表
  Future<List<Dictionary>> getAllDictionaries();

  /// 根据ID获取字典
  Future<Dictionary> getDictionaryById(String id);

  /// 搜索字典
  Future<List<Dictionary>> searchDictionaries(String query);

  /// 根据分类获取字典
  Future<List<Dictionary>> getDictionariesByCategory(String category);

  /// 根据语言获取字典
  Future<List<Dictionary>> getDictionariesByLanguage(LanguageType language);

  /// 获取热门字典
  Future<List<Dictionary>> getPopularDictionaries({int limit = 10});

  /// 获取推荐字典
  Future<List<Dictionary>> getRecommendedDictionaries({int limit = 10});

  /// 获取字典详情
  Future<Dictionary> getDictionaryDetails(String id);

  /// 下载字典数据
  Future<void> downloadDictionary(String id);

  /// 获取字典下载进度
  Stream<double> getDictionaryDownloadProgress(String id);

  /// 取消字典下载
  Future<void> cancelDictionaryDownload(String id);

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
  Future<Word> getWordDetails(String dictionaryId, String wordName);

  /// 获取字典统计信息
  Future<Map<String, dynamic>> getDictionaryStatistics(String id);

  /// 检查字典更新
  Future<bool> checkDictionaryUpdate(String id);

  /// 更新字典
  Future<void> updateDictionary(String id);

  /// 获取字典版本信息
  Future<String> getDictionaryVersion(String id);

  /// 验证字典完整性
  Future<bool> validateDictionaryIntegrity(String id);

  /// 获取字典元数据
  Future<Map<String, dynamic>> getDictionaryMetadata(String id);

  /// 上报字典使用统计
  Future<void> reportDictionaryUsage(String id, Map<String, dynamic> stats);

  /// 获取字典评分和评论
  Future<Map<String, dynamic>> getDictionaryRatings(String id);

  /// 提交字典评分
  Future<void> submitDictionaryRating(
    String id,
    double rating,
    String? comment,
  );
}
