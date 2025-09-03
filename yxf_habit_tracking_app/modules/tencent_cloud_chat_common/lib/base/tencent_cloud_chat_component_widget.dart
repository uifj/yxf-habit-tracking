import 'package:flutter/material.dart';

/// 一个抽象的组件类，采用了组件化的架构，将一些组件都封装出来。 即插即用。
/// This abstract class represents a base component for Tencent Cloud Chat.
///
/// This abstract class serves as the foundation for all primary components in Tencent Cloud Chat,
/// such as Message, Conversation, etc. By extending this class, external developers can benefit
/// from consistent parameter naming and a clear understanding of how to use these components effectively.
abstract class TencentCloudChatComponent<T, U, K, H> extends StatefulWidget {
  /// The options for the component, such as conversation ID, message type, etc.
  final T? options;

  /// The configuration for the component, including module and function switches, 功能开关
  /// and other settings like `upperRecallTime`, appearance, etc.
  final U? config;

  /// The custom builders for the component, such as message widget builder,
  /// avatar builder, etc., which allow developers to customize the appearance
  /// and behavior of the component.
  ///* 自定义构建器，用于自定义组件
  final K? builders;

  /// The event handlers for the component, including lifecycle hooks like
  /// events related to chat business (e.g., before or after sending a message),
  /// interactive events (e.g., onTapAvatar), and more.
  //* 事件处理器，包括生命周期钩子和交互事件
  final H? eventHandlers;

  /// Constructor for TencentCloudChatComponent.
  const TencentCloudChatComponent({
    Key? key,
    this.options,
    this.config,
    this.builders,
    this.eventHandlers,
  }) : super(key: key);
}
