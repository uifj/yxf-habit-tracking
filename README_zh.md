🚀 yxf_habit_tracking - 有限风习惯追踪APP

yxf_habit_tracking APP 是一个企业级的跨平台习惯追踪应用，使用 Flutter 构建。帮助用户培养良好习惯、管理任务并提高生产力，包含番茄工作法、目标设定和实时打字练习等功能。

English Documentation | README.md

✨ 功能特性

🎯 核心模块

• 📅 日程待办管理

  • 父任务/子任务层级结构

  • 番茄钟计时器集成

  • 基于优先级的任务排序

• 🎯 习惯养成系统

  • 预定义目标（如"中文双拼目标"）

  • 自定义习惯创建

  • 进度跟踪和分析

• ⌨️ 实时打字练习

  • 在线打字练习

  • 可下载单词包

  • 中文文章练习包

• 📊 高级数据分析

  • 习惯完成统计

  • 生产力洞察

  • 可定制报告

• 🌐 WebView 集成

  • 应用内浏览器功能

  • 安全网页内容访问

🏗️ 企业级架构

• 整洁架构 分层设计（表现层-领域层-数据层）

• 多平台支持: Android, iOS, HarmonyOS, Windows, macOS

• 国际化 (i18n) 支持 ARB 文件

• 动态主题切换 与自定义设计系统

• BLoC 状态管理 实现可预测的状态转换

🛠️ 技术栈

框架与库

• Flutter 3.19.0 - 跨平台 UI 框架

• Dart 3.3.0 - 编程语言

• BLoC 8.1.0 - 状态管理

• Equatable - 值比较

• Dio - HTTP 客户端

国际化

• flutter_localizations - 官方本地化支持

• intl - 国际化包

• ARB 文件 - 翻译资源文件

数据持久化

• Hive - 本地数据库

• SharedPreferences - 简单键值存储

UI 组件

• Fluent UI - Windows 设计系统

• Cupertino - iOS 设计语言

• Material 3 - Android 材料设计

📁 项目结构


lib/
├── core/
│   ├── constants/          # 应用常量
│   ├── errors/             # 错误类
│   ├── network/            # Dio 客户端设置
│   ├── theme/              # 主题数据
│   └── utils/              # 工具类
├── data/
│   ├── datasources/        # 本地和远程数据源
│   ├── models/             # 数据模型
│   └── repositories/       # 仓库实现
├── domain/
│   ├── entities/           # 业务实体
│   ├── repositories/       # 仓库契约
│   └── usecases/           # 应用用例
├── presentation/
│   ├── blocs/              # BLoC 类
│   ├── pages/              # 页面
│   ├── widgets/            # 自定义组件
│   └── router/             # 应用路由
└── main.dart               # 应用入口点


🚀 快速开始

先决条件

• Flutter SDK 3.19.0 或更高版本

• Dart 3.3.0 或更高版本

• IDE (VS Code 或 Android Studio 带 Flutter 插件)

安装

1. 克隆仓库
   git clone https://github.com/your-username/yxf_habit_tracking.git
   cd yxf_habit_tracking
   

2. 安装依赖
   flutter pub get
   

3. 生成本地化文件
   flutter gen-l10n
   

4. 运行应用
   flutter run
   

构建指令

Android APK:
flutter build apk --release --target-platform android-arm64


iOS:
flutter build ios --release


Windows:
flutter build windows --release


macOS:
flutter build macos --release


🌍 国际化

应用使用 Flutter 内置的本地化系统与 ARB 文件：

1. 翻译文件: lib/l10n/arb/intl_*.arb
2. 生成类: lib/l10n/generated/
3. 支持语言: 英文、中文（简体）、中文（繁体）

添加新翻译：
flutter gen-l10n


🎨 主题系统

应用支持动态主题切换：

• 明亮/暗黑模式 切换

• 自定义配色方案

• 平台自适应主题 (Material/Cupertino/Fluent)
// 主题配置示例
ThemeData(
  primaryColor: Colors.blue,
  fontFamily: 'NotoSans',
  platform: TargetPlatform.windows,
);


📊 BLoC 状态管理

应用使用 BLoC 模式进行状态管理：
// BLoC 实现示例
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetHabits usecase;

  HabitBloc({required this.usecase}) : super(HabitInitial()) {
    on<LoadHabits>((event, emit) async {
      emit(HabitLoading());
      final result = await usecase();
      emit(HabitLoaded(habits: result));
    });
  }
}


🔧 配置

环境设置

在根目录创建 .env 文件：

APP_NAME=yxf_habit_tracking
API_BASE_URL=https://api.example.com
ENABLE_ANALYTICS=true


Firebase 设置 (可选)

1. 创建 Firebase 项目
2. 添加平台配置
3. 启用 Analytics, Crashlytics

📈 性能优化

应用实现了多种性能优化：

• Const 构造函数 用于 widget 优化

• ListView.builder 用于高效滚动

• 内存管理 与自动释放

• 图片缓存 与压缩

• 代码分割 减少包体积

🤝 贡献指南

我们欢迎贡献！请阅读CONTRIBUTING.md并遵循CODE_OF_CONDUCT.md。

开发流程

1. Fork 仓库
2. 创建特性分支 (git checkout -b feature/amazing-feature)
3. 提交更改 (git commit -m '添加神奇特性')
4. 推送到分支 (git push origin feature/amazing-feature)
5. 开启 Pull Request

代码标准

• Dart 风格: 遵循 Effective Dart 指南

• BLoC 模式: 简单状态使用 cubit

• 测试: ≥80% 测试覆盖率要求

• 文档: 文档化所有公共 API

📝 测试

单元测试

flutter test


Widget 测试

flutter test test/widget_test.dart


集成测试

flutter drive --target=test_driver/app.dart


📊 分析与监控

• Firebase Analytics - 用户行为跟踪

• Crashlytics - 错误监控

• Performance Monitoring - 应用性能指标

🚀 部署

Android Play Store

flutter build appbundle --release


iOS App Store

flutter build ipa --release


Windows Store

flutter build windows --release


📋 开发路线图
v1.0 - 基础习惯追踪和待办管理

v1.5 - 高级分析和数据可视化

v2.0 - AI 驱动的习惯推荐

v2.5 - 社交功能和社区挑战

v3.0 - 可穿戴设备集成

📄 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件。

🙏 致谢

• Flutter 团队 - 出色的跨平台框架

• BLoC 库 - 优秀的状态管理解决方案

• Hive - 快速的本地数据库

• 贡献者 - 所有帮助改进此项目的人

📞 支持

如果您有任何问题或需要帮助，请：

1. 查看docs/README.md
2. 提交../../issues
3. 联系我们: mailto:email@example.com

使用 💙 和 Flutter 构建

这两个 README 文件提供了完整的企业级 Flutter 应用文档，涵盖了架构设计、国际化、状态管理、多平台支持等关键方面。文档结构清晰，内容专业，符合开源项目标准。
