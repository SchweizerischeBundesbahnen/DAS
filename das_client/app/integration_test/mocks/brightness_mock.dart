import 'package:app/brightness/brightness_manager.dart';

class MockBrightnessManager implements BrightnessManager {
  double currentBrightness = 1.0;
  final List<double> calledWith = [];
  bool writeSettingsPermission;

  MockBrightnessManager({this.writeSettingsPermission = true});

  @override
  Future<void> setBrightness(double value) async {
    calledWith.add(value);
    currentBrightness = value;
  }

  @override
  Future<double> getCurrentBrightness() async {
    return currentBrightness;
  }

  @override
  Future<bool> hasWriteSettingsPermission() async {
    return writeSettingsPermission;
  }

  @override
  Future<void> requestWriteSettings() async {}
}
