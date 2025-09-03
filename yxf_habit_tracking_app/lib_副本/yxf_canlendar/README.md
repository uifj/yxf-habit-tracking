# Hunnu Calendar Module - BLoC 重构版本

## 概述

本模块是基于 BLoC 架构模式重构的任务管理日历模块，遵循企业级开发最佳实践和标准。模块采用清洁架构（Clean Architecture）设计，实现了数据层、业务逻辑层和表现层的分离。

## 架构设计

### 目录结构

```
lib/hunnu_canlendar/
├── lib/
│   ├── bloc/                    # BLoC 状态管理
│   │   ├── todo_bloc.dart       # 主要业务逻辑处理
│   │   ├── todo_event.dart      # 事件定义
│   │   └── todo_state.dart      # 状态定义
│   ├── core/                    # 核心功能
│   │   └── error/               # 错误处理
│   │       ├── exceptions.dart  # 异常定义
│   │       └── failures.dart   # 失败类型定义
│   ├── models/                  # 数据模型
│   │   └── task.dart           # 任务模型
│   ├── repositories/            # 数据仓库层
│   │   └── task_repository.dart # 任务数据访问抽象
│   ├── services/                # 服务层
│   │   ├── db_helper.dart      # 本地数据库服务
│   │   ├── notification_services.dart # 通知服务
│   │   └── task_services.dart  # 远程任务服务
│   ├── ui/                     # 用户界面
│   │   ├── pages/              # 页面组件
│   │   │   ├── add_task_page_bloc.dart
│   │   │   ├── all_task_page_bloc.dart
│   │   │   └── home_page_bloc.dart
│   │   ├── widgets/            # 可复用组件
│   │   ├── size_config.dart    # 尺寸配置
│   │   └── theme.dart          # 主题配置
│   ├── dependency_injection.dart # 依赖注入
│   └── main_bloc.dart          # 应用入口
└── README.md                   # 本文档
```

### 核心组件

#### 1. BLoC 状态管理

- **TodoBloc**: 核心业务逻辑处理器
- **TodoEvent**: 定义所有可能的用户操作事件
- **TodoState**: 定义应用的各种状态

#### 2. 数据层

- **TaskRepository**: 数据访问抽象接口
- **TaskRepositoryImpl**: 具体实现，整合本地和远程数据源
- **DBHelper**: SQLite 本地数据库管理
- **TaskServices**: Firebase 远程数据服务

#### 3. 错误处理

- **统一异常处理**: 定义了完整的异常类型体系
- **错误恢复机制**: 提供优雅的错误处理和用户反馈

## 主要功能

### 任务管理
- ✅ 创建任务
- ✅ 编辑任务
- ✅ 删除任务
- ✅ 标记任务完成
- ✅ 批量操作

### 数据同步
- ✅ 本地与远程数据同步
- ✅ 离线模式支持
- ✅ 冲突解决策略

### 过滤和搜索
- ✅ 按日期过滤
- ✅ 按优先级过滤
- ✅ 任务状态筛选

### 通知提醒
- ✅ 本地通知
- ✅ 定时提醒
- ✅ 通知权限管理

## 使用方法

### 1. 初始化依赖

```dart
import 'package:hunnu_canlendar/dependency_injection.dart';

// 在应用启动时初始化
await DependencyInjection.init();
```

### 2. 在 Widget 中使用

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunnu_canlendar/bloc/todo_bloc.dart';
import 'package:hunnu_canlendar/dependency_injection.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.get<TodoBloc>()
        ..add(InitializeTodoEvent()),
      child: MaterialApp(
        home: HomePageBloc(),
      ),
    );
  }
}
```

### 3. 发送事件

```dart
// 添加任务
context.read<TodoBloc>().add(AddTaskEvent(task));

// 加载任务
context.read<TodoBloc>().add(LoadTasksEvent());

// 按日期过滤
context.read<TodoBloc>().add(FilterTasksByDateEvent(selectedDate));
```

### 4. 监听状态

```dart
BlocConsumer<TodoBloc, TodoState>(
  listener: (context, state) {
    if (state is TodoError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is TodoLoading) {
      return CircularProgressIndicator();
    }
    if (state is TodoLoaded) {
      return TaskListWidget(tasks: state.tasks);
    }
    return Container();
  },
)
```

## 错误处理

模块提供了完整的错误处理机制：

### 异常类型
- `DatabaseException`: 数据库操作异常
- `NetworkException`: 网络连接异常
- `ValidationException`: 数据验证异常
- `TaskNotFoundException`: 任务未找到异常
- `SyncException`: 数据同步异常
- `NotificationException`: 通知服务异常

### 使用示例

```dart
try {
  await taskRepository.addTask(task);
} on ValidationException catch (e) {
  // 处理验证错误
  showErrorDialog('输入数据无效: ${e.message}');
} on DatabaseException catch (e) {
  // 处理数据库错误
  showErrorDialog('数据保存失败: ${e.message}');
} catch (e) {
  // 处理其他未知错误
  showErrorDialog('操作失败，请稍后重试');
}
```

## 数据模型

### Task 模型

```dart
class Task {
  final int? id;
  final String? userId;
  final String? title;
  final String? note;
  final int? isCompleted;
  final String? priority;
  final String? date;
  final String? startTime;
  final String? endTime;
  final int? color;
  final int? remind;
  final String? repeat;

  // 构造函数和方法...
}
```

## 性能优化

1. **懒加载**: 按需加载数据和组件
2. **缓存策略**: 本地数据缓存减少网络请求
3. **批量操作**: 支持批量插入和更新
4. **内存管理**: 及时释放不需要的资源

## 测试

模块设计支持单元测试和集成测试：

```dart
// 示例测试
void main() {
  group('TodoBloc Tests', () {
    late TodoBloc todoBloc;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      todoBloc = TodoBloc(mockRepository);
    });

    test('should emit TodoLoaded when LoadTasksEvent is added', () async {
      // 测试逻辑
    });
  });
}
```

## 迁移指南

从 GetX 版本迁移到 BLoC 版本：

1. **替换控制器**: 将 `GetxController` 替换为 `BlocProvider`
2. **更新状态管理**: 使用 `BlocBuilder` 和 `BlocListener`
3. **事件驱动**: 将直接方法调用改为事件分发
4. **依赖注入**: 使用新的依赖注入系统

## 最佳实践

1. **单一职责**: 每个 BLoC 只处理特定的业务逻辑
2. **不可变状态**: 所有状态对象都应该是不可变的
3. **错误处理**: 始终处理可能的异常情况
4. **资源管理**: 及时关闭 BLoC 和释放资源
5. **测试覆盖**: 为关键业务逻辑编写测试

## 依赖库

本模块使用以下核心依赖：

- `flutter_bloc: ^8.1.3` - BLoC 状态管理
- `bloc: ^8.1.2` - BLoC 核心库
- `equatable: ^2.0.5` - 对象比较
- `sqflite` - 本地数据库
- `cloud_firestore` - 远程数据存储
- `flutter_local_notifications` - 本地通知

## 贡献指南

1. 遵循现有的代码风格和架构模式
2. 为新功能添加相应的测试
3. 更新文档说明
4. 确保错误处理的完整性

## 许可证

本模块遵循项目的整体许可证协议。