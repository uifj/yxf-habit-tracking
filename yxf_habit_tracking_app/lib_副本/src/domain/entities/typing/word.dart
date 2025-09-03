import 'package:equatable/equatable.dart';

/// 单词实体类
class Word extends Equatable {
  /// 单词名称
  final String name;

  /// 翻译列表
  final List<String> translations;

  /// 美式音标
  final String? usPhonetic;

  /// 英式音标
  final String? ukPhonetic;

  /// 备注
  final String? notation;

  /// 在章节中的索引
  final int? index;

  const Word({
    required this.name,
    required this.translations,
    this.usPhonetic,
    this.ukPhonetic,
    this.notation,
    this.index,
  });

  /// 创建带索引的单词
  Word withIndex(int index) {
    return Word(
      name: name,
      translations: translations,
      usPhonetic: usPhonetic,
      ukPhonetic: ukPhonetic,
      notation: notation,
      index: index,
    );
  }

  /// 获取主要翻译
  String get primaryTranslation =>
      translations.isNotEmpty ? translations.first : '';

  /// 获取所有翻译的字符串
  String get allTranslations => translations.join('; ');

  /// 是否有音标
  bool get hasPhonetic => usPhonetic != null || ukPhonetic != null;

  /// 获取音标（优先美式）
  String? get phonetic => usPhonetic ?? ukPhonetic;

  @override
  List<Object?> get props => [
        name,
        translations,
        usPhonetic,
        ukPhonetic,
        notation,
        index,
      ];

  @override
  String toString() {
    return 'Word(name: $name, translations: $translations, index: $index)';
  }
}
