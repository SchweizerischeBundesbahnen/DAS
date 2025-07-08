import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/train_journey_table_break_series_test.dart' as train_journey_table_break_series_tests;
import 'test/train_journey_table_calculated_speed_test.dart' as train_journey_table_calculated_speed_tests;
import 'test/train_journey_table_track_equipment_test.dart' as train_journey_table_track_equipment_tests;
import 'test/warnapp_test.dart' as warnapp_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  warnapp_tests.main();
  train_journey_table_break_series_tests.main();
  train_journey_table_track_equipment_tests.main();
  train_journey_table_calculated_speed_tests.main();
}
