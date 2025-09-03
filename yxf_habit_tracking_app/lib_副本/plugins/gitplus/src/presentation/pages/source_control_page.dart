import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/git_repository_bloc.dart';
import '../bloc/git_file_status_bloc.dart';
import '../bloc/commit_bloc.dart';
import '../../domain/entities/git_file_status_entity.dart';
import 'diff_view_page.dart';

/// 源码控制页面 - 类似于obsidian-git的Source Control View
class SourceControlPage extends StatefulWidget {
  final String repositoryPath;

  const SourceControlPage({
    Key? key,
    required this.repositoryPath,
  }) : super(key: key);

  @override
  State<SourceControlPage> createState() => _SourceControlPageState();
}

class _SourceControlPageState extends State<SourceControlPage> {
  final TextEditingController _commitMessageController =
      TextEditingController();
  final Set<String> _selectedFiles = <String>{};

  @override
  void initState() {
    super.initState();
    _refreshFileStatuses();
  }

  void _refreshFileStatuses() {
    context.read<GitFileStatusBloc>().add(
          GetFileStatusesEvent(widget.repositoryPath),
        );
  }

  @override
  void dispose() {
    _commitMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('源码控制'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '设置',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFileStatuses,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 提交消息输入区域
          _buildCommitMessageSection(),
          const Divider(height: 1),
          // 文件状态列表
          Expanded(
            child: _buildFileStatusList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitMessageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _commitMessageController,
            decoration: const InputDecoration(
              hintText: '输入提交消息...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _canCommit() ? _commitChanges : null,
                  icon: const Icon(Icons.check),
                  label: const Text('提交'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _canCommit() ? _commitAndSync : null,
                  icon: const Icon(Icons.sync),
                  label: const Text('提交并同步'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileStatusList() {
    return BlocBuilder<GitFileStatusBloc, GitFileStatusState>(
      builder: (context, state) {
        if (state is GitFileStatusLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GitFileStatusError) {
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
                  '加载文件状态失败',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _refreshFileStatuses,
                      child: const Text('重试'),
                    ),
                    const SizedBox(width: 12),
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

        if (state is GitFileStatusLoaded) {
          if (state.fileStatuses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '工作目录干净',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '没有需要提交的更改',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final stagedFiles =
              state.fileStatuses.where((f) => f.isStaged).toList();
          final unstagedFiles =
              state.fileStatuses.where((f) => !f.isStaged).toList();

          return ListView(
            children: [
              if (stagedFiles.isNotEmpty)
                ..._buildFileSection('已暂存的更改', stagedFiles, true),
              if (unstagedFiles.isNotEmpty)
                ..._buildFileSection('未暂存的更改', unstagedFiles, false),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<Widget> _buildFileSection(
    String title,
    List<GitFileStatusEntity> files,
    bool isStaged,
  ) {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Text(
              '${files.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isStaged ? Icons.remove : Icons.add),
              onPressed: () => isStaged ? _unstageAllFiles() : _stageAllFiles(),
              tooltip: isStaged ? '取消暂存所有文件' : '暂存所有文件',
              iconSize: 20,
            ),
          ],
        ),
      ),
      ...files.map((file) => _buildFileItem(file)),
    ];
  }

  Widget _buildFileItem(GitFileStatusEntity file) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: _getStatusColor(file.status),
        child: Text(
          file.statusIcon,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        file.displayPath,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: file.insertions > 0 || file.deletions > 0
          ? Text(
              '+${file.insertions} -${file.deletions}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _viewFileDiff(file),
            tooltip: '查看差异',
            iconSize: 20,
          ),
          IconButton(
            icon: Icon(file.isStaged ? Icons.remove : Icons.add),
            onPressed: () =>
                file.isStaged ? _unstageFile(file.path) : _stageFile(file.path),
            tooltip: file.isStaged ? '取消暂存' : '暂存',
            iconSize: 20,
          ),
          if (!file.isStaged)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => _discardFileChanges(file.path),
              tooltip: '丢弃更改',
              iconSize: 20,
            ),
        ],
      ),
      onTap: () => _viewFileDiff(file),
    );
  }

  Color _getStatusColor(GitFileStatusType status) {
    switch (status) {
      case GitFileStatusType.added:
        return Colors.green;
      case GitFileStatusType.modified:
        return Colors.blue;
      case GitFileStatusType.deleted:
        return Colors.red;
      case GitFileStatusType.renamed:
        return Colors.orange;
      case GitFileStatusType.copied:
        return Colors.purple;
      case GitFileStatusType.untracked:
        return Colors.grey;
      case GitFileStatusType.ignored:
        return Colors.grey[400]!;
      case GitFileStatusType.typeChanged:
        return Colors.amber;
    }
  }

  bool _canCommit() {
    return _commitMessageController.text.trim().isNotEmpty;
  }

  void _commitChanges() {
    final message = _commitMessageController.text.trim();
    if (message.isEmpty) return;

    context.read<CommitBloc>().add(
          CommitChangesEvent(
            repoPath: widget.repositoryPath,
            message: message,
          ),
        );

    _commitMessageController.clear();
  }

  void _commitAndSync() {
    final message = _commitMessageController.text.trim();
    if (message.isEmpty) return;

    // 先提交，然后推送
    context.read<CommitBloc>().add(
          CommitChangesEvent(
            repoPath: widget.repositoryPath,
            message: message,
          ),
        );

    // TODO: 添加推送逻辑
    _commitMessageController.clear();
  }

  void _stageFile(String filePath) {
    context.read<GitFileStatusBloc>().add(
          StageFileEvent(widget.repositoryPath, filePath),
        );
  }

  void _unstageFile(String filePath) {
    context.read<GitFileStatusBloc>().add(
          UnstageFileEvent(widget.repositoryPath, filePath),
        );
  }

  void _stageAllFiles() {
    context.read<GitFileStatusBloc>().add(
          StageAllFilesEvent(widget.repositoryPath),
        );
  }

  void _unstageAllFiles() {
    context.read<GitFileStatusBloc>().add(
          UnstageAllFilesEvent(widget.repositoryPath),
        );
  }

  void _discardFileChanges(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认丢弃更改'),
        content: Text('确定要丢弃文件 "$filePath" 的所有更改吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GitFileStatusBloc>().add(
                    DiscardFileChangesEvent(widget.repositoryPath, filePath),
                  );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _viewFileDiff(GitFileStatusEntity file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiffViewPage(
          repositoryPath: widget.repositoryPath,
          filePath: file.path,
          fileStatus: file,
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('用户配置'),
              subtitle: const Text('设置Git用户名和邮箱'),
              onTap: () {
                Navigator.pop(context);
                _showUserConfig();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('系统诊断'),
              subtitle: const Text('检查Git环境和仓库状态'),
              onTap: () {
                Navigator.pop(context);
                _showDiagnostics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              subtitle: const Text('查看版本信息'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserConfig() {
    // TODO: 实现用户配置对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户配置功能即将推出')),
    );
  }

  void _showDiagnostics() {
    // TODO: 实现系统诊断页面导航
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('系统诊断功能即将推出')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Git Plus',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.source, size: 48),
      children: [
        const Text('一个功能强大的Git客户端插件，为Flutter应用提供完整的版本控制功能。'),
      ],
    );
  }
}
