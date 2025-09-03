// todo: 实现一种插件页面，支持用户启用/禁用插件。
// 比如 git插件
import 'package:flutter/material.dart';

class PluginPage extends StatefulWidget {
  const PluginPage({super.key});

  @override
  State<PluginPage> createState() => _PluginPageState();
}

class _PluginPageState extends State<PluginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件'),
      ),
      body: const Center(
        child: Text('插件页面'),
      ),
    );
  }
}
