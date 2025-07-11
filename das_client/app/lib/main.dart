import 'package:app/app.dart';
import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/flavor.dart';
import 'package:app/util/device_id_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

Future<void> start(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDASLogging(flavor);
  await _initDependencyInjection(flavor);
  runDasApp();
}

Future<void> runDasApp() async => runApp(App());

Future<void> _initDASLogging(Flavor flavor) async {
  final deviceId = await DeviceIdInfo.getDeviceId();
  final logPrinter = LogPrinter(appName: 'DAS ${flavor.displayName}', isDebugMode: kDebugMode);
  final dasLogger = LoggerComponent.createDasLogger(deviceId: deviceId, backendUrl: flavor.backendUrl);

  Logger.root.level = flavor.logLevel;
  Logger.root.onRecord.listen(logPrinter.call);
  Logger.root.onRecord.listen(dasLogger.call);
}

Future<void> _initDependencyInjection(Flavor flavor) async {
  await DI.init(flavor); // registers flavor, scopes, and scope handler

  final scopeHandler = DI.get<ScopeHandler>();
  await scopeHandler.push<DASBaseScope>();
  // TODO: The problem here is that someone who still has a session with TMS authenticator
  // will not seem to be logged in anymore since we assume SferaMock as the default in app start.
  // This is necessary to ensure that an authenticator is available for the SplashPage.
  await scopeHandler.push<SferaMockScope>();
}
