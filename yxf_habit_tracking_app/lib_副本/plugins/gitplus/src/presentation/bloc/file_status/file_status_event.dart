import 'package:equatable/equatable.dart';

/// 文件状态事件基类
abstract class FileStatusEvent extends Equatable {
  const FileStatusEvent();

  @override
  List<Object?> get props => [];
}

/// 加载文件状态列表事件
class LoadFileStatuses extends FileStatusEvent {
  final String repoPath;

  const LoadFileStatuses(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 刷新文件状态列表事件
class RefreshFileStatuses extends FileStatusEvent {
  final String repoPath;

  const RefreshFileStatuses(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 暂存文件事件
class StageFile extends FileStatusEvent {
  final String repoPath;
  final String filePath;

  const StageFile(this.repoPath, this.filePath);

  @override
  List<Object?> get props => [repoPath, filePath];
}

/// 取消暂存文件事件
class UnstageFile extends FileStatusEvent {
  final String repoPath;
  final String filePath;

  const UnstageFile(this.repoPath, this.filePath);

  @override
  List<Object?> get props => [repoPath, filePath];
}

/// 暂存多个文件事件
class StageFiles extends FileStatusEvent {
  final String repoPath;
  final List<String> filePaths;

  const StageFiles(this.repoPath, this.filePaths);

  @override
  List<Object?> get props => [repoPath, filePaths];
}

/// 取消暂存多个文件事件
class UnstageFiles extends FileStatusEvent {
  final String repoPath;
  final List<String> filePaths;

  const UnstageFiles(this.repoPath, this.filePaths);

  @override
  List<Object?> get props => [repoPath, filePaths];
}

/// 暂存所有文件事件
class StageAllFiles extends FileStatusEvent {
  final String repoPath;

  const StageAllFiles(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 取消暂存所有文件事件
class UnstageAllFiles extends FileStatusEvent {
  final String repoPath;

  const UnstageAllFiles(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 切换文件暂存状态事件
class ToggleFileStaging extends FileStatusEvent {
  final String repoPath;
  final String filePath;
  final bool isCurrentlyStaged;

  const ToggleFileStaging(
    this.repoPath,
    this.filePath,
    this.isCurrentlyStaged,
  );

  @override
  List<Object?> get props => [repoPath, filePath, isCurrentlyStaged];
}

/// 丢弃文件更改事件
class DiscardFileChanges extends FileStatusEvent {
  final String repoPath;
  final String filePath;

  const DiscardFileChanges(this.repoPath, this.filePath);

  @override
  List<Object?> get props => [repoPath, filePath];
}

/// 丢弃所有更改事件
class DiscardAllChanges extends FileStatusEvent {
  final String repoPath;

  const DiscardAllChanges(this.repoPath);

  @override
  List<Object?> get props => [repoPath];
}

/// 选择文件事件
class SelectFile extends FileStatusEvent {
  final String filePath;

  const SelectFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// 取消选择文件事件
class DeselectFile extends FileStatusEvent {
  final String filePath;

  const DeselectFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// 切换文件选择状态事件
class ToggleFileSelection extends FileStatusEvent {
  final String filePath;

  const ToggleFileSelection(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// 选择所有文件事件
class SelectAllFiles extends FileStatusEvent {
  const SelectAllFiles();
}

/// 取消选择所有文件事件
class DeselectAllFiles extends FileStatusEvent {
  const DeselectAllFiles();
}

/// 切换全选状态事件
class ToggleSelectAll extends FileStatusEvent {
  const ToggleSelectAll();
}
