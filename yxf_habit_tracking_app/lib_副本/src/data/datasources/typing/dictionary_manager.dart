import 'dart:async';
import '../../../domain/entities/typing/dictionary.dart';
import '../../../domain/entities/typing/word.dart';
import 'dictionary_assets_datasource.dart';

/// 词典管理器 - 负责词典数据的统一管理和优化
class DictionaryManager {
  final DictionaryAssetsDataSource _assetsDataSource;

  // 单例模式
  static DictionaryManager? _instance;
  static DictionaryManager get instance {
    _instance ??= DictionaryManager._internal(DictionaryAssetsDataSource());
    return _instance!;
  }

  DictionaryManager._internal(this._assetsDataSource);

  // 预加载状态跟踪
  final Set<String> _preloadedDictionaries = {};
  final Map<String, Completer<void>> _loadingCompleters = {};

  /// 预加载指定词典
  Future<void> preloadDictionary(String dictionaryId) async {
    // 如果已经预加载，直接返回
    if (_preloadedDictionaries.contains(dictionaryId)) {
      return;
    }

    // 如果正在加载，等待加载完成
    if (_loadingCompleters.containsKey(dictionaryId)) {
      await _loadingCompleters[dictionaryId]!.future;
      return;
    }

    // 开始加载
    final completer = Completer<void>();
    _loadingCompleters[dictionaryId] = completer;

    try {
      await _assetsDataSource.preloadDictionary(dictionaryId);
      _preloadedDictionaries.add(dictionaryId);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingCompleters.remove(dictionaryId);
    }
  }

  /// 获取词典单词（带智能预加载）
  Future<List<Word>> getDictionaryWords(String dictionaryId) async {
    // 确保词典已预加载
    await preloadDictionary(dictionaryId);
    return await _assetsDataSource.getDictionaryWords(dictionaryId);
  }

  /// 获取分页单词
  Future<List<Word>> getChapterWords({
    required String dictionaryId,
    required int chapterIndex,
    int wordsPerChapter = 20,
  }) async {
    final allWords = await getDictionaryWords(dictionaryId);

    if (allWords.isEmpty) {
      return [];
    }

    final startIndex = chapterIndex * wordsPerChapter;
    if (startIndex >= allWords.length) {
      return [];
    }

    final endIndex = (startIndex + wordsPerChapter).clamp(0, allWords.length);
    final chapterWords = allWords.sublist(startIndex, endIndex);

    // 重新设置索引以确保连续性
    return chapterWords.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;
      return Word(
        name: word.name,
        translations: word.translations,
        usPhonetic: word.usPhonetic,
        ukPhonetic: word.ukPhonetic,
        index: index,
      );
    }).toList();
  }

  /// 获取所有可用词典
  Future<List<Dictionary>> getAllDictionaries() async {
    return await _assetsDataSource.getAllAssetsDictionaries();
  }

  /// 根据ID获取词典信息
  Future<Dictionary?> getDictionaryById(String id) async {
    return await _assetsDataSource.getAssetsDictionaryById(id);
  }

  /// 清除所有缓存
  void clearCache() {
    _assetsDataSource.clearCache();
    _preloadedDictionaries.clear();
    _loadingCompleters.clear();
  }

  /// 检查词典是否已预加载
  bool isDictionaryPreloaded(String dictionaryId) {
    return _preloadedDictionaries.contains(dictionaryId);
  }

  /// 获取词典章节数
  Future<int> getDictionaryChapterCount(String dictionaryId,
      {int wordsPerChapter = 20}) async {
    final words = await getDictionaryWords(dictionaryId);
    return (words.length / wordsPerChapter).ceil();
  }
}
