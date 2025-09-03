import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/git_repository_bloc.dart';
import '../bloc/git_file_status_bloc.dart';
import '../bloc/commit_bloc.dart';
import '../bloc/diff_bloc.dart';
import '../../domain/repositories/git_repository.dart';
import 'source_control_page.dart';
import 'history_page.dart';
import 'git_status_page.dart';
import '../widgets/git_user_config_dialog.dart';
import 'package:flutter/services.dart';

/// Git主页面 - 类似obsidian-git的主界面，提供源码控制和历史记录功能
class GitMainPage extends StatefulWidget {
  final String repositoryPath;

  const GitMainPage({
    Key? key,
    required this.repositoryPath,
  }) : super(key: key);

  @override
  State<GitMainPage> createState() => _GitMainPageState();
}

class _GitMainPageState extends State<GitMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String? _currentBranch;
  bool _hasUncommittedChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    _checkRepository();
    _loadBranchInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkRepository() {
    context.read<GitRepositoryBloc>().add(
          CheckIsGitRepositoryEvent(widget.repositoryPath),
        );
  }

  void _loadBranchInfo() async {
    try {
      final repository = context.read<GitRepository>();
      final branch = await repository.getCurrentBranch(widget.repositoryPath);
      final status = await repository.getFileStatuses(widget.repositoryPath);
      setState(() {
        _currentBranch = branch;
        _hasUncommittedChanges = status.isNotEmpty;
      });
    } catch (e) {
      // 忽略错误，可能还不是Git仓库
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GitFileStatusBloc>(
          create: (context) => GitFileStatusBloc(
            context.read<GitRepository>(),
          ),
        ),
        BlocProvider<CommitBloc>(
          create: (context) => CommitBloc(
            context.read<GitRepository>(),
          ),
        ),
        BlocProvider<DiffBloc>(
          create: (context) => DiffBloc(
            context.read<GitRepository>(),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Git Plus'),
              if (_currentBranch != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_tree,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentBranch!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (_hasUncommittedChanges) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.source),
                text: '源码控制',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: '历史记录',
              ),
            ],
          ),
          actions: [
            if (_currentBranch != null)
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncRepository,
                tooltip: '同步',
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'branch',
                  child: ListTile(
                    leading: Icon(Icons.account_tree),
                    title: Text('分支管理'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('设置'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'diagnostics',
                  child: ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('系统诊断'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocListener<GitRepositoryBloc, GitRepositoryState>(
          listener: (context, state) {
            if (state is GitRepositoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: BlocBuilder<GitRepositoryBloc, GitRepositoryState>(
            builder: (context, state) {
              if (state is GitRepositoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GitRepositoryError) {
                return _buildErrorView(state.message);
              }

              if (state is GitRepositoryIsGitRepo && !state.isGitRepo) {
                return _buildNotGitRepoView();
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  SourceControlPage(repositoryPath: widget.repositoryPath),
                  HistoryPage(repositoryPath: widget.repositoryPath),
                ],
              );
            },
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildErrorView(String message) {
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
            'Git操作失败',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _checkRepository,
                child: const Text('重试'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _showDiagnostics,
                child: const Text('诊断'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotGitRepoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '不是Git仓库',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            '当前目录不是Git仓库\n请选择一个Git仓库目录或初始化新仓库',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _initRepository,
                child: const Text('初始化仓库'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _selectRepository,
                child: const Text('选择仓库'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 0) {
      // 源码控制页面显示快速提交按钮
      return FloatingActionButton(
        onPressed: _quickCommit,
        tooltip: '快速提交',
        child: const Icon(Icons.commit),
      );
    } else if (_currentIndex == 1) {
      // 历史记录页面显示刷新按钮
      return FloatingActionButton(
        onPressed: _refreshHistory,
        tooltip: '刷新历史',
        child: const Icon(Icons.refresh),
      );
    }
    return null;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'branch':
        _showBranchManager();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'diagnostics':
        _showDiagnostics();
        break;
    }
  }

  void _syncRepository() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('正在同步...'),
            ],
          ),
        ),
      );
      
      // TODO: 实现实际的同步逻辑
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('同步完成'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadBranchInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('同步失败: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showBranchManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => _buildBranchSheet(scrollController),
      ),
    );
  }

  Widget _buildBranchSheet(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_tree),
                const SizedBox(width: 8),
                Text(
                  '分支管理',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createBranch,
                  tooltip: '新建分支',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                if (_currentBranch != null)
                  ListTile(
                    leading: const Icon(Icons.radio_button_checked, color: Colors.green),
                    title: Text(_currentBranch!),
                    subtitle: const Text('当前分支'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) => _handleBranchAction(action, _currentBranch!),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('重命名'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('删除'),
                        ),
                      ],
                    ),
                  ),
                // TODO: 显示其他分支
                ListTile(
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: const Text('develop'),
                  onTap: () => _switchBranch('develop'),
                ),
                ListTile(
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: const Text('feature/new-ui'),
                  onTap: () => _switchBranch('feature/new-ui'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createBranch() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => _buildCreateBranchDialog(),
    );
  }

  Widget _buildCreateBranchDialog() {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text('新建分支'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: '分支名称',
          hintText: '输入新分支名称',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              Navigator.pop(context);
              _createNewBranch(controller.text);
            }
          },
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _createNewBranch(String branchName) {
    // TODO: 实现创建分支逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('创建分支: $branchName')),
    );
  }

  void _switchBranch(String branchName) {
    Navigator.pop(context);
    // TODO: 实现切换分支逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('切换到分支: $branchName')),
    );
  }

  void _handleBranchAction(String action, String branchName) {
    switch (action) {
      case 'rename':
        _renameBranch(branchName);
        break;
      case 'delete':
        _deleteBranch(branchName);
        break;
    }
  }

  void _renameBranch(String branchName) {
    // TODO: 实现重命名分支逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('重命名分支: $branchName')),
    );
  }

  void _deleteBranch(String branchName) {
    // TODO: 实现删除分支逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('删除分支: $branchName')),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Git设置',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('用户配置'),
            subtitle: const Text('设置Git用户名和邮箱'),
            onTap: _showUserConfig,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('仓库配置'),
            subtitle: const Text('查看和修改仓库配置'),
            onTap: _showRepoConfig,
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('系统诊断'),
            subtitle: const Text('检查Git安装和权限状态'),
            onTap: () {
              Navigator.pop(context);
              _showDiagnostics();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: const Text('Git Plus v1.0.0'),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  void _initRepository() {
    context.read<GitRepositoryBloc>().add(
          InitRepositoryEvent(widget.repositoryPath),
        );
  }

  void _selectRepository() {
    // TODO: 实现文件夹选择器
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('文件夹选择功能待实现'),
      ),
    );
  }

  void _quickCommit() {
    // 切换到源码控制页面并触发快速提交
    if (_currentIndex != 0) {
      _tabController.animateTo(0);
    }
    // TODO: 触发源码控制页面的快速提交功能
  }

  void _refreshHistory() {
    // 刷新历史记录
    context.read<CommitBloc>().add(
          GetCommitHistoryEvent(
            repoPath: widget.repositoryPath,
            limit: 50,
          ),
        );
  }

  void _showUserConfig() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => GitUserConfigDialog(
        repositoryPath: widget.repositoryPath,
        isGlobal: false,
      ),
    );
  }

  void _showRepoConfig() {
    Navigator.pop(context);
    // TODO: 显示仓库配置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('仓库配置功能待实现'),
      ),
    );
  }

  void _showAbout() {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'Git Plus',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.source, size: 48),
      children: [
        const Text('一个功能强大的Git客户端，灵感来自obsidian-git插件。'),
        const SizedBox(height: 16),
        const Text('功能特性：'),
        const Text('• 源码控制管理'),
        const Text('• 提交历史查看'),
        const Text('• 文件差异对比'),
        const Text('• 分支管理'),
      ],
    );
  }

  void _showDiagnostics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GitStatusPage(
          repositoryPath: widget.repositoryPath,
        ),
      ),
    );
  }
}
