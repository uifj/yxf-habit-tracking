import 'package:equatable/equatable.dart';
import '../typing/dictionary.dart';

/// 键盘音效类型
enum KeySoundType {
  none,
  default_,
  alpacas,
  cherryMxBlues,
  cherryMxBrowns,
  cherryMxReds,
  gateron,
  kailhBox,
  typewriter;

  String get displayName {
    switch (this) {
      case KeySoundType.none:
        return '无音效';
      case KeySoundType.default_:
        return '默认';
      case KeySoundType.alpacas:
        return 'Alpacas';
      case KeySoundType.cherryMxBlues:
        return 'Cherry MX Blues';
      case KeySoundType.cherryMxBrowns:
        return 'Cherry MX Browns';
      case KeySoundType.cherryMxReds:
        return 'Cherry MX Reds';
      case KeySoundType.gateron:
        return 'Gateron';
      case KeySoundType.kailhBox:
        return 'Kailh Box';
      case KeySoundType.typewriter:
        return 'Typewriter';
    }
  }

  String get fileName {
    switch (this) {
      case KeySoundType.none:
        return '';
      case KeySoundType.default_:
        return 'Default.wav';
      case KeySoundType.alpacas:
        return 'Alpacas.mp3';
      case KeySoundType.cherryMxBlues:
        return 'Cherry MX Blues.mp3';
      case KeySoundType.cherryMxBrowns:
        return 'Cherry MX Browns.mp3';
      case KeySoundType.cherryMxReds:
        return 'Cherry MX Blacks.mp3'; // 修正文件名
      case KeySoundType.gateron:
        return 'Gateron Red Inks.mp3'; // 修正文件名
      case KeySoundType.kailhBox:
        return 'Kailh Box Navies.mp3'; // 修正文件名
      case KeySoundType.typewriter:
        return 'Buckling Spring.mp3'; // 修正文件名
    }
  }
}

/// 听写模式
enum DictationMode {
  off,
  auto,
  manual;

  String get displayName {
    switch (this) {
      case DictationMode.off:
        return '关闭';
      case DictationMode.auto:
        return '自动';
      case DictationMode.manual:
        return '手动';
    }
  }
}

/// 循环次数选项
enum LoopTimesOption {
  one,
  two,
  three,
  four,
  five,
  infinite;

  int get value {
    switch (this) {
      case LoopTimesOption.one:
        return 1;
      case LoopTimesOption.two:
        return 2;
      case LoopTimesOption.three:
        return 3;
      case LoopTimesOption.four:
        return 4;
      case LoopTimesOption.five:
        return 5;
      case LoopTimesOption.infinite:
        return -1;
    }
  }

  String get displayName {
    switch (this) {
      case LoopTimesOption.one:
        return '1次';
      case LoopTimesOption.two:
        return '2次';
      case LoopTimesOption.three:
        return '3次';
      case LoopTimesOption.four:
        return '4次';
      case LoopTimesOption.five:
        return '5次';
      case LoopTimesOption.infinite:
        return '无限';
    }
  }

  bool get isInfinite => this == LoopTimesOption.infinite;
}

/// 主题模式
enum ThemeMode {
  system,
  light,
  dark;

  String get displayName {
    switch (this) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }
}

/// 字体大小
enum FontSize {
  small,
  medium,
  large,
  extraLarge;

  double get value {
    switch (this) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 18.0;
      case FontSize.extraLarge:
        return 20.0;
    }
  }

  String get displayName {
    switch (this) {
      case FontSize.small:
        return '小';
      case FontSize.medium:
        return '中';
      case FontSize.large:
        return '大';
      case FontSize.extraLarge:
        return '特大';
    }
  }
}

/// 用户设置
class UserSettings extends Equatable {
  /// 主题模式
  final ThemeMode themeMode;

  /// 字体大小
  final FontSize fontSize;

  /// 是否启用键盘音效
  final bool enableKeySound;

  /// 键盘音效类型
  final KeySoundType keySoundType;

  /// 音效音量 (0.0 - 1.0)
  final double soundVolume;

  /// 是否启用单词发音
  final bool enableWordPronunciation;

  /// 发音类型
  final PronunciationType pronunciationType;

  /// 发音音量 (0.0 - 1.0)
  final double pronunciationVolume;

  /// 听写模式
  final DictationMode dictationMode;

  /// 是否显示音标
  final bool showPhonetic;

  /// 是否显示翻译
  final bool showTranslation;

  /// 是否启用自动切换下一章
  final bool autoSwitchChapter;

  /// 循环次数
  final LoopTimesOption loopTimes;

  /// 是否启用随机模式
  final bool enableRandomMode;

  /// 是否启用错词复习
  final bool enableErrorReview;

  /// 是否启用实时WPM显示
  final bool showRealtimeWPM;

  /// 是否启用进度条
  final bool showProgressBar;

  /// 是否启用快捷键
  final bool enableShortcuts;

  /// 是否启用自动保存
  final bool enableAutoSave;

  /// 自动保存间隔（秒）
  final int autoSaveInterval;

  /// 是否启用数据统计
  final bool enableStatistics;

  /// 是否启用学习提醒
  final bool enableStudyReminder;

  /// 学习提醒时间
  final List<DateTime> studyReminderTimes;

  /// 默认词典ID
  final String? defaultDictionaryId;

  /// 每章单词数
  final int wordsPerChapter;

  /// 是否启用夜间模式护眼
  final bool enableEyeProtection;

  /// 护眼模式颜色温度
  final double eyeProtectionTemperature;

  /// 语言设置
  final String languageCode;

  const UserSettings({
    this.themeMode = ThemeMode.system,
    this.fontSize = FontSize.medium,
    this.enableKeySound = true,
    this.keySoundType = KeySoundType.default_,
    this.soundVolume = 0.5,
    this.enableWordPronunciation = true,
    this.pronunciationType = PronunciationType.us,
    this.pronunciationVolume = 0.7,
    this.dictationMode = DictationMode.off,
    this.showPhonetic = true,
    this.showTranslation = true,
    this.autoSwitchChapter = false,
    this.loopTimes = LoopTimesOption.one,
    this.enableRandomMode = false,
    this.enableErrorReview = true,
    this.showRealtimeWPM = true,
    this.showProgressBar = true,
    this.enableShortcuts = true,
    this.enableAutoSave = true,
    this.autoSaveInterval = 30,
    this.enableStatistics = true,
    this.enableStudyReminder = false,
    this.studyReminderTimes = const [],
    this.defaultDictionaryId,
    this.wordsPerChapter = 20,
    this.enableEyeProtection = false,
    this.eyeProtectionTemperature = 0.8,
    this.languageCode = 'zh_CN',
  });

  /// 复制并修改设置
  UserSettings copyWith({
    ThemeMode? themeMode,
    FontSize? fontSize,
    bool? enableKeySound,
    KeySoundType? keySoundType,
    double? soundVolume,
    bool? enableWordPronunciation,
    PronunciationType? pronunciationType,
    double? pronunciationVolume,
    DictationMode? dictationMode,
    bool? showPhonetic,
    bool? showTranslation,
    bool? autoSwitchChapter,
    LoopTimesOption? loopTimes,
    bool? enableRandomMode,
    bool? enableErrorReview,
    bool? showRealtimeWPM,
    bool? showProgressBar,
    bool? enableShortcuts,
    bool? enableAutoSave,
    int? autoSaveInterval,
    bool? enableStatistics,
    bool? enableStudyReminder,
    List<DateTime>? studyReminderTimes,
    String? defaultDictionaryId,
    int? wordsPerChapter,
    bool? enableEyeProtection,
    double? eyeProtectionTemperature,
    String? languageCode,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      enableKeySound: enableKeySound ?? this.enableKeySound,
      keySoundType: keySoundType ?? this.keySoundType,
      soundVolume: soundVolume ?? this.soundVolume,
      enableWordPronunciation:
          enableWordPronunciation ?? this.enableWordPronunciation,
      pronunciationType: pronunciationType ?? this.pronunciationType,
      pronunciationVolume: pronunciationVolume ?? this.pronunciationVolume,
      dictationMode: dictationMode ?? this.dictationMode,
      showPhonetic: showPhonetic ?? this.showPhonetic,
      showTranslation: showTranslation ?? this.showTranslation,
      autoSwitchChapter: autoSwitchChapter ?? this.autoSwitchChapter,
      loopTimes: loopTimes ?? this.loopTimes,
      enableRandomMode: enableRandomMode ?? this.enableRandomMode,
      enableErrorReview: enableErrorReview ?? this.enableErrorReview,
      showRealtimeWPM: showRealtimeWPM ?? this.showRealtimeWPM,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      enableShortcuts: enableShortcuts ?? this.enableShortcuts,
      enableAutoSave: enableAutoSave ?? this.enableAutoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      enableStatistics: enableStatistics ?? this.enableStatistics,
      enableStudyReminder: enableStudyReminder ?? this.enableStudyReminder,
      studyReminderTimes: studyReminderTimes ?? this.studyReminderTimes,
      defaultDictionaryId: defaultDictionaryId ?? this.defaultDictionaryId,
      wordsPerChapter: wordsPerChapter ?? this.wordsPerChapter,
      enableEyeProtection: enableEyeProtection ?? this.enableEyeProtection,
      eyeProtectionTemperature:
          eyeProtectionTemperature ?? this.eyeProtectionTemperature,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  /// 是否启用音效
  bool get hasAnySound => enableKeySound || enableWordPronunciation;

  /// 是否为深色主题
  bool get isDarkTheme => themeMode == ThemeMode.dark;

  /// 是否为浅色主题
  bool get isLightTheme => themeMode == ThemeMode.light;

  /// 是否跟随系统主题
  bool get isSystemTheme => themeMode == ThemeMode.system;

  @override
  List<Object?> get props => [
        themeMode,
        fontSize,
        enableKeySound,
        keySoundType,
        soundVolume,
        enableWordPronunciation,
        pronunciationType,
        pronunciationVolume,
        dictationMode,
        showPhonetic,
        showTranslation,
        autoSwitchChapter,
        loopTimes,
        enableRandomMode,
        enableErrorReview,
        showRealtimeWPM,
        showProgressBar,
        enableShortcuts,
        enableAutoSave,
        autoSaveInterval,
        enableStatistics,
        enableStudyReminder,
        studyReminderTimes,
        defaultDictionaryId,
        wordsPerChapter,
        enableEyeProtection,
        eyeProtectionTemperature,
        languageCode,
      ];
}
