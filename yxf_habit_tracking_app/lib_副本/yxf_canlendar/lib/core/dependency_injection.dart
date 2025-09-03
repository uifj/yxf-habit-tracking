// import 'db/db_helper.dart';  因鸿蒙平台不适配sqlite组件，使用SharedPrefsHelper
import 'db/shared_prefs_helper.dart';
import '../data/services/task_services.dart';
import '../data/repositories/task_repository.dart';
import '../presentation/bloc/todo_bloc.dart';

/// 依赖注入管理类
/// 负责管理应用中所有服务和仓库的依赖关系
class DependencyInjection {
  static SharedPrefsHelper? _dbHelper;
  // static NotifyHelper? _notifyHelper;
  static TaskServices? _taskServices;
  static TaskRepository? _taskRepository;
  static TodoBloc? _todoBloc;

  /// 初始化所有依赖
  static Future<void> init() async {
    // 注册数据库服务
    _dbHelper = SharedPrefsHelper();

    // 注册通知服务
    // _notifyHelper = NotifyHelper();

    // 注册远程服务
    _taskServices = TaskServices();

    // 注册仓库
    _taskRepository = TaskRepositoryImpl(
      dbHelper: _dbHelper!,
      taskServices: _taskServices!,
      // notifyHelper: _notifyHelper!,
    );

    // 注册 BLoC
    _todoBloc = TodoBloc(taskRepository: _taskRepository!);
  }

  /// 清理所有依赖
  static void dispose() {
    _todoBloc?.close();
    _dbHelper = null;
    // _notifyHelper = null;
    _taskServices = null;
    _taskRepository = null;
    _todoBloc = null;
  }
}

/// 服务定位器
/// 提供简单的服务获取接口
class ServiceLocator {
  static T get<T>() {
    if (T == SharedPrefsHelper) return DependencyInjection._dbHelper as T;
    // if (T == NotifyHelper) return DependencyInjection._notifyHelper as T;
    if (T == TaskServices) return DependencyInjection._taskServices as T;
    if (T == TaskRepository) return DependencyInjection._taskRepository as T;
    if (T == TodoBloc) return DependencyInjection._todoBloc as T;
    throw Exception('Service of type $T not found');
  }
}

/// 依赖注入装饰器
/// 用于标记需要依赖注入的类
class Injectable {
  const Injectable();
}

/// 单例装饰器
/// 用于标记单例类
class Singleton {
  const Singleton();
}

/// 工厂装饰器
/// 用于标记工厂类
class Factory {
  const Factory();
}

/// 懒加载单例装饰器
/// 用于标记懒加载单例类
class LazySingleton {
  const LazySingleton();
}
