import 'dart:core';

import 'package:sfera/component.dart';

abstract class LocalRegulationHtmlGenerator {
  LocalRegulationHtmlGenerator._();

  String generate({required List<LocalRegulationSection> sections});
}
