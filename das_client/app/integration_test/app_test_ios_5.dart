import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/additional_speed_restriction_modal_test.dart' as additional_speed_restriction_modal_test;
import 'test/service_point_modal_test.dart' as service_point_modal_test;
import 'test/train_journey_table_collapsible_rows_test.dart' as train_journey_table_collapsible_rows_test;
import 'test/train_journey_table_station_property_test.dart' as train_journey_table_station_property_test;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  service_point_modal_test.main();
  additional_speed_restriction_modal_test.main();
  train_journey_table_station_property_test.main();
  train_journey_table_collapsible_rows_test.main();
}
