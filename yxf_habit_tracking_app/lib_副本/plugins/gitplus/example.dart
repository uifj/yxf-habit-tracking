import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'gitplus.dart';
import 'src/presentation/pages/git_status_page.dart';
// import 'src/presentation/dialogs/git_user_config_dialog.dart';

/// Git Plus插件使用示例
/// 展示如何在Flutter应用中集成和使用Git Plus功能
class GitPlusExample extends StatefulWidget {
  const GitPlusExample({Key? key}) : super(key: key);

  @override
  State<GitPlusExample> createState() => _GitPlusExampleState();
}

class _GitPlusExampleState extends State<GitPlusExample> {
  Directory? _selectedDirectory;
  Color _directoryFocusColor = Colors.grey;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Plus Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _selectedDirectory == null
          ? _buildDirectorySelector()
          : RepositoryProvider<GitRepository>(
              create: (context) => GitRepositoryImpl(
                GitDataSourceImpl(),
              ),
              child: BlocProvider<GitRepositoryBloc>(
                create: (context) => GitRepositoryBloc(
                  context.read<GitRepository>(),
                ),
                child: GitMainPage(repositoryPath: _selectedDirectory!.path),
              ),
            ),
    );
  }

  /// 构建目录选择界面
  Widget _buildDirectorySelector() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Plus - 选择仓库目录'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 80,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Git Plus',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '请选择一个Git仓库目录来开始使用',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDirectorySelectionCard(),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _selectDirectory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '选择Git仓库目录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _showDiagnostics,
                          icon: const Icon(Icons.medical_services),
                          label: const Text('系统诊断'),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('用户配置功能请在Git主页面中使用'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_outline),
                          label: const Text('用户配置'),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              _buildQuickStartGuide(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建快速开始指南
  Widget _buildQuickStartGuide() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '快速开始',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1. 点击"系统诊断"检查Git环境\n'
              '2. 点击"用户配置"设置Git用户信息\n'
              '3. 选择一个Git仓库目录开始使用\n'
              '4. 如果目录不是Git仓库，可以初始化为新仓库',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示系统诊断
  void _showDiagnostics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GitStatusPage(
          repositoryPath: _selectedDirectory?.path,
        ),
      ),
    );
  }

  /// 显示用户配置
  // void _showUserConfig() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => GitUserConfigDialog(
  //       repositoryPath: _selectedDirectory?.path,
  //     ),
  //   );
  // }

  /// 构建目录选择卡片
  Widget _buildDirectorySelectionCard() {
    return GestureDetector(
      onTap: _selectDirectory,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: _directoryFocusColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: _directoryFocusColor,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDirectory == null ? '点击选择Git仓库目录' : '已选择目录',
              style: TextStyle(
                color: _directoryFocusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedDirectory != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _selectedDirectory!.path,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 选择目录
  Future<void> _selectDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? directoryPath =
          await FilePicker.platform.getDirectoryPath();
      if (directoryPath != null) {
        setState(() {
          _selectedDirectory = Directory(directoryPath);
          _directoryFocusColor = Colors.green;
        });
      }
    } catch (e) {
      _showErrorMessage('选择目录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// 简单的启动示例
void main() {
  runApp(
    const GitPlusExample(),
  );
}

/// 如何在现有应用中集成Git Plus
class IntegrationExample extends StatelessWidget {
  const IntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Plus集成示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () => _showDiagnostics(context),
            tooltip: '系统诊断',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showUserConfig(context),
            tooltip: '用户配置',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 24),
            _buildFeaturesSection(context),
            const SizedBox(height: 24),
            _buildActionsSection(context),
            const SizedBox(height: 24),
            _buildIntegrationGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.source,
              size: 64,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Git Plus v${GitPlusPlugin.version}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              GitPlusPlugin.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能特性',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...GitPlusPlugin.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openGitPlus(context),
                  icon: const Icon(Icons.launch),
                  label: const Text('打开Git Plus'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showDiagnostics(context),
                  icon: const Icon(Icons.medical_services),
                  label: const Text('系统诊断'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showUserConfig(context),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('用户配置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationGuide() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.integration_instructions, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '集成指南',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '在您的应用中集成Git Plus：\n\n'
              '1. 添加依赖和导入\n'
              '2. 创建GitRepository实例\n'
              '3. 使用BlocProvider包装您的Widget\n'
              '4. 调用GitMainPage显示Git界面\n\n'
              '详细示例请参考CustomConfigExample类。',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _openGitPlus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GitPlusExample(),
      ),
    );
  }

  void _showDiagnostics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GitStatusPage(),
      ),
    );
  }

  void _showUserConfig(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('用户配置功能请在Git主页面中使用'),
      ),
    );
  }
}

/// 自定义配置示例
class CustomConfigExample {
  /// 创建自定义的Git仓库实例
  static GitRepository createCustomGitRepository() {
    return GitRepositoryImpl(
      GitDataSourceImpl(),
    );
  }

  /// 创建预配置的BLoC提供者
  static Widget createBlocProviders({
    required Widget child,
    required GitRepository gitRepository,
  }) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<GitRepository>.value(value: gitRepository),
        BlocProvider<GitRepositoryBloc>(
          create: (context) => GitRepositoryBloc(gitRepository),
        ),
        BlocProvider<GitFileStatusBloc>(
          create: (context) => GitFileStatusBloc(gitRepository),
        ),
        BlocProvider<CommitBloc>(
          create: (context) => CommitBloc(gitRepository),
        ),
        BlocProvider<DiffBloc>(
          create: (context) => DiffBloc(gitRepository),
        ),
      ],
      child: child,
    );
  }

  /// 使用自定义主题的Git Plus
  static Widget createThemedGitPlus({
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.dark(),
      home: const GitPlusExample(),
    );
  }

  /// 创建带有诊断功能的完整示例
  static Widget createFullFeaturedExample({
    String? initialPath,
    ThemeData? theme,
  }) {
    return MaterialApp(
      title: 'Git Plus - Full Featured',
      theme: theme ??
          ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
      home: _FullFeaturedExample(initialPath: initialPath),
    );
  }
}

/// 完整功能示例
class _FullFeaturedExample extends StatefulWidget {
  final String? initialPath;

  const _FullFeaturedExample({this.initialPath});

  @override
  State<_FullFeaturedExample> createState() => _FullFeaturedExampleState();
}

class _FullFeaturedExampleState extends State<_FullFeaturedExample> {
  Directory? _selectedDirectory;

  @override
  void initState() {
    super.initState();
    if (widget.initialPath != null) {
      _selectedDirectory = Directory(widget.initialPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDirectory == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Git Plus - 完整示例'),
          actions: [
            IconButton(
              icon: const Icon(Icons.medical_services),
              onPressed: () => _showDiagnostics(),
              tooltip: '系统诊断',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('请选择Git仓库目录'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectDirectory,
                child: const Text('选择目录'),
              ),
            ],
          ),
        ),
      );
    }

    return RepositoryProvider<GitRepository>(
      create: (context) => GitRepositoryImpl(GitDataSourceImpl()),
      child: BlocProvider<GitRepositoryBloc>(
        create: (context) => GitRepositoryBloc(
          context.read<GitRepository>(),
        ),
        child: GitMainPage(repositoryPath: _selectedDirectory!.path),
      ),
    );
  }

  Future<void> _selectDirectory() async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _selectedDirectory = Directory(directoryPath);
      });
    }
  }

  void _showDiagnostics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GitStatusPage(
          repositoryPath: _selectedDirectory?.path,
        ),
      ),
    );
  }
}
