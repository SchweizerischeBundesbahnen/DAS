import 'package:app/launcher/launcher_impl.dart';

class MockLauncher({required super.userSettings, required super.flavor}) extends LauncherImpl {
  final launchedUrls = <String>[];

  @override
  Future<bool> launch(String url) async {
    launchedUrls.add(url);
    return true;
  }
}
