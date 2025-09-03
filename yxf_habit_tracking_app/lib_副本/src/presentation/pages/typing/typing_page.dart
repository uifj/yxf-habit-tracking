import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import '../../bloc/bloc.dart';
import '../../bloc/typing/typing_state.dart' as states;

/// 打字练习页面
/// 支持多平台：iOS、Android、macOS、Windows
class TypingPage extends StatelessWidget {
  const TypingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用全局提供的TypingBloc实例
    return const _TypingPageView();
  }
}

class _TypingPageView extends StatefulWidget {
  const _TypingPageView();

  @override
  State<_TypingPageView> createState() => _TypingPageViewState();
}

class _TypingPageViewState extends TencentCloudChatState<_TypingPageView> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // 显示模式：true为实时反馈模式，false为整体比对模式
  bool _isRealtimeMode = true;

  // 整体比对模式下的错误状态
  // ignore: unused_field
  bool _hasWordError = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // 获取路由参数并初始化练习会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final dictionaryId = args['dictionaryId'] as String?;
        final chapterIndex = args['chapterIndex'] as int?;

        if (dictionaryId != null && chapterIndex != null) {
          context.read<TypingBloc>().add(
                TypingStarted(
                  dictionaryId: dictionaryId,
                  chapterIndex: chapterIndex,
                  words: const [], // 空列表，让TypingBloc从数据源加载
                ),
              );
        }
      }
    });
  }

  /// 构建统计信息面板
  Widget _buildStatisticsPanel(
    TypingInProgress state,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '速度',
            '${state.currentWPM.toInt()} WPM',
            Icons.speed,
            colorTheme,
            textStyle,
          ),
          Container(
            height: 40,
            width: 1,
            color: colorTheme.onBackground.withOpacity(0.2),
          ),
          _buildStatItem(
            '准确率',
            '${state.currentAccuracy.toInt()}%',
            Icons.track_changes,
            colorTheme,
            textStyle,
          ),
          Container(
            height: 40,
            width: 1,
            color: colorTheme.onBackground.withOpacity(0.2),
          ),
          _buildStatItem(
            '进度',
            '${state.currentWordIndex + 1}/${state.totalWords}',
            Icons.timeline,
            colorTheme,
            textStyle,
          ),
        ],
      ),
    );
  }

  /// 构建单个统计项
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorTheme.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            fontWeight: FontWeight.bold,
            color: colorTheme.onBackground,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: textStyle.fontsize_12,
            color: colorTheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 构建整体比对模式的单词显示组件
  Widget _buildWholeWordDisplay(
    String targetWord,
    String currentInput,
    TencentCloudChatThemeColors colorTheme,
  ) {
    // 判断是否应该显示错误状态
    bool shouldShowError = currentInput.length == targetWord.length &&
        currentInput.toLowerCase() != targetWord.toLowerCase();

    Color textColor;
    Color? backgroundColor;

    if (shouldShowError) {
      // 输入完成但错误 - 红色
      textColor = Colors.red.shade700;
      backgroundColor = Colors.red.shade50;
    } else if (currentInput.length == targetWord.length &&
        currentInput.toLowerCase() == targetWord.toLowerCase()) {
      // 输入完成且正确 - 绿色
      textColor = Colors.green.shade700;
      backgroundColor = Colors.green.shade50;
    } else {
      // 正常状态 - 默认颜色
      textColor = colorTheme.onBackground;
      backgroundColor = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: shouldShowError
              ? Colors.red.shade300
              : colorTheme.onBackground.withOpacity(0.1),
          width: shouldShowError ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shouldShowError
                ? Colors.red.withOpacity(0.1)
                : colorTheme.onBackground.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        targetWord,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      context
          .read<TypingBloc>()
          .add(TypingTimerTick(elapsedTime: _stopwatch.elapsedMilliseconds));
    });
  }

  void _onInputChanged(String value) {
    final bloc = context.read<TypingBloc>();
    final state = bloc.state;

    if (state is TypingInProgress) {
      final currentWord = state.currentWord;
      if (currentWord == null) return;

      // 发送字符输入事件（仅当输入长度增加时）
      if (value.length > state.currentInput.length && value.isNotEmpty) {
        final lastChar = value[value.length - 1];
        bloc.add(TypingCharacterInput(
          character: lastChar,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      // 检查是否完成当前单词
      if (value.trim().toLowerCase() == currentWord.name.toLowerCase()) {
        bloc.add(TypingWordCompleted(
          inputWord: value.trim(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
        // 延迟清空输入框，让用户看到完成状态
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _inputController.clear();
          }
        });
      }
    }
  }

  void _onSubmitted(String value) {
    final bloc = context.read<TypingBloc>();
    final state = bloc.state;

    if (state is TypingInProgress) {
      final currentWord = state.currentWord;
      if (currentWord != null) {
        if (value.trim().toLowerCase() == currentWord.name.toLowerCase()) {
          bloc.add(TypingWordCompleted(
            inputWord: value.trim(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
          _inputController.clear();
        } else {
          // 显示错误并允许重试
          bloc.add(const TypingWordRetry());
          // 清空输入让用户重新输入
          _inputController.clear();
        }
      }
    }
  }

  void _resetSession() {
    context.read<TypingBloc>().add(const TypingReset());
    _inputController.clear();
  }

  /// 构建单词字符显示组件，支持字符级别的错误高亮
  Widget _buildWordDisplay(
    String targetWord,
    String currentInput,
    TencentCloudChatThemeColors colorTheme,
  ) {
    final List<Widget> characterWidgets = [];

    for (int i = 0; i < targetWord.length; i++) {
      final char = targetWord[i];
      Color textColor;
      Color? backgroundColor;

      if (i < currentInput.length) {
        // 用户已输入的字符
        if (currentInput[i].toLowerCase() == char.toLowerCase()) {
          // 正确的字符 - 绿色
          textColor = Colors.green.shade700;
          backgroundColor = Colors.green.shade50;
        } else {
          // 错误的字符 - 红色
          textColor = Colors.red.shade700;
          backgroundColor = Colors.red.shade50;
        }
      } else if (i == currentInput.length) {
        // 当前要输入的字符 - 高亮显示
        textColor = colorTheme.primaryColor;
        backgroundColor = colorTheme.primaryColor.withOpacity(0.1);
      } else {
        // 未输入的字符 - 默认颜色
        textColor = colorTheme.onBackground.withOpacity(0.5);
      }

      characterWidgets.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Text(
            char,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 2,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorTheme.onBackground.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorTheme.onBackground.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: characterWidgets,
      ),
    );
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qwerty Learner',
                      style: TextStyle(
                        fontSize: textStyle.fontsize_20,
                        fontWeight: FontWeight.bold,
                        color: colorTheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    // 显示模式切换按钮
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorTheme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRealtimeMode
                                ? Icons.flash_on
                                : Icons.check_circle,
                            size: 16,
                            color: colorTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isRealtimeMode ? '实时模式' : '整体模式',
                            style: TextStyle(
                              fontSize: textStyle.fontsize_12,
                              color: colorTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        color: colorTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isRealtimeMode = !_isRealtimeMode;
                          _hasWordError = false;
                          _inputController.clear();
                        });
                      },
                      tooltip: '切换显示模式',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildContent(context, colorTheme, textStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return BlocBuilder<TypingBloc, TypingState>(
      builder: (context, state) {
        if (state is TypingLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is TypingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_20,
                    fontWeight: FontWeight.bold,
                    color: colorTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: textStyle.fontsize_14,
                    color: colorTheme.onBackground.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resetSession,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (state is states.TypingCompleted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.celebration,
                  size: 64,
                  color: colorTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '练习完成！',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_24,
                    fontWeight: FontWeight.bold,
                    color: colorTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                  Text(
                    '最终成绩: ${state.finalWPM.toInt()} WPM',
                    style: TextStyle(
                      fontSize: textStyle.fontsize_16,
                      color: colorTheme.onBackground,
                    ),
                  ),
                  Text(
                    '准确率: ${state.finalAccuracy.toInt()}%',
                    style: TextStyle(
                      fontSize: textStyle.fontsize_16,
                      color: colorTheme.onBackground,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resetSession,
                  child: const Text('重新开始'),
                ),
              ],
            ),
          );
        }

        if (state is TypingInProgress) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: colorTheme.onBackground.withOpacity(0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorTheme.primaryColor),
                ),
                const SizedBox(height: 20),
                _buildStatisticsPanel(state, colorTheme, textStyle),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.currentWord != null) ...[
                          _isRealtimeMode
                              ? _buildWordDisplay(
                                  state.currentWord!.name,
                                  state.currentInput,
                                  colorTheme,
                                )
                              : _buildWholeWordDisplay(
                                  state.currentWord!.name,
                                  state.currentInput,
                                  colorTheme,
                                ),
                          const SizedBox(height: 8),
                          Text(
                            state.currentWord!.translations.join(', '),
                            style: TextStyle(
                              fontSize: textStyle.fontsize_16,
                              color: colorTheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Container(
                          width: 400,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorTheme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorTheme.primaryColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _inputController,
                            focusNode: _inputFocusNode,
                            onChanged: _onInputChanged,
                            onSubmitted: _onSubmitted,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorTheme.onBackground,
                              letterSpacing: 1,
                            ),
                            decoration: InputDecoration(
                              hintText: '请输入上方单词...',
                              hintStyle: TextStyle(
                                color: colorTheme.onBackground.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // TypingInitial state
        return Center(
          child: ElevatedButton(
            onPressed: () {
              // 使用空的单词列表，让TypingBloc从数据源加载
              context.read<TypingBloc>().add(const TypingStarted(
                    words: [], // 空列表，将从数据源加载
                    dictionaryId: '926', // 使用926核心词汇
                    chapterIndex: 0,
                  ));
            },
            child: const Text('开始练习'),
          ),
        );
      },
    );
  }

  @override
  Widget? mobileBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget? desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: Row(
          children: [
            // 侧边栏（桌面端）
            Container(
              width: 300,
              color: colorTheme.desktopBackgroundColorLinearGradientOne,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Qwerty Learner',
                      style: TextStyle(
                        fontSize: textStyle.fontsize_20,
                        fontWeight: FontWeight.bold,
                        color: colorTheme.onBackground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSidebar(context, colorTheme, textStyle),
                  ),
                ],
              ),
            ),
            // 主内容区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context, colorTheme, textStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          Text(
            '当前词典',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CET-4 核心词汇',
            style: TextStyle(
              color: colorTheme.onBackground.withOpacity(0.7),
              fontSize: textStyle.fontsize_14,
            ),
          ),
          const SizedBox(height: 20),
          // 显示模式切换区域
          Text(
            '显示模式',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isRealtimeMode ? Icons.flash_on : Icons.check_circle,
                      size: 18,
                      color: colorTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRealtimeMode ? '实时模式' : '整体模式',
                      style: TextStyle(
                        fontSize: textStyle.fontsize_14,
                        color: colorTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isRealtimeMode ? '字符输入时即时显示正确/错误状态' : '输入完成后整体显示正确/错误状态',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_12,
                    color: colorTheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isRealtimeMode = !_isRealtimeMode;
                        _hasWordError = false;
                        _inputController.clear();
                      });
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('切换模式'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '进度',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<TypingBloc, TypingState>(
            builder: (context, state) {
              if (state is TypingInProgress) {
                return LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: colorTheme.onBackground.withOpacity(0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorTheme.primaryColor),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
