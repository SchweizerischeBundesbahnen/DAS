abstract class Launcher {
  bool hasTourSystemConfigured();

  Future<bool> launchTourSystem();

  Future<bool> launch(String url);
}
