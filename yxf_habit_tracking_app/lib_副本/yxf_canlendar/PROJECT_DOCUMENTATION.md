# YXF Calendar - 企业级任务管理与习惯追踪系统

## 项目概述

**YXF Calendar** 是一个基于 Flutter 开发的企业级任务管理与习惯追踪系统，采用现代化的架构设计和最佳实践。该项目遵循 Clean Architecture 原则，使用 BLoC 状态管理模式，提供了完整的任务管理、习惯追踪、数据同步等功能。

### 核心特性

- 🎯 **任务管理**: 创建、编辑、删除、完成任务，支持子任务和优先级
- 📅 **日历视图**: 直观的日历界面，支持日期筛选和任务展示
- 🔄 **习惯追踪**: 习惯养成追踪，支持连击统计和完成率分析
- ⏱️ **番茄钟**: 集成番茄工作法，提升工作效率
- 🏷️ **标签系统**: 灵活的标签分类管理
- 🔄 **数据同步**: 本地与远程数据同步，支持离线模式
- 🌙 **主题切换**: 支持浅色/深色主题自动切换
- 🔔 **通知提醒**: 本地通知和定时提醒功能
- 📊 **数据统计**: 详细的任务和习惯统计分析

## 技术架构

### 架构模式

项目采用 **Clean Architecture** + **BLoC** 的架构模式：

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   Pages     │  │   Widgets   │  │      BLoC       │  │
│  │             │  │             │  │  (State Mgmt)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Use Cases  │  │   Entities  │  │  Repositories   │  │
│  │             │  │   (Models)  │  │  (Interfaces)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Repositories│  │ Data Sources│  │    Services     │  │
│  │ (Impl)      │  │ (Local/API) │  │  (External)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 目录结构

```
lib/yxf_canlendar/
├── lib/
│   ├── core/                          # 核心功能模块
│   │   ├── config/                    # 配置文件
│   │   │   └── size_config.dart       # 屏幕尺寸配置
│   │   ├── db/                        # 数据库层
│   │   │   ├── db_helper.dart         # SQLite数据库助手
│   │   │   └── shared_prefs_helper.dart # SharedPreferences助手
│   │   ├── error/                     # 错误处理
│   │   │   ├── exceptions.dart        # 异常定义
│   │   │   └── failures.dart          # 失败类型定义
│   │   ├── providers/                 # Provider状态管理
│   │   │   ├── calendar_provider.dart # 日历状态提供者
│   │   │   ├── provider_setup.dart    # Provider配置
│   │   │   └── task_provider.dart     # 任务状态提供者
│   │   ├── utils/                     # 工具类
│   │   │   ├── date_util.dart         # 日期工具
│   │   │   ├── logger.dart            # 日志工具
│   │   │   └── toast_util.dart        # 提示工具
│   │   └── dependency_injection.dart  # 依赖注入
│   ├── data/                          # 数据层
│   │   ├── models/                    # 数据模型
│   │   │   ├── task.dart              # 任务模型
│   │   │   ├── habit.dart             # 习惯模型
│   │   │   └── custom_tag.dart        # 标签模型
│   │   ├── repositories/              # 数据仓库实现
│   │   │   ├── task_repository.dart   # 任务仓库
│   │   │   ├── habit_repository.dart  # 习惯仓库
│   │   │   ├── timer_repository.dart  # 计时器仓库
│   │   │   └── tag_repository.dart    # 标签仓库
│   │   └── services/                  # 外部服务
│   │       └── task_services.dart     # 任务API服务
│   └── presentation/                  # 表现层
│       ├── bloc/                      # BLoC状态管理
│       │   ├── todo_bloc.dart         # 任务BLoC
│       │   ├── todo_event.dart        # 任务事件
│       │   ├── todo_state.dart        # 任务状态
│       │   ├── habit_bloc.dart        # 习惯BLoC
│       │   ├── timer_bloc.dart        # 计时器BLoC
│       │   └── tag_bloc.dart          # 标签BLoC
│       ├── pages/                     # 页面组件
│       │   ├── yxfmain.dart           # 应用主入口
│       │   └── calendar_page.dart     # 日历页面
│       └── widgets/                   # UI组件
│           ├── task_list_widget.dart  # 任务列表组件
│           ├── task_tile.dart         # 任务项组件
│           ├── habit_tile.dart        # 习惯项组件
│           └── habit_tracker_modal.dart # 习惯追踪模态窗口
├── huunu_canlendar.dart               # 模块导出文件
├── test_app.dart                      # 测试应用入口
└── README.md                          # 项目说明文档
```

## 核心功能模块

### 1. 任务管理系统

#### 数据模型

**Task 模型**包含以下核心字段：
- `id`: 任务唯一标识
- `title`: 任务标题
- `note`: 任务描述
- `isCompleted`: 完成状态
- `priority`: 优先级（低、中、高）
- `date`: 任务日期
- `startTime/endTime`: 开始/结束时间
- `subtasks`: 子任务列表
- `tag`: 关联标签
- `focusTimeSeconds`: 专注时间统计
- `metadata`: 扩展数据

#### 功能特性

- ✅ CRUD操作（创建、读取、更新、删除）
- ✅ 子任务管理
- ✅ 优先级设置
- ✅ 日期筛选
- ✅ 标签分类
- ✅ 批量操作
- ✅ 搜索功能

### 2. 习惯追踪系统

#### 数据模型

**Habit 模型**包含以下核心字段：
- `id`: 习惯唯一标识
- `name`: 习惯名称
- `description`: 习惯描述
- `completedDates`: 完成日期列表
- `subtasks`: 习惯子任务
- `streak`: 连续完成天数
- `totalCompletions`: 总完成次数
- `isActive`: 激活状态

#### 功能特性

- 📊 习惯完成统计
- 🔥 连击天数计算
- 📈 完成率分析
- 🎯 目标设定
- 📅 历史记录查看

### 3. BLoC 状态管理

#### TodoBloc（任务管理）

**事件类型**：
- `InitializeTodoEvent`: 初始化
- `LoadTasksEvent`: 加载任务
- `AddTaskEvent`: 添加任务
- `UpdateTaskEvent`: 更新任务
- `DeleteTaskEvent`: 删除任务
- `FilterTasksByDateEvent`: 按日期筛选
- `SyncDataEvent`: 数据同步

**状态类型**：
- `TodoInitial`: 初始状态
- `TodoLoading`: 加载中
- `TodoLoaded`: 加载完成
- `TodoError`: 错误状态
- `TodoSyncing`: 同步中

#### HabitBloc（习惯管理）

提供习惯追踪的完整状态管理，包括习惯的增删改查、完成标记、统计分析等功能。

### 4. 数据持久化

#### 本地存储

- **SharedPreferences**: 轻量级数据存储，适用于鸿蒙平台
- **数据序列化**: JSON格式存储，支持复杂数据结构
- **缓存管理**: 智能缓存策略，提升性能

#### 远程同步

- **RESTful API**: 标准HTTP接口
- **离线支持**: 本地优先，网络恢复时自动同步
- **冲突解决**: 智能合并策略

### 5. 错误处理机制

#### 异常类型

```dart
// 核心异常类型
DatabaseException     // 数据库操作异常
NetworkException      // 网络连接异常
ValidationException   // 数据验证异常
SyncException        // 数据同步异常
ServerException      // 服务器异常
```

#### 错误恢复

- 自动重试机制
- 优雅降级处理
- 用户友好的错误提示
- 详细的错误日志记录

## 技术栈

### 核心依赖

```yaml
dependencies:
  flutter: sdk
  
  # 状态管理
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  provider: ^6.0.5
  
  # 数据处理
  equatable: ^2.0.5
  json_annotation: ^4.8.1
  
  # 本地存储
  shared_preferences: ^2.2.2
  
  # 网络请求
  http: ^1.1.0
  
  # 国际化
  intl: ^0.18.1
  flutter_localizations:
    sdk: flutter
  
  # UI组件
  flutter/material.dart
  flutter/cupertino.dart
```

### 开发工具

- **IDE**: 支持 VS Code、Android Studio、IntelliJ IDEA
- **调试**: Flutter Inspector、Dart DevTools
- **测试**: Unit Tests、Widget Tests、Integration Tests
- **代码质量**: Dart Analyzer、Flutter Lints

## 性能优化

### 1. 内存管理

- **对象池**: 复用频繁创建的对象
- **弱引用**: 避免内存泄漏
- **及时释放**: 页面销毁时清理资源

### 2. 渲染优化

- **懒加载**: 大列表使用ListView.builder
- **缓存策略**: 图片和数据缓存
- **动画优化**: 使用高效的动画实现

### 3. 数据优化

- **分页加载**: 大数据集分批加载
- **增量更新**: 只更新变化的数据
- **压缩存储**: 数据压缩减少存储空间

## 安全性

### 1. 数据安全

- **加密存储**: 敏感数据本地加密
- **传输安全**: HTTPS协议传输
- **访问控制**: 用户权限验证

### 2. 代码安全

- **输入验证**: 严格的数据验证
- **异常处理**: 完善的异常捕获
- **日志脱敏**: 敏感信息不记录日志

## 测试策略

### 1. 单元测试

- **BLoC测试**: 状态管理逻辑测试
- **工具类测试**: 核心工具函数测试
- **模型测试**: 数据模型序列化测试

### 2. 集成测试

- **API测试**: 网络接口集成测试
- **数据库测试**: 本地存储集成测试
- **端到端测试**: 完整业务流程测试

### 3. UI测试

- **Widget测试**: 组件渲染测试
- **交互测试**: 用户操作流程测试
- **视觉回归测试**: UI一致性测试

## 部署与发布

### 1. 构建配置

```bash
# 开发环境构建
flutter build apk --debug

# 生产环境构建
flutter build apk --release
flutter build ios --release

# Web平台构建
flutter build web --release
```

### 2. 平台支持

- ✅ **Android**: API 21+
- ✅ **iOS**: iOS 11.0+
- ✅ **Web**: 现代浏览器
- ✅ **macOS**: macOS 10.14+
- ✅ **Windows**: Windows 10+
- ✅ **Linux**: Ubuntu 18.04+
- ✅ **鸿蒙**: HarmonyOS 2.0+

## 使用指南

### 1. 环境配置

```bash
# 检查Flutter环境
flutter doctor

# 获取依赖
flutter pub get

# 运行应用
flutter run
```

### 2. 集成到现有项目

```dart
// 1. 添加依赖注入
import 'package:yxf_calendar/core/dependency_injection.dart';

// 2. 初始化
await DependencyInjection.init();

// 3. 使用BLoC
BlocProvider(
  create: (context) => ServiceLocator.get<TodoBloc>(),
  child: YourWidget(),
)
```

### 3. 自定义配置

```dart
// 主题配置
ThemeData customTheme = ThemeData(
  primarySwatch: Colors.blue,
  // 其他主题配置
);

// 本地化配置
locale: const Locale('zh', 'CN'),
supportedLocales: [
  Locale('zh', 'CN'),
  Locale('en', 'US'),
],
```

## 扩展开发

### 1. 添加新功能

1. **创建数据模型**: 在`data/models/`目录下添加新模型
2. **实现仓库接口**: 在`data/repositories/`目录下实现数据访问
3. **创建BLoC**: 在`presentation/bloc/`目录下添加状态管理
4. **设计UI组件**: 在`presentation/widgets/`目录下创建界面

### 2. 自定义主题

```dart
// 自定义颜色主题
class CustomColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
}

// 应用主题
ThemeData buildCustomTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CustomColors.primary,
    ),
    // 其他主题配置
  );
}
```

### 3. 添加新的数据源

```dart
// 实现新的数据源接口
class NewDataSource implements DataSource {
  @override
  Future<List<Task>> getTasks() async {
    // 实现数据获取逻辑
  }
}

// 在依赖注入中注册
class DependencyInjection {
  static void registerDataSources() {
    // 注册新数据源
  }
}
```

## 最佳实践

### 1. 代码规范

- **命名规范**: 使用驼峰命名法，类名首字母大写
- **文件组织**: 按功能模块组织文件结构
- **注释规范**: 重要方法和类添加详细注释
- **代码格式**: 使用`dart format`统一代码格式

### 2. 性能优化

- **避免不必要的重建**: 合理使用`const`构造函数
- **优化列表渲染**: 使用`ListView.builder`处理大数据
- **内存管理**: 及时释放不需要的资源
- **异步处理**: 使用`async/await`处理异步操作

### 3. 错误处理

- **异常捕获**: 在关键操作中添加try-catch
- **用户反馈**: 提供清晰的错误提示信息
- **日志记录**: 记录详细的错误日志便于调试
- **优雅降级**: 在功能不可用时提供备选方案

## 贡献指南

### 1. 开发流程

1. **Fork项目**: 从主仓库fork到个人仓库
2. **创建分支**: 为新功能创建独立分支
3. **开发测试**: 完成功能开发并添加测试
4. **提交PR**: 提交Pull Request到主仓库
5. **代码审查**: 等待代码审查和合并

### 2. 代码提交规范

```bash
# 提交信息格式
type(scope): description

# 示例
feat(task): add task priority feature
fix(habit): fix habit streak calculation
docs(readme): update installation guide
```

### 3. 问题反馈

- **Bug报告**: 使用Issue模板报告问题
- **功能请求**: 详细描述需求和使用场景
- **文档改进**: 指出文档中的错误或不足

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

## 联系方式

- **项目维护者**: YXF开发团队
- **技术支持**: 通过GitHub Issues提交问题
- **文档更新**: 欢迎提交文档改进建议

---

**注意**: 本文档会随着项目的发展持续更新，请关注最新版本。