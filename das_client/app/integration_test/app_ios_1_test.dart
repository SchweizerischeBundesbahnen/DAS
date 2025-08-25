import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/train_journey_table_test.dart' as train_journey_table_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  //IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  train_journey_table_tests.main();
}
