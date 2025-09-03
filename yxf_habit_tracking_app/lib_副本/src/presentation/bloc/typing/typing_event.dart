import 'package:equatable/equatable.dart';
import '../../../domain/entities/typing/word.dart';

/// 打字练习事件基类
abstract class TypingEvent extends Equatable {
  const TypingEvent();

  @override
  List<Object?> get props => [];
}

/// 开始打字练习
class TypingStarted extends TypingEvent {
  final String dictionaryId;
  final int chapterIndex;
  final List<Word> words;

  const TypingStarted({
    required this.dictionaryId,
    required this.chapterIndex,
    required this.words,
  });

  @override
  List<Object?> get props => [dictionaryId, chapterIndex, words];
}

/// 用户输入字符
class TypingCharacterInput extends TypingEvent {
  final String character;
  final int timestamp;

  const TypingCharacterInput({
    required this.character,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [character, timestamp];
}

/// 用户完成单词输入
class TypingWordCompleted extends TypingEvent {
  final String inputWord;
  final int timestamp;

  const TypingWordCompleted({
    required this.inputWord,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [inputWord, timestamp];
}

/// 用户删除字符
class TypingCharacterDeleted extends TypingEvent {
  final int timestamp;

  const TypingCharacterDeleted({
    required this.timestamp,
  });

  @override
  List<Object?> get props => [timestamp];
}

/// 暂停打字练习
class TypingPaused extends TypingEvent {
  const TypingPaused();
}

/// 恢复打字练习
class TypingResumed extends TypingEvent {
  const TypingResumed();
}

/// 重置打字练习
class TypingReset extends TypingEvent {
  const TypingReset();
}

/// 完成打字练习
class TypingCompleted extends TypingEvent {
  const TypingCompleted();
}

/// 更新计时器
class TypingTimerTick extends TypingEvent {
  final int elapsedTime;

  const TypingTimerTick({
    required this.elapsedTime,
  });

  @override
  List<Object?> get props => [elapsedTime];
}

/// 跳过当前单词
class TypingWordSkipped extends TypingEvent {
  const TypingWordSkipped();
}

/// 重新练习当前单词
class TypingWordRetry extends TypingEvent {
  const TypingWordRetry();
}
