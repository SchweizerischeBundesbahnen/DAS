import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warnapp/component.dart';
import 'package:warnapp/src/mock_motion_data_provider.dart';
import 'package:warnapp/src/warnapp_listener.dart';

import 'warnapp_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WarnappListener>(),
])
main() {
  group('Warnapp service tests', () {
    test('Test abfahrt detected 1', () {
      testAbfahrtDetected('test_resources/motion_log_abfahrt_1.txt', 1);
    });

    test('Test abfahrt detected 2', () {
      testAbfahrtDetected('test_resources/motion_log_abfahrt_2.txt', 1);
    });

    test('Test kurze abfahrt detected 1', () {
      testAbfahrtDetected('test_resources/motion_log_kurze_abfahrt_1.txt', 1);
    });

    test('Test kurze abfahrt detected 2', () {
      testAbfahrtDetected('test_resources/motion_log_kurze_abfahrt_2.txt', 1);
    });

    test('Test stillstand 1', () {
      testAbfahrtDetected('test_resources/motion_log_stillstand_1.txt', 0);
    });

    test('Test stillstand 2', () {
      testAbfahrtDetected('test_resources/motion_log_stillstand_2.txt', 0);
    });
  });
}

void testAbfahrtDetected(String testFile, int abfahrtCount) {
  final listenerMock = MockWarnappListener();
  final motionDataFile = File(testFile);
  final motionDataProvider = MockMotionDataProvider(motionData: motionDataFile.readAsStringSync());
  final warappService = WarnappComponent.createWarnappService(motionDataProvider: motionDataProvider);
  warappService.addListener(listenerMock);

  warappService.enable();

  if (abfahrtCount == 0) {
    verifyNever(listenerMock.onAbfahrtDetected());
  } else {
    verify(listenerMock.onAbfahrtDetected()).called(abfahrtCount);
  }
}
