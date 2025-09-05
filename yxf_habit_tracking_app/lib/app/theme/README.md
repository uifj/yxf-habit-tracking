# Flutter Theme Management with BLoC

基于 BLoC Cubit 模式的 Flutter 主题管理系统

## 概述

这是一个使用 BLoC Cubit 模式重构的主题管理系统，提供了灵活、响应式的主题切换功能。该系统支持亮色/暗色模式切换、自定义主色调、自定义颜色配置等功能。

## 架构设计

### 核心组件

1. **ThemeCubit** - 主题状态管理
2. **ThemeState** - 主题状态数据模型
3. **AppThemeFactory** - 主题工厂类
4. **ThemeBuilder** - 主题构建器组件
5. **Extensions** - 便捷访问扩展

### 文件结构

```
lib/app/theme/
├── cubit/
│   ├── theme_cubit.dart          # 主题状态管理
│   └── theme_state.dart          # 主题状态模型
├── models/
│   └── theme_models.dart         # 主题数据模型
├── widgets/
│   └── theme_builder.dart        # 主题相关组件
├── extensions/
│   └── theme_extensions.dart     # 扩展方法
├── examples/
│   └── theme_usage_example.dart  # 使用示例
├── theme_factory.dart            # 主题工厂
├── theme.dart                    # 模块导出
└── README.md                     # 文档
```

## 快速开始

### 1. 基本集成

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/app/theme/theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit()
        ..setSystemTheme() // 初始化为系统主题
        ..setPrimaryColor(const Color(0xFF13B9FF)), // 设置默认主色调
      child: ThemeBuilder(
        builder: (context, lightTheme, darkTheme, themeMode) {
          return MaterialApp(
            title: 'My App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}
```

### 2. 使用主题切换组件

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主题管理示例'),
        actions: [
          ThemeSwitcher(), // 主题切换按钮
        ],
      ),
      body: Column(
        children: [
          ThemeModeIndicator(), // 主题模式指示器
          ThemeModeSelector(),  // 主题模式选择器
        ],
      ),
    );
  }
}
```

### 3. 程序化主题控制

```dart
// 切换亮暗模式
context.read<ThemeCubit>().toggleBrightness();

// 设置特定主题模式
context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);

// 设置主色调
context.read<ThemeCubit>().setPrimaryColor(Colors.blue);

// 设置自定义亮色主题颜色
context.read<ThemeCubit>().setLightThemeColors(
  CustomThemeColors(
    primary: Colors.blue,
    secondary: Colors.green,
    // ... 其他颜色
  ),
);

// 重置为默认主题
context.read<ThemeCubit>().resetToDefault();

// 跟随系统主题
context.read<ThemeCubit>().setSystemTheme();
```

## 扩展方法

系统提供了丰富的扩展方法，方便访问主题相关数据：

```dart
// 访问主题数据
context.theme          // 当前 ThemeData
context.colorScheme    // 当前 ColorScheme
context.textTheme      // 当前 TextTheme

// 检查主题模式
context.isDark         // 是否为暗色模式
context.isLight        // 是否为亮色模式

// 访问 ThemeCubit 和 ThemeState
context.themeCubit     // ThemeCubit 实例
context.themeState     // 当前 ThemeState

// 快捷操作
context.toggleTheme()           // 切换亮暗模式
context.setThemeMode(mode)      // 设置主题模式
context.setPrimaryColor(color)  // 设置主色调
```

## 自定义主题

### 1. 自定义颜色

```dart
// 定义自定义亮色主题颜色
final customLightColors = CustomThemeColors(
  primary: Color(0xFF1976D2),
  secondary: Color(0xFF388E3C),
  surface: Color(0xFFFAFAFA),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFD32F2F),
);

// 应用自定义颜色
context.read<ThemeCubit>().setLightThemeColors(customLightColors);
```

### 2. 自定义暗色主题

```dart
// 定义自定义暗色主题颜色
final customDarkColors = DarkCustomThemeColors(
  primary: Color(0xFF90CAF9),
  secondary: Color(0xFFA5D6A7),
  surface: Color(0xFF121212),
  background: Color(0xFF000000),
  error: Color(0xFFCF6679),
);

// 应用自定义暗色颜色
context.read<ThemeCubit>().setDarkThemeColors(customDarkColors);
```

## 主题持久化

可以结合 `shared_preferences` 或其他持久化方案来保存用户的主题偏好：

```dart
class ThemePersistence {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }
  
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }
  
  static Future<void> savePrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }
  
  static Future<Color> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_primaryColorKey) ?? 0xFF13B9FF;
    return Color(colorValue);
  }
}
```

## 与现有代码的兼容性

为了保持向后兼容性，原有的 `AppTheme` 类仍然可用：

```dart
// 旧的使用方式仍然有效
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  // ...
)
```

## 最佳实践

1. **在应用根部提供 ThemeCubit**：确保整个应用都能访问主题状态
2. **使用 ThemeBuilder**：让主题变更能够响应式地更新整个应用
3. **利用扩展方法**：使用提供的扩展方法来简化主题访问
4. **持久化用户偏好**：保存用户的主题选择，提升用户体验
5. **测试主题切换**：确保在不同主题下UI都能正常显示

## 性能考虑

- 主题切换使用 BLoC 的响应式更新，只有依赖主题的组件会重建
- `ThemeBuilder` 优化了主题数据的传递，避免不必要的重建
- 扩展方法提供了高效的主题数据访问

## 故障排除

### 常见问题

1. **主题切换不生效**
   - 确保使用了 `ThemeBuilder` 包装 `MaterialApp`
   - 检查是否正确提供了 `ThemeCubit`

2. **扩展方法不可用**
   - 确保导入了 `extensions/theme_extensions.dart`
   - 检查是否在正确的 `BuildContext` 中使用

3. **自定义颜色不显示**
   - 确保调用了相应的设置方法
   - 检查颜色值是否正确

## 示例代码

完整的使用示例请参考 `examples/theme_usage_example.dart` 文件。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个主题管理系统。

## 许可证

本项目采用 MIT 许可证。