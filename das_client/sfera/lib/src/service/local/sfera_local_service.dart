import 'dart:core';

import 'package:app/model/journey/journey.dart';

abstract class SferaLocalService {
  const SferaLocalService._();

  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate});
}
