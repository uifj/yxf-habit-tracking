import 'package:equatable/equatable.dart';
import 'word.dart';

/// 打字状态枚举
enum TypingStatus {
  idle,
  typing,
  paused,
  finished,
}

/// 用户输入日志
class UserInputLog extends Equatable {
  /// 单词索引
  final int index;

  /// 正确字符数
  final int correctCount;

  /// 错误字符数
  final int wrongCount;

  /// 输入时间戳列表
  final List<int> letterTimeArray;

  /// 字母错误记录
  final Map<String, int> letterMistakes;

  const UserInputLog({
    required this.index,
    required this.correctCount,
    required this.wrongCount,
    required this.letterTimeArray,
    required this.letterMistakes,
  });

  /// 是否完全正确
  bool get isPerfect => wrongCount == 0 && correctCount > 0;

  /// 准确率
  double get accuracy {
    final total = correctCount + wrongCount;
    return total > 0 ? (correctCount / total) * 100 : 0.0;
  }

  @override
  List<Object?> get props => [
        index,
        correctCount,
        wrongCount,
        letterTimeArray,
        letterMistakes,
      ];
}

/// 章节数据
class ChapterData extends Equatable {
  /// 单词列表
  final List<Word> words;

  /// 当前单词索引
  final int currentIndex;

  /// 正确字符数
  final int correctCount;

  /// 错误字符数
  final int wrongCount;

  /// 单词总数
  final int wordCount;

  /// 用户输入日志
  final List<UserInputLog> userInputLogs;

  /// 单词记录ID列表
  final List<int> wordRecordIds;

  const ChapterData({
    required this.words,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.wordCount = 0,
    this.userInputLogs = const [],
    this.wordRecordIds = const [],
  });

  /// 获取当前单词
  Word? get currentWord {
    if (currentIndex >= 0 && currentIndex < words.length) {
      return words[currentIndex];
    }
    return null;
  }

  /// 是否完成
  bool get isCompleted => currentIndex >= words.length;

  /// 进度百分比
  double get progress {
    if (words.isEmpty) return 0.0;
    return (currentIndex / words.length).clamp(0.0, 1.0);
  }

  /// 总字符数
  int get totalChars => correctCount + wrongCount;

  /// 准确率
  double get accuracy {
    return totalChars > 0 ? (correctCount / totalChars) * 100 : 0.0;
  }

  /// 复制并更新当前索引
  ChapterData copyWithCurrentIndex(int newIndex) {
    return ChapterData(
      words: words,
      currentIndex: newIndex,
      correctCount: correctCount,
      wrongCount: wrongCount,
      wordCount: wordCount,
      userInputLogs: userInputLogs,
      wordRecordIds: wordRecordIds,
    );
  }

  /// 复制并更新统计数据
  ChapterData copyWithStats({
    int? correctCount,
    int? wrongCount,
    List<UserInputLog>? userInputLogs,
    List<int>? wordRecordIds,
  }) {
    return ChapterData(
      words: words,
      currentIndex: currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      wordCount: wordCount,
      userInputLogs: userInputLogs ?? this.userInputLogs,
      wordRecordIds: wordRecordIds ?? this.wordRecordIds,
    );
  }

  @override
  List<Object?> get props => [
        words,
        currentIndex,
        correctCount,
        wrongCount,
        wordCount,
        userInputLogs,
        wordRecordIds,
      ];
}

/// 计时器数据
class TimerData extends Equatable {
  /// 开始时间
  final DateTime? startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 已用时间（毫秒）
  final int elapsedTime;

  /// 是否运行中
  final bool isRunning;

  const TimerData({
    this.startTime,
    this.endTime,
    this.elapsedTime = 0,
    this.isRunning = false,
  });

  /// 总持续时间
  Duration get duration => Duration(milliseconds: elapsedTime);

  /// WPM（每分钟单词数）
  double calculateWPM(int correctChars) {
    if (elapsedTime == 0) return 0.0;
    final minutes = elapsedTime / 60000.0;
    return (correctChars / 5.0) / minutes;
  }

  /// 开始计时
  TimerData start() {
    return TimerData(
      startTime: DateTime.now(),
      endTime: null,
      elapsedTime: 0,
      isRunning: true,
    );
  }

  /// 停止计时
  TimerData stop() {
    return TimerData(
      startTime: startTime,
      endTime: DateTime.now(),
      elapsedTime: elapsedTime,
      isRunning: false,
    );
  }

  /// 更新已用时间
  TimerData tick(int newElapsedTime) {
    return TimerData(
      startTime: startTime,
      endTime: endTime,
      elapsedTime: newElapsedTime,
      isRunning: isRunning,
    );
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        elapsedTime,
        isRunning,
      ];
}

/// 打字会话
class TypingSession extends Equatable {
  /// 会话ID
  final String id;

  /// 词典ID
  final String dictionaryId;

  /// 章节索引
  final int chapterIndex;

  /// 章节数据
  final ChapterData chapterData;

  /// 计时器数据
  final TimerData timerData;

  /// 打字状态
  final TypingStatus status;

  /// 是否为复习模式
  final bool isReviewMode;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const TypingSession({
    required this.id,
    required this.dictionaryId,
    required this.chapterIndex,
    required this.chapterData,
    required this.timerData,
    this.status = TypingStatus.idle,
    this.isReviewMode = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 是否完成
  bool get isCompleted => status == TypingStatus.finished;

  /// 是否正在进行
  bool get isActive => status == TypingStatus.typing;

  /// 总WPM
  double get wpm => timerData.calculateWPM(chapterData.correctCount);

  /// 准确率
  double get accuracy => chapterData.accuracy;

  /// 复制并更新状态
  TypingSession copyWith({
    ChapterData? chapterData,
    TimerData? timerData,
    TypingStatus? status,
  }) {
    return TypingSession(
      id: id,
      dictionaryId: dictionaryId,
      chapterIndex: chapterIndex,
      chapterData: chapterData ?? this.chapterData,
      timerData: timerData ?? this.timerData,
      status: status ?? this.status,
      isReviewMode: isReviewMode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        dictionaryId,
        chapterIndex,
        chapterData,
        timerData,
        status,
        isReviewMode,
        createdAt,
        updatedAt,
      ];
}
