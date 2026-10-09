import 'package:app/launcher/launcher_impl.dart';

class MockLauncher extends LauncherImpl {
  MockLauncher({required super.userPropertiesRepository, required super.flavor});

  final launchedUrls = <String>[];

  @override
  Future<bool> launch(String url) async {
    launchedUrls.add(url);
    return true;
  }
}
