import 'package:warnapp/src/data/motion_data.dart';

abstract class MotionDataListener {
  const MotionDataListener._();

  void onMotionData(MotionData motionData);
}
