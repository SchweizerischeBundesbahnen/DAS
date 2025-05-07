import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/logger_repo_impl.dart';
import 'package:logger/src/log_level.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<LogApiService>(), MockSpec<LogFileService>()])
import 'logger_repo_test.mocks.dart';

void main() {
  late LoggerRepo testee;
  late MockLogApiService mockApiService;
  late MockLogFileService mockFileService;

  setUp(() {
    mockFileService = MockLogFileService();
    mockApiService = MockLogApiService();
    testee = LoggerRepoImpl(cacheService: mockFileService, remoteService: mockApiService);
  });

  final simpleLogFile = LogEntry(
    'A simple log message',
    LogLevel.warning,
    {'key': 'value'},
  );

  final fourKiloBytesLog = LogEntry(
    // metadata takes around 70 bytes
    'A' * 3935,
    LogLevel.warning,
    {},
  );

  test('saveLog_whenNoCompletedLogFiles_shouldWriteAndNotRollover', () async {
    // arrange
    when(mockFileService.writeLog(any)).thenAnswer((_) => Future.value());
    when(mockFileService.hasCompletedLogFiles).thenAnswer((_) => Future.value(false));

    // act
    await testee.saveLog(simpleLogFile);

    // expect
    verify(mockFileService.writeLog(any)).called(1);
    verify(mockFileService.hasCompletedLogFiles).called(1);
    verifyNever(mockFileService.completedLogFiles);
    verifyNever(mockApiService.sendLogs);
  });
}

//
//   test('Test rolls over files after size limit reached', () async {
//     final loggingService = LogService(backendService: mockBackendService);
//     when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(false));
//
//     var files = logDirectory.listSync();
//     expect(files, hasLength(0));
//     final logEntry = LogEntry('Test message', LogLevel.info, {'version': '0.1', 'systemName': 'unitTests'});
//     loggingService.save(logEntry);
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(1));
//
//     for (var i = 0; i < 400; i++) {
//       loggingService.save(logEntry);
//     }
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(2));
//
//     await Future.delayed(const Duration(milliseconds: 20));
//   });
//
//   test('Test send logs after rolling over file', () async {
//     final loggingService = LogService(backendService: mockBackendService);
//     when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(false));
//
//     var files = logDirectory.listSync();
//     expect(files, hasLength(0));
//     final logEntry = LogEntry('Test message', LogLevel.info, {'version': '0.1', 'systemName': 'unitTests'});
//     loggingService.save(logEntry);
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(1));
//
//     for (var i = 0; i < 400; i++) {
//       loggingService.save(logEntry);
//     }
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(2));
//
//     verify(mockBackendService.sendLogs(any)).called(1);
//   });
//
//   test('Test file deletion after successful backend request', () async {
//     final loggingService = LogService(backendService: mockBackendService);
//     when(mockBackendService.sendLogs(any)).thenAnswer((input) => Future.value(true));
//
//     var files = logDirectory.listSync();
//     expect(files, hasLength(0));
//     final logEntry = LogEntry('Test message', LogLevel.info, {'version': '0.1', 'systemName': 'unitTests'});
//     loggingService.save(logEntry);
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(1));
//
//     for (var i = 0; i < 400; i++) {
//       loggingService.save(logEntry);
//     }
//
//     await Future.delayed(const Duration(milliseconds: 20));
//
//     files = logDirectory.listSync();
//     expect(files, hasLength(1));
//     verify(mockBackendService.sendLogs(any)).called(1);
//   });
// }
