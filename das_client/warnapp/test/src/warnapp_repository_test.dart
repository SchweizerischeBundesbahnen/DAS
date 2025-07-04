import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/component.dart';

void main() {
  group('Warnapp service tests', () {
    test('Test abfahrt detected 1', () async {
      await testAbfahrtDetected('test_resources/motion_log_abfahrt_1.txt', 1);
    });

    test('Test abfahrt detected 2', () async {
      await testAbfahrtDetected('test_resources/motion_log_abfahrt_2.txt', 1);
    });

    test('Test kurze abfahrt detected 1', () async {
      await testAbfahrtDetected('test_resources/motion_log_kurze_abfahrt_1.txt', 1);
    });

    test('Test kurze abfahrt detected 2', () async {
      await testAbfahrtDetected('test_resources/motion_log_kurze_abfahrt_2.txt', 1);
    });

    test('Test stillstand 1', () async {
      await testAbfahrtDetected('test_resources/motion_log_stillstand_1.txt', 0);
    });

    test('Test stillstand 2', () async {
      await testAbfahrtDetected('test_resources/motion_log_stillstand_2.txt', 0);
    });
  });
}

Future<void> testAbfahrtDetected(String testFile, int abfahrtCount) async {
  final motionDataFile = File(testFile);
  final motionDataService = MockMotionDataService(motionData: motionDataFile.readAsStringSync());
  final warnappRepository = WarnappComponent.createWarnappRepository(motionDataService: motionDataService);

  var abfahrtDetectedCount = 0;
  warnappRepository.abfahrtEventStream.listen((data) => abfahrtDetectedCount++);

  warnappRepository.enable();

  // wait for listener to be triggered
  await Future.delayed(Duration(milliseconds: 1));

  expect(abfahrtDetectedCount, abfahrtCount);
}
