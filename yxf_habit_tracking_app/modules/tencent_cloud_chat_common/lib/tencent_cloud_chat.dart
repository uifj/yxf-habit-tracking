library tencent_cloud_chat;

import 'package:tencent_cloud_chat_common/cache/tencent_cloud_chat_cache_global.dart';
// import 'package:tencent_cloud_chat_common/chat_sdk/tencent_cloud_chat_sdk.dart';
// import 'package:tencent_cloud_chat_common/controller/tencent_cloud_chat_controller.dart';
import 'package:tencent_cloud_chat_common/data/tencent_cloud_chat_data.dart';
import 'package:tencent_cloud_chat_common/eventbus/tencent_cloud_chat_eventbus.dart';
import 'package:tencent_cloud_chat_common/log/tencent_cloud_chat_log.dart';
// import 'package:tencent_cloud_chat_common/models/tencent_cloud_chat_callbacks_trigger.dart';
import 'package:tencent_cloud_chat_common/observer/tencent_cloud_chat_observer.dart';

export 'package:path_provider/path_provider.dart';
export 'package:tencent_cloud_chat_intl/tencent_cloud_chat_intl.dart';

// 主要入口类
// - 统一入口 ：通过 TencentCloudChat.instance 提供全局访问点
// - 依赖注入 ：集成所有核心组件实例
// - 模块导出 ：导出常用的第三方库（path_provider、国际化）
class TencentCloudChat {
  TencentCloudChat._();

  static final TencentCloudChat _instance = TencentCloudChat._();

  static TencentCloudChat get instance => _instance;

  // final TencentCloudChatCallbacksTrigger callbacks =
  //     TencentCloudChatCallbacksTriggerGenerator.getInstance();

  // final TencentCloudChatCoreController chatController =
  //     TencentCloudChatCoreControllerGenerator.getInstance();

  // static TencentCloudChatCoreController get controller =>
  //     TencentCloudChat.instance.chatController;

  final TencentCloudChatLog logInstance =
      TencentCloudChatLogGenerator.getInstance();

  final TencentCloudChatData dataInstance = TencentCloudChatData.getInstance();

  final TencentCloudChatEventBus eventBusInstance =
      TencentCloudChatEventBusGenerator.getInstance();

  // final TencentCloudChatSDK chatSDKInstance =
  //     TencentCloudChatSDKGenerator.getInstance();

  final TencentCloudChatCacheGlobal cache =
      TencentCloudChatCacheGlobal.instance;

  final TencentCloudChatObserver navigatorObserver =
      TencentCloudChatObserver.getInstance();
}
