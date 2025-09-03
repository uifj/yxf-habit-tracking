import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Git状态和诊断页面
class GitStatusPage extends StatefulWidget {
  final String? repositoryPath;

  const GitStatusPage({Key? key, this.repositoryPath}) : super(key: key);

  @override
  State<GitStatusPage> createState() => _GitStatusPageState();
}

class _GitStatusPageState extends State<GitStatusPage> {
  bool _isLoading = false;
  Map<String, dynamic> _diagnosticResults = {};

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    final results = <String, dynamic>{};

    // 检查Git是否安装
    results['git_installed'] = await _checkGitInstalled();
    
    // 检查Git版本
    results['git_version'] = await _getGitVersion();
    
    // 检查Git路径
    results['git_path'] = await _getGitPath();
    
    // 检查目录权限
    if (widget.repositoryPath != null) {
      results['directory_permissions'] = await _checkDirectoryPermissions(widget.repositoryPath!);
      results['is_git_repo'] = await _checkIsGitRepository(widget.repositoryPath!);
    }
    
    // 检查系统信息
    results['platform'] = Platform.operatingSystem;
    results['environment'] = Platform.environment;

    setState(() {
      _diagnosticResults = results;
      _isLoading = false;
    });
  }

  Future<bool> _checkGitInstalled() async {
    try {
      // 尝试多种Git路径
      final gitPaths = [
        'git',
        '/usr/bin/git',
        '/usr/local/bin/git',
        '/opt/homebrew/bin/git',
      ];
      
      for (final gitPath in gitPaths) {
        try {
          final result = await Process.run(gitPath, ['--version']);
          if (result.exitCode == 0) {
            return true;
          }
        } catch (e) {
          continue;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getGitVersion() async {
    try {
      // 尝试多种Git路径
      final gitPaths = [
        'git',
        '/usr/bin/git',
        '/usr/local/bin/git',
        '/opt/homebrew/bin/git',
      ];
      
      for (final gitPath in gitPaths) {
        try {
          final result = await Process.run(gitPath, ['--version']);
          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Future<String?> _getGitPath() async {
    try {
      final result = await Process.run('which', ['git']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Future<bool> _checkDirectoryPermissions(String path) async {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // 测试写权限
      final testFile = File('$path/.git_test_${DateTime.now().millisecondsSinceEpoch}');
      await testFile.writeAsString('test');
      await testFile.delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkIsGitRepository(String path) async {
    try {
      final result = await Process.run(
        'git',
        ['rev-parse', '--git-dir'],
        workingDirectory: path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git 状态诊断'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDiagnosticResults(),
    );
  }

  Widget _buildDiagnosticResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Git 安装状态', [
          _buildResultItem(
            'Git 已安装',
            _diagnosticResults['git_installed'] == true,
            _diagnosticResults['git_installed'] == true ? '✓ Git 已正确安装' : '✗ Git 未安装或不可访问',
          ),
          if (_diagnosticResults['git_version'] != null)
            _buildInfoItem('Git 版本', _diagnosticResults['git_version']),
          if (_diagnosticResults['git_path'] != null)
            _buildInfoItem('Git 路径', _diagnosticResults['git_path']),
        ]),
        
        if (widget.repositoryPath != null) ...[
          const SizedBox(height: 24),
          _buildSection('仓库状态', [
            _buildInfoItem('仓库路径', widget.repositoryPath!),
            _buildResultItem(
              '目录权限',
              _diagnosticResults['directory_permissions'] == true,
              _diagnosticResults['directory_permissions'] == true 
                  ? '✓ 目录权限正常' 
                  : '✗ 目录权限不足',
            ),
            _buildResultItem(
              'Git 仓库',
              _diagnosticResults['is_git_repo'] == true,
              _diagnosticResults['is_git_repo'] == true 
                  ? '✓ 这是一个有效的 Git 仓库' 
                  : '✗ 这不是一个 Git 仓库',
            ),
          ]),
        ],
        
        const SizedBox(height: 24),
        _buildSection('系统信息', [
          _buildInfoItem('操作系统', _diagnosticResults['platform'] ?? 'Unknown'),
          if (_diagnosticResults['environment'] != null)
            _buildInfoItem('PATH', _diagnosticResults['environment']['PATH'] ?? 'Not available'),
        ]),
        
        const SizedBox(height: 24),
        _buildTroubleshootingSection(),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, bool isSuccess, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '故障排除建议',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_diagnosticResults['git_installed'] != true) ...[
              _buildTroubleshootingItem(
                '安装 Git',
                '请访问 https://git-scm.com/downloads 下载并安装 Git',
              ),
            ],
            if (_diagnosticResults['directory_permissions'] == false) ...[
              _buildTroubleshootingItem(
                '权限问题',
                '请确保应用有权限访问指定目录，或选择其他目录',
              ),
            ],
            if (_diagnosticResults['git_path']?.contains('/opt/homebrew/bin/git') == true) ...[
              _buildTroubleshootingItem(
                'Homebrew Git 权限',
                '尝试运行: sudo xattr -r -d com.apple.quarantine /opt/homebrew/bin/git',
              ),
            ],
            _buildTroubleshootingItem(
              '重新启动应用',
              '如果刚刚安装了 Git，请重新启动应用程序',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}