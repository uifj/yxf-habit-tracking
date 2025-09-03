import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tencent_cloud_chat_common/widgets/material_app.dart';
import 'package:tencent_cloud_chat_demo/core/router/app_router.dart';
import 'package:tencent_cloud_chat_demo/core/services/deep_link_service.dart';
import 'package:tencent_cloud_chat_demo/core/services/navigation_service.dart';
import 'package:tencent_cloud_chat_demo/src/presentation/bloc/bloc.dart';
import 'package:tencent_cloud_chat_demo/src/data/datasources/typing/dictionary_assets_datasource.dart';
import 'package:tencent_cloud_chat_demo/src/data/datasources/typing/audio_assets_datasource.dart';

// void main() async {
//   // 确保Flutter绑定初始化
//   WidgetsFlutterBinding.ensureInitialized();

//   // 初始化本地化数据，解决 LocaleDataException
//   await initializeDateFormatting('zh_CN', null);
//   await initializeDateFormatting('en_US', null);

//   // 运行应用
//   runApp(const YxfCalendarApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化深度链接服务
  final deepLinkService = DeepLinkService();
  deepLinkService.initialize();

  // 设置深度链接处理回调
  deepLinkService.setDeepLinkHandler((url, params) {
    debugPrint('收到深度链接: $url, 参数: $params');
    // 这里可以添加额外的深度链接处理逻辑
  });

  // 设置分享内容处理回调
  deepLinkService.setSharedContentHandler((content, type) {
    debugPrint('收到分享内容: $content, 类型: $type');
    // 这里可以添加分享内容处理逻辑
  });

  if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
    runApp(MyApp(prefs: prefs));
    try {
      doWhenWindowReady(() {
        const initialSize = Size(1300, 830);
        appWindow.minSize = const Size(1100, 630);
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    } catch (err) {
      //err
    }
  } else {
    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
    runApp(MyApp(prefs: prefs));
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // 初始化ToastUtil

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: prefs),
        // 数据源提供者
        RepositoryProvider<DictionaryAssetsDataSource>(
          create: (context) => DictionaryAssetsDataSource(),
        ),
        RepositoryProvider<AudioAssetsDataSource>(
          create: (context) => AudioAssetsDataSource(),
        ),
        // 仓库提供者 - 暂时注释掉，等待后续集成
        // RepositoryProvider<DictionaryRepository>(
        //   create: (context) => DictionaryRepositoryImpl(
        //     assetsDataSource: context.read<DictionaryAssetsDataSource>(),
        //     remoteDataSource: // TODO: 需要实现
        //     localDataSource: // TODO: 需要实现
        //   ),
        // ),
        // RepositoryProvider<AudioRepository>(
        //   create: (context) => AudioRepositoryImpl(
        //     assetsDataSource: context.read<AudioAssetsDataSource>(),
        //   ),
        // ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TypingBloc>(
            create: (context) => TypingBloc(
              dictionaryDataSource: context.read<DictionaryAssetsDataSource>(),
              audioDataSource: context.read<AudioAssetsDataSource>(),
            ),
          ),
          BlocProvider<StatisticsBloc>(
            create: (context) => StatisticsBloc(prefs: prefs),
          ),
        ],
        child: TencentCloudChatMaterialApp(
          title: '有限风APP',
          debugShowCheckedModeBanner: false,
          builder: FToastBuilder(),
          navigatorKey: NavigationService.navigatorKey,
          routes: AppRouter.routes,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
