import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:fimber/fimber.dart';
import 'package:integration_test/integration_test.dart';

import 'test/automatic_advancement_test.dart' as automatic_advancement_tests;
import 'test/service_point_modal_test.dart' as service_point_modal_test;
import 'test/navigation_test.dart' as navigation_tests;
import 'test/train_search_test.dart' as train_search_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  navigation_tests.main();
  train_search_tests.main();
  automatic_advancement_tests.main();
  service_point_modal_test.main();
}
