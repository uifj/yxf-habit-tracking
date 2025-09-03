# ToastUtil - 企业级Flutter Toast组件

## 概述

ToastUtil是一个功能完善的Flutter Toast提示组件，参考了后台管理平台和微信的提示方式设计，提供了企业级应用所需的各种提示功能。

## 特性

### 🎯 核心功能
- ✅ 五种提示类型：成功、错误、警告、信息、加载
- ✅ 三种显示位置：顶部、中心、底部
- ✅ 丰富的自定义配置选项
- ✅ 流畅的动画效果（淡入淡出、滑动、缩放）
- ✅ 触觉反馈支持
- ✅ 点击关闭功能
- ✅ 字符串扩展方法

### 🎨 视觉设计
- 现代化的UI设计
- 符合Material Design规范
- 支持自定义颜色、字体、圆角等
- 阴影效果增强视觉层次
- 响应式布局适配不同屏幕

### 🔧 技术特点
- 基于Overlay实现，不影响页面布局
- 单例模式管理，避免重复显示
- 内存管理优化，自动清理资源
- 类型安全的API设计
- 完善的错误处理机制

## 快速开始

### 1. 初始化

在`main.dart`中初始化ToastUtil：

```dart
import 'package:flutter/material.dart';
import '../../../../hunnu_canlendar/lib/core/utils/path/to/toast_util.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 创建全局导航键
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // 初始化ToastUtil
    ToastUtil.init(navigatorKey);
    
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey, // 重要：设置导航键
      home: MyHomePage(),
    );
  }
}
```

### 2. 基础用法

```dart
// 成功提示
ToastUtil.success('操作成功！');

// 错误提示
ToastUtil.error('操作失败，请重试');

// 警告提示
ToastUtil.warning('请注意数据安全');

// 信息提示
ToastUtil.info('这是一条信息提示');

// 加载提示
ToastUtil.loading('正在处理中...');

// 隐藏当前提示
ToastUtil.hide();
```

### 3. 字符串扩展方法

```dart
// 使用字符串扩展方法
'操作成功！'.showSuccess();
'操作失败'.showError();
'注意事项'.showWarning();
'提示信息'.showInfo();
'加载中...'.showLoading();
```

## 高级配置

### ToastConfig配置选项

```dart
class ToastConfig {
  final Duration duration;              // 显示时长
  final ToastPosition position;         // 显示位置
  final Color? backgroundColor;         // 背景颜色
  final Color? textColor;              // 文字颜色
  final double? fontSize;              // 字体大小
  final EdgeInsets? padding;           // 内边距
  final BorderRadius? borderRadius;    // 圆角
  final bool enableHapticFeedback;     // 触觉反馈
  final bool dismissOnTap;             // 点击关闭
  final double? maxWidth;              // 最大宽度
  final TextAlign textAlign;           // 文字对齐
}
```

### 自定义配置示例

```dart
// 顶部显示，持续3秒
ToastUtil.success(
  '这是顶部提示',
  config: const ToastConfig(
    position: ToastPosition.top,
    duration: Duration(seconds: 3),
  ),
);

// 自定义样式
ToastUtil.success(
  '自定义样式的提示',
  config: ToastConfig(
    backgroundColor: Colors.indigo.withOpacity(0.9),
    textColor: Colors.white,
    fontSize: 16,
    borderRadius: BorderRadius.circular(20),
    maxWidth: 300,
  ),
);

// 禁用触觉反馈和点击关闭
ToastUtil.info(
  '重要信息',
  config: const ToastConfig(
    enableHapticFeedback: false,
    dismissOnTap: false,
    duration: Duration(seconds: 5),
  ),
);
```

## 实际应用场景

### 网络请求处理

```dart
class ApiService {
  static Future<void> fetchData() async {
    try {
      // 显示加载提示
      ToastUtil.loading('正在加载数据...');
      
      // 执行网络请求
      final response = await http.get(Uri.parse('https://api.example.com/data'));
      
      // 隐藏加载提示
      ToastUtil.hide();
      
      if (response.statusCode == 200) {
        // 显示成功提示
        ToastUtil.success('数据加载成功');
      } else {
        // 显示错误提示
        ToastUtil.error('服务器错误：${response.statusCode}');
      }
    } catch (e) {
      // 隐藏加载提示
      ToastUtil.hide();
      
      // 显示网络错误提示
      ToastUtil.error('网络连接失败，请检查网络设置');
    }
  }
}
```

### 表单验证

```dart
class FormValidator {
  static bool validateEmail(String email) {
    if (email.isEmpty) {
      ToastUtil.warning('请输入邮箱地址');
      return false;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ToastUtil.error('邮箱格式不正确');
      return false;
    }
    
    return true;
  }
  
  static bool validatePassword(String password) {
    if (password.length < 6) {
      ToastUtil.warning('密码长度不能少于6位');
      return false;
    }
    
    if (password.length < 8) {
      ToastUtil.info('建议使用8位以上密码以提高安全性');
    }
    
    return true;
  }
}
```

### 用户操作反馈

```dart
class UserActions {
  static void saveUserProfile(UserProfile profile) {
    try {
      // 保存用户资料
      UserRepository.save(profile);
      
      // 显示成功提示
      ToastUtil.success('个人资料保存成功');
    } catch (e) {
      // 显示错误提示
      ToastUtil.error('保存失败：${e.toString()}');
    }
  }
  
  static void deleteItem(String itemName) {
    // 显示警告提示
    ToastUtil.warning('确定要删除"$itemName"吗？此操作不可撤销');
  }
  
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastUtil.success('已复制到剪贴板');
  }
}
```

## 最佳实践

### 1. 提示类型选择

- **Success（成功）**：操作成功完成时使用
- **Error（错误）**：操作失败或发生错误时使用
- **Warning（警告）**：需要用户注意但不阻止操作时使用
- **Info（信息）**：提供额外信息或说明时使用
- **Loading（加载）**：长时间操作进行中时使用

### 2. 显示时长建议

- **成功提示**：2-3秒
- **错误提示**：3-5秒（让用户有足够时间阅读错误信息）
- **警告提示**：3-4秒
- **信息提示**：2-3秒
- **加载提示**：直到操作完成

### 3. 文案编写原则

- 简洁明了，避免冗长
- 使用用户友好的语言
- 错误提示要提供解决方案
- 避免技术术语，使用通俗易懂的表达

### 4. 性能优化

```dart
// 避免频繁显示Toast
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
        case ToastType.error:
          ToastUtil.error(message);
          break;
        // ... 其他类型
      }
    }
  }
}
```

### 5. 国际化支持

```dart
class LocalizedToast {
  static void success(String messageKey) {
    final message = AppLocalizations.of(context).translate(messageKey);
    ToastUtil.success(message);
  }
  
  static void error(String messageKey) {
    final message = AppLocalizations.of(context).translate(messageKey);
    ToastUtil.error(message);
  }
}
```

## 注意事项

1. **初始化**：必须在MaterialApp中设置navigatorKey并调用ToastUtil.init()
2. **内存管理**：长时间显示的Toast（如loading）记得手动调用hide()
3. **用户体验**：避免同时显示多个Toast，组件会自动处理覆盖
4. **测试**：在单元测试中可能需要mock ToastUtil的方法
5. **性能**：避免在高频回调中显示Toast，考虑使用节流机制

## 故障排除

### 常见问题

**Q: Toast不显示**
A: 检查是否正确初始化ToastUtil并设置了navigatorKey

**Q: Toast显示位置不正确**
A: 确保在正确的BuildContext中调用，避免在initState等生命周期方法中直接调用

**Q: 动画效果不流畅**
A: 检查设备性能，考虑简化动画或调整动画时长

**Q: 触觉反馈不工作**
A: 确保设备支持触觉反馈，并且用户没有在系统设置中禁用

## 更新日志

### v1.0.0
- 初始版本发布
- 支持五种提示类型
- 完整的自定义配置
- 动画效果和触觉反馈
- 字符串扩展方法

## 贡献

欢迎提交Issue和Pull Request来改进这个组件。

## 许可证

MIT License