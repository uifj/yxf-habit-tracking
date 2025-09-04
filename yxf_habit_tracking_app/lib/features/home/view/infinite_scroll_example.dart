import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 无限滚动功能示例
///
/// 展示如何在Flutter中实现高性能的无限滚动列表
/// 适用于大量数据的分页加载场景
class InfiniteScrollExample extends StatefulWidget {
  const InfiniteScrollExample({super.key});

  @override
  State<InfiniteScrollExample> createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 数据列表
  List<String> _items = [];

  // 分页状态
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
    // 加载初始数据
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听器 - 核心逻辑
  void _onScroll() {
    // 当滚动到接近底部时触发加载更多
    if (_isBottom && !_isLoadingMore && !_hasReachedMax) {
      _loadMoreData();
    }
  }

  /// 检查是否滚动到底部
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // 当滚动到90%位置时开始预加载
    return currentScroll >= (maxScroll * 0.9);
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasReachedMax = false;
      _items.clear();
    });

    try {
      final newItems = await _fetchData(page: 0, pageSize: _pageSize);

      if (mounted) {
        setState(() {
          _items = newItems;
          _currentPage = 0;
          _hasReachedMax = newItems.length < _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('加载数据失败: $e');
      }
    }
  }

  /// 加载更多数据
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || _hasReachedMax) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newItems = await _fetchData(page: nextPage, pageSize: _pageSize);

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _currentPage = nextPage;
          _hasReachedMax = newItems.length < _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        _showErrorSnackBar('加载更多数据失败: $e');
      }
    }
  }

  /// 模拟数据获取API
  Future<List<String>> _fetchData(
      {required int page, required int pageSize}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟数据
    final startIndex = page * pageSize;
    final endIndex = startIndex + pageSize;

    // 模拟总共有100条数据
    const totalItems = 100;
    if (startIndex >= totalItems) {
      return [];
    }

    final actualEndIndex = endIndex > totalItems ? totalItems : endIndex;

    return List.generate(
      actualEndIndex - startIndex,
      (index) => '数据项 ${startIndex + index + 1}',
    );
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: '重试',
          onPressed: () {
            if (_items.isEmpty) {
              _loadInitialData();
            } else {
              _loadMoreData();
            }
          },
        ),
      ),
    );
  }

  /// 构建底部加载指示器
  Widget _buildBottomLoader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: _isLoadingMore
          ? const CupertinoActivityIndicator()
          : _hasReachedMax
              ? Text(
                  '已加载全部数据',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                )
              : const SizedBox.shrink(),
    );
  }

  /// 构建列表项
  Widget _buildListItem(String item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(item),
        subtitle: Text('索引: $index'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了: $item')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('无限滚动示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 16),
            Text('正在加载数据...'),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _hasReachedMax ? _items.length : _items.length + 1,
          itemBuilder: (context, index) {
            // 如果是最后一项且未达到最大值，显示加载指示器
            if (index >= _items.length) {
              return _buildBottomLoader();
            }

            return _buildListItem(_items[index], index);
          },
        ),
      ),
    );
  }
}

/// 无限滚动最佳实践说明：
///
/// 1. **性能优化**：
///    - 使用ListView.builder进行懒加载
///    - 合理设置预加载阈值（90%位置）
///    - 避免在滚动过程中进行重复请求
///
/// 2. **用户体验**：
///    - 提供下拉刷新功能
///    - 显示加载状态指示器
///    - 错误处理和重试机制
///    - 到达底部时的友好提示
///
/// 3. **状态管理**：
///    - 正确管理加载状态
///    - 防止重复请求
///    - 处理页面销毁时的资源清理
///
/// 4. **数据处理**：
///    - 合理的分页大小设置
///    - 数据去重和缓存策略
///    - 网络错误的优雅处理
///
/// 5. **可扩展性**：
///    - 支持不同的数据源
///    - 可配置的加载参数
///    - 易于集成到现有项目
