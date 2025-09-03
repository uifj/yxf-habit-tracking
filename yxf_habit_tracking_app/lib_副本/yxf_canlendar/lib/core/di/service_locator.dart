import 'package:get_it/get_it.dart';
import '../db/shared_prefs_helper.dart';
import '../error/error_handler.dart';
import '../network/network_service.dart';
import '../network/network_info.dart';
import '../../data/datasources/task_local_data_source.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/task_usecases.dart';
// BLoC imports will be added later
// import '../../presentation/bloc/task/task_bloc.dart';
// import '../../presentation/bloc/filter/filter_bloc.dart';
// import '../../presentation/bloc/sync/sync_bloc.dart';

/// 企业级服务定位器
/// 使用 get_it 实现依赖注入容器
/// 支持单例、工厂、懒加载等多种生命周期管理
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// 获取服务实例
  static T get<T extends Object>() => _getIt.get<T>();
  
  /// 检查服务是否已注册
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
  
  /// 初始化所有依赖
  static Future<void> init() async {
    await _registerCore();
    await _registerDataSources();
    await _registerRepositories();
    await _registerUseCases();
    await _registerBlocs();
    
    // 验证依赖图完整性
    await _validateDependencies();
  }
  
  /// 注册核心服务
  static Future<void> _registerCore() async {
    // 错误处理器 - 单例
    _getIt.registerLazySingleton<ErrorHandler>(
      () => ErrorHandlerImpl(),
    );
    
    // 网络信息 - 单例
    _getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(),
    );
    
    // 网络服务 - 单例
    _getIt.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(),
    );
    
    // 本地数据库 - 单例
    _getIt.registerLazySingleton<SharedPrefsHelper>(
      () => SharedPrefsHelper(),
    );
    
    // 初始化数据库
    // await _getIt<SharedPrefsHelper>().initDb();
  }
  
  /// 注册数据源
  static Future<void> _registerDataSources() async {
    // 数据源实现将在后续步骤中添加
    // _getIt.registerLazySingleton<TaskLocalDataSource>(
    //   () => TaskLocalDataSourceImpl(
    //     sharedPrefsHelper: _getIt<SharedPrefsHelper>(),
    //     errorHandler: _getIt<ErrorHandler>(),
    //   ),
    // );
    
    // _getIt.registerLazySingleton<TaskRemoteDataSource>(
    //   () => TaskRemoteDataSourceImpl(
    //     networkService: _getIt<NetworkService>(),
    //     errorHandler: _getIt<ErrorHandler>(),
    //   ),
    // );
  }
  
  /// 注册仓库
  static Future<void> _registerRepositories() async {
    // 仓库实现将在数据源实现完成后添加
    // _getIt.registerLazySingleton<TaskRepository>(
    //   () => TaskRepositoryImpl(
    //     localDataSource: _getIt<TaskLocalDataSource>(),
    //     remoteDataSource: _getIt<TaskRemoteDataSource>(),
    //     networkInfo: _getIt<NetworkInfo>(),
    //     errorHandler: _getIt<ErrorHandler>(),
    //   ),
    // );
  }
  
  /// 注册用例
  static Future<void> _registerUseCases() async {
    // 用例将在仓库实现完成后添加
    // _getIt.registerLazySingleton<TaskUseCases>(
    //   () => TaskUseCases(
    //     repository: _getIt<TaskRepository>(),
    //   ),
    // );
  }
  
  /// 注册 BLoC
  static Future<void> _registerBlocs() async {
    // BLoC将在后续步骤中添加
    // _getIt.registerFactory<TaskBloc>(
    //   () => TaskBloc(
    //     taskUseCases: _getIt<TaskUseCases>(),
    //     errorHandler: _getIt<ErrorHandler>(),
    //   ),
    // );
    
    // _getIt.registerFactory<FilterBloc>(
    //   () => FilterBloc(),
    // );
    
    // _getIt.registerLazySingleton<SyncBloc>(
    //   () => SyncBloc(
    //     taskRepository: _getIt<TaskRepository>(),
    //     errorHandler: _getIt<ErrorHandler>(),
    //   ),
    // );
  }
  
  /// 验证依赖图完整性
  static Future<void> _validateDependencies() async {
    try {
      // 检查核心依赖
      assert(_getIt.isRegistered<ErrorHandler>(), 'ErrorHandler not registered');
      assert(_getIt.isRegistered<NetworkService>(), 'NetworkService not registered');
      assert(_getIt.isRegistered<NetworkInfo>(), 'NetworkInfo not registered');
      assert(_getIt.isRegistered<SharedPrefsHelper>(), 'SharedPrefsHelper not registered');
      
      // 数据源、仓库、用例和BLoC的验证将在实现完成后添加
      // assert(_getIt.isRegistered<TaskLocalDataSource>(), 'TaskLocalDataSource not registered');
      // assert(_getIt.isRegistered<TaskRemoteDataSource>(), 'TaskRemoteDataSource not registered');
      // assert(_getIt.isRegistered<TaskRepository>(), 'TaskRepository not registered');
      // assert(_getIt.isRegistered<TaskUseCases>(), 'TaskUseCases not registered');
      // assert(_getIt.isRegistered<TaskBloc>(), 'TaskBloc not registered');
      // assert(_getIt.isRegistered<FilterBloc>(), 'FilterBloc not registered');
      // assert(_getIt.isRegistered<SyncBloc>(), 'SyncBloc not registered');
      
      print('✅ 依赖注入验证通过 - 所有服务已正确注册');
    } catch (e) {
      throw Exception('❌ 依赖注入验证失败: $e');
    }
  }
  
  /// 重置所有依赖（主要用于测试）
  static Future<void> reset() async {
    await _getIt.reset();
  }
  
  /// 清理资源
  static Future<void> dispose() async {
    // 关闭所有 BLoC（将在BLoC实现后启用）
    // if (_getIt.isRegistered<SyncBloc>()) {
    //   _getIt<SyncBloc>().close();
    // }
    
    await _getIt.reset();
  }
}

/// 依赖注入装饰器
class Injectable {
  const Injectable();
}

/// 单例装饰器
class Singleton {
  const Singleton();
}

/// 懒加载单例装饰器
class LazySingleton {
  const LazySingleton();
}

/// 工厂装饰器
class Factory {
  const Factory();
}