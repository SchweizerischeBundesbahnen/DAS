import 'package:das_client/brightness/brightness_manager.dart';

class MockBrightnessManager implements BrightnessManager {
  double currentBrightness = 1.0;
  final List<double> calledWith = [];

  @override
  Future<void> setBrightness(double value) async {
    calledWith.add(value);
    currentBrightness = value;
  }

  @override
  Future<double> getCurrentBrightness() async {
    return currentBrightness;
  }
}
