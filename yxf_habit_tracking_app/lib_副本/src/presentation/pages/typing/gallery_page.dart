import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import 'package:tencent_cloud_chat_demo/core/router/app_route_names.dart';
import '../../../domain/entities/typing/dictionary.dart';
import '../../../data/datasources/typing/dictionary_manager.dart';
import '../../../../core/router/app_route_navigator.dart';
import '../../../../core/error/error_handler.dart';

/// 词典选择页面
/// 支持多平台：iOS、Android、macOS、Windows
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends TencentCloudChatState<GalleryPage> {
  final DictionaryManager _dictionaryManager = DictionaryManager.instance;

  List<Dictionary> _dictionaries = [];
  Dictionary? _selectedDictionary;
  List<Map<String, dynamic>> _chapters = [];
  Map<String, dynamic>? _selectedChapter;
  bool _isLoading = true;
  String? _errorMessage;

  // 词典分类
  final Map<String, List<Dictionary>> _categorizedDictionaries = {};
  String _selectedCategory = 'all';

  // 手风琴展开状态
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadDictionaries();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '考试':
      case 'exam':
        return Icons.school;
      case '商务':
      case 'business':
        return Icons.business;
      case '日常':
      case 'daily':
        return Icons.chat;
      case '技术':
      case 'tech':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }

  Future<void> _loadDictionaries() async {
    try {
      safeSetState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 从DictionaryManager加载所有词典
      final dictionaries = await _dictionaryManager.getAllDictionaries();

      // 按分类组织词典
      _categorizedDictionaries.clear();
      _categorizedDictionaries['all'] = dictionaries;

      for (final dict in dictionaries) {
        final category = dict.category;
        if (!_categorizedDictionaries.containsKey(category)) {
          _categorizedDictionaries[category] = [];
        }
        _categorizedDictionaries[category]!.add(dict);
      }

      safeSetState(() {
        _dictionaries = dictionaries;
        _isLoading = false;

        if (_dictionaries.isNotEmpty) {
          _selectedDictionary = _dictionaries.first;
          _loadChapters();
        }
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        _errorMessage = '加载词典失败: $e';
      });
    }
  }

  Future<void> _loadChapters() async {
    if (_selectedDictionary == null) return;

    try {
      // 使用DictionaryManager计算章节数量
      const wordsPerChapter = 50; // 每章50个单词
      final chapterCount = await _dictionaryManager.getDictionaryChapterCount(
        _selectedDictionary!.id,
        wordsPerChapter: wordsPerChapter,
      );

      // 生成章节列表
      _chapters = List.generate(
        chapterCount,
        (index) => {
          'id': '${_selectedDictionary!.id}_chapter_$index',
          'dictionaryId': _selectedDictionary!.id,
          'title': '第${index + 1}章',
          'description': '包含$wordsPerChapter个单词',
          'wordCount': wordsPerChapter,
          'order': index,
        },
      );

      safeSetState(() {
        _selectedChapter = null; // 重置选中的章节
      });
    } catch (e) {
      print('加载章节失败: $e');
      _chapters = [];
      safeSetState(() {});
    }
  }

  void _onDictionarySelected(Dictionary dictionary) {
    safeSetState(() {
      _selectedDictionary = dictionary;
      _selectedChapter = null;
    });
    _loadChapters();
  }

  void _onChapterSelected(Map<String, dynamic> chapter) {
    safeSetState(() {
      _selectedChapter = chapter;
    });
  }

  void _onCategoryChanged(String category) {
    safeSetState(() {
      _selectedCategory = category;
      _selectedDictionary = null;
      _selectedChapter = null;
      _chapters = [];
    });
  }

  Future<void> _startPractice() async {
    if (_selectedDictionary == null || _selectedChapter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择词典和章节')),
      );
      return;
    }

    try {
      // 预加载选中的词典
      await _dictionaryManager.preloadDictionary(_selectedDictionary!.id);

      // 检查widget是否仍然mounted
      if (!mounted) return;

      // 导航到练习页面
      await AppRouteNavigator.navigateToTyping(
        context: context,
        dictionaryId: _selectedDictionary!.id,
        chapterIndex: _selectedChapter!['order'],
      );

      // 练习完成后可能需要刷新状态
      // 这里可以添加练习完成后的回调处理
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          type: ErrorType.unknown,
          customMessage: '启动练习失败，请稍后重试',
          onRetry: () => _startPractice(),
        );
      }
    }
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    if (_isLoading) {
      return TencentCloudChatThemeWidget(
        build: (context, colorTheme, textStyle) => Scaffold(
          backgroundColor: colorTheme.backgroundColor,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return TencentCloudChatThemeWidget(
        build: (context, colorTheme, textStyle) => Scaffold(
          backgroundColor: colorTheme.backgroundColor,
          body: Center(
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
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: textStyle.fontsize_16,
                    color: colorTheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDictionaries,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      'Qwerty Learner - 词典选择',
                      style: TextStyle(
                        fontSize: textStyle.fontsize_20,
                        fontWeight: FontWeight.bold,
                        color: colorTheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    // 分类选择下拉菜单
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: _categorizedDictionaries.keys.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category == 'all' ? '全部' : category,
                            style: TextStyle(
                              color: colorTheme.onBackground,
                              fontSize: textStyle.fontsize_14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _onCategoryChanged(value);
                        }
                      },
                      underline: Container(),
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
    final currentDictionaries =
        _categorizedDictionaries[_selectedCategory] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择词典',
                style: TextStyle(
                  fontSize: textStyle.fontsize_18,
                  fontWeight: FontWeight.bold,
                  color: colorTheme.onBackground,
                ),
              ),
              Text(
                '${currentDictionaries.length} 个',
                style: TextStyle(
                  fontSize: textStyle.fontsize_14,
                  color: colorTheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentDictionaries.length,
              itemBuilder: (context, index) {
                final dictionary = currentDictionaries[index];
                final isSelected = _selectedDictionary?.id == dictionary.id;

                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected
                        ? colorTheme.primaryColor
                        : colorTheme.backgroundColor,
                    child: InkWell(
                      onTap: () => _onDictionarySelected(dictionary),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dictionary.name,
                              style: TextStyle(
                                fontSize: textStyle.fontsize_16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : colorTheme.onBackground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dictionary.description,
                              style: TextStyle(
                                fontSize: textStyle.fontsize_12,
                                color: isSelected
                                    ? Colors.white70
                                    : colorTheme.onBackground.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (dictionary.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: dictionary.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white24
                                          : colorTheme.primaryColor
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white70
                                            : colorTheme.primaryColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const Spacer(),
                            Text(
                              '${dictionary.length} 词',
                              style: TextStyle(
                                fontSize: textStyle.fontsize_12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white70
                                    : colorTheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDictionary?.name ?? '选择章节',
                style: TextStyle(
                  fontSize: textStyle.fontsize_18,
                  fontWeight: FontWeight.bold,
                  color: colorTheme.onBackground,
                ),
              ),
              if (_selectedDictionary != null)
                Text(
                  '${_chapters.length} 个章节',
                  style: TextStyle(
                    fontSize: textStyle.fontsize_14,
                    color: colorTheme.onBackground.withOpacity(0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDictionary == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: colorTheme.onBackground.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '请选择一个词典查看章节',
                          style: TextStyle(
                            fontSize: textStyle.fontsize_16,
                            color: colorTheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : _chapters.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = _chapters[index];
                          final isSelected =
                              _selectedChapter?['id'] == chapter['id'];

                          return Card(
                            elevation: isSelected ? 4 : 1,
                            color: isSelected
                                ? colorTheme.primaryColor
                                : colorTheme.backgroundColor,
                            child: InkWell(
                              onTap: () => _onChapterSelected(chapter),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        chapter['title'],
                                        style: TextStyle(
                                          fontSize: textStyle.fontsize_14,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : colorTheme.onBackground,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Flexible(
                                      child: Text(
                                        '${chapter['wordCount']} 词',
                                        style: TextStyle(
                                          fontSize: textStyle.fontsize_12,
                                          color: isSelected
                                              ? Colors.white70
                                              : colorTheme.onBackground
                                                  .withOpacity(0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedChapter != null ? _startPractice : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor:
                    colorTheme.onBackground.withOpacity(0.1),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                '开始练习',
                style: TextStyle(
                  fontSize: textStyle.fontsize_16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
              child: _buildContent(context, colorTheme, textStyle),
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
          Text(
            '词典分类',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildAccordionCategoryItem(
                    '全部', Icons.all_inclusive, colorTheme, textStyle),
                ..._categorizedDictionaries.keys
                    .where((key) => key != 'all')
                    .expand((category) => [
                          _buildAccordionCategoryItem(
                            category,
                            _getCategoryIcon(category),
                            colorTheme,
                            textStyle,
                          ),
                          if (_expandedCategories.contains(category))
                            ..._buildCategoryDictionaries(
                                category, colorTheme, textStyle),
                        ]),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              AppRouteNavigator.navigateTo(
                  context: context, routeName: AppRouteNames.typingTest);
            },
            child: Text(
              '每月练习',
              style: TextStyle(
                color: colorTheme.onBackground,
                fontSize: textStyle.fontsize_16,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAccordionCategoryItem(
      String title,
      IconData icon,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    final isExpanded = _expandedCategories.contains(title);
    final categoryKey = title.toLowerCase();
    final dictCount = _categorizedDictionaries[categoryKey]?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: colorTheme.primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorTheme.onBackground,
            fontSize: textStyle.fontsize_14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$dictCount 个词典',
          style: TextStyle(
            color: colorTheme.onBackground.withOpacity(0.6),
            fontSize: textStyle.fontsize_12,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: colorTheme.primaryColor,
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          safeSetState(() {
            if (expanded) {
              _expandedCategories.add(title);
            } else {
              _expandedCategories.remove(title);
            }
          });
        },
        children: _buildCategoryDictionaries(title, colorTheme, textStyle),
      ),
    );
  }

  List<Widget> _buildCategoryDictionaries(
      String category,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    final categoryKey = category.toLowerCase();
    final dictionaries = _categorizedDictionaries[categoryKey] ?? [];

    return dictionaries.map((dictionary) {
      final isSelected = _selectedDictionary?.id == dictionary.id;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          elevation: isSelected ? 3 : 1,
          color: isSelected ? colorTheme.primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              dictionary.name,
              style: TextStyle(
                color: isSelected
                    ? colorTheme.primaryColor
                    : colorTheme.onBackground,
                fontSize: textStyle.fontsize_14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dictionary.description,
                  style: TextStyle(
                    color: colorTheme.onBackground.withOpacity(0.7),
                    fontSize: textStyle.fontsize_12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dictionary.length} 词',
                  style: TextStyle(
                    color: colorTheme.onBackground.withOpacity(0.6),
                    fontSize: textStyle.fontsize_10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: colorTheme.primaryColor,
                  )
                : null,
            onTap: () {
              _onDictionarySelected(dictionary);
            },
          ),
        ),
      );
    }).toList();
  }
}
