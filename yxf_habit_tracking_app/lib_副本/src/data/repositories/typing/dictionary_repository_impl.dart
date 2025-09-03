import '../../../domain/entities/typing/dictionary.dart';
import '../../../domain/entities/typing/word.dart';
import '../../../domain/repositories/typing/dictionary_repository.dart';
import '../../datasources/typing/dictionary_remote_datasource.dart';
import '../../datasources/typing/dictionary_local_datasource.dart';
import '../../datasources/typing/dictionary_assets_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

/// 字典仓库实现类
class DictionaryRepositoryImpl implements DictionaryRepository {
  final DictionaryRemoteDataSource remoteDataSource;
  final DictionaryLocalDataSource localDataSource;
  final DictionaryAssetsDataSource assetsDataSource;

  DictionaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.assetsDataSource,
  });

  @override
  Future<List<Dictionary>> getAllDictionaries() async {
    try {
      final List<Dictionary> allDictionaries = [];

      // 1. 首先获取Assets字典（本地内置）
      try {
        final assetsDictionaries =
            await assetsDataSource.getAllAssetsDictionaries();
        allDictionaries.addAll(assetsDictionaries);
      } catch (e) {
        print('Failed to load assets dictionaries: $e');
      }

      // 2. 然后尝试从本地缓存获取
      try {
        final localDictionaries = await localDataSource.getAllDictionaries();
        allDictionaries.addAll(localDictionaries);
      } catch (e) {
        print('Failed to load local dictionaries: $e');
      }

      // 3. 如果需要，从远程获取
      if (allDictionaries.isEmpty) {
        try {
          final remoteDictionaries =
              await remoteDataSource.getAllDictionaries();
          allDictionaries.addAll(remoteDictionaries);

          // 缓存到本地
          await localDataSource.cacheDictionaries(remoteDictionaries);
        } catch (e) {
          print('Failed to load remote dictionaries: $e');
        }
      }

      return allDictionaries;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<Dictionary> getDictionaryById(String id) async {
    try {
      // 1. 首先尝试从Assets获取
      final assetsDictionary =
          await assetsDataSource.getAssetsDictionaryById(id);
      if (assetsDictionary != null) {
        return assetsDictionary;
      }

      // 2. 然后尝试从本地缓存获取
      final localDictionary = await localDataSource.getDictionaryById(id);
      if (localDictionary != null) {
        return localDictionary;
      }

      // 3. 最后从远程获取
      final remoteDictionary = await remoteDataSource.getDictionaryById(id);

      // 缓存到本地
      await localDataSource.cacheDictionary(remoteDictionary);

      return remoteDictionary;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> searchDictionaries(String query) async {
    try {
      // 首先搜索本地数据
      final localResults = await localDataSource.searchDictionaries(query);

      // 尝试从远程搜索更多结果
      try {
        final remoteResults = await remoteDataSource.searchDictionaries(query);

        // 合并结果，去重
        final allResults = <Dictionary>[];
        final seenIds = <String>{};

        for (final dict in [...localResults, ...remoteResults]) {
          if (!seenIds.contains(dict.id)) {
            allResults.add(dict);
            seenIds.add(dict.id);
          }
        }

        // 缓存新的远程结果
        final newRemoteResults = remoteResults
            .where((dict) => !localResults.any((local) => local.id == dict.id))
            .toList();
        if (newRemoteResults.isNotEmpty) {
          await localDataSource.cacheDictionaries(newRemoteResults);
        }

        return allResults;
      } catch (e) {
        // 如果远程搜索失败，返回本地结果
        return localResults;
      }
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> getDictionariesByCategory(String category) async {
    try {
      final localDictionaries =
          await localDataSource.getDictionariesByCategory(category);

      try {
        final remoteDictionaries =
            await remoteDataSource.getDictionariesByCategory(category);

        // 合并并去重
        final allResults = <Dictionary>[];
        final seenIds = <String>{};

        for (final dict in [...localDictionaries, ...remoteDictionaries]) {
          if (!seenIds.contains(dict.id)) {
            allResults.add(dict);
            seenIds.add(dict.id);
          }
        }

        return allResults;
      } catch (e) {
        return localDictionaries;
      }
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> getDictionariesByLanguage(
      LanguageType language) async {
    try {
      final localDictionaries =
          await localDataSource.getDictionariesByLanguage(language);

      try {
        final remoteDictionaries =
            await remoteDataSource.getDictionariesByLanguage(language);

        // 合并并去重
        final allResults = <Dictionary>[];
        final seenIds = <String>{};

        for (final dict in [...localDictionaries, ...remoteDictionaries]) {
          if (!seenIds.contains(dict.id)) {
            allResults.add(dict);
            seenIds.add(dict.id);
          }
        }

        return allResults;
      } catch (e) {
        return localDictionaries;
      }
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> getPopularDictionaries({int limit = 10}) async {
    try {
      final remoteDictionaries =
          await remoteDataSource.getPopularDictionaries(limit: limit);

      // 缓存热门字典
      await localDataSource.cacheDictionaries(remoteDictionaries);

      return remoteDictionaries;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> getRecommendedDictionaries({int limit = 10}) async {
    try {
      final remoteDictionaries =
          await remoteDataSource.getRecommendedDictionaries(limit: limit);

      // 缓存推荐字典
      await localDataSource.cacheDictionaries(remoteDictionaries);

      return remoteDictionaries;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<Dictionary> getDictionaryDetails(String id) async {
    try {
      // 首先尝试从本地获取详情
      final localDictionary = await localDataSource.getDictionaryById(id);

      // 从远程获取最新详情
      final remoteDictionary = await remoteDataSource.getDictionaryDetails(id);

      // 更新本地缓存
      await localDataSource.updateDictionary(remoteDictionary);

      return remoteDictionary;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      // 网络错误时返回本地缓存
      final localDictionary = await localDataSource.getDictionaryById(id);
      if (localDictionary != null) {
        return localDictionary;
      }
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> downloadDictionary(String id) async {
    try {
      await remoteDataSource.downloadDictionary(id);

      // 标记为已下载
      await localDataSource.markDictionaryAsDownloaded(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Stream<double> getDictionaryDownloadProgress(String id) {
    return remoteDataSource.getDictionaryDownloadProgress(id);
  }

  @override
  Future<void> cancelDictionaryDownload(String id) async {
    try {
      await remoteDataSource.cancelDictionaryDownload(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> deleteDictionary(String id) async {
    try {
      await localDataSource.deleteDictionary(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> updateDictionary(Dictionary dictionary) async {
    try {
      await remoteDataSource.updateDictionary(dictionary.id);

      // 更新本地缓存
      await localDataSource.updateDictionary(dictionary);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> getDictionaryWords(String dictionaryId) async {
    try {
      // 1. 首先尝试从Assets获取
      try {
        final assetsDictionary =
            await assetsDataSource.getAssetsDictionaryById(dictionaryId);
        if (assetsDictionary != null) {
          return await assetsDataSource.getDictionaryWords(dictionaryId);
        }
      } catch (e) {
        // Assets中没有该字典，继续其他方式
      }

      // 2. 检查本地缓存
      if (await localDataSource.areDictionaryWordsCached(dictionaryId)) {
        return await localDataSource.getDictionaryWords(dictionaryId);
      }

      // 3. 从远程获取
      final words = await remoteDataSource.getDictionaryWords(dictionaryId);

      // 缓存到本地
      await localDataSource.cacheDictionaryWords(dictionaryId, words);

      return words;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> getChapterWords(
      String dictionaryId, int chapter, int wordsPerChapter) async {
    try {
      // 首先检查本地是否有缓存
      if (await localDataSource.areChapterWordsCached(dictionaryId, chapter)) {
        return await localDataSource.getChapterWords(dictionaryId, chapter);
      }

      // 从远程获取
      final words =
          await remoteDataSource.getChapterWords(dictionaryId, chapter);

      // 缓存到本地
      await localDataSource.cacheChapterWords(dictionaryId, chapter, words);

      return words;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> getWordsByRange(
    String dictionaryId,
    int startIndex,
    int endIndex,
  ) async {
    try {
      // 首先尝试从本地获取
      final localWords = await localDataSource.getWordsByRange(
        dictionaryId,
        startIndex,
        endIndex,
      );

      if (localWords.isNotEmpty) {
        return localWords;
      }

      // 从远程获取
      final words = await remoteDataSource.getWordsByRange(
        dictionaryId,
        startIndex,
        endIndex,
      );

      return words;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> searchWordsInDictionary(
    String dictionaryId,
    String query,
  ) async {
    try {
      // 首先搜索本地缓存
      final localWords = await localDataSource.searchWordsInDictionary(
        dictionaryId,
        query,
      );

      // 如果本地有足够结果，直接返回
      if (localWords.length >= 20) {
        return localWords;
      }

      // 从远程搜索
      try {
        final remoteWords = await remoteDataSource.searchWordsInDictionary(
          dictionaryId,
          query,
        );

        // 合并结果
        final allWords = <Word>[];
        final seenNames = <String>{};

        for (final word in [...localWords, ...remoteWords]) {
          if (!seenNames.contains(word.name)) {
            allWords.add(word);
            seenNames.add(word.name);
          }
        }

        return allWords;
      } catch (e) {
        return localWords;
      }
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<Word> getWordDetails(String dictionaryId, String wordName) async {
    try {
      // 首先尝试从本地获取
      final localWord =
          await localDataSource.getWordDetails(dictionaryId, wordName);
      if (localWord != null) {
        return localWord;
      }

      // 从远程获取
      final word =
          await remoteDataSource.getWordDetails(dictionaryId, wordName);

      return word;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDictionaryStatistics(String id) async {
    try {
      return await remoteDataSource.getDictionaryStatistics(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<bool> checkDictionaryUpdate(String id) async {
    try {
      return await remoteDataSource.checkDictionaryUpdate(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localDataSource.clearAllDictionaries();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      return await localDataSource.getTotalCacheSize();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<int> getDictionaryChapterCount(
      String dictionaryId, int wordsPerChapter) async {
    try {
      final dictionary = await getDictionaryById(dictionaryId);
      return (dictionary.length / wordsPerChapter).ceil();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDictionaryStats(String dictionaryId) async {
    try {
      return await remoteDataSource.getDictionaryStatistics(dictionaryId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Dictionary>> getDownloadedDictionaries() async {
    try {
      return await localDataSource.getDownloadedDictionaries();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<bool> isDictionaryDownloaded(String dictionaryId) async {
    try {
      final dictionary = await localDataSource.getDictionaryById(dictionaryId);
      return dictionary?.isDownloaded ?? false;
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> clearDictionaryCache() async {
    try {
      await localDataSource.clearAllDictionaries();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<int> getDictionaryCacheSize() async {
    try {
      return await localDataSource.getTotalCacheSize();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> refreshDictionaries() async {
    try {
      // 清除本地缓存
      await localDataSource.clearAllDictionaries();

      // 重新获取远程数据
      final remoteDictionaries = await remoteDataSource.getAllDictionaries();

      // 缓存到本地
      await localDataSource.cacheDictionaries(remoteDictionaries);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> getRandomWords(String dictionaryId, int count) async {
    try {
      final allWords = await getDictionaryWords(dictionaryId);
      if (allWords.length <= count) {
        return allWords;
      }

      final shuffled = List<Word>.from(allWords)..shuffle();
      return shuffled.take(count).toList();
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<List<Word>> searchWords(String dictionaryId, String query) async {
    try {
      return await searchWordsInDictionary(dictionaryId, query);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }

  @override
  Future<void> updateDictionaryData(String dictionaryId) async {
    try {
      // 从远程获取最新的字典数据并更新本地缓存
      final updatedDictionary =
          await remoteDataSource.getDictionaryById(dictionaryId);
      await localDataSource.updateDictionary(updatedDictionary);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw DictionaryFailure(e.toString());
    }
  }
}
