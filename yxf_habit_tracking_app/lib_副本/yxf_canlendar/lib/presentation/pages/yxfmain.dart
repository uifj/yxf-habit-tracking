import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../core/db/shared_prefs_helper.dart';
import '../../data/services/task_services.dart';
import 'calendar_page.dart';

/// 企业级YXF日历应用
/// 采用Clean Architecture + BLoC模式
/// 支持任务管理、习惯追踪、番茄钟计时器等功能

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地化数据，解决 LocaleDataException
  await initializeDateFormatting('zh_CN', null);
  await initializeDateFormatting('en_US', null);

  // 运行应用
  runApp(const YxfCalendarApp());
}

class YxfCalendarApp extends StatelessWidget {
  const YxfCalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YXF Calendar - 企业级任务管理系统',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      // 本地化配置
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      home: _buildAppWithProviders(),
    );
  }

  /// 构建应用主题 - 浅色模式
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 构建应用主题 - 深色模式
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 构建带有BLoC提供者的应用
  Widget _buildAppWithProviders() {
    return MultiBlocProvider(
      providers: _createBlocProviders(),
      child: const CalendarPage(),
    );
  }

  /// 创建所有BLoC提供者
  List<BlocProvider> _createBlocProviders() {
    return [
      // 任务管理BLoC
      BlocProvider<TodoBloc>(
        create: (context) => TodoBloc(
          taskRepository: TaskRepositoryImpl(
            dbHelper: SharedPrefsHelper(),
            taskServices: TaskServices(),
          ),
        )..add(const InitializeTodoEvent()),
      ),

      // 习惯追踪BLoC
      BlocProvider<HabitBloc>(
        create: (context) => HabitBloc(
          habitRepository: HabitRepositoryImpl(),
        )..add(const InitializeHabitEvent()),
      ),

      // 番茄钟计时器BLoC
      BlocProvider<TimerBloc>(
        create: (context) => TimerBloc(
          timerRepository: TimerRepositoryImpl(),
        )..add(const InitializeTimerEvent()),
      ),

      // 标签管理BLoC
      BlocProvider<TagBloc>(
        create: (context) => TagBloc(
          tagRepository: const TagRepositoryImpl(),
        )..add(const InitializeTagEvent()),
      ),
    ];
  }
}
