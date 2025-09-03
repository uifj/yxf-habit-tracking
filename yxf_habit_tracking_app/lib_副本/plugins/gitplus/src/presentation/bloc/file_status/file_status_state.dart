import 'package:equatable/equatable.dart';
import '../../../domain/entities/git_file_status_entity.dart';

/// 文件状态状态基类
abstract class FileStatusState extends Equatable {
  const FileStatusState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class FileStatusInitial extends FileStatusState {
  const FileStatusInitial();
}

/// 加载中状态
class FileStatusLoading extends FileStatusState {
  const FileStatusLoading();
}

/// 加载成功状态
class FileStatusLoaded extends FileStatusState {
  final List<GitFileStatusEntity> files;
  final Set<String> selectedFiles;
  final String repoPath;

  const FileStatusLoaded(
    this.files,
    this.selectedFiles,
    this.repoPath,
  );

  /// 获取已暂存的文件
  List<GitFileStatusEntity> get stagedFiles {
    return files.where((file) => file.isStaged).toList();
  }

  /// 获取未暂存的文件
  List<GitFileStatusEntity> get unstagedFiles {
    return files.where((file) => !file.isStaged).toList();
  }

  /// 获取已选择的文件
  List<GitFileStatusEntity> get selectedFileEntities {
    return files.where((file) => selectedFiles.contains(file.path)).toList();
  }

  /// 是否有已暂存的文件
  bool get hasStagedFiles => stagedFiles.isNotEmpty;

  /// 是否有未暂存的文件
  bool get hasUnstagedFiles => unstagedFiles.isNotEmpty;

  /// 是否有选择的文件
  bool get hasSelectedFiles => selectedFiles.isNotEmpty;

  /// 是否全选
  bool get isAllSelected =>
      files.isNotEmpty && selectedFiles.length == files.length;

  /// 是否部分选择
  bool get isPartiallySelected => selectedFiles.isNotEmpty && !isAllSelected;

  /// 复制并修改属性
  FileStatusLoaded copyWith({
    List<GitFileStatusEntity>? files,
    Set<String>? selectedFiles,
    String? repoPath,
  }) {
    return FileStatusLoaded(
      files ?? this.files,
      selectedFiles ?? this.selectedFiles,
      repoPath ?? this.repoPath,
    );
  }

  @override
  List<Object?> get props => [files, selectedFiles, repoPath];
}

/// 加载失败状态
class FileStatusError extends FileStatusState {
  final String message;
  final Exception? exception;

  const FileStatusError(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}

/// 文件操作中状态
class FileStatusOperating extends FileStatusState {
  final String operation;
  final List<String> filePaths;
  final List<GitFileStatusEntity> currentFiles;
  final Set<String> selectedFiles;
  final String repoPath;

  const FileStatusOperating(
    this.operation,
    this.filePaths,
    this.currentFiles,
    this.selectedFiles,
    this.repoPath,
  );

  @override
  List<Object?> get props =>
      [operation, filePaths, currentFiles, selectedFiles, repoPath];
}

/// 文件操作成功状态
class FileStatusOperationSuccess extends FileStatusState {
  final String operation;
  final List<String> filePaths;
  final List<GitFileStatusEntity> files;
  final Set<String> selectedFiles;
  final String repoPath;

  const FileStatusOperationSuccess(
    this.operation,
    this.filePaths,
    this.files,
    this.selectedFiles,
    this.repoPath,
  );

  @override
  List<Object?> get props =>
      [operation, filePaths, files, selectedFiles, repoPath];
}

/// 文件操作失败状态
class FileStatusOperationError extends FileStatusState {
  final String operation;
  final List<String> filePaths;
  final String message;
  final Exception? exception;
  final List<GitFileStatusEntity> currentFiles;
  final Set<String> selectedFiles;
  final String repoPath;

  const FileStatusOperationError(
    this.operation,
    this.filePaths,
    this.message,
    this.currentFiles,
    this.selectedFiles,
    this.repoPath, {
    this.exception,
  });

  @override
  List<Object?> get props => [
        operation,
        filePaths,
        message,
        exception,
        currentFiles,
        selectedFiles,
        repoPath,
      ];
}
