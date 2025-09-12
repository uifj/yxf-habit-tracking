import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:url_launcher/url_launcher.dart';

/// 就业指导类型枚举
enum EmploymentGuideType {
  career('职业规划', Icons.timeline_outlined),
  resume('简历制作', Icons.description_outlined),
  interview('面试技巧', Icons.record_voice_over_outlined),
  policy('就业政策', Icons.policy_outlined),
  internship('实习指导', Icons.work_outline),
  entrepreneurship('创业指导', Icons.lightbulb_outline);

  const EmploymentGuideType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 就业指导项模型
class EmploymentGuideItem {
  final String id;
  final String title;
  final String description;
  final String? content;
  final String? url;
  final IconData icon;
  final Color? color;
  final List<String>? tags;
  final DateTime? publishDate;
  final int? readCount;

  const EmploymentGuideItem({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    this.url,
    this.icon = Icons.article_outlined,
    this.color,
    this.tags,
    this.publishDate,
    this.readCount,
  });
}

/// 就业指导页面
class EmploymentGuidePage extends StatefulWidget {
  final EmploymentGuideType selectedType;

  const EmploymentGuidePage({
    super.key,
    this.selectedType = EmploymentGuideType.career,
  });

  static Route<void> route({EmploymentGuideType? selectedType}) {
    return MaterialPageRoute<void>(
      builder: (_) => EmploymentGuidePage(
        selectedType: selectedType ?? EmploymentGuideType.career,
      ),
    );
  }

  @override
  State<EmploymentGuidePage> createState() => _EmploymentGuidePageState();
}

class _EmploymentGuidePageState
    extends TencentCloudChatState<EmploymentGuidePage> {
  late EmploymentGuideType _selectedType;
  final Map<EmploymentGuideType, List<EmploymentGuideItem>> _guideData =
      _generateGuideData();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTypeSelector(),
          Expanded(child: _buildGuideList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('就业指导'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          onPressed: () => _showFilterDialog(),
          icon: const Icon(Icons.filter_list),
          tooltip: '筛选',
        ),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索就业指导内容...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: EmploymentGuideType.values.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(type.label),
                  ],
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建指导列表
  Widget _buildGuideList() {
    final guides = _getFilteredGuides();

    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType.icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? '未找到相关内容'
                  : '暂无${_selectedType.label}内容',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        return _buildGuideCard(guide);
      },
    );
  }

  /// 构建指导卡片
  Widget _buildGuideCard(EmploymentGuideItem guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openGuideDetail(guide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          (guide.color ?? Theme.of(context).colorScheme.primary)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      guide.icon,
                      color:
                          guide.color ?? Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (guide.publishDate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(guide.publishDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (guide.readCount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${guide.readCount}次阅读',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                guide.description,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (guide.tags?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: guide.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建浮动操作按钮
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(),
      tooltip: '快速操作',
      child: const Icon(Icons.add),
    );
  }

  /// 获取过滤后的指导列表
  List<EmploymentGuideItem> _getFilteredGuides() {
    final guides = _guideData[_selectedType] ?? [];

    if (_searchQuery.isEmpty) {
      return guides;
    }

    return guides.where((guide) {
      return guide.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guide.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (guide.tags?.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())) ??
              false);
    }).toList();
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  /// 打开指导详情
  void _openGuideDetail(EmploymentGuideItem guide) {
    if (guide.url != null) {
      _launchUrl(guide.url!);
    } else {
      _showGuideDetail(guide);
    }
  }

  /// 启动URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开链接')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打开链接失败')),
        );
      }
    }
  }

  /// 显示指导详情
  void _showGuideDetail(EmploymentGuideItem guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      guide.icon,
                      color:
                          guide.color ?? Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (guide.content != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          guide.content!,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ],
                      if (guide.tags?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        const Text(
                          '相关标签',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: guide.tags!.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选选项'),
        content: const Text('筛选功能正在开发中，敬请期待。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示快速操作
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text('收藏指导'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('收藏功能正在开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享内容'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分享功能正在开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('意见反馈'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('反馈功能正在开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 生成指导数据
  static Map<EmploymentGuideType, List<EmploymentGuideItem>>
      _generateGuideData() {
    return {
      EmploymentGuideType.career: [
        EmploymentGuideItem(
          id: 'career_1',
          title: '大学生职业生涯规划指南',
          description: '帮助大学生明确职业目标，制定合理的职业发展规划',
          content: '职业生涯规划是一个持续的过程，需要不断地自我认知、环境分析和目标调整...',
          icon: Icons.timeline_outlined,
          color: Colors.blue,
          tags: ['职业规划', '自我认知', '目标设定'],
          publishDate: DateTime.now().subtract(const Duration(days: 2)),
          readCount: 1250,
        ),
        EmploymentGuideItem(
          id: 'career_2',
          title: 'SWOT分析在职业规划中的应用',
          description: '运用SWOT分析法，全面评估个人优势劣势和外部机会威胁',
          content: 'SWOT分析是一种战略规划工具，可以帮助个人更好地了解自己...',
          icon: Icons.analytics_outlined,
          color: Colors.green,
          tags: ['SWOT分析', '自我评估', '战略规划'],
          publishDate: DateTime.now().subtract(const Duration(days: 5)),
          readCount: 890,
        ),
      ],
      EmploymentGuideType.resume: [
        EmploymentGuideItem(
          id: 'resume_1',
          title: '简历制作完全指南',
          description: '从零开始，教你制作一份出色的个人简历',
          content: '一份好的简历是求职成功的第一步，需要突出个人优势和匹配度...',
          icon: Icons.description_outlined,
          color: Colors.orange,
          tags: ['简历制作', '求职技巧', '个人品牌'],
          publishDate: DateTime.now().subtract(const Duration(days: 1)),
          readCount: 2100,
        ),
        EmploymentGuideItem(
          id: 'resume_2',
          title: '简历常见错误及避免方法',
          description: '盘点简历制作中的常见误区，提供改进建议',
          content: '许多求职者在简历制作中会犯一些常见错误，影响求职效果...',
          icon: Icons.error_outline,
          color: Colors.red,
          tags: ['简历优化', '错误避免', '求职建议'],
          publishDate: DateTime.now().subtract(const Duration(days: 3)),
          readCount: 1560,
        ),
      ],
      EmploymentGuideType.interview: [
        EmploymentGuideItem(
          id: 'interview_1',
          title: '面试技巧与注意事项',
          description: '掌握面试技巧，提高面试成功率',
          content: '面试是求职过程中的关键环节，需要充分准备和良好表现...',
          icon: Icons.record_voice_over_outlined,
          color: Colors.purple,
          tags: ['面试技巧', '沟通能力', '职场礼仪'],
          publishDate: DateTime.now().subtract(const Duration(days: 4)),
          readCount: 1800,
        ),
      ],
      EmploymentGuideType.policy: [
        EmploymentGuideItem(
          id: 'policy_1',
          title: '2024年大学生就业政策解读',
          description: '详细解读最新的大学生就业扶持政策',
          content: '国家出台了多项政策支持大学生就业创业，包括税收优惠、补贴政策等...',
          icon: Icons.policy_outlined,
          color: Colors.teal,
          tags: ['就业政策', '政策解读', '扶持措施'],
          publishDate: DateTime.now().subtract(const Duration(days: 7)),
          readCount: 980,
        ),
      ],
      EmploymentGuideType.internship: [
        EmploymentGuideItem(
          id: 'internship_1',
          title: '实习生存指南',
          description: '实习期间如何快速适应职场环境，提升专业能力',
          content: '实习是从学生向职场人转变的重要阶段，需要积极学习和适应...',
          icon: Icons.work_outline,
          color: Colors.indigo,
          tags: ['实习指导', '职场适应', '能力提升'],
          publishDate: DateTime.now().subtract(const Duration(days: 6)),
          readCount: 1320,
        ),
      ],
      EmploymentGuideType.entrepreneurship: [
        EmploymentGuideItem(
          id: 'entrepreneurship_1',
          title: '大学生创业入门指南',
          description: '从创业想法到实际行动，全面指导大学生创业',
          content: '创业需要勇气和智慧，更需要科学的方法和充分的准备...',
          icon: Icons.lightbulb_outline,
          color: Colors.amber,
          tags: ['创业指导', '商业计划', '风险管理'],
          publishDate: DateTime.now().subtract(const Duration(days: 8)),
          readCount: 750,
        ),
      ],
    };
  }
}
