import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/journey_table_additional_speed_restriction_test.dart' as journey_table_additional_speed_restriction_tests;
import 'test/journey_table_balise_level_crossing_test.dart' as journey_table_balise_level_crossing_tests;
import 'test/journey_table_updates_test.dart' as journey_table_updates_tests;
import 'test/service_point_modal_test.dart' as service_point_modal_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  service_point_modal_tests.main();
  journey_table_additional_speed_restriction_tests.main();
  journey_table_balise_level_crossing_tests.main();
  journey_table_updates_tests.main();
}
