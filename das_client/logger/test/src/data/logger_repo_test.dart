import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/api/send_logs_exception.dart';
import 'package:logger/src/data/dto/log_file_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/logger_repo_impl.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<LogApiService>(),
  MockSpec<LogFileService>(),
  MockSpec<SendLogsRequest>(),
  MockSpec<SendLogsResponse>(),
])
import 'logger_repo_test.mocks.dart';

void main() {
  late LoggerRepo testee;
  late MockLogApiService apiService;
  late MockLogFileService fileService;
  late MockSendLogsRequest mockSendLogsRequest;
  late MockSendLogsResponse mockSendLogsResponse;

  setUp(() {
    fileService = MockLogFileService();
    apiService = MockLogApiService();
    mockSendLogsRequest = MockSendLogsRequest();
    mockSendLogsResponse = MockSendLogsResponse();
    testee = LoggerRepoImpl(fileService: fileService, apiService: apiService);
  });

  final simpleLogFile = LogEntry(
    'A simple log message',
    .warning,
    {'key': 'value'},
  );

  test('saveLog_whenNoCompletedLogFiles_shouldWriteAndNotRollover', () async {
    // GIVEN
    when(fileService.writeLog(any)).thenAnswer((_) => Future.value());
    when(fileService.hasCompletedLogFiles).thenAnswer((_) => Future.value(false));

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verifyNever(fileService.completedLogFiles);
    verifyNever(apiService.sendLogs);
  });

  test('saveLog_whenHasCompletedLogFiles_shouldWriteAndRolloverAndDelete', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(1);
    verify(fileService.deleteLogFile(logFile.file)).called(1);
  });

  test('saveLog_whenHasMultipleCompletedLogFiles_shouldWriteAndRolloverAndDelete', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file, logFile.file, logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(3);
    verify(fileService.deleteLogFile(logFile.file)).called(3);
  });

  test('saveLog_whenSendFailsTemporarily_shouldNotDeleteLogFile', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenThrow(const TransientSendLogsException('fakeException'));
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(apiService.sendLogs).called(1);
    verifyNever(fileService.deleteLogFile(any));
  });

  test('saveLog_whenRolloverTimeReached_shouldWriteRolloverAndDelete', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => false);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);
    final sixMinutesFromNow = DateTime.now().add(const Duration(minutes: 6));

    // WHEN
    await withClock(Clock.fixed(sixMinutesFromNow), () async {
      await testee.saveLog(simpleLogFile);
    });

    // THEN
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(1);
    verify(fileService.deleteLogFile(logFile.file)).called(1);
  });

  test('saveLog_whenSendFailsPermanently_shouldDeleteLogFile', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenThrow(const PermanentSendLogsException('rejected by remote'));
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(apiService.sendLogs).called(1);
    verify(fileService.deleteLogFile(logFile.file)).called(1);
  });

  test('saveLog_whenSendFailsPermanently_shouldContinueWithRemainingFiles', () async {
    // GIVEN
    final poisonFile = File('poisonFile.json');
    final goodFile = File('goodFile.json');
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [poisonFile, goodFile]);
    when(fileService.deleteLogFile(any)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(poisonFile)).thenThrow(const PermanentSendLogsException('rejected by remote'));
    when(mockSendLogsRequest.call(goodFile)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(apiService.sendLogs).called(2);
    verify(fileService.deleteLogFile(poisonFile)).called(1);
    verify(fileService.deleteLogFile(goodFile)).called(1);
  });

  test('saveLog_whenSendFailsPermanently_shouldNotDelayNextSend', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenThrow(const PermanentSendLogsException('rejected by remote'));
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // WHEN
    await testee.saveLog(simpleLogFile);
    await testee.saveLog(simpleLogFile);

    // THEN
    verify(apiService.sendLogs).called(2);
  });

  test('saveLog_whenSendFailsTemporarily_shouldNotResendUntilAfterDelay', () async {
    // GIVEN
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile.file]);
    when(fileService.deleteLogFile(logFile.file)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenThrow(const TransientSendLogsException('fakeException'));
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));

    // WHEN
    await testee.saveLog(simpleLogFile); // will fail
    await testee.saveLog(simpleLogFile); // shouldNotCallAgain
    await withClock(Clock.fixed(fiveMinutesFromNow), () async {
      await testee.saveLog(simpleLogFile); // should try and fail again
    });

    // THEN
    verify(apiService.sendLogs).called(2);
    verifyNever(fileService.deleteLogFile(any));
  });
}
