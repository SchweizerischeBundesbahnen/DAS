import 'dart:convert';
import 'dart:io';

import 'package:das_client/logging/src/log_entry.dart';
import 'package:das_client/logging/src/log_level.dart';
import 'package:das_client/logging/src/log_service.dart';
import 'package:das_client/service/backend_service.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../mocks/path_provider_mock.dart';
import 'logging_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BackendService>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory logDirectory;
  late MockBackendService mockBackendService = MockBackendService();
  GetIt.I.registerSingleton<BackendService>(mockBackendService);
  Fimber.plantTree(DebugTree());

  setUp(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    logDirectory = Directory("${(await getApplicationSupportDirectory()).path}/logs");
    logDirectory.createSync(recursive: true);
    logDirectory.listSync().forEach((element) {
      element.deleteSync();
    });
    reset(mockBackendService);
    await GetIt.I.allReady();
  });

  test('Test writes logs to new file in directory', () async {
    LogService loggingService = LogService();

    var files = logDirectory.listSync();
    expect(files, hasLength(0));

    var logEntry = LogEntry("Test message", LogLevel.info, {});
    loggingService.save(logEntry);
    await Future.delayed(const Duration(milliseconds: 30));

    files = logDirectory.listSync();
    expect(files, hasLength(1));
  });

  test('Test writes appends comma after writing log', () async {
    LogService loggingService = LogService();

    var files = logDirectory.listSync();
    expect(files, hasLength(0));

    var logEntry = LogEntry("Test message", LogLevel.fatal, {});
    loggingService.save(logEntry);
    await Future.delayed(const Duration(milliseconds: 30));

    files = logDirectory.listSync();
    expect(files, hasLength(1));
    expect((files[0] as File).readAsStringSync(), "${jsonEncode(logEntry)},");
  });

  test('Test writes multiple logs to same file', () async {
    LogService loggingService = LogService();

    var files = logDirectory.listSync();
    expect(files, hasLength(0));

    loggingService.save(LogEntry("Test message", LogLevel.info, {}));
    loggingService.save(LogEntry("Test message 2", LogLevel.error, {}));
    loggingService.save(LogEntry("Test message 3", LogLevel.warning, {}));
    loggingService.save(LogEntry("Test message 4", LogLevel.debug, {}));
    await Future.delayed(const Duration(milliseconds: 30));

    files = logDirectory.listSync();
    expect(files, hasLength(1));
  });

  test('Test log entry json encode & decode', () async {
    final logEntry = LogEntry("Test message", LogLevel.info, {'version': "0.1", 'systemName': "unitTests"});
    final logEntryDecoded = LogEntry.fromJson(jsonDecode(jsonEncode(logEntry)));

    expect(logEntryDecoded.message, logEntry.message);
    expect(logEntryDecoded.level, logEntry.level);
    expect(logEntryDecoded.time, logEntry.time);
    expect(logEntryDecoded.source, logEntry.source);
    expect(logEntryDecoded.metadata, logEntry.metadata);
  });

  test('Test rolls over files after size limit reached', () async {
    LogService loggingService = LogService();
    when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(false));

    var files = logDirectory.listSync();
    expect(files, hasLength(0));
    final logEntry = LogEntry("Test message", LogLevel.info, {'version': "0.1", 'systemName': "unitTests"});
    loggingService.save(logEntry);

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(1));

    for (var i = 0; i < 400; i++) {
      loggingService.save(logEntry);
    }

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(2));

    await Future.delayed(const Duration(milliseconds: 20));
  });

  test('Test send logs after rolling over file', () async {
    LogService loggingService = LogService();
    when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(false));

    var files = logDirectory.listSync();
    expect(files, hasLength(0));
    final logEntry = LogEntry("Test message", LogLevel.info, {'version': "0.1", 'systemName': "unitTests"});
    loggingService.save(logEntry);

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(1));

    for (var i = 0; i < 400; i++) {
      loggingService.save(logEntry);
    }

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(2));

    verify(mockBackendService.sendLogs(any)).called(1);
  });

  test('Test file deletion after successful backend request', () async {
    LogService loggingService = LogService();
    when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(true));

    var files = logDirectory.listSync();
    expect(files, hasLength(0));
    final logEntry = LogEntry("Test message", LogLevel.info, {'version': "0.1", 'systemName': "unitTests"});
    loggingService.save(logEntry);

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(1));

    for (var i = 0; i < 400; i++) {
      loggingService.save(logEntry);
    }

    await Future.delayed(const Duration(milliseconds: 20));

    files = logDirectory.listSync();
    expect(files, hasLength(1));
    verify(mockBackendService.sendLogs(any)).called(1);
  });
}
