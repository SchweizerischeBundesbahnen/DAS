import 'package:app/i18n/gen/app_localizations.dart';
import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/journey_search_overlay_test.dart' as journey_search_overlay_tests;
import 'test/train_journey_header_test.dart' as train_journey_header_tests;
import 'test/train_journey_notification_test.dart' as train_journey_notification_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  train_journey_header_tests.main();
  train_journey_notification_tests.main();
  journey_search_overlay_tests.main();
}
