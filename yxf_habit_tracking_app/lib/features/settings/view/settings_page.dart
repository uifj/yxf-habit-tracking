import 'package:flutter/material.dart';
import 'locale_page.dart';
import 'theme_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ThemePage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('语言设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LocalePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
