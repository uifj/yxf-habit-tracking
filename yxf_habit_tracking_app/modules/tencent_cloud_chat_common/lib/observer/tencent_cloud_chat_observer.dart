import 'package:flutter/widgets.dart';
// todo: 注释
// import 'package:tencent_cloud_chat_common/tencent_cloud_chat.dart';

/// A utility class for checking page routes behavior and add action for audio player for TencentCloudChat .
/// * 路由观察者 ：用于监听路由变化，当路由变化时，根据路由类型执行相应的操作
// 设计模式 ：观察者模式 + 单例模式
// 继承关系 ：继承自 Flutter 的
class TencentCloudChatObserver extends RouteObserver<PageRoute<dynamic>> {
  static final TencentCloudChatObserver _instance = TencentCloudChatObserver();
  static bool isClose = false;

  static TencentCloudChatObserver getInstance() {
    return _instance;
  }

  /// function handles audio in message when route changed
  void _handleRouteChanged(PageRoute<dynamic> route) {
    // todo: 注释
    // TencentCloudChat.instance.dataInstance.messageData.stopPlayAudio(); // 当路由切换就暂停音频播放
  }

  /// function for checking and handling routes `Push` behavior and stop playing audio.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic>) {
      _handleRouteChanged(route);
    }
  }

  /// function for checking and handling routes `Pop` behavior and stop playing audio.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute<dynamic>) {
      _handleRouteChanged(previousRoute);
    }
  }

  /// function for checking and handling routes `Replace route` behavior and stop playing audio.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute<dynamic>) {
      _handleRouteChanged(newRoute);
    }
  }
}
