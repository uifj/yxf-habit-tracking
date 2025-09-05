# Tencent Cloud Chat Common Widgets

Introducing the Common Widgets collection, an essential part of the Tencent Cloud Chat UIKit, designed to provide you with a set of versatile and reusable components.

These components are engineered to automatically adapt to both mobile and desktop environments, ensuring a consistent and responsive user interface across platforms.

To streamline the development process and maintain UI consistency throughout your chat applications, we have made all our internal common components available for you to use. 

By leveraging these pre-built widgets, you can significantly reduce development time and effort while maintaining a professional and cohesive appearance in your applications.

The required plugins for integration are:
- [tencent_cloud_chat_common](https://pub.dev/packages/tencent_cloud_chat_common)
- [tencent_cloud_chat_conversation](https://pub.dev/packages/tencent_cloud_chat_conversation)
- [tencent_cloud_chat_message](https://pub.dev/packages/tencent_cloud_chat_message)
- [tencent_cloud_chat_contact](https://pub.dev/packages/tencent_cloud_chat_contact)
- [tencent_cloud_chat_sticker](https://pub.dev/packages/tencent_cloud_chat_sticker)
- [tencent_cloud_chat_message_reaction](https://pub.dev/packages/tencent_cloud_chat_message_reaction)
- [tencent_cloud_chat_text_translate](https://pub.dev/packages/tencent_cloud_chat_text_translate)
- [tencent_cloud_chat_sound_to_text](https://pub.dev/packages/tencent_cloud_chat_sound_to_text)
- [tencent_cloud_chat_push](https://pub.dev/packages/tencent_cloud_chat_push)
- [tencent_calls_uikit](https://pub.dev/packages/tencent_calls_uikit)

For the integration method, please refer to [github demo](https://github.com/TencentCloud/chat-demo-flutter/tree/v2).

To integrate the old version of **WeChat style** UI, please integrate [tencent_cloud_chat_uikit](https://pub.dev/packages/tencent_cloud_chat_uikit), you can refer to [github demo](https://github.com/TencentCloud/chat-demo-flutter/tree/main).

## Usage Examples

Here are a few examples of how you can utilize these common widgets in your application:

- **TencentCloudChatAvatar**: This is an Avatar component that you can use to display user or group avatars.
- **TencentCloudChatOperationBar**: This is a configurable operation bar component that you can customize to suit your application needs.

And many more components are available for you to explore and integrate into your chat applications.

## Desktop-Specific Components

In addition to the common components, we also provide a set of desktop-specific components. These components are designed to cater to desktop interactions, offering a more tailored user experience on desktop environments. For instance:

- **TencentCloudChatDesktopPopup.showColumnMenu**: This is a vertical menu component, typically used for context menus.
- **TencentCloudChatDesktopPopup.showSecondaryConfirmDialog**: This is a secondary confirmation dialog component, used when you need user confirmation for actions such as deleting a message.
- **TencentCloudChatDesktopPopup.showPopupWindow**: This component displays a movable modal window.
- **TencentCloudChatDesktopPopup.showMedia**: This is a full-screen media preview component for images, videos, and more.
- **TencentCloudChatDragArea**: This component provides a drag area for desktop applications.

These are just a few examples of the many components available in the Tencent Cloud Chat UIKit. Feel free to explore these and many other components to create a truly engaging and user-friendly chat application.

If you have any questions or need further information, feel free to reach out us.

- [Telegram](https://t.me/+gvScYl0uQ3U4MTRl)
- [X (Twitter)](https://x.com/runlin_wang95)

---

## 📚 架构设计文档

### 🏗️ 系统架构概览

`tencent_cloud_chat_common` 是腾讯云聊天 UIKit 的核心基础模块，采用企业级模块化架构设计，为整个聊天系统提供统一的基础服务和组件支持。

**核心架构特点**：
- **分层架构**：数据层 → 业务层 → 表现层的清晰分层
- **模块化设计**：独立的功能模块，低耦合高内聚
- **事件驱动**：基于 EventBus 的组件间通信机制
- **单例模式**：核心服务采用单例确保全局一致性

### 🎯 核心模块说明

#### 📁 `/lib/base/` - 基础抽象层
提供所有组件的基础抽象类和通用接口定义。

- **`tencent_cloud_chat_component_widget.dart`**: 组件基类，定义统一的组件接口
- **`tencent_cloud_chat_state_widget.dart`**: 状态管理基类
- **`tencent_cloud_chat_theme_widget.dart`**: 主题相关基类

#### 🎨 `/lib/data/` - 数据管理层
统一的数据访问和状态管理中心。

- **`/basic/`**: 基础数据管理，包含用户配置、登录状态等
- **`/theme/`**: 主题数据管理，支持亮色/暗色模式切换
- **`/search/`**: 搜索相关数据管理
- **`tencent_cloud_chat_data.dart`**: 数据管理器主入口
- **`tencent_cloud_chat_data_abstract.dart`**: 数据抽象基类

#### 🚌 `/lib/eventbus/` - 事件总线系统
基于观察者模式的组件间通信机制。

- **`tencent_cloud_chat_eventbus.dart`**: 事件总线核心实现
  - 类型安全的事件传递
  - 白名单机制防止滥用
  - 事件缓存支持
  - 广播流支持多订阅者

#### 💾 `/lib/cache/` - 缓存系统
基于 Hive 的高性能本地缓存解决方案。

- **`tencent_cloud_chat_cache_global.dart`**: 全局缓存管理器
  - 支持语言环境缓存
  - 权限信息缓存
  - 键盘高度缓存
  - 自动初始化和清理

#### 📝 `/lib/log/` - 日志系统
分级日志记录和管理系统。

- **`tencent_cloud_chat_log.dart`**: 日志管理器
  - 支持 5 个日志级别（none/debug/info/error/all）
  - 批量写入提高性能
  - 内存缓存 + 定时写入
  - Debug 模式实时控制台输出

#### 🧭 `/lib/router/` - 路由管理系统
全局路由注册和导航管理。

- **`tencent_cloud_chat_router.dart`**: 路由管理器核心
- **`tencent_cloud_chat_route_names.dart`**: 路由名称定义
- **`tencent_cloud_chat_navigator.dart`**: 导航辅助函数

支持的路由包括：
- 会话页面 (`conversation`)
- 消息页面 (`message`)
- 用户资料 (`userProfile`)
- 群组资料 (`groupProfile`)
- 搜索功能 (`globalSearch`, `messageSearch`)

#### 🎭 `/lib/observer/` - 路由观察者
监听路由变化并执行相应操作。

- **`tencent_cloud_chat_observer.dart`**: 路由观察者实现
  - 继承 Flutter RouteObserver
  - 自动处理音频播放状态
  - 支持路由生命周期监听

#### 🧩 `/lib/components/` - 组件配置系统
组件配置和事件处理的统一管理。

- **`/component_config/`**: 组件配置类
- **`/component_event_handlers/`**: 事件处理器
- **`/component_options/`**: 组件选项定义
- **`/components_definition/`**: 组件定义和基类

#### 🛠️ `/lib/utils/` - 工具类库
提供各种实用工具和辅助功能。

- **`tencent_cloud_chat_utils.dart`**: 通用工具函数
- **`error_message_converter.dart`**: 错误消息转换器
- **`tencent_cloud_chat_permission_handlers.dart`**: 权限处理器
- **`tencent_cloud_chat_download_utils.dart`**: 下载工具
- **`tencent_cloud_chat_lru.dart`**: LRU 缓存实现

#### 🎨 `/lib/widgets/` - UI 组件库
丰富的可复用 UI 组件集合。

- **`/avatar/`**: 头像组件
- **`/cacheImage/`**: 缓存图片组件
- **`/dialog/`**: 对话框组件
- **`/shimmer/`**: 骨架屏组件
- **`/operation_bar/`**: 操作栏组件
- **`/desktop_popup/`**: 桌面端弹窗组件
- **`material_app.dart`**: 主应用组件

#### 🌐 `/lib/cross_platforms_adapter/` - 跨平台适配
处理不同平台的差异化需求。

- **`tencent_cloud_chat_platform_adapter.dart`**: 平台检测和适配
- **`tencent_cloud_chat_screen_adapter.dart`**: 屏幕适配

### 🏛️ 设计模式应用

| 设计模式 | 应用场景 | 核心类 |
|----------|----------|--------|
| **单例模式** | 核心服务管理 | `TencentCloudChatRouter`, `TencentCloudChatLog`, `TencentCloudChatEventBus` |
| **观察者模式** | 事件通信、主题变更 | `TencentCloudChatEventBus`, `TencentCloudChatTheme` |
| **工厂模式** | 组件创建 | 各种 Builder 类 |
| **适配器模式** | 平台差异处理 | `TencentCloudChatPlatformAdapter` |
| **模板方法模式** | 组件基类设计 | `TencentCloudChatComponent` |

### 🚀 核心特性

#### 1. 统一入口管理
```dart
// 通过 TencentCloudChat 单例访问所有核心服务
TencentCloudChat.instance.logInstance     // 日志服务
TencentCloudChat.instance.dataInstance    // 数据管理
TencentCloudChat.instance.eventBusInstance // 事件总线
TencentCloudChat.instance.cache           // 缓存服务
```

#### 2. 事件驱动架构
```dart
// 监听主题变更事件
TencentCloudChat.instance.eventBusInstance
  .on<TencentCloudChatTheme>('TencentCloudChatTheme')
  ?.listen((theme) {
    // 处理主题变更
  });
```

#### 3. 智能缓存系统
```dart
// 缓存用户语言设置
await TencentCloudChat.instance.cache.cacheLocale(locale);

// 获取缓存的语言设置
Locale? cachedLocale = TencentCloudChat.instance.cache.getCachedLocale();
```

#### 4. 全局路由管理
```dart
// 注册路由
TencentCloudChatRouter().registerRouter(
  routeName: TencentCloudChatRouteNames.conversation,
  builder: (context) => ConversationPage(),
);

// 导航到指定页面
navigateToConversation(
  context: context,
  options: ConversationOptions(),
);
```

### 📊 性能优化策略

1. **懒加载机制**: 组件按需初始化，减少启动时间
2. **内存管理**: 智能缓存策略，自动清理过期数据
3. **批量操作**: 日志批量写入，事件批量处理
4. **跨平台优化**: 针对不同平台的性能调优

### 🔒 安全与合规

- **数据加密**: 敏感数据本地加密存储
- **权限管理**: 最小权限原则，动态权限检查
- **输入验证**: 防止注入攻击和数据污染
- **隐私保护**: 符合 GDPR 等国际隐私法规

### 🧪 测试策略

- **单元测试**: 核心模块 90% 以上覆盖率
- **集成测试**: 组件间协作验证
- **性能测试**: 内存使用、响应时间监控
- **兼容性测试**: 多平台、多设备适配验证

### 📈 架构演进

**当前版本 (v1.x)**:
- ✅ 基础架构建设完成
- ✅ 核心模块稳定运行
- ✅ 跨平台支持完善

**下一版本 (v2.x)**:
- 🔄 插件化架构支持
- 🔄 微服务架构演进
- 🔄 AI 功能集成

---

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下规范：

1. **代码风格**: 遵循 Dart 官方代码规范
2. **提交格式**: 使用语义化提交消息
3. **测试要求**: 新功能必须包含单元测试
4. **文档更新**: 重要变更需要更新文档

## 📄 许可证

本项目采用 MIT 许可证，详情请查看 [LICENSE](LICENSE) 文件。
