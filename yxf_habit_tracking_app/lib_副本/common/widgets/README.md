# 通用组件库

本目录包含了项目中的通用UI组件，经过优化后具有更好的可复用性、可定制性和代码质量。

## 组件列表

### 1. OpacityButton (透明背景按钮)

**文件位置**: `button/opacity_button.dart`

#### 优化内容
- ✅ **修复编译错误**: 解决了缺少 `context` 参数的问题
- ✅ **组件化重构**: 从函数式组件重构为 `StatelessWidget`
- ✅ **增强可定制性**: 添加了多个可选参数用于自定义样式
- ✅ **改进交互体验**: 添加了禁用状态和动画效果
- ✅ **保持向后兼容**: 提供便捷函数保持原有API

#### 主要特性
- 🎨 **主题适配**: 自动适配深色/浅色主题
- 🔧 **高度可定制**: 支持自定义尺寸、颜色、透明度等
- ♿ **无障碍支持**: 支持禁用状态的视觉反馈
- 🎭 **动画效果**: 内置平滑的过渡动画
- 📱 **响应式设计**: 适配不同屏幕尺寸

#### 使用示例

```dart
// 基础用法
OpacityButton(
  icon: Icons.settings,
  onTap: () => print('设置'),
)

// 自定义样式
OpacityButton(
  icon: Icons.favorite,
  onTap: () => print('收藏'),
  size: 56,
  iconSize: 24,
  iconColor: Colors.red,
  borderRadius: 16,
)

// 禁用状态
OpacityButton(
  icon: Icons.lock,
  onTap: () {},
  enabled: false,
)

// 便捷函数（向后兼容）
opacityButton(
  icon: Icons.share,
  onTap: () => print('分享'),
)
```

#### API 参数

| 参数 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `icon` | `IconData` | 必需 | 按钮图标 |
| `onTap` | `VoidCallback` | 必需 | 点击回调 |
| `size` | `double` | 44 | 按钮尺寸 |
| `iconSize` | `double` | 20 | 图标尺寸 |
| `borderRadius` | `double` | 12 | 圆角半径 |
| `enabled` | `bool` | true | 是否启用 |
| `backgroundOpacity` | `double?` | null | 背景透明度 |
| `borderOpacity` | `double?` | null | 边框透明度 |
| `iconColor` | `Color?` | null | 图标颜色 |

---

### 2. ActionModal (底部动作弹窗)

**文件位置**: `modal/action_modal.dart`

#### 优化内容
- ✅ **修复编译错误**: 解决了未定义的 `colorTheme` 和 `textStyle` 变量
- ✅ **使用标准主题系统**: 替换为 Flutter 标准的 `Theme` 系统
- ✅ **增强功能性**: 添加标题、自定义样式、危险操作等功能
- ✅ **改进用户体验**: 优化布局、动画和交互逻辑
- ✅ **保持向后兼容**: 提供废弃标记的兼容函数

#### 主要特性
- 🎨 **现代化设计**: 采用 Material Design 3 设计规范
- 🔧 **高度可配置**: 支持标题、自定义颜色、圆角等
- ⚠️ **危险操作支持**: 内置红色警告样式
- 🎭 **流畅动画**: 优化的弹出和关闭动画
- 📱 **安全区域适配**: 自动处理底部安全区域
- 🌓 **主题适配**: 完美适配深色/浅色主题

#### 使用示例

```dart
// 基础用法
showActionBottomModal(
  context: context,
  actions: [
    ActionModal(
      label: '分享',
      icon: Icons.share,
      onTap: () => print('分享'),
    ),
    ActionModal(
      label: '收藏',
      icon: Icons.bookmark,
      onTap: () => print('收藏'),
    ),
  ],
);

// 带标题的弹窗
showActionBottomModal(
  context: context,
  title: '选择操作',
  actions: [...],
);

// 包含危险操作
showActionBottomModal(
  context: context,
  title: '文件操作',
  actions: [
    ActionModal(
      label: '编辑',
      icon: Icons.edit,
      onTap: () => print('编辑'),
    ),
    ActionModal(
      label: '删除',
      icon: Icons.delete,
      onTap: () => print('删除'),
      isDestructive: true, // 危险操作样式
    ),
  ],
);

// 自定义样式
showActionBottomModal(
  context: context,
  backgroundColor: Colors.grey[100],
  borderRadius: 24,
  actions: [
    ActionModal(
      label: '自定义操作',
      icon: Icons.star,
      onTap: () => print('自定义'),
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.withOpacity(0.1),
    ),
  ],
);
```

#### ActionModal 参数

| 参数 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `label` | `String` | 必需 | 动作标签文本 |
| `icon` | `IconData` | 必需 | 动作图标 |
| `onTap` | `VoidCallback` | 必需 | 点击回调 |
| `iconColor` | `Color?` | null | 图标颜色 |
| `backgroundColor` | `Color?` | null | 背景颜色 |
| `textColor` | `Color?` | null | 文本颜色 |
| `isDestructive` | `bool` | false | 是否为危险操作 |

#### showActionBottomModal 参数

| 参数 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `context` | `BuildContext` | 必需 | 上下文 |
| `actions` | `List<ActionModal>` | 必需 | 动作列表 |
| `title` | `String?` | null | 弹窗标题 |
| `backgroundColor` | `Color?` | null | 背景颜色 |
| `borderRadius` | `double` | 16 | 圆角半径 |
| `enableDrag` | `bool` | true | 是否允许拖拽 |
| `isDismissible` | `bool` | true | 是否可点击外部关闭 |

---

## 示例代码

完整的使用示例请参考 `examples/component_examples.dart` 文件，其中包含了所有组件的各种用法演示。

## 迁移指南

### OpacityButton 迁移

**旧用法**:
```dart
// 编译错误的旧代码
opacityButton(
  icon: Icons.settings,
  onTap: () {},
)
```

**新用法**:
```dart
// 推荐使用组件形式
OpacityButton(
  icon: Icons.settings,
  onTap: () {},
)

// 或继续使用便捷函数（已修复）
opacityButton(
  icon: Icons.settings,
  onTap: () {},
)
```

### ActionModal 迁移

**旧用法**:
```dart
// 有编译错误的旧代码
showTencentCloudChatBottomModal(
  context: context,
  actions: [...],
)
```

**新用法**:
```dart
// 推荐使用新函数
showActionBottomModal(
  context: context,
  actions: [...],
)

// 旧函数仍可用但已废弃
showTencentCloudChatBottomModal( // @Deprecated
  context: context,
  actions: [...],
)
```

## 设计原则

1. **一致性**: 所有组件遵循统一的设计语言和交互模式
2. **可访问性**: 支持无障碍功能，包括语义化标签和键盘导航
3. **性能优化**: 使用高效的渲染和动画实现
4. **主题适配**: 完美支持深色/浅色主题切换
5. **向后兼容**: 保持API的向后兼容性，平滑迁移

## 注意事项

1. **主题依赖**: 组件依赖 Flutter 的 `Theme` 系统，确保在 `MaterialApp` 中使用
2. **上下文要求**: 某些组件需要有效的 `BuildContext`，注意调用时机
3. **性能考虑**: 避免在 `build` 方法中创建大量组件实例
4. **测试覆盖**: 建议为自定义配置编写单元测试

## 贡献指南

如需添加新组件或优化现有组件，请遵循以下原则：

1. 保持API的简洁性和一致性
2. 提供完整的文档和示例
3. 确保主题适配和无障碍支持
4. 添加适当的单元测试
5. 保持向后兼容性