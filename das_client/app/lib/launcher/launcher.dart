import 'package:sfera/component.dart';

abstract class Launcher {
  bool hasTourSystemConfigured();

  Future<bool> launchTourSystem();

  Future<bool> launch(String url);

  Future<bool> launchServicePointPortal(ServicePoint servicePoint);
}
