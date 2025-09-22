import 'package:local_regulations/src/local_regulation_generator.dart';
import 'package:local_regulations/src/local_regulation_generator_impl.dart';

export 'package:local_regulations/src/local_regulation_generator.dart';

class LocalRegulationComponent {
  const LocalRegulationComponent._();

  static LocalRegulationHtmlGenerator createLocalRegulationHtmlGenerator() => LocalRegulationHtmlGeneratorImpl();
}
