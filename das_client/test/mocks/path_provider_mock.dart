import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String temporaryPath = 'temporaryPath';
const String applicationSupportPath = 'applicationSupportPath';
const String downloadsPath = 'downloadsPath';
const String libraryPath = 'libraryPath';
const String applicationDocumentsPath = 'applicationDocumentsPath';
const String externalCachePath = 'externalCachePath';
const String externalStoragePath = 'externalStoragePath';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {

  @override
  Future<String> getTemporaryPath() async {
    return temporaryPath;
  }

  @override
  Future<String> getApplicationSupportPath() async {
    return applicationSupportPath;
  }

  @override
  Future<String> getLibraryPath() async {
    return libraryPath;
  }

  @override
  Future<String> getApplicationDocumentsPath() async {
    return applicationDocumentsPath;
  }

  @override
  Future<String> getExternalStoragePath() async {
    return externalStoragePath;
  }

  @override
  Future<List<String>> getExternalCachePaths() async {
    return <String>[externalCachePath];
  }

  @override
  Future<String> getDownloadsPath() async {
    return downloadsPath;
  }
}