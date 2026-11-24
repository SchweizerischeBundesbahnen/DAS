import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;

const String fakeTemporaryPath = 'temporaryPath';
const String fakeApplicationSupportPath = 'applicationSupportPath';
const String fakeDownloadsPath = 'downloadsPath';
const String fakeLibraryPath = 'libraryPath';
const String fakeApplicationDocumentsPath = 'applicationDocumentsPath';
const String fakeExternalCachePath = 'externalCachePath';
const String fakeExternalStoragePath = 'externalStoragePath';
const String fakeApplicationCachePath = 'applicationCachePath';

class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getTemporaryPath() async => p.join(rootPath, fakeTemporaryPath);

  @override
  Future<String?> getApplicationSupportPath() async => p.join(rootPath, fakeApplicationSupportPath);

  @override
  Future<String?> getLibraryPath() async => p.join(rootPath, fakeLibraryPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => p.join(rootPath, fakeApplicationDocumentsPath);

  @override
  Future<String?> getExternalStoragePath() async => p.join(rootPath, fakeExternalStoragePath);

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[p.join(rootPath, fakeExternalCachePath)];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[p.join(rootPath, fakeExternalStoragePath)];
  }

  @override
  Future<String?> getDownloadsPath() async => p.join(rootPath, fakeDownloadsPath);

  @override
  Future<String?> getApplicationCachePath() async => p.join(rootPath, fakeApplicationCachePath);
}
