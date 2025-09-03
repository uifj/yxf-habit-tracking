import 'package:tencent_cloud_chat_common/data/basic/tencent_cloud_chat_basic_data.dart';
import 'package:tencent_cloud_chat_common/data/search/tencent_cloud_chat_search_data.dart';
import 'package:tencent_cloud_chat_common/data/theme/tencent_cloud_chat_theme.dart';

/// A class that manages the core data for TencentCloudChat .
///
/// This class provides access to various data classes for the Chat UIKit,
/// such as basic data, conversation data, message data, theme data,
/// group profile data, and user profile data.
class TencentCloudChatData {
  static TencentCloudChatData? _instance;
  static TencentCloudChatData getInstance() {
    _instance ??= TencentCloudChatData._internal();

    return _instance!;
  }

  TencentCloudChatData._internal();

  final TencentCloudChatTheme theme = TencentCloudChatTheme(); // 主题数据
  final TencentCloudChatBasicData basic =
      TencentCloudChatBasicData<TencentCloudChatBasicDataKeys>(
          TencentCloudChatBasicDataKeys.none); // 基础数据
  final TencentCloudChatSearchData search =
      TencentCloudChatSearchData(TencentCloudChatSearchDataKeys.none); // 搜索数据
}
