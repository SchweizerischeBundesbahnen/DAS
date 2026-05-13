import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/additional_speed_restriction_modal_test.dart' as additional_speed_restriction_modal_test;
import 'test/departure_process_test.dart' as departure_process_tests;
import 'test/suspicious_segment_test.dart' as suspicious_segment_tests;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  additional_speed_restriction_modal_test.main();
  departure_process_tests.main();
  suspicious_segment_tests.main();
}
