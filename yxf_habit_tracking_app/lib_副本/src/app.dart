import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/cross_platforms_adapter/tencent_cloud_chat_screen_adapter.dart';
import 'package:tencent_cloud_chat_common/cross_platforms_adapter/tencent_cloud_chat_platform_adapter.dart';
import 'package:tencent_cloud_chat_demo/src/presentation/pages/main_app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:tencent_cloud_chat_demo/toast_utils.dart';

// * 经过了appRouter
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends TencentCloudChatState<MyHomePage> {
  int currentIndex = 0;

  List<Widget> pages = [];

  _MyHomePageState() : super(needFPSMonitor: true);

  bool isLogin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // * 初始化屏幕适配器
    TencentCloudChatScreenAdapter.init(context);

    // 调试信息：打印平台和屏幕类型检测结果
    debugPrint('=== 平台检测调试信息 ===');
    debugPrint('Platform.isMacOS: ${Platform.isMacOS}');
    debugPrint('kIsWeb: $kIsWeb');
    debugPrint(
        'TencentCloudChatPlatformAdapter().isDesktop: ${TencentCloudChatPlatformAdapter().isDesktop}');
    debugPrint(
        'TencentCloudChatPlatformAdapter().isMacOS: ${TencentCloudChatPlatformAdapter().isMacOS}');
    debugPrint(
        'TencentCloudChatScreenAdapter.deviceScreenType: ${TencentCloudChatScreenAdapter.deviceScreenType}');
    debugPrint('MediaQuery.of(context).size: ${MediaQuery.of(context).size}');
    debugPrint('=========================');
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    FlutterNativeSplash.remove();
    return const MainApp();
  }

  @override
  Widget desktopBuilder(BuildContext context) {
    FlutterNativeSplash.remove();
    return const MainApp();
  }

  @override
  Widget mobileBuilder(BuildContext context) {
    FlutterNativeSplash.remove();
    return const MainApp();
  }
}

class MyHomePageData {
  final String title;

  MyHomePageData({required this.title});

  Map<String, dynamic> toMap() {
    return {'title': title};
  }

  static MyHomePageData fromMap(Map<String, dynamic> map) {
    return MyHomePageData(title: map['title'] as String);
  }
}
