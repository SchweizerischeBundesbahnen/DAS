import 'package:warnapp/src/device_motion_data_service.dart';
import 'package:warnapp/src/mock_motion_data_service.dart';
import 'package:warnapp/src/motion_data_service.dart';
import 'package:warnapp/src/warnapp_repository.dart';
import 'package:warnapp/src/warnapp_repository_impl.dart';

export 'package:warnapp/src/mock_motion_data_service.dart';
export 'package:warnapp/src/motion_data_listener.dart';
export 'package:warnapp/src/motion_data_service.dart';
export 'package:warnapp/src/warnapp_repository.dart';

class WarnappComponent {
  const WarnappComponent._();

  static WarnappRepository createWarnappRepository({MotionDataService? motionDataService}) {
    return WarnappRepositoryImpl(motionDataService: motionDataService ?? createDeviceMotionDataService());
  }

  static MotionDataService createDeviceMotionDataService() {
    return DeviceMotionDataService();
  }

  static MotionDataService createMockMotionDataService({String? motionData, Duration? samplingPeriod}) {
    return MockMotionDataService(motionData: motionData, samplingPeriod: samplingPeriod);
  }
}
