# Git Plus Plugin

一个功能强大的Flutter Git客户端插件，灵感来自obsidian-git插件。提供完整的Git操作界面和功能。

## 功能特性

- ✅ **源码控制管理** - 查看文件状态、暂存/取消暂存文件、提交更改
- ✅ **提交历史查看** - 浏览提交历史、查看提交详情
- ✅ **文件差异对比** - 查看文件更改的详细差异
- ✅ **分支管理** - 创建、切换、合并分支
- ✅ **仓库初始化和克隆** - 初始化新仓库或克隆远程仓库
- ✅ **用户配置管理** - 管理Git用户信息和仓库配置

## 架构设计

本插件采用Clean Architecture架构模式，分为三层：

### Domain Layer (领域层)
- **Entities**: Git相关的实体类
- **Repositories**: 仓库接口定义

### Data Layer (数据层)
- **Models**: 数据模型
- **DataSources**: 数据源实现
- **Repositories**: 仓库接口实现

### Presentation Layer (表现层)
- **BLoC**: 状态管理
- **Pages**: UI页面

## 快速开始

### 1. 导入插件

```dart
import 'package:your_app/plugins/gitplus/gitplus.dart';
```

### 2. 基本使用

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepositoryProvider<GitRepository>(
        create: (context) => GitRepositoryImpl(
          GitDataSourceImpl(),
        ),
        child: BlocProvider<GitRepositoryBloc>(
          create: (context) => GitRepositoryBloc(
            context.read<GitRepository>(),
          ),
          child: GitMainPage(
            repositoryPath: '/path/to/your/git/repository',
          ),
        ),
      ),
    );
  }
}
```

### 3. 完整集成示例

```dart
class GitIntegration extends StatelessWidget {
  final String repositoryPath;

  const GitIntegration({required this.repositoryPath});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<GitRepository>(
          create: (context) => GitRepositoryImpl(GitDataSourceImpl()),
        ),
        BlocProvider<GitRepositoryBloc>(
          create: (context) => GitRepositoryBloc(
            context.read<GitRepository>(),
          ),
        ),
        BlocProvider<GitFileStatusBloc>(
          create: (context) => GitFileStatusBloc(
            context.read<GitRepository>(),
          ),
        ),
        BlocProvider<CommitBloc>(
          create: (context) => CommitBloc(
            context.read<GitRepository>(),
          ),
        ),
        BlocProvider<DiffBloc>(
          create: (context) => DiffBloc(
            context.read<GitRepository>(),
          ),
        ),
      ],
      child: GitMainPage(repositoryPath: repositoryPath),
    );
  }
}
```

## 主要组件

### GitMainPage
主界面，包含源码控制和历史记录两个标签页。

```dart
GitMainPage(
  repositoryPath: '/path/to/repository',
)
```

### SourceControlPage
源码控制页面，显示文件状态、提供暂存/提交功能。

```dart
SourceControlPage(
  repositoryPath: '/path/to/repository',
)
```

### HistoryPage
历史记录页面，显示提交历史列表。

```dart
HistoryPage(
  repositoryPath: '/path/to/repository',
)
```

### DiffViewPage
差异查看页面，显示文件的详细更改。

```dart
DiffViewPage(
  repositoryPath: '/path/to/repository',
  filePath: 'path/to/file.dart',
  fromCommit: 'commit1',
  toCommit: 'commit2',
)
```

### CommitDetailPage
提交详情页面，显示单个提交的详细信息。

```dart
CommitDetailPage(
  repositoryPath: '/path/to/repository',
  commit: gitCommitEntity,
)
```

## BLoC状态管理

### GitRepositoryBloc
管理Git仓库的基本操作：
- 初始化仓库
- 检查是否为Git仓库
- 克隆仓库
- 配置管理

### GitFileStatusBloc
管理文件状态操作：
- 获取文件状态
- 暂存/取消暂存文件
- 丢弃文件更改

### CommitBloc
管理提交操作：
- 提交更改
- 获取提交历史
- 获取提交详情

### DiffBloc
管理差异查看：
- 获取文件差异
- 获取提交差异

## 自定义配置

### 自定义主题

```dart
MaterialApp(
  theme: ThemeData.dark(), // 使用深色主题
  home: GitMainPage(repositoryPath: repositoryPath),
)
```

### 自定义Git数据源

```dart
class CustomGitDataSource implements GitDataSource {
  // 实现自定义的Git操作逻辑
}

// 使用自定义数据源
GitRepositoryImpl(CustomGitDataSource())
```

## 依赖项

确保在`pubspec.yaml`中添加以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  # 其他必要依赖...
```

## 注意事项

1. **权限要求**: 确保应用有读写文件系统的权限
2. **Git环境**: 需要系统安装Git命令行工具
3. **路径格式**: 仓库路径必须是绝对路径
4. **错误处理**: 建议在使用时添加适当的错误处理逻辑

## 示例项目

查看`example.dart`文件获取完整的使用示例。

## 版本信息

- **版本**: 1.0.0
- **Flutter版本要求**: >=3.0.0
- **Dart版本要求**: >=2.17.0

## 许可证

本项目采用MIT许可证。