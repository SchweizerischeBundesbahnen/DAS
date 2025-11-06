import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/journey_table_break_series_test.dart' as journey_table_break_series_tests;
import 'test/journey_table_calculated_speed_test.dart' as journey_table_calculated_speed_tests;
import 'test/journey_table_track_equipment_test.dart' as journey_table_track_equipment_tests;
import 'test/settings_test.dart' as settings_test;
import 'test/warnapp_test.dart' as warnapp_tests;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  journey_table_calculated_speed_tests.main();
  settings_test.main();
  warnapp_tests.main();
  journey_table_break_series_tests.main();
  journey_table_track_equipment_tests.main();
}
