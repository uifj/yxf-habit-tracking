import '../../domain/entities/git_repository_entity.dart';
import '../../domain/entities/git_file_status_entity.dart' as entity;
import '../../domain/entities/git_commit_entity.dart';
import '../../domain/entities/git_diff_entity.dart';
import '../../domain/entities/git_config_entity.dart';
import '../../domain/repositories/git_repository.dart';
import '../datasources/git_datasource.dart';
// import '../models/git_repository_model.dart';
import '../models/git_file_status_model.dart' as model;
import '../models/git_commit_model.dart';
import '../models/git_diff_model.dart' as diffModel;
import '../models/git_config_model.dart';

/// Git仓库实现类
class GitRepositoryImpl implements GitRepository {
  final GitDataSource _dataSource;

  GitRepositoryImpl(this._dataSource);

  @override
  Future<GitRepositoryEntity> initRepository(String path,
      {String? initialBranch}) async {
    final model =
        await _dataSource.initRepository(path, initialBranch: initialBranch);
    return GitRepositoryEntity(
      path: model.path,
      name: model.name,
      currentBranch: model.currentBranch,
      isClean: model.isClean,
      commitCount: model.commitCount,
      branches: model.branches,
      remotes: model.remotes,
      lastCommitDate: model.lastCommitDate,
      lastCommitMessage: model.lastCommitMessage,
      lastCommitAuthor: model.lastCommitAuthor,
    );
  }

  @override
  Future<GitRepositoryEntity> cloneRepository(
    String url,
    String localPath, {
    String? branch,
    bool recursive = false,
  }) async {
    final model = await _dataSource.cloneRepository(
      url,
      localPath,
      branch: branch,
      recursive: recursive,
    );
    return GitRepositoryEntity(
      path: model.path,
      name: model.name,
      currentBranch: model.currentBranch,
      isClean: model.isClean,
      commitCount: model.commitCount,
      branches: model.branches,
      remotes: model.remotes,
      lastCommitDate: model.lastCommitDate,
      lastCommitMessage: model.lastCommitMessage,
      lastCommitAuthor: model.lastCommitAuthor,
    );
  }

  @override
  Future<GitRepositoryEntity> getRepository(String path) async {
    final model = await _dataSource.getRepository(path);
    return GitRepositoryEntity(
      path: model.path,
      name: model.name,
      currentBranch: model.currentBranch,
      isClean: model.isClean,
      commitCount: model.commitCount,
      branches: model.branches,
      remotes: model.remotes,
      lastCommitDate: model.lastCommitDate,
      lastCommitMessage: model.lastCommitMessage,
      lastCommitAuthor: model.lastCommitAuthor,
    );
  }

  @override
  Future<GitRepositoryEntity> getRepositoryStatus(String path) async {
    final model = await _dataSource.getRepositoryStatus(path);
    return GitRepositoryEntity(
      path: model.path,
      name: model.name,
      currentBranch: model.currentBranch,
      isClean: model.isClean,
      commitCount: model.commitCount,
      branches: model.branches,
      remotes: model.remotes,
      lastCommitDate: model.lastCommitDate,
      lastCommitMessage: model.lastCommitMessage,
      lastCommitAuthor: model.lastCommitAuthor,
    );
  }

  @override
  Future<bool> isRepository(String path) async {
    return await _dataSource.isGitRepository(path);
  }

  @override
  Future<List<entity.GitFileStatusEntity>> getFileStatuses(
      String repoPath) async {
    final models = await _dataSource.getFileStatuses(repoPath);
    return models.map((model) => _mapFileStatusModelToEntity(model)).toList();
  }

  entity.GitFileStatusEntity _mapFileStatusModelToEntity(
      model.GitFileStatusModel modelData) {
    return entity.GitFileStatusEntity(
      path: modelData.path,
      oldPath: modelData.oldPath,
      status: _mapFileStatusType(modelData.status),
      isStaged: modelData.isStaged,
      diff: modelData.diff,
      insertions: modelData.insertions,
      deletions: modelData.deletions,
    );
  }

  entity.GitFileStatusType _mapFileStatusType(
      model.GitFileStatusType modelType) {
    switch (modelType) {
      case model.GitFileStatusType.untracked:
        return entity.GitFileStatusType.untracked;
      case model.GitFileStatusType.modified:
        return entity.GitFileStatusType.modified;
      case model.GitFileStatusType.added:
        return entity.GitFileStatusType.added;
      case model.GitFileStatusType.deleted:
        return entity.GitFileStatusType.deleted;
      case model.GitFileStatusType.renamed:
        return entity.GitFileStatusType.renamed;
      case model.GitFileStatusType.copied:
        return entity.GitFileStatusType.copied;
      case model.GitFileStatusType.unmerged:
        return entity.GitFileStatusType.typeChanged;
      case model.GitFileStatusType.ignored:
        return entity.GitFileStatusType.ignored;
    }
  }

  @override
  Future<void> stageFile(String repoPath, String filePath) async {
    await _dataSource.stageFile(repoPath, filePath);
  }

  @override
  Future<void> unstageFile(String repoPath, String filePath) async {
    await _dataSource.unstageFile(repoPath, filePath);
  }

  @override
  Future<void> stageFiles(String repoPath, List<String> filePaths) async {
    for (final filePath in filePaths) {
      await _dataSource.stageFile(repoPath, filePath);
    }
  }

  @override
  Future<void> unstageFiles(String repoPath, List<String> filePaths) async {
    for (final filePath in filePaths) {
      await _dataSource.unstageFile(repoPath, filePath);
    }
  }

  @override
  Future<void> stageAllFiles(String repoPath) async {
    await _dataSource.stageAllFiles(repoPath);
  }

  @override
  Future<void> unstageAllFiles(String repoPath) async {
    await _dataSource.unstageAllFiles(repoPath);
  }

  @override
  Future<void> discardFileChanges(String repoPath, String filePath,
      {bool force = false}) async {
    await _dataSource.discardFileChanges(repoPath, filePath);
  }

  @override
  Future<String> commit(String repoPath, String message,
      {List<String>? files}) async {
    return await _dataSource.commit(repoPath, message, files: files);
  }

  @override
  Future<bool> isGitRepository(String repoPath) async {
    return await _dataSource.isGitRepository(repoPath);
  }

  @override
  Future<void> discardAllChanges(String repoPath, {bool force = false}) async {
    await _dataSource.discardAllChanges(repoPath);
  }

  @override
  Future<String> commitChanges(String repoPath, String message,
      {List<String>? files}) async {
    return await _dataSource.commit(repoPath, message, files: files);
  }

  @override
  Future<void> push(String repoPath, {String? remote, String? branch}) async {
    await _dataSource.push(repoPath, remote: remote, branch: branch);
  }

  @override
  Future<void> pull(String repoPath, {String? remote, String? branch}) async {
    await _dataSource.pull(repoPath, remote: remote, branch: branch);
  }

  @override
  Future<List<GitCommitEntity>> getCommitHistory(
    String repoPath, {
    String? branch,
    int? limit,
    int? skip,
  }) async {
    final models = await _dataSource.getCommitHistory(
      repoPath,
      branch: branch,
      limit: limit,
      skip: skip,
    );
    return models.map((model) => _mapCommitModelToEntity(model)).toList();
  }

  @override
  Future<GitCommitEntity> getCommit(String repoPath, String sha) async {
    final model = await _dataSource.getCommit(repoPath, sha);
    return _mapCommitModelToEntity(model);
  }

  GitCommitEntity _mapCommitModelToEntity(GitCommitModel model) {
    return GitCommitEntity(
      sha: model.sha,
      message: model.message,
      author: model.author,
      committer: model.committer,
      date: model.date,
      parents: model.parents,
      changedFiles: model.changedFiles,
      insertions: model.insertions,
      deletions: model.deletions,
    );
  }

  @override
  Future<GitDiffEntity> getFileDiff(
    String repoPath,
    String filePath, {
    String? fromCommit,
    String? toCommit,
    bool staged = false,
  }) async {
    final model = await _dataSource.getFileDiff(
      repoPath,
      filePath,
      fromCommit: fromCommit,
      toCommit: toCommit,
      staged: staged,
    );
    return _mapDiffModelToEntity(model);
  }

  @override
  Future<List<GitDiffEntity>> getCommitDiff(String repoPath, String sha) async {
    final models = await _dataSource.getCommitDiff(repoPath, sha);
    return models.map((model) => _mapDiffModelToEntity(model)).toList();
  }

  GitDiffEntity _mapDiffModelToEntity(diffModel.GitDiffModel diffModelData) {
    return GitDiffEntity(
      filePath: diffModelData.filePath,
      oldFilePath: diffModelData.oldFilePath,
      isNewFile: diffModelData.isNewFile,
      isDeletedFile: diffModelData.isDeletedFile,
      isBinaryFile: diffModelData.isBinaryFile,
      insertions: diffModelData.insertions,
      deletions: diffModelData.deletions,
      hunks: diffModelData.hunks.map(_mapDiffHunkModelToEntity).toList(),
      rawDiff: diffModelData.rawDiff,
    );
  }

  GitDiffHunkEntity _mapDiffHunkModelToEntity(
      diffModel.GitDiffHunkModel hunkModel) {
    return GitDiffHunkEntity(
      header: hunkModel.header,
      oldStartLine: hunkModel.oldStart,
      oldLineCount: hunkModel.oldCount,
      newStartLine: hunkModel.newStart,
      newLineCount: hunkModel.newCount,
      lines: hunkModel.lines.map(_mapDiffLineModelToEntity).toList(),
    );
  }

  GitDiffLineEntity _mapDiffLineModelToEntity(
      diffModel.GitDiffLineModel lineModel) {
    return GitDiffLineEntity(
      type: _mapDiffLineType(lineModel.type),
      content: lineModel.content,
      oldLineNumber: lineModel.oldLineNumber,
      newLineNumber: lineModel.newLineNumber,
    );
  }

  GitDiffLineType _mapDiffLineType(diffModel.GitDiffLineType modelType) {
    switch (modelType) {
      case diffModel.GitDiffLineType.context:
        return GitDiffLineType.context;
      case diffModel.GitDiffLineType.addition:
        return GitDiffLineType.added;
      case diffModel.GitDiffLineType.deletion:
        return GitDiffLineType.deleted;
      case diffModel.GitDiffLineType.header:
        return GitDiffLineType.header;
      case diffModel.GitDiffLineType.hunk:
        return GitDiffLineType.hunkHeader;
    }
  }

  @override
  Future<List<String>> getBranches(String repoPath,
      {bool includeRemote = false}) async {
    return await _dataSource.getBranches(repoPath,
        includeRemote: includeRemote);
  }

  @override
  Future<String?> getCurrentBranch(String repoPath) async {
    return await _dataSource.getCurrentBranch(repoPath);
  }

  @override
  Future<void> createBranch(String repoPath, String branchName,
      {String? fromBranch}) async {
    await _dataSource.createBranch(repoPath, branchName,
        fromBranch: fromBranch);
  }

  @override
  Future<void> checkoutBranch(String repoPath, String branchName) async {
    await _dataSource.checkoutBranch(repoPath, branchName);
  }

  @override
  Future<void> deleteBranch(String repoPath, String branchName,
      {bool force = false}) async {
    await _dataSource.deleteBranch(repoPath, branchName, force: force);
  }

  @override
  Future<void> mergeBranch(String repoPath, String branchName) async {
    await _dataSource.mergeBranch(repoPath, branchName);
  }

  @override
  Future<Map<String, String>> getRemotes(String repoPath) async {
    return await _dataSource.getRemotes(repoPath);
  }

  @override
  Future<void> addRemote(String repoPath, String name, String url) async {
    await _dataSource.addRemote(repoPath, name, url);
  }

  @override
  Future<void> removeRemote(String repoPath, String name) async {
    await _dataSource.removeRemote(repoPath, name);
  }

  @override
  Future<List<String>> getTags(String repoPath) async {
    return await _dataSource.getTags(repoPath);
  }

  @override
  Future<void> createTag(String repoPath, String tagName,
      {String? message}) async {
    await _dataSource.createTag(repoPath, tagName, message: message);
  }

  @override
  Future<void> deleteTag(String repoPath, String tagName) async {
    await _dataSource.deleteTag(repoPath, tagName);
  }

  @override
  Future<GitConfigEntity> getConfig(String repoPath) async {
    final model = await _dataSource.getConfig(repoPath);
    return GitConfigEntity(
      userName: model.userName,
      userEmail: model.userEmail,
      autoSync: GitAutoSyncConfigEntity(
        enabled: model.autoSync.enabled,
        intervalMinutes: model.autoSync.intervalMinutes,
        pullOnStartup: model.autoSync.pullOnStartup,
        pushOnStartup: model.autoSync.pushAfterCommit,
        commitOnSchedule: model.autoSync.commitOnSchedule,
        defaultCommitMessage: model.autoSync.defaultCommitMessage,
      ),
      showStatusBar: true,
      showFileStatusIcons: true,
      showBranchInfo: true,
      ignoredFiles: model.ignoredFiles,
      remotes: model.remotes,
      submodules: const {},
      githubToken: model.githubToken,
      githubUsername: model.githubUsername,
      enableGithubIntegration: model.githubToken != null,
    );
  }

  @override
  Future<void> saveConfig(String repoPath, GitConfigEntity config) async {
    final model = GitConfigModel(
      userName: config.userName,
      userEmail: config.userEmail,
      autoSync: GitAutoSyncConfig(
        enabled: config.autoSync.enabled,
        intervalMinutes: config.autoSync.intervalMinutes,
        pullOnStartup: config.autoSync.pullOnStartup,
        pushAfterCommit: config.autoSync.pushOnStartup,
        commitOnSchedule: config.autoSync.commitOnSchedule,
        defaultCommitMessage: config.autoSync.defaultCommitMessage,
      ),
      showAuthor: true,
      showDate: true,
      maxCommitsToShow: 100,
      ignoredFiles: config.ignoredFiles,
      remotes: config.remotes,
      enableSubmodules: config.submodules.isNotEmpty,
      githubToken: config.githubToken,
      githubUsername: config.githubUsername,
    );
    await _dataSource.saveConfig(repoPath, model);
  }

  @override
  Future<bool> isWorkingTreeClean(String repoPath) async {
    return await _dataSource.isWorkingTreeClean(repoPath);
  }

  @override
  Future<int> getCommitCount(String repoPath, {String? branch}) async {
    return await _dataSource.getCommitCount(repoPath, branch: branch);
  }

  @override
  Future<GitCommitEntity?> getLastCommit(String repoPath,
      {String? branch}) async {
    final model = await _dataSource.getLastCommit(repoPath, branch: branch);
    if (model == null) return null;
    return _mapCommitModelToEntity(model);
  }

  @override
  Future<void> resetToCommit(String repoPath, String sha,
      {bool hard = false}) async {
    await _dataSource.resetToCommit(repoPath, sha, hard: hard);
  }

  @override
  Future<void> rebaseBranch(String repoPath, String branchName) async {
    await _dataSource.rebaseBranch(repoPath, branchName);
  }

  @override
  Future<List<String>> getConflictFiles(String repoPath) async {
    return await _dataSource.getConflictFiles(repoPath);
  }

  @override
  Future<void> resolveConflict(String repoPath, String filePath) async {
    await _dataSource.resolveConflict(repoPath, filePath);
  }

  @override
  Future<void> abortMerge(String repoPath) async {
    await _dataSource.abortMerge(repoPath);
  }

  @override
  Future<void> continueMerge(String repoPath) async {
    await _dataSource.continueMerge(repoPath);
  }

  @override
  Future<List<String>> getSubmodules(String repoPath) async {
    return await _dataSource.getSubmodules(repoPath);
  }

  @override
  Future<void> initSubmodules(String repoPath) async {
    await _dataSource.initSubmodules(repoPath);
  }

  @override
  Future<void> updateSubmodules(String repoPath) async {
    await _dataSource.updateSubmodules(repoPath);
  }
}
