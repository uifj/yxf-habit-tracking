# 企业级路由系统使用指南

本文档介绍了Flutter项目中企业级路由系统的配置和使用方法。

## 系统架构

### 核心组件

1. **AppRouter** (`app_router.dart`)
   - 单例模式的路由管理器
   - 提供静态和动态路由支持
   - 集成路由历史跟踪和错误处理

2. **AppRouteNames** (`app_route_names.dart`)
   - 集中管理所有路由名称常量
   - 提供静态路由映射和元数据
   - 支持路由分类和权限管理

3. **AppRouteNavigator** (`app_route_navigator.dart`)
   - 提供便捷的导航方法
   - 封装常用导航操作

4. **DeepLinkService** (`../services/deep_link_service.dart`)
   - 处理深度链接和分享内容
   - 与原生平台通信
   - 自动路由映射

5. **NavigationService** (`../services/navigation_service.dart`)
   - 全局导航状态管理
   - 上下文无关的导航操作
   - 对话框和弹窗管理

## 配置说明

### 1. main.dart 配置

```dart
// 在应用初始化时配置路由系统
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化深度链接服务
  final deepLinkService = DeepLinkService();
  deepLinkService.initialize();
  
  // 设置深度链接处理回调
  deepLinkService.setDeepLinkHandler((url, params) {
    debugPrint('收到深度链接: $url, 参数: $params');
  });
  
  runApp(MyApp());
}

// 在MaterialApp中配置路由
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      routes: AppRouter.routes,                    // 静态路由
      onGenerateRoute: AppRouter.onGenerateRoute,  // 动态路由
    );
  }
}
```

### 2. Android配置

#### AndroidManifest.xml

```xml
<!-- 深度链接配置 -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="tuikit" />
</intent-filter>

<!-- 文件分享支持 -->
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/*" />
    <data android:mimeType="image/*" />
</intent-filter>
```

#### MainActivity.kt

```kotlin
// 深度链接处理
private fun handleDeepLink(uri: Uri) {
    methodChannel.invokeMethod("onDeepLink", mapOf(
        "url" to uri.toString(),
        "scheme" to uri.scheme,
        "host" to uri.host,
        "path" to uri.path,
        "query" to uri.query
    ))
}

// 分享内容处理
private fun handleSharedContent(content: String) {
    methodChannel.invokeMethod("onSharedContent", mapOf(
        "content" to content,
        "type" to "text"
    ))
}
```

## 使用方法

### 1. 基本导航

```dart
// 使用AppRouter进行导航
final appRouter = AppRouter();

// 导航到指定页面
await appRouter.navigateTo(
  context: context,
  routeName: AppRouteNames.gallery,
  options: {'param1': 'value1'},
);

// 使用NavigationService进行导航（推荐）
final navigationService = NavigationService();

// 简单导航
await navigationService.navigateTo(
  AppRouteNames.settings,
  arguments: {'userId': '123'},
);

// 替换当前页面
await navigationService.navigateTo(
  AppRouteNames.home,
  replace: true,
);

// 清除栈并导航
await navigationService.navigateAndClearStack(
  AppRouteNames.login,
);
```

### 2. 动态路由注册

```dart
// 注册动态路由
AppRouter().registerRouter(
  '/custom/page',
  (context, arguments) => CustomPage(data: arguments),
);

// 注销动态路由
AppRouter().unregisterRouter('/custom/page');
```

### 3. 深度链接处理

```dart
// 生成深度链接
final deepLinkService = DeepLinkService();
final url = deepLinkService.generateDeepLink(
  '/gallery',
  params: {'category': 'photos'},
);
// 结果: tuikit://app/gallery?category=photos

// 分享深度链接
await deepLinkService.shareDeepLink(
  '/typing/test',
  params: {'level': 'advanced'},
  title: '分享打字测试',
);
```

### 4. 对话框和弹窗

```dart
final navigationService = NavigationService();

// 显示错误对话框
await navigationService.showErrorDialog(
  '错误',
  '网络连接失败，请检查网络设置',
);

// 显示确认对话框
final confirmed = await navigationService.showConfirmDialog(
  '确认删除',
  '确定要删除这个项目吗？',
);

if (confirmed == true) {
  // 执行删除操作
}

// 显示加载对话框
navigationService.showLoadingDialog('正在处理...');
// 处理完成后隐藏
navigationService.hideLoadingDialog();

// 显示SnackBar
navigationService.showSnackBar(
  '操作成功',
  duration: Duration(seconds: 2),
);
```

### 5. 路由元数据和权限

```dart
// 获取路由标题
final title = AppRouteNames.getRouteTitle(AppRouteNames.settings);

// 检查路由是否需要认证
final requiresAuth = AppRouteNames.requiresAuthentication(AppRouteNames.settings);

// 按类别获取路由
final coreRoutes = AppRouteNames.getRoutesByCategory(RouteCategory.core);
final featureRoutes = AppRouteNames.getRoutesByCategory(RouteCategory.feature);
```

## 路由列表

### 核心路由
- `/home` - 首页
- `/gallery` - 图库页面
- `/typing` - 打字练习主页
- `/typing/test` - 打字测试页面
- `/analysis` - 数据分析页面

### 功能路由
- `/tools` - 工具页面

### 设置路由
- `/settings` - 设置页面

### 错误路由
- `/notFound` - 404页面
- `/networkError` - 网络错误页面
- `/serverError` - 服务器错误页面

## 深度链接格式

### 基本格式
```
tuikit://app/[path]?[params]
```

### 示例
```
tuikit://app/home                    # 首页
tuikit://app/gallery                 # 图库
tuikit://app/typing/test?level=1     # 打字测试（级别1）
tuikit://app/settings?tab=account    # 设置页面（账户标签）
```

## 最佳实践

### 1. 路由命名
- 使用小写字母和下划线
- 保持路由名称简洁明了
- 使用层级结构组织相关路由

### 2. 参数传递
- 优先使用路由参数而非全局状态
- 对复杂对象使用序列化
- 验证参数的有效性

### 3. 错误处理
- 为所有路由提供错误页面
- 记录导航错误日志
- 提供用户友好的错误信息

### 4. 性能优化
- 使用懒加载减少初始包大小
- 缓存常用页面实例
- 避免深层嵌套路由

### 5. 安全考虑
- 验证深度链接参数
- 检查用户权限
- 防止恶意路由注入

## 调试和监控

### 1. 路由历史
```dart
// 获取路由历史
final history = AppRouter().routeHistory;
for (final entry in history) {
  print('${entry.timestamp}: ${entry.routeName}');
}
```

### 2. 路由统计
```dart
// 获取路由统计信息
final stats = AppRouter().getRouteStatistics();
print('总导航次数: ${stats['totalNavigations']}');
print('最常访问路由: ${stats['mostVisitedRoute']}');
```

### 3. 日志记录
路由系统会自动记录所有导航操作，包括：
- 导航时间戳
- 源路由和目标路由
- 传递的参数
- 错误信息（如果有）

## 故障排除

### 常见问题

1. **路由未找到**
   - 检查路由名称是否正确
   - 确认路由已在AppRouteNames中定义
   - 验证动态路由是否已注册

2. **深度链接不工作**
   - 检查AndroidManifest.xml配置
   - 确认URL格式正确
   - 验证DeepLinkService是否已初始化

3. **导航上下文错误**
   - 使用NavigationService而非直接使用BuildContext
   - 确保全局导航键已正确设置
   - 检查页面生命周期状态

4. **参数传递失败**
   - 验证参数类型和格式
   - 检查序列化/反序列化逻辑
   - 确认参数名称匹配

### 调试技巧

1. 启用详细日志记录
2. 使用Flutter Inspector检查路由栈
3. 监控内存使用情况
4. 测试各种深度链接场景

## 更新日志

### v1.0.0
- 初始版本发布
- 基础路由功能
- 深度链接支持
- Android平台集成

### v1.1.0
- 添加NavigationService
- 改进错误处理
- 增强路由元数据
- 性能优化

---

如有问题或建议，请联系开发团队。