import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:git/git.dart';
import '../models/git_repository_model.dart';
import '../models/git_commit_model.dart';
import '../models/git_file_status_model.dart';
import '../models/git_diff_model.dart';
import '../models/git_config_model.dart';
import 'git_datasource.dart';

/// Git数据源实现类
class GitDataSourceImpl implements GitDataSource {
  
  /// 检查Git是否可用
  Future<bool> _isGitAvailable() async {
    try {
      // 尝试多种方式查找Git
      final gitPaths = [
        'git', // 系统PATH中的git
        '/usr/bin/git', // 系统默认路径
        '/usr/local/bin/git', // Homebrew Intel路径
        '/opt/homebrew/bin/git', // Homebrew Apple Silicon路径
      ];
      
      for (final gitPath in gitPaths) {
        try {
          final versionResult = await Process.run(gitPath, ['--version']);
          if (versionResult.exitCode == 0) {
            // 找到可用的Git，保存路径供后续使用
            _gitExecutablePath = gitPath;
            return true;
          }
        } catch (e) {
          // 继续尝试下一个路径
          continue;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Git可执行文件路径
  String _gitExecutablePath = 'git';
  
  /// 检查目录权限
  Future<bool> _hasDirectoryPermissions(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        // 尝试创建目录
        await dir.create(recursive: true);
      }
      
      // 测试写权限
      final testFile = File(path.join(dirPath, '.git_test_${DateTime.now().millisecondsSinceEpoch}'));
      await testFile.writeAsString('test');
      await testFile.delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 安全的Git命令执行
  Future<ProcessResult> _runGitSafely(List<String> args, {String? workingDirectory}) async {
    try {
      // 首先检查Git是否可用
      if (!await _isGitAvailable()) {
        throw Exception('Git is not available or not properly installed');
      }
      
      // 检查工作目录权限
      if (workingDirectory != null && !await _hasDirectoryPermissions(workingDirectory)) {
        throw Exception('Insufficient permissions for directory: $workingDirectory');
      }
      
      return await Process.run(
        _gitExecutablePath,
        args,
        workingDirectory: workingDirectory,
        runInShell: true,
      );
    } catch (e) {
      throw Exception('Git command failed: $e');
    }
  }

  @override
  Future<GitRepositoryModel> initRepository(String repoPath,
      {String? initialBranch}) async {
    try {
      // 检查目录是否存在，如果不存在则创建
      final dir = Directory(repoPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // 检查权限
      if (!await _hasDirectoryPermissions(repoPath)) {
        throw Exception('Insufficient permissions to initialize repository at: $repoPath');
      }
      
      // 使用安全的Git命令初始化
      final args = ['init'];
      if (initialBranch != null) {
        args.addAll(['--initial-branch', initialBranch]);
      }
      args.add(repoPath);
      
      final result = await _runGitSafely(args);
      if (result.exitCode != 0) {
        throw Exception('Git init failed: ${result.stderr}');
      }
      
      // 使用GitDir获取仓库信息
      final gitDir = await GitDir.fromExisting(repoPath);
      return await _buildRepositoryModel(gitDir);
    } catch (e) {
      throw Exception('Failed to initialize repository: $e');
    }
  }

  @override
  Future<bool> isGitRepository(String repoPath) async {
    try {
      return await GitDir.isGitDir(repoPath);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<GitRepositoryModel> getRepository(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      return await _buildRepositoryModel(gitDir);
    } catch (e) {
      throw Exception('Failed to get repository: $e');
    }
  }

  @override
  Future<GitRepositoryModel> getRepositoryStatus(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      return await _buildRepositoryModel(gitDir);
    } catch (e) {
      throw Exception('Failed to get repository status: $e');
    }
  }

  @override
  Future<List<GitFileStatusModel>> getFileStatuses(String repoPath) async {
    try {
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }
      
      final result = await _runGitSafely(['status', '--porcelain'], workingDirectory: repoPath);
      if (result.exitCode != 0) {
        throw Exception('Failed to get file statuses: ${result.stderr}');
      }
      
      final output = result.stdout as String;
      return _parseFileStatuses(output);
    } catch (e) {
      throw Exception('Failed to get file statuses: $e');
    }
  }

  @override
  Future<void> stageFile(String repoPath, String filePath) async {
    try {
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }
      
      final result = await _runGitSafely(['add', filePath], workingDirectory: repoPath);
      if (result.exitCode != 0) {
        throw Exception('Failed to stage file: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Failed to stage file: $e');
    }
  }

  @override
  Future<void> unstageFile(String repoPath, String filePath) async {
    try {
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }
      
      final result = await _runGitSafely(['reset', 'HEAD', filePath], workingDirectory: repoPath);
      if (result.exitCode != 0) {
        throw Exception('Failed to unstage file: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Failed to unstage file: $e');
    }
  }

  @override
  Future<void> stageAllFiles(String repoPath) async {
    try {
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }
      
      final result = await _runGitSafely(['add', '.'], workingDirectory: repoPath);
      if (result.exitCode != 0) {
        throw Exception('Failed to stage all files: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Failed to stage all files: $e');
    }
  }

  @override
  Future<void> unstageAllFiles(String repoPath) async {
    try {
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }
      
      final result = await _runGitSafely(['reset', 'HEAD'], workingDirectory: repoPath);
      if (result.exitCode != 0) {
        throw Exception('Failed to unstage all files: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Failed to unstage all files: $e');
    }
  }

  @override
  Future<String> commit(String repoPath, String message,
      {List<String>? files}) async {
    try {
      // 检查仓库是否存在
      if (!await isGitRepository(repoPath)) {
        throw Exception('Not a git repository: $repoPath');
      }

      // 如果指定了文件，先添加到暂存区
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          final addResult = await _runGitSafely(['add', file], workingDirectory: repoPath);
          if (addResult.exitCode != 0) {
            throw Exception('Failed to stage file $file: ${addResult.stderr}');
          }
        }
      }

      // 执行提交
      final commitResult = await _runGitSafely(['commit', '-m', message], workingDirectory: repoPath);
      if (commitResult.exitCode != 0) {
        throw Exception('Commit failed: ${commitResult.stderr}');
      }

      // 获取最新提交的SHA
      final shaResult = await _runGitSafely(['rev-parse', 'HEAD'], workingDirectory: repoPath);
      if (shaResult.exitCode != 0) {
        throw Exception('Failed to get commit SHA: ${shaResult.stderr}');
      }
      
      return (shaResult.stdout as String).trim();
    } catch (e) {
      throw Exception('Failed to commit: $e');
    }
  }

  @override
  Future<void> push(String repoPath, {String? remote, String? branch}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['push'];

      if (remote != null) {
        args.add(remote);
        if (branch != null) {
          args.add(branch);
        }
      }

      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to push: $e');
    }
  }

  @override
  Future<void> pull(String repoPath, {String? remote, String? branch}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['pull'];

      if (remote != null) {
        args.add(remote);
        if (branch != null) {
          args.add(branch);
        }
      }

      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to pull: $e');
    }
  }

  @override
  Future<List<GitCommitModel>> getCommitHistory(
    String repoPath, {
    String? branch,
    int? limit,
    int? skip,
  }) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = [
        'log',
        '--pretty=format:%H|%s|%an|%ae|%ad|%P',
        '--date=iso'
      ];

      if (branch != null) {
        args.add(branch);
      }

      if (limit != null) {
        args.addAll(['-n', limit.toString()]);
      }

      if (skip != null) {
        args.addAll(['--skip', skip.toString()]);
      }

      final result = await gitDir.runCommand(args);
      final output = result.stdout as String;

      return _parseCommitHistory(output);
    } catch (e) {
      throw Exception('Failed to get commit history: $e');
    }
  }

  @override
  Future<GitCommitModel> getCommit(String repoPath, String sha) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final commit = await gitDir.commitFromRevision(sha);

      // 获取提交统计信息
      final statsResult =
          await gitDir.runCommand(['show', '--stat', '--format=', sha]);
      final statsOutput = statsResult.stdout as String;

      final stats = _parseCommitStats(statsOutput);

      return GitCommitModel(
        sha: sha,
        message: commit.message,
        author: commit.author,
        committer: commit.committer,
        date: _parseCommitDate(commit.author),
        parents: commit.parents,
        changedFiles: stats['files'] ?? [],
        insertions: stats['insertions'] ?? 0,
        deletions: stats['deletions'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to get commit: $e');
    }
  }

  @override
  Future<GitDiffModel> getFileDiff(
    String repoPath,
    String filePath, {
    String? fromCommit,
    String? toCommit,
    bool staged = false,
  }) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['diff'];

      if (staged) {
        args.add('--cached');
      }

      if (fromCommit != null) {
        if (toCommit != null) {
          args.add('$fromCommit..$toCommit');
        } else {
          args.add(fromCommit);
        }
      }

      args.add(filePath);

      final result = await gitDir.runCommand(args);
      final output = result.stdout as String;

      return _parseDiff(output, filePath);
    } catch (e) {
      throw Exception('Failed to get file diff: $e');
    }
  }

  @override
  Future<List<GitDiffModel>> getCommitDiff(String repoPath, String sha) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final result = await gitDir.runCommand(['show', '--format=', sha]);
      final output = result.stdout as String;

      return _parseMultipleDiffs(output);
    } catch (e) {
      throw Exception('Failed to get commit diff: $e');
    }
  }

  @override
  Future<List<String>> getBranches(String repoPath,
      {bool includeRemote = false}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final branches = await gitDir.branches();

      final result = branches.map((b) => b.branchName).toList();

      if (includeRemote) {
        final remoteResult = await gitDir.runCommand(['branch', '-r']);
        final remoteOutput = remoteResult.stdout as String;
        final remoteBranches = remoteOutput
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();
        result.addAll(remoteBranches);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get branches: $e');
    }
  }

  @override
  Future<String?> getCurrentBranch(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final branch = await gitDir.currentBranch();
      return branch.branchName;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createBranch(String repoPath, String branchName,
      {String? fromBranch}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['checkout', '-b', branchName];

      if (fromBranch != null) {
        args.add(fromBranch);
      }

      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  @override
  Future<void> checkoutBranch(String repoPath, String branchName) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['checkout', branchName]);
    } catch (e) {
      throw Exception('Failed to checkout branch: $e');
    }
  }

  @override
  Future<void> deleteBranch(String repoPath, String branchName,
      {bool force = false}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['branch', force ? '-D' : '-d', branchName];
      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  @override
  Future<Map<String, String>> getRemotes(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final result = await gitDir.runCommand(['remote', '-v']);
      final output = result.stdout as String;

      final remotes = <String, String>{};
      for (final line in output.split('\n')) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final url = parts[1].split(' ')[0].trim();
          remotes[name] = url;
        }
      }

      return remotes;
    } catch (e) {
      throw Exception('Failed to get remotes: $e');
    }
  }

  @override
  Future<void> addRemote(String repoPath, String name, String url) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['remote', 'add', name, url]);
    } catch (e) {
      throw Exception('Failed to add remote: $e');
    }
  }

  @override
  Future<void> removeRemote(String repoPath, String name) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['remote', 'remove', name]);
    } catch (e) {
      throw Exception('Failed to remove remote: $e');
    }
  }

  @override
  Future<List<String>> getTags(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final tags = await gitDir.tags();
      return await tags.map((tag) => tag.tag).toList();
    } catch (e) {
      throw Exception('Failed to get tags: $e');
    }
  }

  @override
  Future<void> createTag(String repoPath, String tagName,
      {String? message}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['tag'];

      if (message != null) {
        args.addAll(['-a', tagName, '-m', message]);
      } else {
        args.add(tagName);
      }

      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  @override
  Future<void> deleteTag(String repoPath, String tagName) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['tag', '-d', tagName]);
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }

  @override
  Future<void> discardFileChanges(String repoPath, String filePath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['checkout', '--', filePath]);
    } catch (e) {
      throw Exception('Failed to discard file changes: $e');
    }
  }

  @override
  Future<void> discardAllChanges(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['reset', '--hard', 'HEAD']);
      await gitDir.runCommand(['clean', '-fd']);
    } catch (e) {
      throw Exception('Failed to discard all changes: $e');
    }
  }

  @override
  Future<List<String>> getSubmodules(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final result =
          await gitDir.runCommand(['submodule', 'status'], throwOnError: false);

      if (result.exitCode != 0) {
        return [];
      }

      final output = result.stdout as String;
      return output
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim().split(' ')[1])
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> initSubmodules(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['submodule', 'init']);
    } catch (e) {
      throw Exception('Failed to init submodules: $e');
    }
  }

  @override
  Future<void> updateSubmodules(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['submodule', 'update', '--recursive']);
    } catch (e) {
      throw Exception('Failed to update submodules: $e');
    }
  }

  @override
  Future<GitRepositoryModel> cloneRepository(
    String url,
    String localPath, {
    String? branch,
    bool recursive = false,
  }) async {
    try {
      final args = ['clone'];

      if (branch != null) {
        args.addAll(['-b', branch]);
      }

      if (recursive) {
        args.add('--recursive');
      }

      args.addAll([url, localPath]);

      await _runGitSafely(args);

      return await getRepository(localPath);
    } catch (e) {
      throw Exception('Failed to clone repository: $e');
    }
  }

  @override
  Future<GitConfigModel> getConfig(String repoPath) async {
    // 这里应该从配置文件或数据库中读取配置
    // 暂时返回默认配置
    return GitConfigModel.defaultConfig();
  }

  @override
  Future<void> saveConfig(String repoPath, GitConfigModel config) async {
    // 这里应该将配置保存到配置文件或数据库中
    // 暂时不实现
  }

  @override
  Future<bool> isWorkingTreeClean(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      return await gitDir.isWorkingTreeClean();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getCommitCount(String repoPath, {String? branch}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      return await gitDir.commitCount(branch ?? 'HEAD');
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<GitCommitModel?> getLastCommit(String repoPath,
      {String? branch}) async {
    try {
      final commits =
          await getCommitHistory(repoPath, branch: branch, limit: 1);
      return commits.isNotEmpty ? commits.first : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetToCommit(String repoPath, String sha,
      {bool hard = false}) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final args = ['reset'];

      if (hard) {
        args.add('--hard');
      }

      args.add(sha);

      await gitDir.runCommand(args);
    } catch (e) {
      throw Exception('Failed to reset to commit: $e');
    }
  }

  @override
  Future<void> mergeBranch(String repoPath, String branchName) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['merge', branchName]);
    } catch (e) {
      throw Exception('Failed to merge branch: $e');
    }
  }

  @override
  Future<void> rebaseBranch(String repoPath, String branchName) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['rebase', branchName]);
    } catch (e) {
      throw Exception('Failed to rebase branch: $e');
    }
  }

  @override
  Future<List<String>> getConflictFiles(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      final result =
          await gitDir.runCommand(['diff', '--name-only', '--diff-filter=U']);
      final output = result.stdout as String;

      return output
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> resolveConflict(String repoPath, String filePath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['add', filePath]);
    } catch (e) {
      throw Exception('Failed to resolve conflict: $e');
    }
  }

  @override
  Future<void> abortMerge(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['merge', '--abort']);
    } catch (e) {
      throw Exception('Failed to abort merge: $e');
    }
  }

  @override
  Future<void> continueMerge(String repoPath) async {
    try {
      final gitDir = await GitDir.fromExisting(repoPath);
      await gitDir.runCommand(['merge', '--continue']);
    } catch (e) {
      throw Exception('Failed to continue merge: $e');
    }
  }

  // 私有辅助方法
  Future<GitRepositoryModel> _buildRepositoryModel(GitDir gitDir) async {
    final repoName = path.basename(gitDir.path);
    final isClean = await gitDir.isWorkingTreeClean();
    final commitCount = await gitDir.commitCount();

    String? currentBranch;
    try {
      final branch = await gitDir.currentBranch();
      currentBranch = branch.branchName;
    } catch (e) {
      // 可能是新仓库，没有提交
    }

    final branches = await gitDir.branches();
    final branchNames = branches.map((b) => b.branchName).toList();

    final remotes = await getRemotes(gitDir.path);

    GitCommitModel? lastCommit;
    try {
      lastCommit = await getLastCommit(gitDir.path);
    } catch (e) {
      // 可能是新仓库，没有提交
    }

    return GitRepositoryModel(
      path: gitDir.path,
      name: repoName,
      currentBranch: currentBranch,
      isClean: isClean,
      commitCount: commitCount,
      branches: branchNames,
      remotes: remotes.keys.toList(),
      lastCommitDate: lastCommit?.date,
      lastCommitMessage: lastCommit?.message,
      lastCommitAuthor: lastCommit?.author,
    );
  }

  List<GitFileStatusModel> _parseFileStatuses(String output) {
    final files = <GitFileStatusModel>[];

    for (final line in output.split('\n')) {
      if (line.trim().isEmpty) continue;

      final statusCode = line.substring(0, 2);
      final filePath = line.substring(3);

      GitFileStatusType status;
      bool isStaged = false;

      switch (statusCode[0]) {
        case 'A':
          status = GitFileStatusType.added;
          isStaged = true;
          break;
        case 'M':
          status = GitFileStatusType.modified;
          isStaged = true;
          break;
        case 'D':
          status = GitFileStatusType.deleted;
          isStaged = true;
          break;
        case 'R':
          status = GitFileStatusType.renamed;
          isStaged = true;
          break;
        case 'C':
          status = GitFileStatusType.copied;
          isStaged = true;
          break;
        case '?':
          status = GitFileStatusType.untracked;
          break;
        case '!':
          status = GitFileStatusType.ignored;
          break;
        default:
          if (statusCode[1] == 'M') {
            status = GitFileStatusType.modified;
          } else if (statusCode[1] == 'D') {
            status = GitFileStatusType.deleted;
          } else {
            status = GitFileStatusType.untracked;
          }
      }

      files.add(GitFileStatusModel(
        path: filePath,
        status: status,
        isStaged: isStaged,
        insertions: 0, // 需要额外的命令来获取
        deletions: 0, // 需要额外的命令来获取
      ));
    }

    return files;
  }

  List<GitCommitModel> _parseCommitHistory(String output) {
    final commits = <GitCommitModel>[];

    for (final line in output.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');
      if (parts.length < 6) continue;

      final sha = parts[0];
      final message = parts[1];
      final author = parts[2];
      final email = parts[3];
      final dateStr = parts[4];
      final parentsStr = parts[5];

      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final parents =
          parentsStr.trim().isEmpty ? <String>[] : parentsStr.split(' ');

      commits.add(GitCommitModel(
        sha: sha,
        message: message,
        author: '$author <$email>',
        committer: '$author <$email>',
        date: date,
        parents: parents,
        changedFiles: const [], // 需要额外的命令来获取
        insertions: 0, // 需要额外的命令来获取
        deletions: 0, // 需要额外的命令来获取
      ));
    }

    return commits;
  }

  DateTime _parseCommitDate(String authorLine) {
    // 解析类似 "Author Name <email@example.com> 1234567890 +0800" 的格式
    final regex = RegExp(r'(\d+)\s+([+-]\d{4})$');
    final match = regex.firstMatch(authorLine);

    if (match != null) {
      final timestamp = int.tryParse(match.group(1)!);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> _parseCommitStats(String output) {
    final files = <String>[];
    int insertions = 0;
    int deletions = 0;

    for (final line in output.split('\n')) {
      if (line.trim().isEmpty) continue;

      if (line.contains('|')) {
        final parts = line.split('|');
        if (parts.isNotEmpty) {
          files.add(parts[0].trim());
        }
      }

      if (line.contains('insertion') || line.contains('deletion')) {
        final regex = RegExp(r'(\d+)\s+insertion');
        final insertionMatch = regex.firstMatch(line);
        if (insertionMatch != null) {
          insertions = int.tryParse(insertionMatch.group(1)!) ?? 0;
        }

        final deletionRegex = RegExp(r'(\d+)\s+deletion');
        final deletionMatch = deletionRegex.firstMatch(line);
        if (deletionMatch != null) {
          deletions = int.tryParse(deletionMatch.group(1)!) ?? 0;
        }
      }
    }

    return {
      'files': files,
      'insertions': insertions,
      'deletions': deletions,
    };
  }

  GitDiffModel _parseDiff(String output, String filePath) {
    // 简化的差异解析实现
    final hunks = <GitDiffHunkModel>[];
    int insertions = 0;
    int deletions = 0;

    final lines = output.split('\n');
    for (final line in lines) {
      if (line.startsWith('+') && !line.startsWith('+++')) {
        insertions++;
      } else if (line.startsWith('-') && !line.startsWith('---')) {
        deletions++;
      }
    }

    return GitDiffModel(
      filePath: filePath,
      isNewFile: output.contains('new file mode'),
      isDeletedFile: output.contains('deleted file mode'),
      isBinaryFile: output.contains('Binary files'),
      insertions: insertions,
      deletions: deletions,
      hunks: hunks,
      rawDiff: output,
    );
  }

  List<GitDiffModel> _parseMultipleDiffs(String output) {
    // 简化实现，实际应该解析多个文件的差异
    return [];
  }
}
