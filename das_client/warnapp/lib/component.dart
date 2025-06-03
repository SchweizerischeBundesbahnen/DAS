import 'package:warnapp/src/device_motion_data_provider.dart';
import 'package:warnapp/src/motion_data_provider.dart';
import 'package:warnapp/src/warnapp_service.dart';
import 'package:warnapp/src/warnapp_service_impl.dart';

export 'package:warnapp/src/motion_data_listener.dart';
export 'package:warnapp/src/motion_data_provider.dart';
export 'package:warnapp/src/warnapp_service.dart';

class WarnappComponent {
  const WarnappComponent._();

  static WarnappService createWarnappService({MotionDataProvider? motionDataProvider}) {
    return WarnappServiceImpl(motionDataProvider: motionDataProvider ?? createDeviceMotionDataProvider());
  }

  static MotionDataProvider createDeviceMotionDataProvider() {
    return DeviceMotionDataProvider();
  }
}
