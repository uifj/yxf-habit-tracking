# ToastUtil 集成指南

## 项目集成步骤

### 1. 在现有项目中集成ToastUtil

由于您的项目使用了`TencentCloudChatMaterialApp`，需要特殊的集成方式：

#### 方法一：修改main.dart（推荐）

在您的`main.dart`文件中添加ToastUtil初始化：

```dart
// 在文件顶部添加导入
import '../../../../hunnu_canlendar/lib/core/utils/hunnu_canlendar/lib/core/utils/toast_util.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  // 创建全局导航键
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // 初始化ToastUtil
    ToastUtil.init(navigatorKey);
    
    return MultiRepositoryProvider(
      providers: [
        // ... 现有的providers
      ],
      child: MultiBlocProvider(
        providers: [
          // ... 现有的BlocProviders
        ],
        child: TencentCloudChatMaterialApp(
          title: 'Tencent Cloud Chat',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // 添加这一行
          routes: AppRouter.routes,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
```

#### 方法二：在应用启动后初始化

如果无法修改MaterialApp配置，可以在应用启动后获取导航键：

```dart
class _MyHomePageState extends TencentCloudChatState<MyHomePage> {
  @override
  void initState() {
    super.initState();
    
    // 延迟初始化ToastUtil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigatorKey = GlobalKey<NavigatorState>();
      navigatorKey.currentState = Navigator.of(context);
      ToastUtil.init(navigatorKey);
    });
    
    // ... 其他初始化代码
  }
}
```

### 2. 替换现有的ToastUtils

您的项目中已经有一个`ToastUtils`类，建议：

1. **逐步迁移**：保留现有的ToastUtils，新功能使用ToastUtil
2. **完全替换**：将所有ToastUtils调用替换为ToastUtil

#### 迁移对照表

```dart
// 旧的调用方式
ToastUtils.showToast('消息');

// 新的调用方式
ToastUtil.success('消息');  // 成功提示
ToastUtil.error('消息');    // 错误提示
ToastUtil.info('消息');     // 信息提示
```

### 3. 在TaskProvider中的使用

您的`TaskProvider`已经导入了`ToastUtil`，现在可以正常使用：

```dart
// 在TaskProvider中的使用示例
Future<bool> addTask(Task task) async {
  try {
    _setLoading(true);
    _clearMessages();

    final addedTask = await _taskRepository.addTask(task);
    _tasks.add(addedTask);
    _applyFiltersAndSort();
    _updateStatistics();

    // 使用新的ToastUtil
    ToastUtil.success('任务"${addedTask.title}"添加成功');
    log('Task added successfully: ${addedTask.title}');
    return true;
  } catch (e) {
    _setError('Failed to add task: ${e.toString()}');
    ToastUtil.error('添加任务失败：${e.toString()}');
    log('Error adding task: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
```

## 使用场景示例

### 1. 网络请求处理

```dart
class ApiService {
  static Future<void> fetchUserData() async {
    try {
      // 显示加载提示
      ToastUtil.loading('正在加载用户数据...');
      
      final response = await http.get(Uri.parse('/api/user'));
      
      // 隐藏加载提示
      ToastUtil.hide();
      
      if (response.statusCode == 200) {
        ToastUtil.success('用户数据加载成功');
      } else {
        ToastUtil.error('服务器错误：${response.statusCode}');
      }
    } catch (e) {
      ToastUtil.hide();
      ToastUtil.error('网络连接失败，请检查网络设置');
    }
  }
}
```

### 2. 表单验证

```dart
class FormValidator {
  static bool validateInput(String input) {
    if (input.isEmpty) {
      ToastUtil.warning('请输入必填信息');
      return false;
    }
    
    if (input.length < 3) {
      ToastUtil.error('输入内容不能少于3个字符');
      return false;
    }
    
    return true;
  }
}
```

### 3. 用户操作反馈

```dart
class UserActions {
  static void saveSettings() {
    try {
      // 保存设置逻辑
      SettingsRepository.save();
      ToastUtil.success('设置保存成功');
    } catch (e) {
      ToastUtil.error('保存失败：${e.toString()}');
    }
  }
  
  static void deleteItem(String itemName) {
    ToastUtil.warning('确定要删除"$itemName"吗？');
  }
}
```

## 自定义配置示例

### 1. 全局配置

```dart
class AppToastConfig {
  // 应用主题色配置
  static const ToastConfig successConfig = ToastConfig(
    backgroundColor: Color(0xFF52C41A),
    duration: Duration(seconds: 2),
    position: ToastPosition.center,
  );
  
  static const ToastConfig errorConfig = ToastConfig(
    backgroundColor: Color(0xFFFF4D4F),
    duration: Duration(seconds: 3),
    position: ToastPosition.center,
  );
  
  // 使用自定义配置
  static void showSuccess(String message) {
    ToastUtil.success(message, config: successConfig);
  }
  
  static void showError(String message) {
    ToastUtil.error(message, config: errorConfig);
  }
}
```

### 2. 特殊场景配置

```dart
// 重要操作提示（顶部显示，较长时间）
ToastUtil.warning(
  '重要：此操作不可撤销，请谨慎操作',
  config: const ToastConfig(
    position: ToastPosition.top,
    duration: Duration(seconds: 5),
    dismissOnTap: false,
  ),
);

// 快速反馈提示（底部显示，短时间）
ToastUtil.success(
  '操作完成',
  config: const ToastConfig(
    position: ToastPosition.bottom,
    duration: Duration(seconds: 1),
  ),
);
```

## 测试集成

### 1. 创建测试页面

```dart
class ToastTestPage extends StatelessWidget {
  const ToastTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast测试'))，
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => ToastUtil.success('测试成功提示'),
              child: const Text('测试成功提示'),
            ),
            ElevatedButton(
              onPressed: () => ToastUtil.error('测试错误提示'),
              child: const Text('测试错误提示'),
            ),
            ElevatedButton(
              onPressed: () => ToastUtil.loading('测试加载提示'),
              child: const Text('测试加载提示'),
            ),
            ElevatedButton(
              onPressed: () => ToastUtil.hide(),
              child: const Text('隐藏提示'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. 在路由中添加测试页面

```dart
// 在AppRouter中添加
static const String toastTest = '/toast-test';

static Map<String, WidgetBuilder> get routes => {
  // ... 现有路由
  toastTest: (context) => const ToastTestPage(),
};
```

## 常见问题解决

### 1. Toast不显示

**原因**：未正确初始化或navigatorKey设置错误

**解决方案**：
```dart
// 确保在MaterialApp中设置navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
ToastUtil.init(navigatorKey);

// 在MaterialApp中使用
MaterialApp(
  navigatorKey: navigatorKey,
  // ...
)
```

### 2. 与现有Toast冲突

**原因**：同时使用多个Toast库

**解决方案**：
```dart
// 创建统一的Toast管理器
class UnifiedToast {
  static void show(String message, {ToastType type = ToastType.info}) {
    // 隐藏其他Toast
    ToastUtils.hide(); // 隐藏旧的Toast
    ToastUtil.hide();  // 隐藏新的Toast
    
    // 显示新Toast
    switch (type) {
      case ToastType.success:
        ToastUtil.success(message);
        break;
      case ToastType.error:
        ToastUtil.error(message);
        break;
      // ...
    }
  }
}
```

### 3. 在异步操作中使用

```dart
class AsyncOperationExample {
  static Future<void> performOperation() async {
    try {
      ToastUtil.loading('处理中...');
      
      await Future.delayed(const Duration(seconds: 2));
      
      // 确保在操作完成后隐藏loading
      ToastUtil.hide();
      ToastUtil.success('操作完成');
    } catch (e) {
      ToastUtil.hide();
      ToastUtil.error('操作失败：${e.toString()}');
    }
  }
}
```

## 性能优化建议

### 1. 避免频繁调用

```dart
class ThrottledToast {
  static DateTime? _lastShowTime;
  static const Duration _throttleDuration = Duration(milliseconds: 500);
  
  static void show(String message, ToastType type) {
    final now = DateTime.now();
    if (_lastShowTime == null || 
        now.difference(_lastShowTime!) > _throttleDuration) {
      _lastShowTime = now;
      
      switch (type) {
        case ToastType.success:
          ToastUtil.success(message);
          break;
        // ...
      }
    }
  }
}
```

### 2. 内存管理

```dart
// 在页面销毁时清理Toast
class MyPage extends StatefulWidget {
  @override
  void dispose() {
    ToastUtil.hide(); // 清理当前显示的Toast
    super.dispose();
  }
}
```

## 总结

1. **初始化**：确保在MaterialApp中正确设置navigatorKey
2. **迁移**：逐步替换现有的Toast调用
3. **测试**：创建测试页面验证功能
4. **优化**：注意性能和内存管理
5. **维护**：建立统一的Toast使用规范

通过以上步骤，您可以成功在现有项目中集成和使用ToastUtil组件。