import 'dart:core';

import 'package:sfera/component.dart';

abstract class SferaLocalRepo {
  const SferaLocalRepo._();

  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate});

  Future<Journey?> getJourney({required String company, required String trainNumber, required DateTime startDate});

  Future<int> cleanup();

  Future<bool> saveData(String data);

  Future<DbMetrics> retrieveMetrics();
}
