import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/entities/typing/dictionary.dart';
import '../../../domain/entities/typing/word.dart';
import '../../../../core/errors/exceptions.dart';

/// Assets字典数据源实现类
class DictionaryAssetsDataSource {
  static const String _assetsPath = 'assets/dicts';

  // 添加缓存机制
  final Map<String, List<Word>> _wordsCache = {};
  final Map<String, Dictionary> _dictionaryCache = {};

  /// 预定义的字典列表
  static const List<Map<String, dynamic>> _predefinedDictionaries = [
    {
      'id': '926',
      'name': '926 Core Words',
      'description': '926个核心英语单词',
      'filename': '926.json',
      'category': 'basic',
      'language': 'en',
      'tags': ['basic', 'core'],
      'length': 926,
    },
    {
      'id': 'cet4',
      'name': 'CET-4 Vocabulary',
      'description': '大学英语四级词汇',
      'filename': 'CET4_T.json',
      'category': 'exam',
      'language': 'en',
      'tags': ['cet4', 'exam'],
      'length': 4000,
    },
    {
      'id': 'cet6',
      'name': 'CET-6 Vocabulary',
      'description': '大学英语六级词汇',
      'filename': 'CET6_T.json',
      'category': 'exam',
      'language': 'en',
      'tags': ['cet6', 'exam'],
      'length': 5500,
    },
    {
      'id': '3000_classroom',
      'name': '3000 Classroom English Words',
      'description': '3000个课堂英语单词',
      'filename': '3000_ClassRoom_English_Words.json',
      'category': 'education',
      'language': 'en',
      'tags': ['classroom', 'education'],
      'length': 3000,
    },
    {
      'id': '4000_essential_meaning',
      'name': '4000 Essential English Words (Meaning)',
      'description': '4000个基础英语单词（含义版）',
      'filename': '4000_Essential_English_Words-meaning.json',
      'category': 'essential',
      'language': 'en',
      'tags': ['essential', 'meaning'],
      'length': 4000,
    },
    {
      'id': '4000_essential_sentence',
      'name': '4000 Essential English Words (Sentence)',
      'description': '4000个基础英语单词（例句版）',
      'filename': '4000_Essential_English_Words-sentence.json',
      'category': 'essential',
      'language': 'en',
      'tags': ['essential', 'sentence'],
      'length': 4000,
    },
    {
      'id': 'coca20000',
      'name': 'COCA 20000 Words',
      'description': 'COCA语料库20000高频词汇',
      'filename': 'coca20000.json',
      'category': 'frequency',
      'language': 'en',
      'tags': ['coca', 'frequency'],
      'length': 20000,
    },
    {
      'id': 'godot_base',
      'name': 'Godot Base',
      'description': 'Godot基础',
      'filename': 'godot-base.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['godot', 'base'],
      'length': 100,
    },
    {
      'id': 'godot_property',
      'name': 'Godot Property',
      'description': 'Godot属性',
      'filename': 'godot-property.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['godot', 'property'],
      'length': 50,
    },
    {
      'id': 'godot_method',
      'name': 'Godot Method',
      'description': 'Godot方法',
      'filename': 'godot-method.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['godot', 'method'],
      'length': 50,
    },
    {
      'id': 'python_builtin',
      'name': 'Python Built-in Functions',
      'description': 'Python内置函数',
      'filename': 'python-builtin.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['python', 'builtin'],
      'length': 100,
    },
    {
      'id': 'python_keywords',
      'name': 'Python Keywords',
      'description': 'Python关键字',
      'filename': 'python-string.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['python', 'keywords'],
      'length': 50,
    },
    {
      'id': 'linux_command',
      'name': 'Linux Commands',
      'description': 'Linux命令行指令',
      'filename': 'linux-command.json',
      'category': 'programming',
      'language': 'programming',
      'tags': ['linux', 'command'],
      'length': 200,
    },
  ];

  /// 获取所有可用的Assets字典
  Future<List<Dictionary>> getAllAssetsDictionaries() async {
    try {
      final List<Dictionary> dictionaries = [];

      for (final dictInfo in _predefinedDictionaries) {
        try {
          // 检查文件是否存在
          await rootBundle.loadString('$_assetsPath/${dictInfo['filename']}');

          final dictionary = Dictionary(
            id: dictInfo['id'],
            name: dictInfo['name'],
            description: dictInfo['description'],
            category: dictInfo['category'],
            language: _parseLanguageType(dictInfo['language']),
            languageCategory: _parseLanguageType(dictInfo['language']),
            tags: List<String>.from(dictInfo['tags']),
            length: dictInfo['length'],
            url: '', // Assets字典没有URL
            chapterCount: 1, // Assets字典默认1个章节
            isDownloaded: true, // Assets字典默认已下载
            downloadTime: DateTime.now(),
          );

          dictionaries.add(dictionary);
        } catch (e) {
          // 如果文件不存在，跳过该字典
          print('Assets dictionary file not found: ${dictInfo['filename']}');
        }
      }

      return dictionaries;
    } catch (e) {
      throw CacheException('Failed to load assets dictionaries: $e');
    }
  }

  /// 根据ID获取Assets字典
  Future<Dictionary?> getAssetsDictionaryById(String id) async {
    try {
      final dictInfo = _predefinedDictionaries.firstWhere(
        (dict) => dict['id'] == id,
        orElse: () => throw CacheException('Dictionary not found: $id'),
      );

      // 检查文件是否存在
      await rootBundle.loadString('$_assetsPath/${dictInfo['filename']}');

      return Dictionary(
        id: dictInfo['id'],
        name: dictInfo['name'],
        description: dictInfo['description'],
        category: dictInfo['category'],
        language: _parseLanguageType(dictInfo['language']),
        languageCategory: _parseLanguageType(dictInfo['language']),
        tags: List<String>.from(dictInfo['tags']),
        length: dictInfo['length'],
        url: '',
        chapterCount: 1,
        isDownloaded: true,
        downloadTime: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取字典的单词列表（带缓存）
  Future<List<Word>> getDictionaryWords(String dictionaryId) async {
    // 检查缓存
    if (_wordsCache.containsKey(dictionaryId)) {
      return _wordsCache[dictionaryId]!;
    }

    try {
      final dictInfo = _predefinedDictionaries.firstWhere(
        (dict) => dict['id'] == dictionaryId,
        orElse: () =>
            throw CacheException('Dictionary not found: $dictionaryId'),
      );

      final String jsonString = await rootBundle.loadString(
        '$_assetsPath/${dictInfo['filename']}',
      );

      final List<dynamic> jsonData = json.decode(jsonString);
      final List<Word> words = [];

      for (int i = 0; i < jsonData.length; i++) {
        final wordData = jsonData[i];

        // 处理不同的JSON格式
        String name;
        List<String> translations;
        String? usPhonetic;
        String? ukPhonetic;

        if (wordData is Map<String, dynamic>) {
          name = wordData['name'] ?? wordData['word'] ?? '';

          // 处理翻译
          if (wordData['trans'] is List) {
            translations = List<String>.from(wordData['trans']);
          } else if (wordData['trans'] is String) {
            translations = [wordData['trans']];
          } else if (wordData['translation'] is List) {
            translations = List<String>.from(wordData['translation']);
          } else if (wordData['translation'] is String) {
            translations = [wordData['translation']];
          } else {
            translations = [''];
          }

          // 处理音标
          usPhonetic = wordData['usphone'] ?? wordData['usPhonetic'];
          ukPhonetic = wordData['ukphone'] ?? wordData['ukPhonetic'];
        } else {
          // 如果是字符串格式
          name = wordData.toString();
          translations = [''];
        }

        if (name.isNotEmpty) {
          words.add(Word(
            name: name,
            translations: translations,
            usPhonetic: usPhonetic,
            ukPhonetic: ukPhonetic,
            index: i,
          ));
        }
      }

      // 缓存结果
      _wordsCache[dictionaryId] = words;
      return words;
    } catch (e) {
      throw CacheException('Failed to load dictionary words: $e');
    }
  }

  /// 清除缓存
  void clearCache() {
    _wordsCache.clear();
    _dictionaryCache.clear();
  }

  /// 预加载字典数据
  Future<void> preloadDictionary(String dictionaryId) async {
    if (!_wordsCache.containsKey(dictionaryId)) {
      await getDictionaryWords(dictionaryId);
    }
  }

  /// 根据索引范围获取单词
  Future<List<Word>> getWordsByRange(
    String dictionaryId,
    int startIndex,
    int endIndex,
  ) async {
    try {
      final allWords = await getDictionaryWords(dictionaryId);

      if (startIndex < 0 ||
          endIndex >= allWords.length ||
          startIndex > endIndex) {
        throw const CacheException('Invalid word range');
      }

      return allWords.sublist(startIndex, endIndex + 1);
    } catch (e) {
      throw CacheException('Failed to get words by range: $e');
    }
  }

  /// 搜索字典中的单词
  Future<List<Word>> searchWordsInDictionary(
    String dictionaryId,
    String query,
  ) async {
    try {
      final allWords = await getDictionaryWords(dictionaryId);
      final queryLower = query.toLowerCase();

      return allWords.where((word) {
        return word.name.toLowerCase().contains(queryLower) ||
            word.translations
                .any((trans) => trans.toLowerCase().contains(queryLower));
      }).toList();
    } catch (e) {
      throw CacheException('Failed to search words: $e');
    }
  }

  /// 解析语言类型
  LanguageType _parseLanguageType(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return LanguageType.en;
      case 'ja':
        return LanguageType.ja;
      case 'de':
        return LanguageType.de;
      case 'kk':
        return LanguageType.kk;
      case 'id':
        return LanguageType.id;
      case 'programming':
        return LanguageType.programming;
      default:
        return LanguageType.en;
    }
  }
}
