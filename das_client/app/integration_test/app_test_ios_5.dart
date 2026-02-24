import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/additional_speed_restriction_modal_test.dart' as additional_speed_restriction_modal_test;
import 'test/journey_table_collapsible_rows_test.dart' as journey_table_collapsible_rows_test;
import 'test/journey_table_station_property_test.dart' as journey_table_station_property_test;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  additional_speed_restriction_modal_test.main();
  journey_table_station_property_test.main();
  journey_table_collapsible_rows_test.main();
}
