import '../../entities/typing/dictionary.dart';
import '../../entities/typing/word.dart';
import '../../repositories/typing/dictionary_repository.dart';
import '../../../../core/errors/failures.dart';

/// 获取所有词典用例
class GetAllDictionaries {
  final DictionaryRepository repository;

  GetAllDictionaries(this.repository);

  Future<List<Dictionary>> call() async {
    try {
      return await repository.getAllDictionaries();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 根据ID获取词典用例
class GetDictionaryById {
  final DictionaryRepository repository;

  GetDictionaryById(this.repository);

  Future<Dictionary?> call(String id) async {
    try {
      return await repository.getDictionaryById(id);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 搜索词典用例
class SearchDictionaries {
  final DictionaryRepository repository;

  SearchDictionaries(this.repository);

  Future<List<Dictionary>> call(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await repository.searchDictionaries(query);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 根据分类获取词典用例
class GetDictionariesByCategory {
  final DictionaryRepository repository;

  GetDictionariesByCategory(this.repository);

  Future<List<Dictionary>> call(String category) async {
    try {
      return await repository.getDictionariesByCategory(category);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 根据语言获取词典用例
class GetDictionariesByLanguage {
  final DictionaryRepository repository;

  GetDictionariesByLanguage(this.repository);

  Future<List<Dictionary>> call(LanguageType language) async {
    try {
      return await repository.getDictionariesByLanguage(language);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取热门词典用例
class GetPopularDictionaries {
  final DictionaryRepository repository;

  GetPopularDictionaries(this.repository);

  Future<List<Dictionary>> call({int limit = 10}) async {
    try {
      return await repository.getPopularDictionaries(limit: limit);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取推荐词典用例
class GetRecommendedDictionaries {
  final DictionaryRepository repository;

  GetRecommendedDictionaries(this.repository);

  Future<List<Dictionary>> call({int limit = 10}) async {
    try {
      return await repository.getRecommendedDictionaries(limit: limit);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 下载词典用例
class DownloadDictionary {
  final DictionaryRepository repository;

  DownloadDictionary(this.repository);

  Future<void> call(String dictionaryId) async {
    try {
      await repository.downloadDictionary(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  /// 获取下载进度
  Stream<double> getDownloadProgress(String dictionaryId) {
    return repository.getDictionaryDownloadProgress(dictionaryId);
  }
}

/// 删除词典用例
class DeleteDictionary {
  final DictionaryRepository repository;

  DeleteDictionary(this.repository);

  Future<void> call(String dictionaryId) async {
    try {
      await repository.deleteDictionary(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 检查词典是否已下载用例
class IsDictionaryDownloaded {
  final DictionaryRepository repository;

  IsDictionaryDownloaded(this.repository);

  Future<bool> call(String dictionaryId) async {
    try {
      return await repository.isDictionaryDownloaded(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取已下载词典用例
class GetDownloadedDictionaries {
  final DictionaryRepository repository;

  GetDownloadedDictionaries(this.repository);

  Future<List<Dictionary>> call() async {
    try {
      return await repository.getDownloadedDictionaries();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取词典单词用例
class GetDictionaryWords {
  final DictionaryRepository repository;

  GetDictionaryWords(this.repository);

  Future<List<Word>> call(String dictionaryId) async {
    try {
      return await repository.getDictionaryWords(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取章节单词用例
class GetChapterWords {
  final DictionaryRepository repository;

  GetChapterWords(this.repository);

  Future<List<Word>> call(
    String dictionaryId,
    int chapterIndex,
    int wordsPerChapter,
  ) async {
    try {
      return await repository.getChapterWords(
        dictionaryId,
        chapterIndex,
        wordsPerChapter,
      );
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取词典章节数用例
class GetDictionaryChapterCount {
  final DictionaryRepository repository;

  GetDictionaryChapterCount(this.repository);

  Future<int> call(
    String dictionaryId,
    int wordsPerChapter,
  ) async {
    try {
      return await repository.getDictionaryChapterCount(
        dictionaryId,
        wordsPerChapter,
      );
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 搜索单词用例
class SearchWords {
  final DictionaryRepository repository;

  SearchWords(this.repository);

  Future<List<Word>> call(
    String dictionaryId,
    String query,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await repository.searchWords(dictionaryId, query);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取随机单词用例
class GetRandomWords {
  final DictionaryRepository repository;

  GetRandomWords(this.repository);

  Future<List<Word>> call(
    String dictionaryId,
    int count,
  ) async {
    try {
      return await repository.getRandomWords(dictionaryId, count);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取词典统计用例
class GetDictionaryStats {
  final DictionaryRepository repository;

  GetDictionaryStats(this.repository);

  Future<Map<String, dynamic>> call(String dictionaryId) async {
    try {
      return await repository.getDictionaryStats(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 检查词典更新用例
class CheckDictionaryUpdate {
  final DictionaryRepository repository;

  CheckDictionaryUpdate(this.repository);

  Future<bool> call(String dictionaryId) async {
    try {
      return await repository.checkDictionaryUpdate(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 更新词典数据用例
class UpdateDictionaryData {
  final DictionaryRepository repository;

  UpdateDictionaryData(this.repository);

  Future<void> call(String dictionaryId) async {
    try {
      await repository.updateDictionaryData(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 取消词典下载用例
class CancelDictionaryDownload {
  final DictionaryRepository repository;

  CancelDictionaryDownload(this.repository);

  Future<void> call(String dictionaryId) async {
    try {
      await repository.cancelDictionaryDownload(dictionaryId);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 清理缓存用例
class ClearDictionaryCache {
  final DictionaryRepository repository;

  ClearDictionaryCache(this.repository);

  Future<void> call() async {
    try {
      await repository.clearCache();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}

/// 获取缓存大小用例
class GetDictionaryCacheSize {
  final DictionaryRepository repository;

  GetDictionaryCacheSize(this.repository);

  Future<int> call() async {
    try {
      return await repository.getCacheSize();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}
