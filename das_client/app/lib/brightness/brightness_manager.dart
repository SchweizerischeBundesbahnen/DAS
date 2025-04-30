abstract class BrightnessManager {
  Future<void> setBrightness(double value);
  Future<double> getCurrentBrightness();
  Future<bool> hasWriteSettingsPermission();
  Future<void> requestWriteSettings();
}
