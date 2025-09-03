// Git Plus Plugin
// 一个功能强大的Git客户端插件，灵感来自obsidian-git

library gitplus;

// Domain Layer
export 'src/domain/entities/git_repository_entity.dart';
export 'src/domain/entities/git_commit_entity.dart';
export 'src/domain/entities/git_file_status_entity.dart';
export 'src/domain/entities/git_diff_entity.dart';
export 'src/domain/entities/git_config_entity.dart';
export 'src/domain/repositories/git_repository.dart';

// Data Layer
export 'src/data/repositories/git_repository_impl.dart';
export 'src/data/datasources/git_datasource.dart';
export 'src/data/datasources/git_datasource_impl.dart';
export 'src/data/models/git_repository_model.dart';
export 'src/data/models/git_commit_model.dart';
export 'src/data/models/git_file_status_model.dart' hide GitFileStatusType;
export 'src/data/models/git_diff_model.dart' hide GitDiffLineType;
export 'src/data/models/git_config_model.dart';

// Presentation Layer
export 'src/presentation/bloc/blocs.dart';
export 'src/presentation/pages/pages.dart';

// Plugin Info
class GitPlusPlugin {
  static const String name = 'Git Plus';
  static const String version = '1.0.0';
  static const String description = '一个功能强大的Git客户端，灵感来自obsidian-git插件';

  static const List<String> features = [
    '源码控制管理',
    '提交历史查看',
    '文件差异对比',
    '分支管理',
    '仓库初始化和克隆',
    '用户配置管理',
  ];
}
