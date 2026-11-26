import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/local/log_file_service_impl.dart';
import 'package:logger/src/log_level.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_platform.fake.dart';

void main() {
  late Directory tempDir;
  late Directory logDir;
  late LogFileService testee;
  late PathProviderPlatform originalPlatform;

  final simpleLogFile = SplunkLogEntryDto(
    time: 1624046400.0,
    event: 'A simple log message',
    level: LogLevel.info.name,
    fields: {'key': 'value'},
  );

  final twentyKiloBytesLog = SplunkLogEntryDto(
    time: 0,
    // metadata takes 60 bytes
    event: 'A' * 20420,
    level: LogLevel.info.name,
    fields: {},
  );

  final largerThanMaxFileSizeLog = SplunkLogEntryDto(
    time: 0,
    event: 'A' * (41 * 1024),
    level: LogLevel.info.name,
    fields: {},
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('logger_cache_test');
    logDir = Directory(p.join(tempDir.path, fakeApplicationSupportPath, 'splunk-logs'));

    originalPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    testee = LogFileServiceImpl();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    PathProviderPlatform.instance = originalPlatform;
  });

  test('writeLog_whenCalledOnce_shouldWriteJsonToFileWithoutComma', () async {
    // WHEN
    await testee.writeLog(simpleLogFile);

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals(simpleLogFile.toJsonString()));
  });

  test('writeLog_whenCalledTwiceWithSimpleFile_shouldAppendToPrevious', () async {
    // WHEN
    await testee.writeLog(simpleLogFile);
    await testee.writeLog(simpleLogFile);

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals('${simpleLogFile.toJsonString()},${simpleLogFile.toJsonString()}'));
  });

  test('writeLog_whenSingleLargeLogEntry_shouldWriteSingleFile', () async {
    // WHEN
    await testee.writeLog(twentyKiloBytesLog);

    // assert
    expect(logDir.listSync().length, equals(1));

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals(twentyKiloBytesLog.toJsonString()));
  });

  test('writeLog_whenLogSizeTooLarge_shouldWriteToNewFileAndHaveCompletedLog', () async {
    // WHEN
    await testee.writeLog(twentyKiloBytesLog);
    await testee.writeLog(twentyKiloBytesLog);

    expect(logDir.listSync().length, equals(2));
  });

  test('hasCompletedLogFiles_whenNoWrite_shouldBeFalse', () async {
    // WHEN + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenSingleSimpleLogEntryWritten_shouldBeFalse', () async {
    // GIVEN
    await testee.writeLog(simpleLogFile);

    // WHEN + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenSimpleAndLargeLogEntryWritten_shouldBeFalse', () async {
    // GIVEN
    await testee.writeLog(simpleLogFile);
    await testee.writeLog(twentyKiloBytesLog);

    // WHEN + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenTwoLargeLogEntryWritten_shouldBeTrue', () async {
    // GIVEN
    await testee.writeLog(twentyKiloBytesLog);
    await testee.writeLog(twentyKiloBytesLog);

    // WHEN + expect
    expect(await testee.hasCompletedLogFiles, true);
  });

  test('completedLogFiles_whenNoneWritten_shouldBeEmpty', () async {
    // WHEN + expect
    expect((await testee.completedLogFiles).isEmpty, true);
  });

  test('completedLogFiles_whenSimpleLogWritten_shouldBeEmpty', () async {
    // GIVEN
    await testee.writeLog(simpleLogFile);

    // WHEN + expect
    expect((await testee.completedLogFiles).isEmpty, true);
  });

  test('completedLogFiles_whenTwoLargeLogWritten_shouldHaveLengthOne', () async {
    // GIVEN
    await testee.writeLog(twentyKiloBytesLog);
    await testee.writeLog(twentyKiloBytesLog);

    // WHEN + expect
    expect((await testee.completedLogFiles).length, 1);
  });

  test('completedLogFiles_whenTwoLargeLogWritten_shouldHaveContentFromLargeLogEntry', () async {
    // GIVEN
    await testee.writeLog(twentyKiloBytesLog);
    await testee.writeLog(twentyKiloBytesLog);

    // WHEN
    final actual = await testee.completedLogFiles;

    // THEN
    final actualLogEntry = actual.first.readAsStringSync();
    expect(actualLogEntry, twentyKiloBytesLog.toJsonString());
  });

  test('deleteLogFile_whenFileGiven_shouldDeleteIt', () async {
    // GIVEN
    await testee.writeLog(twentyKiloBytesLog);
    await testee.writeLog(twentyKiloBytesLog);
    // check whether two files exist (one completed)
    expect(logDir.listSync().length, equals(2));

    final files = await testee.completedLogFiles;
    final file = files.first;

    // WHEN
    await testee.deleteLogFile(file);

    // THEN
    expect(logDir.listSync().length, equals(1));
  });

  test('completeCurrentFile_whenNoLogsWritten_shouldNotCreateCompletedFile', () async {
    // WHEN
    await testee.completeCurrentFile();

    // THEN
    expect(await testee.hasCompletedLogFiles, false);
    expect((await testee.completedLogFiles).isEmpty, true);
  });

  test('completeCurrentFile_whenCalledTwice_shouldOnlyCompleteOnce', () async {
    // GIVEN
    await testee.writeLog(simpleLogFile);

    // WHEN
    await testee.completeCurrentFile();
    await testee.completeCurrentFile();

    // THEN
    expect((await testee.completedLogFiles).length, 1);
    expect((await testee.completedLogFiles).first.readAsStringSync(), simpleLogFile.toJsonString());
  });

  test('writeLog_whenFirstLogExceedsMaxFileSize_shouldNotCompleteEmptyFile', () async {
    // WHEN
    await testee.writeLog(largerThanMaxFileSizeLog);

    // THEN
    expect(await testee.hasCompletedLogFiles, false);
    expect(logDir.listSync().length, equals(1));

    final content = _currentCacheFile(logDir).readAsStringSync();
    expect(content, equals(largerThanMaxFileSizeLog.toJsonString()));
  });

  test('writeLog_whenLogWrittenAfterOversizedLog_shouldCompleteFileContainingOversizedLog', () async {
    // GIVEN
    await testee.writeLog(largerThanMaxFileSizeLog);

    // WHEN
    await testee.writeLog(simpleLogFile);

    // THEN
    final completedFiles = await testee.completedLogFiles;
    expect(completedFiles.length, 1);
    expect(completedFiles.first.readAsStringSync(), largerThanMaxFileSizeLog.toJsonString());

    final content = _currentCacheFile(logDir).readAsStringSync();
    expect(content, equals(simpleLogFile.toJsonString()));
  });

  test('completeCurrentFile_whenHasWrite_shouldRenameFile', () async {
    // GIVEN
    await testee.writeLog(simpleLogFile);
    // check whether one file exist (one completed)
    expect(logDir.listSync().length, equals(1));

    // WHEN
    await testee.completeCurrentFile();

    // THEN
    expect(logDir.listSync().length, equals(1));
    expect(_currentCacheFile(logDir).existsSync(), false);
  });
}

File _currentCacheFile(Directory logDir) {
  final currentFilePath = p.join(logDir.path, 'das-log-lastSavedFile.json');
  final cacheFile = File(currentFilePath);
  return cacheFile;
}
