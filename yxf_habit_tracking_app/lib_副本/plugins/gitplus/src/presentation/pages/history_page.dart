import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/commit_bloc.dart';
import '../../domain/entities/git_commit_entity.dart';
import 'commit_detail_page.dart';
import 'diff_view_page.dart';

/// 历史记录页面 - 类似于obsidian-git的History View
class HistoryPage extends StatefulWidget {
  final String repositoryPath;
  final String? branch;

  const HistoryPage({
    Key? key,
    required this.repositoryPath,
    this.branch,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<GitCommitEntity> _commits = [];
  final List<GitCommitEntity> _filteredCommits = [];
  bool _isLoadingMore = false;
  bool _hasMoreCommits = true;
  bool _isSearching = false;
  String _searchQuery = '';
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadCommitHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCommits();
    }
  }

  void _loadCommitHistory() {
    context.read<CommitBloc>().add(
          GetCommitHistoryEvent(
            repoPath: widget.repositoryPath,
            limit: _pageSize,
            offset: 0,
          ),
        );
  }

  void _loadMoreCommits() {
    if (_isLoadingMore || !_hasMoreCommits) return;

    setState(() {
      _isLoadingMore = true;
    });

    context.read<CommitBloc>().add(
          GetCommitHistoryEvent(
            repoPath: widget.repositoryPath,
            limit: _pageSize,
            offset: _commits.length,
          ),
        );
  }

  void _refreshHistory() {
    _commits.clear();
    _filteredCommits.clear();
    _hasMoreCommits = true;
    _searchQuery = '';
    _searchController.clear();
    _loadCommitHistory();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _filteredCommits.clear();
      }
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '搜索提交消息、作者或SHA...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCommits.clear();
      } else {
        _filteredCommits.clear();
        _filteredCommits.addAll(
          _commits.where((commit) =>
              commit.message.toLowerCase().contains(_searchQuery) ||
              commit.author.toLowerCase().contains(_searchQuery) ||
              commit.sha.toLowerCase().contains(_searchQuery)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch != null ? '历史记录 (${widget.branch})' : '历史记录'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? '关闭搜索' : '搜索',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          Expanded(
            child: BlocListener<CommitBloc, CommitState>(
              listener: (context, state) {
                if (state is CommitHistoryLoaded) {
                  setState(() {
                    if (_commits.isEmpty) {
                      _commits.addAll(state.commits);
                    } else {
                      // 加载更多时，避免重复添加
                      final newCommits = state.commits
                          .where(
                              (commit) => !_commits.any((c) => c.sha == commit.sha))
                          .toList();
                      _commits.addAll(newCommits);
                      if (newCommits.length < _pageSize) {
                        _hasMoreCommits = false;
                      }
                    }
                    _isLoadingMore = false;
                  });
                } else if (state is CommitError) {
                  setState(() {
                    _isLoadingMore = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: BlocBuilder<CommitBloc, CommitState>(
                builder: (context, state) {
                  if (state is CommitLoading && _commits.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CommitError && _commits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '加载历史记录失败',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshHistory,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_commits.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '没有提交记录',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '仓库中还没有任何提交',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final commitsToShow = _searchQuery.isEmpty ? _commits : _filteredCommits;
                  
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: commitsToShow.length + (_hasMoreCommits && _searchQuery.isEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == commitsToShow.length) {
                        // 加载更多指示器
                        return Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: _isLoadingMore
                              ? const CircularProgressIndicator()
                              : const Text(
                                  '已加载全部提交',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        );
                      }

                      final commit = commitsToShow[index];
                      final isLatest = _searchQuery.isEmpty && index == 0;
                      return _buildCommitItem(commit, isLatest);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitItem(GitCommitEntity commit, bool isLatest) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _viewCommitDetail(commit),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 提交信息头部
              Row(
                children: [
                  // 提交SHA
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      commit.shortSha,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 最新标签
                  if (isLatest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'HEAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // 提交时间
                  Text(
                    _formatCommitDate(commit.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 提交消息
              Text(
                commit.message.split('\n').first,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 作者信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      commit.author
                          .split(' ')
                          .map((name) => name[0])
                          .take(2)
                          .join(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commit.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // 统计信息
                  if (commit.insertions > 0 || commit.deletions > 0) ...[
                    Text(
                      '+${commit.insertions}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-${commit.deletions}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCommitDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _viewCommitDetail(GitCommitEntity commit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommitDetailPage(
          repositoryPath: widget.repositoryPath,
          commit: commit,
        ),
      ),
    );
  }
}
