import 'package:warnapp/src/motion_data_listener.dart';

abstract class MotionDataService {
  const MotionDataService._();

  void start(MotionDataListener listener);

  void stop();
}
