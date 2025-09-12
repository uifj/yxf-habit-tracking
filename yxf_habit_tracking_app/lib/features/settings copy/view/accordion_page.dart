import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';

/// 手风琴页面 - 用于展示各种资源和指南
class AccordionPage extends StatefulWidget {
  final String selectedTab;
  final Map<String, List<Map<String, dynamic>>> sectionsData;

  const AccordionPage({
    super.key,
    required this.selectedTab,
    required this.sectionsData,
  });

  static Route<void> route({
    required String selectedTab,
    required Map<String, List<Map<String, dynamic>>> sectionsData,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => AccordionPage(
        selectedTab: selectedTab,
        sectionsData: sectionsData,
      ),
    );
  }

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends TencentCloudChatState<AccordionPage> {
  @override
  Widget defaultBuilder(BuildContext context) {
    final sections = widget.sectionsData[widget.selectedTab] ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.selectedTab),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: sections.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return _buildAccordionTile(section, context);
              },
            )
          : _buildEmptyState(context),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '该分类下暂时没有可用的资源',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个手风琴组件
  Widget _buildAccordionTile(
    Map<String, dynamic> section,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 16,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
            iconColor: Theme.of(context).colorScheme.primary,
            collapsedIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(section['category'] as String),
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              section['category'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              '${(section['items'] as List).length} 个资源',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            children: (section['items'] as List<Map<String, String>>)
                .map((item) => _buildListItem(item, context))
                .toList(),
          ),
        ),
      ),
    );
  }

  /// 构建列表项
  Widget _buildListItem(Map<String, String> item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.link,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          item['label'] as String,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: item['description'] != null
            ? Text(
                item['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap: () => _handleItemTap(item, context),
      ),
    );
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '学习资源':
        return Icons.school_outlined;
      case '生活服务':
        return Icons.home_outlined;
      case '校园指南':
        return Icons.map_outlined;
      case '就业指导':
        return Icons.work_outline;
      case '学术研究':
        return Icons.science_outlined;
      case '社团活动':
        return Icons.groups_outlined;
      case '图书馆':
        return Icons.library_books_outlined;
      case '体育健身':
        return Icons.fitness_center_outlined;
      case '心理健康':
        return Icons.psychology_outlined;
      case '技术支持':
        return Icons.support_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  /// 处理项目点击
  void _handleItemTap(Map<String, String> item, BuildContext context) {
    final url = item['url'];
    final label = item['label'];

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('链接地址无效'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 显示加载提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打开 $label...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    // TODO: 实现页面跳转逻辑
    // 这里可以根据实际需求跳转到WebView页面或其他页面
    // NavigationUtil.push(context, RoutePaths.pureView, arguments: {
    //   'url': url,
    //   'title': label,
    // });

    // 临时实现：显示详情对话框
    _showItemDetails(item, context);
  }

  /// 显示项目详情对话框
  void _showItemDetails(Map<String, String> item, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['label'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['description'] != null) ...[
              Text(
                '描述：',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(item['description'] as String),
              const SizedBox(height: 16),
            ],
            Text(
              '链接：',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              item['url'] as String,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实际打开链接
            },
            child: const Text('打开链接'),
          ),
        ],
      ),
    );
  }
}