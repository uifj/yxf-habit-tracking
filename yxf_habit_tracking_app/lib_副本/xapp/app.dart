import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tencent_cloud_chat_common/widgets/material_app.dart';
import 'package:tencent_cloud_chat_demo/core/utils/toast_utils.dart';
import 'package:tencent_cloud_chat_demo/src/presentation/pages/home/home.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';

class App extends StatelessWidget {
  const App({required this.createTodosRepository, super.key});

  final TodosRepository Function() createTodosRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TodosRepository>(
      create: (_) => createTodosRepository(),
      // dispose: (repository) => repository.dispose(),
      child: TencentCloudChatMaterialApp(
        title: '有限风APP',
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        home: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends TencentCloudChatState<AppView> {
  @override
  void initState() {
    super.initState();
    ToastUtils.init(context);
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return mobileBuilder(context);
  }

  @override
  Widget mobileBuilder(BuildContext context) {
    return const HomePage();
  }

  @override
  Widget desktopBuilder(BuildContext context) {
    return const HomePage();
  }
}
