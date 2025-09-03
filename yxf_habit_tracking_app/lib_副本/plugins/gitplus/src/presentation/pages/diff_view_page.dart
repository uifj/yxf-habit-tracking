import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/diff_bloc.dart';
import '../../domain/entities/git_file_status_entity.dart';
import '../../domain/entities/git_diff_entity.dart';

/// 差异视图页面 - 类似于obsidian-git的Diff View
class DiffViewPage extends StatefulWidget {
  final String repositoryPath;
  final String filePath;
  final GitFileStatusEntity? fileStatus;
  final String? fromCommit;
  final String? toCommit;
  final bool staged;

  const DiffViewPage({
    Key? key,
    required this.repositoryPath,
    required this.filePath,
    this.fileStatus,
    this.fromCommit,
    this.toCommit,
    this.staged = false,
  }) : super(key: key);

  @override
  State<DiffViewPage> createState() => _DiffViewPageState();
}

class _DiffViewPageState extends State<DiffViewPage> {
  @override
  void initState() {
    super.initState();
    _loadDiff();
  }

  void _loadDiff() {
    context.read<DiffBloc>().add(
          GetFileDiffEvent(
            repositoryPath: widget.repositoryPath,
            filePath: widget.filePath,
            fromCommit: widget.fromCommit,
            toCommit: widget.toCommit,
            staged: widget.staged,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiff,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 文件信息头部
          _buildFileHeader(),
          const Divider(height: 1),
          // 差异内容
          Expanded(
            child: _buildDiffContent(),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    if (widget.fromCommit != null && widget.toCommit != null) {
      return '提交差异';
    }
    return widget.staged ? '暂存区差异' : '工作区差异';
  }

  Widget _buildFileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.fileStatus != null) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _getStatusColor(widget.fileStatus!.status),
                  child: Text(
                    widget.fileStatus!.statusIcon,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.filePath,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (widget.fileStatus != null &&
              (widget.fileStatus!.insertions > 0 ||
                  widget.fileStatus!.deletions > 0)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.fileStatus!.insertions > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${widget.fileStatus!.insertions}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.fileStatus!.deletions > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${widget.fileStatus!.deletions}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiffContent() {
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
                  onPressed: _loadDiff,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (state is DiffLoaded) {
          final diff = state.diff;

          if (diff.hunks.isEmpty) {
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
                    '没有差异',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '文件内容相同',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: diff.hunks.length,
            itemBuilder: (context, index) {
              final hunk = diff.hunks[index];
              return _buildDiffHunk(hunk);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDiffHunk(GitDiffHunkEntity hunk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hunk 头部
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue.withOpacity(0.1),
          child: Text(
            hunk.header,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Hunk 内容行
        ...hunk.lines.map((line) => _buildDiffLine(line)),
      ],
    );
  }

  Widget _buildDiffLine(GitDiffLineEntity line) {
    Color? backgroundColor;
    Color? textColor;
    String prefix = ' ';

    switch (line.type) {
      case GitDiffLineType.added:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[800];
        prefix = '+';
        break;
      case GitDiffLineType.deleted:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[800];
        prefix = '-';
        break;
      case GitDiffLineType.context:
        backgroundColor = null;
        textColor = null;
        prefix = ' ';
        break;
      case GitDiffLineType.hunkHeader:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[800];
        prefix = '@';
        break;
      case GitDiffLineType.header:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[800];
        prefix = '#';
        break;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行号
          if (line.oldLineNumber != null || line.newLineNumber != null) ...[
            SizedBox(
              width: 60,
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      line.oldLineNumber?.toString() ?? '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 25,
                    child: Text(
                      line.newLineNumber?.toString() ?? '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ],
          // 前缀符号
          Text(
            prefix,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // 内容
          Expanded(
            child: Text(
              line.content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
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
}
