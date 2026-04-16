import 'package:app/launcher/launcher_impl.dart';

class MockLauncher extends LauncherImpl {
  final launchedUrls = <String>[];

  MockLauncher({required super.userSettings, required super.flavor});

  @override
  Future<bool> launch(String url) async {
    launchedUrls.add(url);
    return true;
  }
}
