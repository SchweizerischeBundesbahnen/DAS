import 'package:app/app.dart';
import 'package:app/auth/auth_cubit.dart';
import 'package:app/di.dart';
import 'package:app/flavor.dart';
import 'package:app/logging/logging_component.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> start(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initLogging();
  await _initDependencyInjection(flavor);
  runDasApp();
}

Future<void> runDasApp() async {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AuthCubit()..init()),
    ],
    child: App(),
  ));
}

Future<void> _initLogging() async {
  Fimber.plantTree(DebugTree(useColors: false));
  Fimber.plantTree(LoggingComponent.createDasLogTree());
}

Future<void> _initDependencyInjection(Flavor flavor) async {
  await DI.init(flavor);
}
