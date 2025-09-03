/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'Qwerty Learner';
  static const String appVersion = '1.0.0';

  // 数据库相关
  static const String dbName = 'qwerty_learner.db';
  static const int dbVersion = 1;

  // 缓存相关
  static const String cacheBoxName = 'qwerty_cache';
  static const String settingsBoxName = 'qwerty_settings';

  // API相关
  static const String baseUrl = 'https://api.qwerty-learner.com';
  static const Duration requestTimeout = Duration(seconds: 30);

  // 本地存储键
  static const String currentDictIdKey = 'current_dict_id';
  static const String currentChapterKey = 'current_chapter';
  static const String keySoundsConfigKey = 'key_sounds_config';
  static const String pronunciationConfigKey = 'pronunciation_config';
  static const String fontSizeConfigKey = 'font_size_config';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String phoneticConfigKey = 'phonetic_config';
  static const String wordDictationConfigKey = 'word_dictation_config';
  static const String randomConfigKey = 'random_config';
  static const String loopWordConfigKey = 'loop_word_config';

  // 默认配置
  static const int defaultChapterSize = 20;
  static const int defaultFontSize = 16;
  static const String defaultDictId = 'CET4_T';
  static const int defaultLoopTimes = 1;

  // 音频文件路径
  static const String soundsPath = 'assets/sounds';
  static const String keySoundsPath = '$soundsPath/key-sound';

  // 词典文件路径
  static const String dictsPath = 'assets/dicts';

  // 支持的语言类型
  static const List<String> supportedLanguages = [
    'en',
    'ja',
    'de',
    'kk',
    'id',
    'code'
  ];

  // 支持的发音类型
  static const List<String> supportedPronunciations = [
    'us',
    'uk',
    'romaji',
    'zh',
    'ja',
    'de',
    'hapin',
    'kk',
    'id'
  ];

  // 按键音效类型
  static const List<String> keySoundTypes = [
    'Default',
    'Cherry MX Blues',
    'Cherry MX Browns',
    'Cherry MX Blacks',
    'Gateron Red Inks',
    'Gateron Black Inks',
    'Holy Pandas',
    'Topre',
    'Kailh Box Navies',
    'NovelKeys Creams',
    'SKCM Blue Alps',
    'Buckling Spring',
    'Turquoise Tealios',
    'Alpacas'
  ];

  // 单词默写模式类型
  static const List<String> dictationModes = [
    'hideAll',
    'hideVowel',
    'hideConsonant',
    'randomHide'
  ];

  // 循环次数选项
  static const List<int> loopOptions = [1, 3, 5, 8, -1]; // -1表示无限循环

  // 动画持续时间
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // 颜色常量
  static const int primaryColorValue = 0xFF6366F1;
  static const int successColorValue = 0xFF10B981;
  static const int errorColorValue = 0xFFEF4444;
  static const int warningColorValue = 0xFFF59E0B;

  // 尺寸常量
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // 字体大小范围
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;

  // 打字相关常量
  static const int minWPM = 0;
  static const int maxWPM = 200;
  static const double minAccuracy = 0.0;
  static const double maxAccuracy = 100.0;

  // 统计相关
  static const int maxRecentRecords = 100;
  static const int maxErrorWords = 50;

  // 网络相关
  static const int maxRetryCount = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
