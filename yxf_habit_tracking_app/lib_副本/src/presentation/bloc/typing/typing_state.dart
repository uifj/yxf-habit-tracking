import 'package:equatable/equatable.dart';
import '../../../domain/entities/typing/typing_session.dart';
import '../../../domain/entities/typing/word.dart';

/// 打字练习状态基类
abstract class TypingState extends Equatable {
  const TypingState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class TypingInitial extends TypingState {
  const TypingInitial();
}

/// 加载中状态
class TypingLoading extends TypingState {
  const TypingLoading();
}

/// 准备状态
class TypingReady extends TypingState {
  final List<Word> words;
  final String dictionaryId;
  final int chapterIndex;

  const TypingReady({
    required this.words,
    required this.dictionaryId,
    required this.chapterIndex,
  });

  @override
  List<Object?> get props => [words, dictionaryId, chapterIndex];
}

/// 进行中状态
class TypingInProgress extends TypingState {
  final TypingSession session;
  final String currentInput;
  final List<CharacterStatus> characterStatuses;
  final bool hasError;
  final String? errorMessage;
  final Map<String, int> mistakeCount;
  final double currentWPM;
  final double currentAccuracy;

  const TypingInProgress({
    required this.session,
    required this.currentInput,
    required this.characterStatuses,
    this.hasError = false,
    this.errorMessage,
    this.mistakeCount = const {},
    this.currentWPM = 0.0,
    this.currentAccuracy = 0.0,
  });

  /// 获取当前单词
  Word? get currentWord => session.chapterData.currentWord;

  /// 获取当前单词索引
  int get currentWordIndex => session.chapterData.currentIndex;

  /// 获取总单词数
  int get totalWords => session.chapterData.words.length;

  /// 获取进度百分比
  double get progress => session.chapterData.progress;

  /// 是否完成当前单词
  bool get isCurrentWordCompleted {
    final word = currentWord;
    if (word == null) return false;
    return currentInput.toLowerCase() == word.name.toLowerCase();
  }

  /// 复制并更新状态
  TypingInProgress copyWith({
    TypingSession? session,
    String? currentInput,
    List<CharacterStatus>? characterStatuses,
    bool? hasError,
    String? errorMessage,
    Map<String, int>? mistakeCount,
    double? currentWPM,
    double? currentAccuracy,
  }) {
    return TypingInProgress(
      session: session ?? this.session,
      currentInput: currentInput ?? this.currentInput,
      characterStatuses: characterStatuses ?? this.characterStatuses,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      currentWPM: currentWPM ?? this.currentWPM,
      currentAccuracy: currentAccuracy ?? this.currentAccuracy,
    );
  }

  @override
  List<Object?> get props => [
        session,
        currentInput,
        characterStatuses,
        hasError,
        errorMessage,
        mistakeCount,
        currentWPM,
        currentAccuracy,
      ];
}

/// 暂停状态
class TypingPaused extends TypingState {
  final TypingSession session;
  final String currentInput;
  final List<CharacterStatus> characterStatuses;
  final Map<String, int> mistakeCount;

  const TypingPaused({
    required this.session,
    required this.currentInput,
    required this.characterStatuses,
    required this.mistakeCount,
  });

  @override
  List<Object?> get props =>
      [session, currentInput, characterStatuses, mistakeCount];
}

/// 完成状态
class TypingCompleted extends TypingState {
  final TypingSession session;
  final Map<String, int> mistakeCount;
  final List<String> mostMistakenWords;
  final double finalWPM;
  final double finalAccuracy;
  final Duration totalTime;

  const TypingCompleted({
    required this.session,
    required this.mistakeCount,
    required this.mostMistakenWords,
    required this.finalWPM,
    required this.finalAccuracy,
    required this.totalTime,
  });

  @override
  List<Object?> get props => [
        session,
        mistakeCount,
        mostMistakenWords,
        finalWPM,
        finalAccuracy,
        totalTime,
      ];
}

/// 错误状态
class TypingError extends TypingState {
  final String message;
  final Exception? exception;

  const TypingError({
    required this.message,
    this.exception,
  });

  @override
  List<Object?> get props => [message, exception];
}

/// 字符状态枚举
enum CharacterStatus {
  /// 未输入
  pending,

  /// 正确
  correct,

  /// 错误
  incorrect,

  /// 当前位置
  current,
}

/// 字符状态数据类
class CharacterStatusData extends Equatable {
  final String character;
  final CharacterStatus status;
  final int index;

  const CharacterStatusData({
    required this.character,
    required this.status,
    required this.index,
  });

  @override
  List<Object?> get props => [character, status, index];
}
