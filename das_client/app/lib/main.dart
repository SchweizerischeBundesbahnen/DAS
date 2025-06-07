import 'package:app/app.dart';
import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
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

Future<void> _initDASLogging() async {
  Fimber.d('Initializing DAS logging by planting BaseScope tree');
  Fimber.plantTree(DI.get());
}

Future<void> _initDependencyInjection(Flavor flavor) async {
  await DI.init(flavor); // registers flavor, scopes, and scope handler

  final scopeHandler = DI.get<ScopeHandler>();
  await scopeHandler.push<DASBaseScope>();
  // TODO: The problem here is that someone who still has a session with TMS authenticator
  //  will not seem to be logged in anymore since we assume SferaMock as the default in app start.
  // This is necessary to ensure that an authenticator is available for the SplashPage.
  await scopeHandler.push<SferaMockScope>();
}
