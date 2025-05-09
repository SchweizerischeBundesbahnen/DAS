import 'dart:core';

import 'package:sfera/src/model/journey/journey.dart';

abstract class SferaLocalRepo {
  const SferaLocalRepo._();

  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate});
}
