// export 'view/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yxf_habit_tracking_app/features/home/home.dart';
import 'package:yxf_habit_tracking_app/app/l10n/l10n.dart';
import 'package:yxf_habit_tracking_app/app/theme/theme.dart';
import 'package:todos_repository/todos_repository.dart';

class App extends StatelessWidget {
  const App({required this.createTodosRepository, super.key});

  final TodosRepository Function() createTodosRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<TodosRepository>(
          create: (_) => createTodosRepository(),
          // dispose: (repository) => repository.dispose(),
        ),
        // Add LocaleCubit for language management
        // 添加LocaleCubit用于语言管理
        BlocProvider(
          create: (context) => LocaleCubit()
            ..initializeWithSystemLocale(), // Initialize with system locale
        ),
        // Add ThemeCubit for theme management
        // 添加ThemeCubit用于主题管理
        BlocProvider(
          create: (context) => ThemeCubit()
            ..setSystemTheme() // Initialize with system theme
            ..setPrimaryColor(
                const Color(0xFF13B9FF)), // Set default primary color
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (context, locale, supportedLocales) {
        return ThemeBuilder(
          builder: (context, lightTheme, darkTheme, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              // Theme configuration
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              // Locale configuration
              locale: locale,
              supportedLocales: supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
