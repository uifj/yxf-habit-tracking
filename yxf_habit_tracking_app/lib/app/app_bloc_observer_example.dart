import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'app_bloc_observer.dart';

/// Example of how to use the optimized AppBlocObserver in main.dart
/// 在main.dart中使用优化后的AppBlocObserver的示例
///
/// This file demonstrates different configurations for various environments
/// 此文件演示了不同环境的各种配置
class AppBlocObserverExample {
  /// Development configuration with full logging and monitoring
  /// 开发环境配置，包含完整的日志记录和监控
  static AppBlocObserver get development => const AppBlocObserver(
        enableDetailedLogging: true,
        enablePerformanceMonitoring: true,
        logLevel: LogLevel.debug,
      );

  /// Testing configuration with minimal logging
  /// 测试环境配置，最小化日志记录
  static AppBlocObserver get testing => const AppBlocObserver(
        enableDetailedLogging: false,
        enablePerformanceMonitoring: false,
        logLevel: LogLevel.warning,
      );

  /// Production configuration with error-only logging
  /// 生产环境配置，仅记录错误日志
  static AppBlocObserver get production => const AppBlocObserver(
        enableDetailedLogging: false,
        enablePerformanceMonitoring: false,
        logLevel: LogLevel.error,
      );

  /// Staging configuration with moderate logging
  /// 预发布环境配置，适度的日志记录
  static AppBlocObserver get staging => const AppBlocObserver(
        enableDetailedLogging: false,
        enablePerformanceMonitoring: true,
        logLevel: LogLevel.info,
      );

  /// Get observer based on current build mode
  /// 根据当前构建模式获取观察者
  static AppBlocObserver get adaptive {
    if (kDebugMode) {
      return development;
    } else if (kProfileMode) {
      return staging;
    } else {
      return production;
    }
  }
}

/// Example main.dart setup
/// main.dart设置示例
/*
void main() {
  // Set up BLoC observer before running the app
  // 在运行应用之前设置BLoC观察者
  Bloc.observer = AppBlocObserverExample.adaptive;
  
  // Alternative: Use specific configuration
  // 替代方案：使用特定配置
  // Bloc.observer = AppBlocObserverExample.development;
  
  runApp(const MyApp());
}
*/

/// Custom observer configuration example
/// 自定义观察者配置示例
class CustomAppBlocObserver extends AppBlocObserver {
  const CustomAppBlocObserver()
      : super(
          enableDetailedLogging: true,
          enablePerformanceMonitoring: true,
          logLevel: LogLevel.debug,
        );

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Custom error handling logic
    // 自定义错误处理逻辑

    // Log to custom analytics service
    // 记录到自定义分析服务
    _logToCustomService(bloc, error, stackTrace);

    // Call parent implementation
    // 调用父类实现
    super.onError(bloc, error, stackTrace);
  }

  void _logToCustomService(
      BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Implement your custom logging logic here
    // 在此实现您的自定义日志记录逻辑
    print('Custom logging: ${bloc.runtimeType} - $error');
  }
}
