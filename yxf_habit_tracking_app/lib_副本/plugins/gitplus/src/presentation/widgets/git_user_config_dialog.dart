import 'package:flutter/material.dart';
import 'dart:io';

/// Git用户配置对话框
class GitUserConfigDialog extends StatefulWidget {
  final String? repositoryPath;
  final bool isGlobal;

  const GitUserConfigDialog({
    Key? key,
    this.repositoryPath,
    this.isGlobal = false,
  }) : super(key: key);

  @override
  State<GitUserConfigDialog> createState() => _GitUserConfigDialogState();
}

class _GitUserConfigDialogState extends State<GitUserConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取当前用户名
      final nameArgs = ['config', widget.isGlobal ? '--global' : '--local', 'user.name'];
      final nameResult = await Process.run(
        'git',
        nameArgs,
        workingDirectory: widget.repositoryPath,
      );
      
      if (nameResult.exitCode == 0) {
        _nameController.text = (nameResult.stdout as String).trim();
      }

      // 获取当前邮箱
      final emailArgs = ['config', widget.isGlobal ? '--global' : '--local', 'user.email'];
      final emailResult = await Process.run(
        'git',
        emailArgs,
        workingDirectory: widget.repositoryPath,
      );
      
      if (emailResult.exitCode == 0) {
        _emailController.text = (emailResult.stdout as String).trim();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载配置失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 设置用户名
      final nameArgs = [
        'config',
        widget.isGlobal ? '--global' : '--local',
        'user.name',
        _nameController.text.trim(),
      ];
      final nameResult = await Process.run(
        'git',
        nameArgs,
        workingDirectory: widget.repositoryPath,
      );
      
      if (nameResult.exitCode != 0) {
        throw Exception('设置用户名失败: ${nameResult.stderr}');
      }

      // 设置邮箱
      final emailArgs = [
        'config',
        widget.isGlobal ? '--global' : '--local',
        'user.email',
        _emailController.text.trim(),
      ];
      final emailResult = await Process.run(
        'git',
        emailArgs,
        workingDirectory: widget.repositoryPath,
      );
      
      if (emailResult.exitCode != 0) {
        throw Exception('设置邮箱失败: ${emailResult.stderr}');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Git用户配置已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isGlobal ? '全局Git用户配置' : '仓库Git用户配置'),
      content: SizedBox(
        width: 400,
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载配置...'),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '输入Git用户名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入用户名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: '邮箱',
                        hintText: '输入Git邮箱地址',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入邮箱地址';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return '请输入有效的邮箱地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isGlobal
                          ? '这些设置将应用到所有Git仓库（除非仓库有本地配置）'
                          : '这些设置仅应用到当前仓库',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveConfig,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}