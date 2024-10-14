import 'package:das_client/flavor.dart';
import 'package:das_client/main.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test/fahrbild_test.dart' as FahrbildTests;
import 'test/navigation_test.dart' as NavigationTests;

import 'di.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());
  await IntegrationTestDI.init(Flavor.dev);

  FahrbildTests.main();
  NavigationTests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester) async {
  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
