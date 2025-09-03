import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/diff_bloc.dart';
import '../../domain/entities/git_commit_entity.dart';
import '../../domain/entities/git_diff_entity.dart';
import 'diff_view_page.dart';

/// 提交详情页面 - 显示单个提交的详细信息和差异
class CommitDetailPage extends StatefulWidget {
  final String repositoryPath;
  final GitCommitEntity commit;

  const CommitDetailPage({
    Key? key,
    required this.repositoryPath,
    required this.commit,
  }) : super(key: key);

  @override
  State<CommitDetailPage> createState() => _CommitDetailPageState();
}

class _CommitDetailPageState extends State<CommitDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadCommitDiff();
  }

  void _loadCommitDiff() {
    context.read<DiffBloc>().add(
          GetCommitDiffEvent(
            repositoryPath: widget.repositoryPath,
            commitSha: widget.commit.sha,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提交 ${widget.commit.shortSha}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyCommitSha(),
            tooltip: '复制SHA',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommitDiff,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 提交信息头部
          _buildCommitHeader(),
          const Divider(height: 1),
          // 文件差异列表
          Expanded(
            child: _buildDiffList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提交消息
          Text(
            widget.commit.message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // 提交信息
          _buildInfoRow('SHA', widget.commit.sha),
          const SizedBox(height: 8),
          _buildInfoRow('作者', widget.commit.author),
          const SizedBox(height: 8),
          _buildInfoRow('提交者', widget.commit.committer),
          const SizedBox(height: 8),
          _buildInfoRow('时间', _formatDate(widget.commit.date)),
          if (widget.commit.parents.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('父提交',
                widget.commit.parents.map((p) => p.substring(0, 8)).join(', ')),
          ],
          const SizedBox(height: 16),
          // 统计信息
          Row(
            children: [
              _buildStatChip(
                  '文件', '${widget.commit.changedFiles.length}', Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip(
                  '插入', '+${widget.commit.insertions}', Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('删除', '-${widget.commit.deletions}', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffList() {
    return BlocBuilder<DiffBloc, DiffState>(
      builder: (context, state) {
        if (state is DiffLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DiffError) {
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
                  '加载差异失败',
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
                  onPressed: _loadCommitDiff,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (state is CommitDiffLoaded) {
          final diffs = state.diffs;

          if (diffs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '没有文件更改',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '此提交没有修改任何文件',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: diffs.length,
            itemBuilder: (context, index) {
              final diff = diffs[index];
              return _buildDiffItem(diff);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDiffItem(GitDiffEntity diff) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _viewFileDiff(diff),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件路径和状态
              Row(
                children: [
                  // 状态图标
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getFileStatusColor(diff),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        _getFileStatusIcon(diff),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 文件路径
                  Expanded(
                    child: Text(
                      _getDisplayPath(diff),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  // 统计信息
                  if (diff.insertions > 0 || diff.deletions > 0) ...[
                    Text(
                      '+${diff.insertions}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-${diff.deletions}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              // 二进制文件提示
              if (diff.isBinaryFile) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '二进制文件',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getFileStatusColor(GitDiffEntity diff) {
    if (diff.isNewFile) return Colors.green;
    if (diff.isDeletedFile) return Colors.red;
    return Colors.blue;
  }

  String _getFileStatusIcon(GitDiffEntity diff) {
    if (diff.isNewFile) return '+';
    if (diff.isDeletedFile) return '-';
    return 'M';
  }

  String _getDisplayPath(GitDiffEntity diff) {
    if (diff.oldFilePath != null && diff.oldFilePath != diff.filePath) {
      return '${diff.oldFilePath} → ${diff.filePath}';
    }
    return diff.filePath;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyCommitSha() {
    Clipboard.setData(ClipboardData(text: widget.commit.sha));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SHA已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewFileDiff(GitDiffEntity diff) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiffViewPage(
          repositoryPath: widget.repositoryPath,
          filePath: diff.filePath,
          fromCommit: widget.commit.parents.isNotEmpty
              ? widget.commit.parents.first
              : null,
          toCommit: widget.commit.sha,
        ),
      ),
    );
  }
}
