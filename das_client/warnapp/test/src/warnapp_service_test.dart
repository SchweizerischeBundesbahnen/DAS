import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:warnapp/component.dart';
import 'package:warnapp/src/mock_motion_data_provider.dart';
import 'package:warnapp/src/warnapp_listener.dart';

@GenerateNiceMocks([
  MockSpec<WarnappListener>(),
])
main() {
  group('Warnapp service tests', () {
    test('Test abfahrt detected 1', () {
      final listenerMock = MockWarnappListener();
      final motionDataFile = File('test_resources/motion_log_abfahrt_1.txt');
      final motionDataProvider = MockMotionDataProvider(motionData: motionDataFile.readAsStringSync());
      final warappService = WarnappComponent.createWarnappService(motionDataProvider: motionDataProvider);

      //warappService.addListener(listener)
    });
  });
}
