// export 'view/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yxf_habit_tracking_app/home/home.dart';
import 'package:yxf_habit_tracking_app/l10n/l10n.dart';
import 'package:yxf_habit_tracking_app/theme/theme.dart';
import 'package:todos_repository/todos_repository.dart';

class App extends StatelessWidget {
  const App({required this.createTodosRepository, super.key});

  final TodosRepository Function() createTodosRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TodosRepository>(
      create: (_) => createTodosRepository(),
      dispose: (repository) => repository.dispose(),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlutterTodosTheme.light,
      darkTheme: FlutterTodosTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
