import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:url_launcher/url_launcher.dart';

/// 资源类型枚举
enum ResourceType {
  library('图书馆', Icons.library_books_outlined),
  academic('学术资源', Icons.school_outlined),
  service('校园服务', Icons.room_service_outlined),
  life('校园生活', Icons.home_outlined),
  employment('就业指导', Icons.work_outline);

  const ResourceType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 资源项模型
class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String? url;
  final IconData icon;
  final Color? color;
  final List<ResourceSubItem>? subItems;

  const ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    this.url,
    this.icon = Icons.link,
    this.color,
    this.subItems,
  });
}

/// 资源子项模型
class ResourceSubItem {
  final String title;
  final String description;
  final String? url;
  final IconData icon;

  const ResourceSubItem({
    required this.title,
    required this.description,
    this.url,
    this.icon = Icons.open_in_new,
  });
}

/// 资源页面
class ResourcesPage extends StatefulWidget {
  final ResourceType selectedType;

  const ResourcesPage({
    super.key,
    this.selectedType = ResourceType.library,
  });

  static Route<void> route({ResourceType? selectedType}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          ResourcesPage(selectedType: selectedType ?? ResourceType.library),
    );
  }

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends TencentCloudChatState<ResourcesPage> {
  late ResourceType _selectedType;
  final Map<ResourceType, List<ResourceItem>> _resourcesData =
      _generateResourcesData();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_selectedType.label),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildTypeSelector(),
        ),
      ),
      body: _buildResourcesList(),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ResourceType.values.map((type) {
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

  /// 构建资源列表
  Widget _buildResourcesList() {
    final resources = _resourcesData[_selectedType] ?? [];

    if (resources.isEmpty) {
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
              '暂无${_selectedType.label}',
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
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _buildResourceCard(resource);
      },
    );
  }

  /// 构建资源卡片
  Widget _buildResourceCard(ResourceItem resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: resource.subItems != null && resource.subItems!.isNotEmpty
          ? _buildExpandableCard(resource)
          : _buildSimpleCard(resource),
    );
  }

  /// 构建可展开卡片
  Widget _buildExpandableCard(ResourceItem resource) {
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (resource.color ?? Theme.of(context).colorScheme.primary)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          resource.icon,
          color: resource.color ?? Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        resource.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        resource.description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      children: resource.subItems!.map((subItem) {
        return ListTile(
          leading: Icon(
            subItem.icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(subItem.title),
          subtitle: Text(subItem.description),
          trailing: subItem.url != null
              ? const Icon(Icons.open_in_new, size: 16)
              : null,
          onTap: subItem.url != null ? () => _launchUrl(subItem.url!) : null,
        );
      }).toList(),
    );
  }

  /// 构建简单卡片
  Widget _buildSimpleCard(ResourceItem resource) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (resource.color ?? Theme.of(context).colorScheme.primary)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          resource.icon,
          color: resource.color ?? Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        resource.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        resource.description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing:
          resource.url != null ? const Icon(Icons.open_in_new, size: 16) : null,
      onTap: resource.url != null
          ? () => _launchUrl(resource.url!)
          : () => _showResourceDetail(resource),
    );
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

  /// 显示资源详情
  void _showResourceDetail(ResourceItem resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                      resource.icon,
                      color: resource.color ??
                          Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resource.title,
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
                        resource.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (resource.url != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _launchUrl(resource.url!);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('访问链接'),
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

  /// 生成资源数据
  static Map<ResourceType, List<ResourceItem>> _generateResourcesData() {
    return {
      ResourceType.library: [
        const ResourceItem(
          id: 'lib_1',
          title: '图书馆主页',
          description: '湖南师范大学图书馆官方网站',
          url: 'https://lib.hunnu.edu.cn',
          icon: Icons.library_books_outlined,
          color: Colors.blue,
        ),
        const ResourceItem(
          id: 'lib_2',
          title: '数字资源',
          description: '电子图书、期刊、数据库等数字资源',
          icon: Icons.computer_outlined,
          color: Colors.green,
          subItems: [
            ResourceSubItem(
              title: '中国知网',
              description: '学术期刊、学位论文数据库',
              url: 'https://www.cnki.net',
            ),
            ResourceSubItem(
              title: '万方数据',
              description: '学术期刊、会议论文数据库',
              url: 'https://www.wanfangdata.com.cn',
            ),
            ResourceSubItem(
              title: '超星电子图书',
              description: '电子图书阅读平台',
              url: 'https://www.chaoxing.com',
            ),
          ],
        ),
        const ResourceItem(
          id: 'lib_3',
          title: '座位预约',
          description: '图书馆座位在线预约系统',
          url: 'https://seat.hunnu.edu.cn',
          icon: Icons.event_seat_outlined,
          color: Colors.orange,
        ),
      ],
      ResourceType.academic: [
        const ResourceItem(
          id: 'aca_1',
          title: '教务系统',
          description: '课程安排、成绩查询、选课系统',
          url: 'https://jwc.hunnu.edu.cn',
          icon: Icons.school_outlined,
          color: Colors.purple,
        ),
        const ResourceItem(
          id: 'aca_2',
          title: '学术资源',
          description: '学术会议、期刊投稿、科研项目',
          icon: Icons.science_outlined,
          color: Colors.teal,
          subItems: [
            ResourceSubItem(
              title: '科研管理系统',
              description: '科研项目申报与管理',
            ),
            ResourceSubItem(
              title: '学术会议信息',
              description: '国内外学术会议信息',
            ),
            ResourceSubItem(
              title: '期刊投稿指南',
              description: '核心期刊投稿指导',
            ),
          ],
        ),
        const ResourceItem(
          id: 'aca_3',
          title: '在线课程',
          description: '网络教学平台、慕课资源',
          url: 'https://course.hunnu.edu.cn',
          icon: Icons.play_lesson_outlined,
          color: Colors.indigo,
        ),
      ],
      ResourceType.service: [
        const ResourceItem(
          id: 'ser_1',
          title: '校园卡服务',
          description: '校园卡充值、挂失、消费查询',
          icon: Icons.credit_card_outlined,
          color: Colors.red,
          subItems: [
            ResourceSubItem(
              title: '在线充值',
              description: '校园卡在线充值服务',
            ),
            ResourceSubItem(
              title: '消费查询',
              description: '校园卡消费记录查询',
            ),
            ResourceSubItem(
              title: '挂失补办',
              description: '校园卡挂失与补办',
            ),
          ],
        ),
        const ResourceItem(
          id: 'ser_2',
          title: '网络服务',
          description: '校园网络、邮箱、VPN服务',
          url: 'https://net.hunnu.edu.cn',
          icon: Icons.wifi_outlined,
          color: Colors.cyan,
        ),
        const ResourceItem(
          id: 'ser_3',
          title: '后勤服务',
          description: '宿舍管理、维修报修、餐饮服务',
          icon: Icons.build_outlined,
          color: Colors.brown,
        ),
      ],
      ResourceType.life: [
        const ResourceItem(
          id: 'life_1',
          title: '校园地图',
          description: '校园建筑分布、路线导航',
          icon: Icons.map_outlined,
          color: Colors.green,
        ),
        const ResourceItem(
          id: 'life_2',
          title: '社团活动',
          description: '学生社团、文体活动信息',
          icon: Icons.groups_outlined,
          color: Colors.pink,
        ),
        const ResourceItem(
          id: 'life_3',
          title: '校园资讯',
          description: '校园新闻、通知公告',
          url: 'https://news.hunnu.edu.cn',
          icon: Icons.newspaper_outlined,
          color: Colors.amber,
        ),
      ],
      ResourceType.employment: [
        const ResourceItem(
          id: 'emp_1',
          title: '就业指导中心',
          description: '就业政策、职业规划、求职技巧',
          url: 'https://career.hunnu.edu.cn',
          icon: Icons.work_outline,
          color: Colors.deepOrange,
        ),
        const ResourceItem(
          id: 'emp_2',
          title: '招聘信息',
          description: '企业招聘、实习岗位信息',
          icon: Icons.business_outlined,
          color: Colors.lightBlue,
        ),
        const ResourceItem(
          id: 'emp_3',
          title: '创业支持',
          description: '创业政策、孵化器、创业大赛',
          icon: Icons.lightbulb_outline,
          color: Colors.yellow,
        ),
      ],
    };
  }
}
