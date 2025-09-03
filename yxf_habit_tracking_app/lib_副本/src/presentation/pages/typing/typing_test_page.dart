import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../../../data/datasources/typing/dictionary_manager.dart';
import '../../../domain/entities/typing/word.dart';

/// 打字功能测试页面 - 用于验证单词切换和数据加载
class TypingTestPage extends StatefulWidget {
  const TypingTestPage({super.key});

  @override
  State<TypingTestPage> createState() => _TypingTestPageState();
}

class _TypingTestPageState extends State<TypingTestPage> {
  final DictionaryManager _dictionaryManager = DictionaryManager.instance;
  List<Word> _testWords = [];
  int _currentIndex = 0;
  String _status = '准备测试...';

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    try {
      setState(() {
        _status = '加载测试数据...';
      });

      // 测试加载926词典的前10个单词
      final words = await _dictionaryManager.getChapterWords(
        dictionaryId: '926',
        chapterIndex: 0,
        wordsPerChapter: 10,
      );

      setState(() {
        _testWords = words;
        _currentIndex = 0;
        _status = words.isNotEmpty ? '加载成功！共${words.length}个单词' : '加载失败：无单词数据';
      });
    } catch (e) {
      setState(() {
        _status = '加载失败：$e';
      });
    }
  }

  void _nextWord() {
    if (_currentIndex < _testWords.length - 1) {
      setState(() {
        _currentIndex++;
        _status = '当前单词 ${_currentIndex + 1}/${_testWords.length}';
      });
    } else {
      setState(() {
        _status = '已到达最后一个单词';
      });
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _status = '当前单词 ${_currentIndex + 1}/${_testWords.length}';
      });
    } else {
      setState(() {
        _status = '已到达第一个单词';
      });
    }
  }

  void _resetTest() {
    setState(() {
      _currentIndex = 0;
      _status = '重置完成';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打字功能测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTestData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 当前单词显示
            if (_testWords.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '单词 ${_currentIndex + 1}/${_testWords.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _testWords[_currentIndex].name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _testWords[_currentIndex].translations.join(', '),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (_testWords[_currentIndex].usPhonetic != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _testWords[_currentIndex].usPhonetic!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _currentIndex > 0 ? _previousWord : null,
                    child: const Text('上一个'),
                  ),
                  ElevatedButton(
                    onPressed: _resetTest,
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: _currentIndex < _testWords.length - 1
                        ? _nextWord
                        : null,
                    child: const Text('下一个'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 开始正式练习按钮
              ElevatedButton(
                onPressed: () {
                  // 启动正式的打字练习
                  context.read<TypingBloc>().add(TypingStarted(
                        words: _testWords,
                        dictionaryId: '926',
                        chapterIndex: 0,
                      ));
                  Navigator.of(context).pop(); // 返回到打字页面
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '开始正式练习',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],

            // 调试信息
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '调试信息',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '词典管理器状态: ${_dictionaryManager.isDictionaryPreloaded("926") ? "已预加载" : "未预加载"}'),
                    Text('测试单词数量: ${_testWords.length}'),
                    Text('当前索引: $_currentIndex'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
