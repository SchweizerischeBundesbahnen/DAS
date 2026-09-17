import 'dart:core';

import 'package:sfera/component.dart';

abstract class LocalRegulationHtmlGenerator._() {
  String generate({required Map<String, LocalRegulationSection> sectionMap, required String? rootId});
}
