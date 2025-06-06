import 'package:app/app.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';

Future<void> start(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree(useColors: false));
  await _initDependencyInjection(flavor);
  await _initDASLogging();
  runDasApp();
}

Future<void> runDasApp() async => runApp(App());

Future<void> _initDASLogging() async => Fimber.plantTree(DI.get());

Future<void> _initDependencyInjection(Flavor flavor) async {
  await DI.init(flavor);
}
