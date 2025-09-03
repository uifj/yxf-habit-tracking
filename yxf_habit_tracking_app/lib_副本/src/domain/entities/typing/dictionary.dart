import 'package:equatable/equatable.dart';

/// 语言类型枚举
enum LanguageType {
  en,
  ja,
  de,
  kk,
  id,
  programming;

  String get code {
    switch (this) {
      case LanguageType.en:
        return 'en';
      case LanguageType.ja:
        return 'ja';
      case LanguageType.de:
        return 'de';
      case LanguageType.kk:
        return 'kk';
      case LanguageType.id:
        return 'id';
      case LanguageType.programming:
        return 'programming';
    }
  }

  String get displayName {
    switch (this) {
      case LanguageType.en:
        return 'English';
      case LanguageType.ja:
        return 'Japanese';
      case LanguageType.de:
        return 'German';
      case LanguageType.kk:
        return 'Kazakh';
      case LanguageType.id:
        return 'Indonesian';
      case LanguageType.programming:
        return 'Programming';
    }
  }
}

/// 发音类型枚举
enum PronunciationType {
  us,
  uk,
  romaji,
  zh,
  ja,
  de,
  hapin,
  kk,
  id;

  String get code {
    switch (this) {
      case PronunciationType.us:
        return 'us';
      case PronunciationType.uk:
        return 'uk';
      case PronunciationType.romaji:
        return 'romaji';
      case PronunciationType.zh:
        return 'zh';
      case PronunciationType.ja:
        return 'ja';
      case PronunciationType.de:
        return 'de';
      case PronunciationType.hapin:
        return 'hapin';
      case PronunciationType.kk:
        return 'kk';
      case PronunciationType.id:
        return 'id';
    }
  }

  String get displayName {
    switch (this) {
      case PronunciationType.us:
        return 'American';
      case PronunciationType.uk:
        return 'British';
      case PronunciationType.romaji:
        return 'romaji';
      case PronunciationType.zh:
        return 'Chinese';
      case PronunciationType.ja:
        return 'Japanese';
      case PronunciationType.de:
        return 'German';
      case PronunciationType.hapin:
        return 'Hapin';
      case PronunciationType.kk:
        return 'Kazakh';
      case PronunciationType.id:
        return 'Indonesian';
    }
  }
}

/// 词典实体类
class Dictionary extends Equatable {
  /// 词典ID
  final String id;

  /// 词典名称
  final String name;

  /// 词典描述
  final String description;

  /// 词典分类
  final String category;

  /// 标签列表
  final List<String> tags;

  /// 词典文件URL
  final String url;

  /// 单词总数
  final int length;

  /// 语言类型
  final LanguageType language;

  /// 语言分类
  final LanguageType languageCategory;

  /// 章节数量
  final int chapterCount;

  /// 默认发音索引
  final int? defaultPronIndex;

  /// 是否已下载
  final bool isDownloaded;

  /// 下载时间
  final DateTime? downloadTime;

  const Dictionary({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.url,
    required this.length,
    required this.language,
    required this.languageCategory,
    required this.chapterCount,
    this.defaultPronIndex,
    this.isDownloaded = false,
    this.downloadTime,
  });

  /// 创建已下载的词典
  Dictionary asDownloaded() {
    return Dictionary(
      id: id,
      name: name,
      description: description,
      category: category,
      tags: tags,
      url: url,
      length: length,
      language: language,
      languageCategory: languageCategory,
      chapterCount: chapterCount,
      defaultPronIndex: defaultPronIndex,
      isDownloaded: true,
      downloadTime: DateTime.now(),
    );
  }

  /// 是否为编程相关词典
  bool get isProgramming => language == LanguageType.programming;

  /// 是否为英语词典
  bool get isEnglish => language == LanguageType.en;

  /// 获取显示名称
  String get displayName => name;

  /// 获取完整描述
  String get fullDescription {
    final buffer = StringBuffer(description);
    if (tags.isNotEmpty) {
      buffer.write(' (${tags.join(', ')})');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        url,
        length,
        language,
        languageCategory,
        chapterCount,
        defaultPronIndex,
        isDownloaded,
        downloadTime,
      ];

  @override
  String toString() {
    return 'Dictionary(id: $id, name: $name, length: $length, language: $language)';
  }
}
