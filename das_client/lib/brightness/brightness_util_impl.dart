import 'package:das_client/brightness/brightness_util.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessUtilImpl implements BrightnessUtil {
  @override
  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value.clamp(0.0, 1.0));
    } catch (e) {
      return;
    }
  }

  @override
  Future<double> getCurrentBrightness() async {
    try {
      return await ScreenBrightness().application;
    } catch (e) {
      return 0.1;
    }
  }
}
