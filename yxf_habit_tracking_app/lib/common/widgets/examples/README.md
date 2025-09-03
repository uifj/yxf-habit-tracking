# 通用模态窗口组件 (NormalModal)

这是一个基于 Flutter 的通用模态窗口组件，提供了统一的动画、布局和交互逻辑，可以用来替代项目中现有的各种模态窗口实现。

## 功能特性

- 🎨 **统一的视觉设计**: 基于 priospace-main 的设计风格
- 🎭 **流畅的动画效果**: 内置缩放和淡入淡出动画
- 🔧 **高度可定制**: 支持自定义标题、图标、颜色、尺寸等
- 📱 **响应式布局**: 自适应不同屏幕尺寸
- 🎯 **易于使用**: 简洁的 API 设计
- 🔄 **可复用组件**: 提供内容包装器、操作栏、按钮等辅助组件

## 组件结构

### 主要组件

1. **NormalModal**: 主模态窗口组件
2. **ModalContentWrapper**: 内容包装器，提供滚动和内边距
3. **ModalActionBar**: 底部操作栏
4. **ModalButton**: 统一样式的按钮组件

## 使用方法

### 基础用法

```dart
import 'package:flutter/material.dart';
import 'normal_modal.dart';

class MyModal extends StatelessWidget {
  final VoidCallback onClose;

  const MyModal({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NormalModal(
      title: '我的模态窗口',
      titleIcon: Icons.settings,
      primaryColor: const Color(0xFF6366F1),
      onClose: onClose,
      content: ModalContentWrapper(
        child: Column(
          children: [
            const Text('这是模态窗口的内容'),
            const SizedBox(height: 24),
            ModalActionBar(
              actions: [
                ModalButton(
                  text: '取消',
                  isOutlined: true,
                  onPressed: onClose,
                ),
                ModalButton(
                  text: '确认',
                  onPressed: () {
                    // 处理确认逻辑
                    onClose();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 高级用法

#### 带返回按钮的模态窗口

```dart
NormalModal(
  title: '添加新项目',
  titleIcon: Icons.add,
  primaryColor: const Color(0xFF10B981),
  showBackButton: true,
  onBack: () {
    // 处理返回逻辑
  },
  onClose: onClose,
  content: // 你的内容
)
```

#### 自定义头部操作按钮

```dart
NormalModal(
  title: '编辑项目',
  headerActions: [
    GestureDetector(
      onTap: () {
        // 删除操作
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 20,
        ),
      ),
    ),
  ],
  // 其他属性...
)
```

#### 禁用背景点击关闭

```dart
NormalModal(
  title: '重要操作',
  dismissible: false, // 禁用背景点击关闭
  // 其他属性...
)
```

## API 参考

### NormalModal 属性

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `title` | `String` | 必需 | 模态窗口标题 |
| `titleIcon` | `IconData?` | `null` | 标题图标 |
| `primaryColor` | `Color` | `Color(0xFF6366F1)` | 主题色 |
| `content` | `Widget` | 必需 | 模态窗口内容 |
| `onClose` | `VoidCallback` | 必需 | 关闭回调 |
| `maxWidth` | `double?` | `500` | 最大宽度 |
| `maxHeight` | `double?` | `700` | 最大高度 |
| `showBackButton` | `bool` | `false` | 是否显示返回按钮 |
| `onBack` | `VoidCallback?` | `null` | 返回按钮回调 |
| `showCloseButton` | `bool` | `true` | 是否显示关闭按钮 |
| `headerActions` | `List<Widget>?` | `null` | 自定义头部操作按钮 |
| `dismissible` | `bool` | `true` | 是否启用背景点击关闭 |

### ModalContentWrapper 属性

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `child` | `Widget` | 必需 | 子组件 |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(24)` | 内边距 |
| `scrollable` | `bool` | `true` | 是否可滚动 |

### ModalActionBar 属性

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `actions` | `List<Widget>` | 必需 | 操作按钮列表 |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(24)` | 内边距 |
| `alignment` | `MainAxisAlignment` | `MainAxisAlignment.end` | 对齐方式 |

### ModalButton 属性

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `text` | `String` | 必需 | 按钮文本 |
| `onPressed` | `VoidCallback?` | `null` | 点击回调 |
| `backgroundColor` | `Color?` | `null` | 背景色 |
| `textColor` | `Color?` | `null` | 文本颜色 |
| `isOutlined` | `bool` | `false` | 是否为轮廓按钮 |
| `isExpanded` | `bool` | `false` | 是否展开填充 |
| `icon` | `IconData?` | `null` | 按钮图标 |

## 迁移指南

### 从现有模态窗口迁移

1. **提取内容部分**: 将现有模态窗口的内容部分提取出来
2. **使用 NormalModal**: 用 NormalModal 包装内容
3. **配置属性**: 根据原有设计配置标题、颜色等属性
4. **重构操作按钮**: 使用 ModalActionBar 和 ModalButton 重构按钮

### 示例迁移

**迁移前 (SettingsModal)**:
```dart
class SettingsModal extends StatefulWidget {
  // 大量重复的动画和布局代码
}
```

**迁移后**:
```dart
class SettingsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NormalModal(
      title: '设置',
      titleIcon: Icons.settings,
      primaryColor: const Color(0xFF6366F1),
      onClose: onClose,
      content: ModalContentWrapper(
        child: // 原有的设置内容
      ),
    );
  }
}
```

## 设计原则

1. **一致性**: 所有模态窗口使用统一的视觉风格
2. **可复用性**: 组件设计支持多种使用场景
3. **可扩展性**: 提供足够的自定义选项
4. **性能优化**: 合理的动画和渲染优化
5. **用户体验**: 流畅的交互和反馈

## 注意事项

1. 确保在使用前导入正确的包
2. 模态窗口内容过多时会自动启用滚动
3. 动画控制器会自动管理，无需手动处理
4. 建议为不同类型的模态窗口使用不同的主题色
5. 在表单模态窗口中，建议使用 ModalActionBar 统一按钮布局

## 示例文件

查看 `modal_examples.dart` 文件了解完整的使用示例，包括:
- 设置模态窗口
- 计时器模态窗口  
- 习惯追踪模态窗口

这些示例展示了如何使用通用组件重构现有的复杂模态窗口。