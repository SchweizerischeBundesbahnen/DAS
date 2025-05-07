import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/local/log_file_service_impl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path/path.dart' as p;

import 'path_provider_platform.fake.dart';

void main() {
  late Directory tempDir;
  late Directory logDir;
  late LogFileService testee;
  late PathProviderPlatform originalPlatform;

  final simpleLogFile = LogEntryDto(
    time: 1624046400.0,
    source: 'test-source',
    message: 'A simple log message',
    level: 'INFO',
    metadata: {'key': 'value'},
  );

  final fourKiloBytesLog = LogEntryDto(
    time: 0,
    source: '',
    // metadata takes 60 bytes
    message: 'A' * 3940,
    level: '',
    metadata: {},
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('logger_cache_test');
    logDir = Directory(p.join(tempDir.path, fakeApplicationSupportPath, 'logs'));

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

  test('writeLog_whenCalledOnce_shouldWriteJsonToFileWithComma', () async {
    // act
    await testee.writeLog(simpleLogFile);

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals('${simpleLogFile.toJsonString()},'));
  });

  test('writeLog_whenCalledTwiceWithSimpleFile_shouldAppendToPrevious', () async {
    // act
    await testee.writeLog(simpleLogFile);
    await testee.writeLog(simpleLogFile);

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals('${simpleLogFile.toJsonString()},${simpleLogFile.toJsonString()},'));
  });

  test('writeLog_whenSingleLargeLogEntry_shouldWriteSingleFile', () async {
    // act
    await testee.writeLog(fourKiloBytesLog);

    // assert
    expect(logDir.listSync().length, equals(1));

    final cacheFile = _currentCacheFile(logDir);
    expect(await cacheFile.exists(), isTrue);

    final content = cacheFile.readAsStringSync();
    expect(content, equals('${fourKiloBytesLog.toJsonString()},'));
  });

  test('writeLog_whenLogSizeTooLarge_shouldWriteToNewFileAndHaveCompletedLog', () async {
    // act
    await testee.writeLog(fourKiloBytesLog);
    await testee.writeLog(fourKiloBytesLog);

    expect(logDir.listSync().length, equals(2));
  });

  test('hasCompletedLogFiles_whenNoWrite_shouldBeFalse', () async {
    // act + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenSingleSimpleLogEntryWritten_shouldBeFalse', () async {
    // arrange
    await testee.writeLog(simpleLogFile);

    // act + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenSimpleAndLargeLogEntryWritten_shouldBeFalse', () async {
    // arrange
    await testee.writeLog(simpleLogFile);
    await testee.writeLog(fourKiloBytesLog);

    // act + expect
    expect(await testee.hasCompletedLogFiles, false);
  });

  test('hasCompletedLogFiles_whenTwoLargeLogEntryWritten_shouldBeTrue', () async {
    // arrange
    await testee.writeLog(fourKiloBytesLog);
    await testee.writeLog(fourKiloBytesLog);

    // act + expect
    expect(await testee.hasCompletedLogFiles, true);
  });

  test('completedLogFiles_whenNoneWritten_shouldBeEmpty', () async {
    // act + expect
    expect((await testee.completedLogFiles).isEmpty, true);
  });

  test('completedLogFiles_whenSimpleLogWritten_shouldBeEmpty', () async {
    // arrange
    await testee.writeLog(simpleLogFile);

    // act + expect
    expect((await testee.completedLogFiles).isEmpty, true);
  });

  test('completedLogFiles_whenTwoLargeLogWritten_shouldHaveLengthOne', () async {
    // arrange
    await testee.writeLog(fourKiloBytesLog);
    await testee.writeLog(fourKiloBytesLog);

    // act + expect
    expect((await testee.completedLogFiles).length, 1);
  });

  test('completedLogFiles_whenTwoLargeLogWritten_shouldHaveContentFromLargeLogEntry', () async {
    // arrange
    await testee.writeLog(fourKiloBytesLog);
    await testee.writeLog(fourKiloBytesLog);

    // act
    final actual = await testee.completedLogFiles;

    // expect
    final actualLogEntry = actual.first.logEntries.first;
    expect(actualLogEntry.toJsonString(), fourKiloBytesLog.toJsonString());
  });

  test('deleteLogFile_whenFileGiven_shouldDeleteIt', () async {
    // arrange
    await testee.writeLog(fourKiloBytesLog);
    await testee.writeLog(fourKiloBytesLog);
    // check whether two files exist (one completed)
    expect(logDir.listSync().length, equals(2));

    final files = await testee.completedLogFiles;
    final file = files.first;

    // act
    await testee.deleteLogFile(file);

    // expect
    expect(logDir.listSync().length, equals(1));
  });
}

File _currentCacheFile(Directory logDir) {
  final currentFilePath = p.join(logDir.path, 'das-log-lastSavedFile.json');
  final cacheFile = File(currentFilePath);
  return cacheFile;
}
