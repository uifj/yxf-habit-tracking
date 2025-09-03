import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/typing/typing_session.dart';
import '../../../domain/entities/typing/word.dart';
import '../../../data/datasources/typing/dictionary_assets_datasource.dart';
import '../../../data/datasources/typing/dictionary_manager.dart';
import '../../../data/datasources/typing/audio_assets_datasource.dart';
import '../../../domain/entities/setting/user_settings.dart';
import 'typing_event.dart' as events;
import 'typing_state.dart' as states;

/// 打字练习BLoC
class TypingBloc extends Bloc<events.TypingEvent, states.TypingState> {
  final DictionaryAssetsDataSource? dictionaryDataSource;
  final AudioAssetsDataSource? audioDataSource;
  final DictionaryManager _dictionaryManager;

  Timer? _timer;
  final Map<String, int> _mistakeCount = {};
  final List<int> _keystrokeTimestamps = [];
  int _startTime = 0;
  int _correctChars = 0;
  int _totalChars = 0;

  TypingBloc({
    this.dictionaryDataSource,
    this.audioDataSource,
  })  : _dictionaryManager = DictionaryManager.instance,
        super(const states.TypingInitial()) {
    on<events.TypingStarted>(_onTypingStarted);
    on<events.TypingCharacterInput>(_onCharacterInput);
    on<events.TypingWordCompleted>(_onWordCompleted);
    on<events.TypingCharacterDeleted>(_onCharacterDeleted);
    on<events.TypingPaused>(_onTypingPaused);
    on<events.TypingResumed>(_onTypingResumed);
    on<events.TypingReset>(_onTypingReset);
    on<events.TypingCompleted>(_onTypingCompleted);
    on<events.TypingTimerTick>(_onTimerTick);
    on<events.TypingWordSkipped>(_onWordSkipped);
    on<events.TypingWordRetry>(_onWordRetry);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// 开始打字练习
  Future<void> _onTypingStarted(
    events.TypingStarted event,
    Emitter<states.TypingState> emit,
  ) async {
    try {
      emit(const states.TypingLoading());

      // 从数据源加载单词数据
      List<Word> words = event.words;
      if (words.isEmpty) {
        try {
          // 使用指定的字典ID或默认字典
          final dictionaryId = event.dictionaryId ?? '926';
          final chapterIndex = event.chapterIndex ?? 0;

          // 使用DictionaryManager加载章节单词
          words = await _dictionaryManager.getChapterWords(
            dictionaryId: dictionaryId,
            chapterIndex: chapterIndex,
            wordsPerChapter: 20,
          );

          // 如果加载失败或为空，使用默认单词
          if (words.isEmpty) {
            words = _getDefaultWords();
          }
        } catch (e) {
          // 如果加载失败，使用默认单词
          words = _getDefaultWords();
        }
      }

      // 创建打字会话
      final session = TypingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dictionaryId: event.dictionaryId ?? 'default',
        chapterIndex: event.chapterIndex ?? 0,
        chapterData: ChapterData(
          words: words,
          currentIndex: 0,
          correctCount: 0,
          wrongCount: 0,
          wordCount: words.length,
        ),
        timerData: const TimerData().start(),
        status: TypingStatus.typing,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 初始化统计数据
      _mistakeCount.clear();
      _keystrokeTimestamps.clear();
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _correctChars = 0;
      _totalChars = 0;

      // 启动计时器
      _startTimer();

      // 生成初始字符状态
      final characterStatuses = _generateCharacterStatuses(
        session.chapterData.currentWord?.name ?? '',
        '',
      );

      emit(states.TypingInProgress(
        session: session,
        currentInput: '',
        characterStatuses: characterStatuses,
        mistakeCount: Map.from(_mistakeCount),
        currentWPM: 0.0,
        currentAccuracy: 100.0,
      ));
    } catch (e) {
      emit(states.TypingError(message: '启动练习失败: ${e.toString()}'));
    }
  }

  /// 处理字符输入
  Future<void> _onCharacterInput(
    events.TypingCharacterInput event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    final currentWord = currentState.currentWord;
    if (currentWord == null) return;

    final newInput = currentState.currentInput + event.character;
    _keystrokeTimestamps.add(event.timestamp);
    _totalChars++;

    // 播放键盘音效
    if (audioDataSource != null) {
      await audioDataSource!.playKeySound(KeySoundType.default_);
    }

    // 检查输入是否正确
    final isCorrect = _isInputCorrect(currentWord.name, newInput);
    final characterStatuses =
        _generateCharacterStatuses(currentWord.name, newInput);

    bool hasError = false;
    String? errorMessage;

    if (!isCorrect) {
      // 记录错误
      final errorChar = event.character.toLowerCase();
      _mistakeCount[errorChar] = (_mistakeCount[errorChar] ?? 0) + 1;
      hasError = true;
      errorMessage = '输入错误："${event.character}"';
    } else {
      _correctChars++;
    }

    // 计算当前WPM和准确率
    final currentWPM = _calculateCurrentWPM();
    final currentAccuracy = _calculateCurrentAccuracy();

    emit(currentState.copyWith(
      currentInput: newInput,
      characterStatuses: characterStatuses,
      hasError: hasError,
      errorMessage: errorMessage,
      mistakeCount: Map.from(_mistakeCount),
      currentWPM: currentWPM,
      currentAccuracy: currentAccuracy,
    ));
  }

  /// 处理单词完成
  Future<void> _onWordCompleted(
    events.TypingWordCompleted event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    final currentWord = currentState.currentWord;
    if (currentWord == null) return;

    // 检查单词是否正确
    final isWordCorrect =
        event.inputWord.trim().toLowerCase() == currentWord.name.toLowerCase();

    if (isWordCorrect) {
      // 单词正确，移动到下一个单词
      final newIndex = currentState.currentWordIndex + 1;

      // 检查是否完成所有单词
      if (newIndex >= currentState.totalWords) {
        // 完成所有单词
        add(const events.TypingCompleted());
        return;
      }

      // 更新会话数据
      final updatedChapterData =
          currentState.session.chapterData.copyWithCurrentIndex(newIndex);
      final updatedSession =
          currentState.session.copyWith(chapterData: updatedChapterData);

      // 验证下一个单词是否存在
      final nextWord = updatedChapterData.currentWord;
      if (nextWord == null) {
        // 如果下一个单词不存在，完成练习
        add(const events.TypingCompleted());
        return;
      }

      // 生成新单词的字符状态
      final characterStatuses = _generateCharacterStatuses(nextWord.name, '');

      // 播放成功音效
      if (audioDataSource != null) {
        await audioDataSource!.playKeySound(KeySoundType.default_);
      }

      emit(currentState.copyWith(
        session: updatedSession,
        currentInput: '', // 清空输入
        characterStatuses: characterStatuses,
        hasError: false,
        errorMessage: null,
      ));
    } else {
      // 单词错误，显示错误信息
      emit(currentState.copyWith(
        hasError: true,
        errorMessage: '单词错误！正确答案是："${currentWord.name}"',
      ));
    }
  }

  /// 处理字符删除
  Future<void> _onCharacterDeleted(
    events.TypingCharacterDeleted event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    if (currentState.currentInput.isEmpty) return;

    final currentWord = currentState.currentWord;
    if (currentWord == null) return;

    final newInput = currentState.currentInput.substring(
      0,
      currentState.currentInput.length - 1,
    );

    final characterStatuses =
        _generateCharacterStatuses(currentWord.name, newInput);

    emit(currentState.copyWith(
      currentInput: newInput,
      characterStatuses: characterStatuses,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// 暂停练习
  Future<void> _onTypingPaused(
    events.TypingPaused event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    _timer?.cancel();

    final pausedSession = currentState.session.copyWith(
      status: TypingStatus.paused,
      timerData: currentState.session.timerData.stop(),
    );

    emit(states.TypingPaused(
      session: pausedSession,
      currentInput: currentState.currentInput,
      characterStatuses: currentState.characterStatuses,
      mistakeCount: currentState.mistakeCount,
    ));
  }

  /// 恢复练习
  Future<void> _onTypingResumed(
    events.TypingResumed event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingPaused) return;

    _startTimer();

    final resumedSession = currentState.session.copyWith(
      status: TypingStatus.typing,
      timerData: currentState.session.timerData.start(),
    );

    emit(states.TypingInProgress(
      session: resumedSession,
      currentInput: currentState.currentInput,
      characterStatuses: currentState.characterStatuses,
      mistakeCount: currentState.mistakeCount,
      currentWPM: _calculateCurrentWPM(),
      currentAccuracy: _calculateCurrentAccuracy(),
    ));
  }

  /// 重置练习
  Future<void> _onTypingReset(
    events.TypingReset event,
    Emitter<states.TypingState> emit,
  ) async {
    _timer?.cancel();
    _mistakeCount.clear();
    _keystrokeTimestamps.clear();
    _correctChars = 0;
    _totalChars = 0;
    emit(const states.TypingInitial());
  }

  /// 完成练习
  Future<void> _onTypingCompleted(
    events.TypingCompleted event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    _timer?.cancel();

    final completedSession = currentState.session.copyWith(
      status: TypingStatus.finished,
      timerData: currentState.session.timerData.stop(),
    );

    // 计算最终统计数据
    final finalWPM = _calculateCurrentWPM();
    final finalAccuracy = _calculateCurrentAccuracy();
    final totalTime =
        Duration(milliseconds: completedSession.timerData.elapsedTime);

    // 找出错误最多的单词
    final mostMistakenWords = _getMostMistakenWords();

    emit(states.TypingCompleted(
      session: completedSession,
      mistakeCount: Map.from(_mistakeCount),
      mostMistakenWords: mostMistakenWords,
      finalWPM: finalWPM,
      finalAccuracy: finalAccuracy,
      totalTime: totalTime,
    ));
  }

  /// 计时器更新
  Future<void> _onTimerTick(
    events.TypingTimerTick event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    final updatedTimerData =
        currentState.session.timerData.tick(event.elapsedTime);
    final updatedSession =
        currentState.session.copyWith(timerData: updatedTimerData);

    emit(currentState.copyWith(
      session: updatedSession,
      currentWPM: _calculateCurrentWPM(),
      currentAccuracy: _calculateCurrentAccuracy(),
    ));
  }

  /// 跳过单词
  Future<void> _onWordSkipped(
    events.TypingWordSkipped event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    final newIndex = currentState.currentWordIndex + 1;

    if (newIndex >= currentState.totalWords) {
      add(const events.TypingCompleted());
      return;
    }

    final updatedChapterData =
        currentState.session.chapterData.copyWithCurrentIndex(newIndex);
    final updatedSession =
        currentState.session.copyWith(chapterData: updatedChapterData);

    final nextWord = updatedChapterData.currentWord;
    final characterStatuses =
        _generateCharacterStatuses(nextWord?.name ?? '', '');

    emit(currentState.copyWith(
      session: updatedSession,
      currentInput: '',
      characterStatuses: characterStatuses,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// 重试单词
  Future<void> _onWordRetry(
    events.TypingWordRetry event,
    Emitter<states.TypingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.TypingInProgress) return;

    final currentWord = currentState.currentWord;
    if (currentWord == null) return;

    final characterStatuses = _generateCharacterStatuses(currentWord.name, '');

    emit(currentState.copyWith(
      currentInput: '',
      characterStatuses: characterStatuses,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// 启动计时器
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - _startTime;
      add(events.TypingTimerTick(elapsedTime: elapsed));
    });
  }

  /// 检查输入是否正确
  bool _isInputCorrect(String targetWord, String input) {
    if (input.length > targetWord.length) return false;
    return targetWord.toLowerCase().startsWith(input.toLowerCase());
  }

  /// 生成字符状态列表
  List<states.CharacterStatus> _generateCharacterStatuses(
      String targetWord, String input) {
    final statuses = <states.CharacterStatus>[];

    for (int i = 0; i < targetWord.length; i++) {
      if (i < input.length) {
        // 已输入的字符
        if (targetWord[i].toLowerCase() == input[i].toLowerCase()) {
          statuses.add(states.CharacterStatus.correct);
        } else {
          statuses.add(states.CharacterStatus.incorrect);
        }
      } else if (i == input.length) {
        // 当前位置
        statuses.add(states.CharacterStatus.current);
      } else {
        // 未输入的字符
        statuses.add(states.CharacterStatus.pending);
      }
    }

    return statuses;
  }

  /// 计算当前WPM
  double _calculateCurrentWPM() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedMinutes = (currentTime - _startTime) / 60000.0;

    if (elapsedMinutes <= 0) return 0.0;

    return (_correctChars / 5.0) / elapsedMinutes;
  }

  /// 计算当前准确率
  double _calculateCurrentAccuracy() {
    if (_totalChars == 0) return 100.0;
    return (_correctChars / _totalChars) * 100.0;
  }

  /// 获取错误最多的单词
  List<String> _getMostMistakenWords() {
    final sortedMistakes = _mistakeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMistakes.take(5).map((e) => e.key).toList();
  }

  /// 获取默认单词列表
  List<Word> _getDefaultWords() {
    return [
      const Word(
        name: 'flutter',
        translations: ['Flutter框架'],
        usPhonetic: '/ˈflʌtər/',
        ukPhonetic: '/ˈflʌtə/',
        index: 0,
      ),
      const Word(
        name: 'dart',
        translations: ['Dart编程语言'],
        usPhonetic: '/dɑːrt/',
        ukPhonetic: '/dɑːt/',
        index: 1,
      ),
      const Word(
        name: 'widget',
        translations: ['小部件'],
        usPhonetic: '/ˈwɪdʒɪt/',
        ukPhonetic: '/ˈwɪdʒɪt/',
        index: 2,
      ),
      const Word(
        name: 'state',
        translations: ['状态'],
        usPhonetic: '/steɪt/',
        ukPhonetic: '/steɪt/',
        index: 3,
      ),
      const Word(
        name: 'build',
        translations: ['构建'],
        usPhonetic: '/bɪld/',
        ukPhonetic: '/bɪld/',
        index: 4,
      ),
    ];
  }
}
