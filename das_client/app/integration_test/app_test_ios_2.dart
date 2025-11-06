import 'package:app/i18n/gen/app_localizations.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/journey_header_test.dart' as journey_header_tests;
import 'test/journey_notification_test.dart' as journey_notification_tests;
import 'test/journey_search_overlay_test.dart' as journey_search_overlay_tests;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  journey_header_tests.main();
  journey_notification_tests.main();
  journey_search_overlay_tests.main();
}
