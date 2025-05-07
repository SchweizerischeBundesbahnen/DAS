import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/dto/log_file_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/logger_repo_impl.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:logger/src/log_level.dart';
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
    LogLevel.warning,
    {'key': 'value'},
  );

  test('saveLog_whenNoCompletedLogFiles_shouldWriteAndNotRollover', () async {
    // arrange
    when(fileService.writeLog(any)).thenAnswer((_) => Future.value());
    when(fileService.hasCompletedLogFiles).thenAnswer((_) => Future.value(false));

    // act
    await testee.saveLog(simpleLogFile);

    // expect
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verifyNever(fileService.completedLogFiles);
    verifyNever(apiService.sendLogs);
  });

  test('saveLog_whenHasCompletedLogFiles_shouldWriteAndRolloverAndDelete', () async {
    // arrange
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile]);
    when(fileService.deleteLogFile(logFile)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // act
    await testee.saveLog(simpleLogFile);

    // expect
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(1);
    verify(fileService.deleteLogFile(logFile)).called(1);
  });

  test('saveLog_whenHasMultipleCompletedLogFiles_shouldWriteAndRolloverAndDelete', () async {
    // arrange
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile, logFile, logFile]);
    when(fileService.deleteLogFile(logFile)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // act
    await testee.saveLog(simpleLogFile);

    // expect
    verify(fileService.writeLog(any)).called(1);
    verify(fileService.hasCompletedLogFiles).called(1);
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(3);
    verify(fileService.deleteLogFile(logFile)).called(3);
  });

  test('saveLog_whenSendFails_shouldNotDeleteLogFile', () async {
    // arrange
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => true);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile]);
    when(fileService.deleteLogFile(logFile)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenThrow(HttpException('fakeException'));
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);

    // act
    await testee.saveLog(simpleLogFile);

    // expect
    verify(apiService.sendLogs).called(1);
    verifyNever(fileService.deleteLogFile(any));
  });

  test('saveLog_whenRolloverTimeReached_shouldWriteRolloverAndDelete', () async {
    // arrange
    final logFile = LogFileDto(logEntries: [simpleLogFile.toDto()], file: File('fakeFile.json'));
    when(fileService.writeLog(any)).thenAnswer((_) async {});
    when(fileService.hasCompletedLogFiles).thenAnswer((_) async => false);
    when(fileService.completedLogFiles).thenAnswer((_) async => [logFile]);
    when(fileService.deleteLogFile(logFile)).thenAnswer((_) async {});
    when(mockSendLogsRequest.call(any)).thenAnswer((_) async => mockSendLogsResponse);
    when(apiService.sendLogs).thenReturn(mockSendLogsRequest);
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));

    // act
    await withClock(Clock.fixed(fiveMinutesFromNow), () async {
      await testee.saveLog(simpleLogFile);
    });

    // expect
    verify(fileService.completedLogFiles).called(1);
    verify(apiService.sendLogs).called(1);
    verify(fileService.deleteLogFile(logFile)).called(1);
  });
}
