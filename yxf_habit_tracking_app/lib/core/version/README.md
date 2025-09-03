# 版本管理系统

本模块提供了企业级的版本管理和应用更新功能，避免硬编码版本信息，为应用的线上更新做好准备。

## 核心组件

### 1. AppVersion
统一的版本信息管理类，提供版本号和构建号的集中管理。

```dart
// 获取版本信息
String version = AppVersion.version;           // "2.6.5"
String buildNumber = AppVersion.buildNumber;   // "20250808"
String fullVersion = AppVersion.fullVersion;   // "2.6.5+20250808"
String displayVersion = AppVersion.displayVersion; // "v2.6.5 (20250808)"

// 版本比较
bool needUpdate = AppVersion.shouldUpdate("2.6.4", "2.6.5"); // true

// 获取版本代码
int versionCode = AppVersion.versionCode; // 20605

// 获取版本请求头
Map<String, String> headers = AppVersion.getVersionHeaders();
```

### 2. VersionService
版本服务类，提供动态版本信息获取和管理功能。

```dart
// 初始化版本服务
await VersionService.instance.initialize();

// 获取当前版本信息
String currentVersion = VersionService.instance.currentVersion;
String currentBuildNumber = VersionService.instance.currentBuildNumber;
String appName = VersionService.instance.appName;
String packageName = VersionService.instance.packageName;

// 检查是否有新版本
bool hasUpdate = VersionService.instance.hasNewVersion("2.6.6");

// 获取版本请求头
Map<String, String> headers = VersionService.instance.getVersionHeaders();
```

### 3. UpdateService
应用更新服务，提供完整的更新检查和处理功能。

```dart
// 检查更新（显示对话框）
await UpdateService.instance.checkForUpdates(
  showDialog: true,
  context: context,
);

// 静默检查更新
bool hasUpdate = await UpdateService.instance.silentCheckForUpdates();

// 获取更新配置
Map<String, dynamic> config = UpdateService.instance.getUpdateConfig();
```

## 使用指南

### 1. 初始化
在应用启动时初始化版本服务：

```dart
// main.dart
await Future.wait([
  // 其他初始化...
  VersionService.instance.initialize(),
]);
```

### 2. 在UI中显示版本信息

```dart
// 使用VersionService获取动态版本信息
Text('版本: ${VersionService.instance.currentVersion}')
Text('构建号: ${VersionService.instance.currentBuildNumber}')
```

### 3. 添加检查更新功能

```dart
// 在设置页面添加检查更新按钮
ListTile(
  title: Text('检查更新'),
  onTap: () async {
    await UpdateService.instance.checkForUpdates(
      showDialog: true,
      context: context,
    );
  },
)
```

### 4. API请求中携带版本信息

```dart
// 获取版本请求头
final headers = VersionService.instance.getVersionHeaders();
// headers包含:
// {
//   'App-Version': '2.6.5',
//   'Build-Number': '20250808',
//   'Version-Code': '20605',
//   'Package-Name': 'com.hunnu.app'
// }

// 在API请求中使用
final response = await apiClient.get('/api/data', headers: headers);
```

## 版本更新流程

### 1. 更新版本号
只需要在 `pubspec.yaml` 中更新版本号：

```yaml
version: 2.6.6+20250109
```

然后更新 `AppVersion` 类中的常量：

```dart
class AppVersion {
  static const String version = '2.6.6';
  static const String buildNumber = '20250109';
  // ...
}
```

### 2. 服务端API支持
服务端需要提供更新检查API，返回格式如下：

```json
{
  "code": "ok",
  "data": {
    "version": "2.6.6",
    "buildNumber": "20250109",
    "description": "修复已知问题，优化用户体验",
    "isForceUpdate": false,
    "downloadUrl": "https://example.com/app-release.apk",
    "releaseDate": "2025-01-09T10:00:00Z"
  }
}
```

### 3. 平台特定处理

#### Android
- 直接下载APK文件
- 支持应用内更新（需要集成相关SDK）

#### iOS
- 跳转到App Store
- 使用App Store链接

## 最佳实践

### 1. 版本号规范
- 主版本号：重大功能更新或架构变更
- 次版本号：新功能添加
- 修订版本号：Bug修复和小改进
- 构建号：每次构建递增（建议使用日期格式：YYYYMMDD）

### 2. 更新策略
- 强制更新：用于安全修复或重要功能
- 可选更新：用于功能优化和体验改进
- 静默检查：在应用启动时后台检查

### 3. 错误处理
- 网络异常时的降级处理
- 更新失败时的重试机制
- 用户取消更新的处理

### 4. 日志记录
所有版本相关操作都会记录到日志系统中，便于问题排查：

```dart
// 记录版本信息
AppVersion.logVersionInfo();
VersionService.instance.logVersionInfo();
```

## 注意事项

1. **版本服务初始化**：确保在使用前调用 `VersionService.instance.initialize()`
2. **权限要求**：Android平台需要网络权限和存储权限
3. **安全考虑**：下载链接应使用HTTPS，验证文件完整性
4. **用户体验**：避免在用户操作过程中强制更新
5. **测试覆盖**：充分测试各种更新场景和异常情况

## 扩展功能

### 1. 增量更新
可以扩展支持增量更新，减少下载大小：

```dart
// TODO: 实现增量更新逻辑
class IncrementalUpdateService {
  // 计算差异包
  // 下载差异文件
  // 应用增量更新
}
```

### 2. 更新统计
记录更新成功率和用户行为：

```dart
// TODO: 实现更新统计
class UpdateAnalytics {
  // 记录更新检查次数
  // 记录更新成功/失败率
  // 记录用户更新行为
}
```

### 3. A/B测试
支持不同用户群体的差异化更新策略：

```dart
// TODO: 实现A/B测试支持
class UpdateABTesting {
  // 用户分组
  // 差异化更新策略
  // 效果统计
}
```