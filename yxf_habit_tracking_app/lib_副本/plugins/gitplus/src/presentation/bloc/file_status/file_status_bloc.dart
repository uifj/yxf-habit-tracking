import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_file_statuses_usecase.dart';
import '../../../domain/usecases/manage_file_staging_usecase.dart';
import 'file_status_event.dart';
import 'file_status_state.dart';

/// 文件状态BLoC
class FileStatusBloc extends Bloc<FileStatusEvent, FileStatusState> {
  final GetFileStatusesUseCase _getFileStatusesUseCase;
  final ManageFileStagingUseCase _manageFileStagingUseCase;

  FileStatusBloc({
    required GetFileStatusesUseCase getFileStatusesUseCase,
    required ManageFileStagingUseCase manageFileStagingUseCase,
  })  : _getFileStatusesUseCase = getFileStatusesUseCase,
        _manageFileStagingUseCase = manageFileStagingUseCase,
        super(const FileStatusInitial()) {
    on<LoadFileStatuses>(_onLoadFileStatuses);
    on<RefreshFileStatuses>(_onRefreshFileStatuses);
    on<StageFile>(_onStageFile);
    on<UnstageFile>(_onUnstageFile);
    on<StageFiles>(_onStageFiles);
    on<UnstageFiles>(_onUnstageFiles);
    on<StageAllFiles>(_onStageAllFiles);
    on<UnstageAllFiles>(_onUnstageAllFiles);
    on<ToggleFileStaging>(_onToggleFileStaging);
    on<DiscardFileChanges>(_onDiscardFileChanges);
    on<DiscardAllChanges>(_onDiscardAllChanges);
    on<SelectFile>(_onSelectFile);
    on<DeselectFile>(_onDeselectFile);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<SelectAllFiles>(_onSelectAllFiles);
    on<DeselectAllFiles>(_onDeselectAllFiles);
    on<ToggleSelectAll>(_onToggleSelectAll);
  }

  /// 处理加载文件状态列表事件
  Future<void> _onLoadFileStatuses(
    LoadFileStatuses event,
    Emitter<FileStatusState> emit,
  ) async {
    emit(const FileStatusLoading());

    try {
      final files = await _getFileStatusesUseCase(event.repoPath);
      emit(FileStatusLoaded(files, const {}, event.repoPath));
    } catch (e) {
      emit(FileStatusError(
        'Failed to load file statuses: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理刷新文件状态列表事件
  Future<void> _onRefreshFileStatuses(
    RefreshFileStatuses event,
    Emitter<FileStatusState> emit,
  ) async {
    final currentState = state;
    Set<String> selectedFiles = {};

    // 保持当前选择状态
    if (currentState is FileStatusLoaded) {
      selectedFiles = currentState.selectedFiles;
    }

    try {
      final files = await _getFileStatusesUseCase(event.repoPath);

      // 过滤掉不存在的选择文件
      final existingFilePaths = files.map((f) => f.path).toSet();
      selectedFiles = selectedFiles.intersection(existingFilePaths);

      emit(FileStatusLoaded(files, selectedFiles, event.repoPath));
    } catch (e) {
      emit(FileStatusError(
        'Failed to refresh file statuses: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// 处理暂存文件事件
  Future<void> _onStageFile(
    StageFile event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'stage',
      [event.filePath],
      event.repoPath,
      () => _manageFileStagingUseCase.stageFile(
        repoPath: event.repoPath,
        filePath: event.filePath,
      ),
    );
  }

  /// 处理取消暂存文件事件
  Future<void> _onUnstageFile(
    UnstageFile event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'unstage',
      [event.filePath],
      event.repoPath,
      () => _manageFileStagingUseCase.unstageFile(
        repoPath: event.repoPath,
        filePath: event.filePath,
      ),
    );
  }

  /// 处理暂存多个文件事件
  Future<void> _onStageFiles(
    StageFiles event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'stage',
      event.filePaths,
      event.repoPath,
      () => _manageFileStagingUseCase.stageFiles(
        repoPath: event.repoPath,
        filePaths: event.filePaths,
      ),
    );
  }

  /// 处理取消暂存多个文件事件
  Future<void> _onUnstageFiles(
    UnstageFiles event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'unstage',
      event.filePaths,
      event.repoPath,
      () => _manageFileStagingUseCase.unstageFiles(
        repoPath: event.repoPath,
        filePaths: event.filePaths,
      ),
    );
  }

  /// 处理暂存所有文件事件
  Future<void> _onStageAllFiles(
    StageAllFiles event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'stage all',
      [],
      event.repoPath,
      () => _manageFileStagingUseCase.stageAllFiles(
        repoPath: event.repoPath,
      ),
    );
  }

  /// 处理取消暂存所有文件事件
  Future<void> _onUnstageAllFiles(
    UnstageAllFiles event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'unstage all',
      [],
      event.repoPath,
      () => _manageFileStagingUseCase.unstageAllFiles(
        repoPath: event.repoPath,
      ),
    );
  }

  /// 处理切换文件暂存状态事件
  Future<void> _onToggleFileStaging(
    ToggleFileStaging event,
    Emitter<FileStatusState> emit,
  ) async {
    final operation = event.isCurrentlyStaged ? 'unstage' : 'stage';

    await _performFileOperation(
      emit,
      operation,
      [event.filePath],
      event.repoPath,
      () => _manageFileStagingUseCase.toggleFileStaging(
        repoPath: event.repoPath,
        filePath: event.filePath,
        isCurrentlyStaged: event.isCurrentlyStaged,
      ),
    );
  }

  /// 处理丢弃文件更改事件
  Future<void> _onDiscardFileChanges(
    DiscardFileChanges event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'discard',
      [event.filePath],
      event.repoPath,
      () => _manageFileStagingUseCase.discardFileChanges(
        repoPath: event.repoPath,
        filePath: event.filePath,
      ),
    );
  }

  /// 处理丢弃所有更改事件
  Future<void> _onDiscardAllChanges(
    DiscardAllChanges event,
    Emitter<FileStatusState> emit,
  ) async {
    await _performFileOperation(
      emit,
      'discard all',
      [],
      event.repoPath,
      () => _manageFileStagingUseCase.discardAllChanges(
        repoPath: event.repoPath,
      ),
    );
  }

  /// 处理选择文件事件
  void _onSelectFile(
    SelectFile event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      final newSelectedFiles = Set<String>.from(currentState.selectedFiles)
        ..add(event.filePath);
      emit(currentState.copyWith(selectedFiles: newSelectedFiles));
    }
  }

  /// 处理取消选择文件事件
  void _onDeselectFile(
    DeselectFile event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      final newSelectedFiles = Set<String>.from(currentState.selectedFiles)
        ..remove(event.filePath);
      emit(currentState.copyWith(selectedFiles: newSelectedFiles));
    }
  }

  /// 处理切换文件选择状态事件
  void _onToggleFileSelection(
    ToggleFileSelection event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      final newSelectedFiles = Set<String>.from(currentState.selectedFiles);
      if (newSelectedFiles.contains(event.filePath)) {
        newSelectedFiles.remove(event.filePath);
      } else {
        newSelectedFiles.add(event.filePath);
      }
      emit(currentState.copyWith(selectedFiles: newSelectedFiles));
    }
  }

  /// 处理选择所有文件事件
  void _onSelectAllFiles(
    SelectAllFiles event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      final allFilePaths = currentState.files.map((f) => f.path).toSet();
      emit(currentState.copyWith(selectedFiles: allFilePaths));
    }
  }

  /// 处理取消选择所有文件事件
  void _onDeselectAllFiles(
    DeselectAllFiles event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      emit(currentState.copyWith(selectedFiles: const {}));
    }
  }

  /// 处理切换全选状态事件
  void _onToggleSelectAll(
    ToggleSelectAll event,
    Emitter<FileStatusState> emit,
  ) {
    final currentState = state;
    if (currentState is FileStatusLoaded) {
      if (currentState.isAllSelected) {
        emit(currentState.copyWith(selectedFiles: const {}));
      } else {
        final allFilePaths = currentState.files.map((f) => f.path).toSet();
        emit(currentState.copyWith(selectedFiles: allFilePaths));
      }
    }
  }

  /// 执行文件操作的通用方法
  Future<void> _performFileOperation(
    Emitter<FileStatusState> emit,
    String operation,
    List<String> filePaths,
    String repoPath,
    Future<void> Function() operationFunction,
  ) async {
    final currentState = state;
    if (currentState is! FileStatusLoaded) return;

    // 发出操作中状态
    emit(FileStatusOperating(
      operation,
      filePaths,
      currentState.files,
      currentState.selectedFiles,
      repoPath,
    ));

    try {
      // 执行操作
      await operationFunction();

      // 重新加载文件状态
      final updatedFiles = await _getFileStatusesUseCase(repoPath);

      // 过滤掉不存在的选择文件
      final existingFilePaths = updatedFiles.map((f) => f.path).toSet();
      final filteredSelectedFiles =
          currentState.selectedFiles.intersection(existingFilePaths);

      // 发出操作成功状态
      emit(FileStatusOperationSuccess(
        operation,
        filePaths,
        updatedFiles,
        filteredSelectedFiles,
        repoPath,
      ));

      // 立即切换到加载完成状态
      emit(FileStatusLoaded(updatedFiles, filteredSelectedFiles, repoPath));
    } catch (e) {
      // 发出操作失败状态
      emit(FileStatusOperationError(
        operation,
        filePaths,
        'Failed to $operation files: ${e.toString()}',
        currentState.files,
        currentState.selectedFiles,
        repoPath,
        exception: e is Exception ? e : Exception(e.toString()),
      ));

      // 恢复到之前的状态
      emit(currentState);
    }
  }
}
