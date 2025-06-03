import 'package:warnapp/src/motion_data_listener.dart';

abstract class MotionDataProvider {
  const MotionDataProvider._();

  void start(MotionDataListener listener);

  void stop();
}
