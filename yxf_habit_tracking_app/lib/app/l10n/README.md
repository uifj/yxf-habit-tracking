# Flutter 语言管理系统 (Locale Management System)

基于 BLoC Cubit 模式的 Flutter 语言管理系统，提供响应式的多语言支持和语言切换功能。

## 🚀 核心特性

- **响应式语言管理**: 基于 BLoC Cubit 模式，支持响应式语言状态管理
- **多语言支持**: 支持英语和中文，可轻松扩展其他语言
- **系统语言跟随**: 支持跟随系统语言设置
- **便捷的扩展方法**: 提供丰富的 BuildContext 扩展方法
- **预制 UI 组件**: 提供语言切换器、语言指示器等常用组件
- **类型安全**: 使用枚举和强类型确保语言管理的类型安全
- **向后兼容**: 与现有的 l10n 系统完全兼容

## 📁 文件结构

```
lib/app/l10n/
├── cubit/
│   ├── locale_cubit.dart      # 语言状态管理 Cubit
│   └── locale_state.dart      # 语言状态模型
├── widgets/
│   └── locale_builder.dart    # 语言相关 UI 组件
├── extensions/
│   └── locale_extensions.dart # BuildContext 扩展方法
├── examples/
│   └── locale_usage_example.dart # 使用示例
├── gen_l10n/
│   └── app_localizations.dart # 生成的本地化文件
├── l10n.dart                  # 统一导出文件
├── app_en.arb                 # 英文本地化资源
├── app_zh.arb                 # 中文本地化资源
└── README.md                  # 本文档
```

## 🎯 快速开始

### 1. 在应用中集成语言管理

```dart
// 在 app.dart 中添加 LocaleCubit
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocaleCubit()
            ..initializeWithSystemLocale(),
        ),
        // 其他 providers...
      ],
      child: const AppView(),
    );
  }
}

// 使用 LocaleBuilder 构建应用
class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (context, locale, supportedLocales) {
        return MaterialApp(
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const HomePage(),
        );
      },
    );
  }
}
```

### 2. 使用语言切换组件

```dart
// 语言切换器
LanguageSwitcher(
  onLanguageChanged: (language) {
    print('Language changed to: ${language.displayName}');
  },
)

// 快速语言切换按钮
QuickLanguageSwitcher()

// 语言选择器（下拉模式）
LanguageSelector(
  mode: LanguageSelectorMode.dropdown,
)

// 语言指示器
LanguageIndicator()
```

### 3. 程序化语言控制

```dart
// 获取 LocaleCubit 实例
final localeCubit = context.read<LocaleCubit>();

// 设置特定语言
localeCubit.setLanguage(SupportedLanguage.english);
localeCubit.setLanguage(SupportedLanguage.chinese);

// 根据语言代码设置
localeCubit.setLanguageByCode('en');
localeCubit.setLanguageByCode('zh');

// 切换语言
localeCubit.toggleLanguage();

// 跟随系统语言
localeCubit.setSystemLocale(true);

// 重置为默认语言
localeCubit.resetToDefault();
```

## 🔧 扩展方法

### BuildContext 扩展

```dart
// 语言访问
context.currentLocale        // 当前语言环境
context.languageCode         // 当前语言代码
context.currentLanguage      // 当前支持的语言
context.languageName         // 当前语言名称
context.languageDisplayName  // 当前语言显示名称

// 语言检查
context.isEnglish           // 是否为英语
context.isChinese           // 是否为中文
context.isSystemLocale      // 是否跟随系统语言

// 语言控制
context.setLanguage(SupportedLanguage.english)
context.setLanguageByCode('zh')
context.toggleLanguage()
context.setSystemLocale(true)
context.resetLanguage()

// 本地化访问
context.localizations       // AppLocalizations 实例
```

### SupportedLanguage 扩展

```dart
SupportedLanguage.english.locale        // Locale('en')
SupportedLanguage.chinese.displayName   // '中文'
SupportedLanguage.fromCode('en')        // SupportedLanguage.english
```

### Locale 扩展

```dart
Locale('en').isSupported           // 检查是否支持
Locale('zh').displayName           // 获取显示名称
Locale('ar').isRTL                 // 检查是否为RTL语言
Locale('en').textDirection         // 获取文本方向
```

## 🎨 自定义语言

### 添加新语言支持

1. **更新 SupportedLanguage 枚举**:
```dart
enum SupportedLanguage {
  english('en', 'English', 'English'),
  chinese('zh', '中文', '中文'),
  japanese('ja', '日本語', '日本語'), // 新增日语
  // ...
}
```

2. **更新 LocaleConfig**:
```dart
class LocaleConfig {
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage.english,
    SupportedLanguage.chinese,
    SupportedLanguage.japanese, // 添加日语支持
  ];
}
```

3. **添加本地化资源文件**:
- 创建 `app_ja.arb` 文件
- 运行 `flutter gen-l10n` 生成本地化代码

## 💾 语言持久化

系统会自动保存用户的语言选择。如需自定义持久化逻辑，可以扩展 `LocaleCubit`：

```dart
class PersistentLocaleCubit extends LocaleCubit {
  final SharedPreferences _prefs;
  
  PersistentLocaleCubit(this._prefs) {
    _loadSavedLanguage();
  }
  
  @override
  void setLanguage(SupportedLanguage language) {
    super.setLanguage(language);
    _saveLanguage(language);
  }
  
  void _loadSavedLanguage() {
    final savedCode = _prefs.getString('language_code');
    if (savedCode != null) {
      setLanguageByCode(savedCode);
    }
  }
  
  void _saveLanguage(SupportedLanguage language) {
    _prefs.setString('language_code', language.code);
  }
}
```

## 🔄 与现有代码的兼容性

新的语言管理系统完全兼容现有的 `AppLocalizationsX` 扩展：

```dart
// 旧版本用法（仍然支持）
context.l10n.appTitle

// 新版本用法
context.localizations.appTitle
```

## 📋 最佳实践

### 1. 语言状态监听
```dart
// 使用 LocaleBuilder 进行响应式构建
LocaleBuilder(
  builder: (context, locale, supportedLocales) {
    return Text('Current language: ${locale.languageCode}');
  },
)

// 使用 BlocListener 监听语言变化
BlocListener<LocaleCubit, LocaleState>(
  listener: (context, state) {
    print('Language changed to: ${state.currentLanguage.displayName}');
  },
  child: YourWidget(),
)
```

### 2. 条件渲染
```dart
// 根据语言显示不同内容
if (context.isEnglish) {
  return EnglishSpecificWidget();
} else if (context.isChinese) {
  return ChineseSpecificWidget();
}
```

### 3. 语言切换动画
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: LocaleBuilder(
    key: ValueKey(context.currentLanguage),
    builder: (context, locale, supportedLocales) {
      return YourLocalizedWidget();
    },
  ),
)
```

## ⚡ 性能考虑

- **LocaleBuilder**: 只在语言状态变化时重建，避免不必要的重建
- **扩展方法**: 提供高效的语言访问，避免重复的 BLoC 查找
- **状态管理**: 使用 Cubit 而非 Bloc，减少样板代码和提高性能
- **类型安全**: 编译时检查，避免运行时错误

## 🐛 故障排除

### 常见问题

1. **语言切换不生效**
   - 确保在应用根部提供了 `LocaleCubit`
   - 检查 `MaterialApp` 是否正确配置了 `locale` 和 `supportedLocales`

2. **扩展方法不可用**
   - 确保导入了 `package:your_app/app/l10n/l10n.dart`
   - 检查是否在正确的 BuildContext 中使用

3. **本地化字符串不显示**
   - 运行 `flutter gen-l10n` 重新生成本地化文件
   - 检查 ARB 文件格式是否正确

### 调试技巧

```dart
// 打印当前语言状态
print('Current language: ${context.currentLanguage}');
print('Is system locale: ${context.isSystemLocale}');
print('Supported locales: ${LocaleConfig.supportedLocales}');

// 监听语言变化
BlocListener<LocaleCubit, LocaleState>(
  listener: (context, state) {
    debugPrint('Language state changed: $state');
  },
  child: YourWidget(),
)
```

## 📚 示例代码

完整的使用示例请参考 `examples/locale_usage_example.dart` 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个语言管理系统！

---

**注意**: 这个语言管理系统基于 BLoC Cubit 模式设计，提供了类型安全、响应式更新、解耦设计、易于测试和向后兼容的架构优势。