// import 'dart:async';
// import 'dart:developer';

// import 'package:bloc/bloc.dart';
// import 'package:flutter/widgets.dart';

// class AppBlocObserver extends BlocObserver {
//   const AppBlocObserver();

//   @override
//   void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
//     super.onChange(bloc, change);
//     log('onChange(${bloc.runtimeType}, $change)');
//   }

//   @override
//   void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
//     log('onError(${bloc.runtimeType}, $error, $stackTrace)');
//     super.onError(bloc, error, stackTrace);
//   }
// }

// Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
//   FlutterError.onError = (details) {
//     log(details.exceptionAsString(), stackTrace: details.stack);
//   };

//   Bloc.observer = const AppBlocObserver();

//   // Add cross-flavor configuration here

//   runApp(await builder());
// }

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yxf_habit_tracking_app/app/app.dart';
import 'package:yxf_habit_tracking_app/app/app_bloc_observer.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

void bootstrap({required TodosApi todosApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  runApp(App(createTodosRepository: () => TodosRepository(todosApi: todosApi)));
}
