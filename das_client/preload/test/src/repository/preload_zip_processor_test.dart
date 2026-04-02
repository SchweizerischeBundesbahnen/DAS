import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:preload/component.dart';
import 'package:preload/src/repository/preload_zip_processor.dart';
import 'package:sfera/component.dart';

import 'preload_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaLocalRepo>(),
])
void main() {
  late PreloadZipProcessor testee;
  late MockSferaLocalRepo mockSferaLocalRepo;

  late Directory tempDir;

  setUp(() async {
    mockSferaLocalRepo = MockSferaLocalRepo();
    when(mockSferaLocalRepo.saveData(any)).thenAnswer((_) => Future.value(true));

    testee = PreloadZipProcessor(sferaLocalRepo: mockSferaLocalRepo);

    tempDir = await Directory.systemTemp.createTemp('preload_zip_processor_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('extractToLocalDatabase_whenEmptyZip_returnsDownloadedWithoutSaves', () async {
    // GIVEN
    final zip = await _makeZip(const [], saveTo: tempDir);

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.downloaded);
    verifyNever(mockSferaLocalRepo.saveData(captureAny));
  });

  test('extractToLocalDatabase_whenZipWithFiles_returnsDownloadedWithSaves', () async {
    // GIVEN
    final zip = await _makeZip(
      [
        _testJP,
        _testSP,
        _testTC,
      ],
      saveTo: tempDir,
    );

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.downloaded);
    final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
    expect(capturesSave, hasLength(1));
    final savedElements = capturesSave[0];
    expect(savedElements, hasLength(3));
    expect(savedElements[0].type, 'JourneyProfile');
    expect(savedElements[1].type, 'SegmentProfile');
    expect(savedElements[2].type, 'TrainCharacteristics');
  });

  test(
    'extractToLocalDatabase_whenMultipleZipsWithDuplicatedFiles_ignoresDuplicatedAndReturnsDownloadedWithSaves',
    () async {
      // GIVEN
      final zip1 = await _makeZip(
        [
          _testJP,
          _testSP,
          _testSP,
        ],
        fileName: 'test1.zip',
        saveTo: tempDir,
      );

      final zip2 = await _makeZip(
        [
          _testJP,
          _testSP,
          _testSP,
          _testTC, // only file that should be processed
        ],
        fileName: 'test2.zip',
        saveTo: tempDir,
      );

      // WHEN
      final status1 = await testee.extractToLocalDatabase(zip1);
      final status2 = await testee.extractToLocalDatabase(zip2);

      // THEN
      expect(status1, S3FileSyncStatus.downloaded);
      expect(status2, S3FileSyncStatus.downloaded);
      final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
      expect(capturesSave, hasLength(2));
      final savedElements1 = capturesSave[0];
      expect(savedElements1, hasLength(3));
      expect(savedElements1[0].type, 'JourneyProfile');
      expect(savedElements1[1].type, 'SegmentProfile');
      expect(savedElements1[2].type, 'SegmentProfile');
      final savedElements2 = capturesSave[1];
      expect(savedElements2, hasLength(1));
      expect(savedElements2[0].type, 'TrainCharacteristics');
    },
  );

  test('extractToLocalDatabase_whenZipWithFilesAndDirectory_ignoresDirectory', () async {
    // GIVEN
    final zip = await _makeZip(
      [_testSP],
      includeDirectoryEntry: true,
      saveTo: tempDir,
    );

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.downloaded);
    final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
    expect(capturesSave, hasLength(1));
    final savedElements = capturesSave[0];
    expect(savedElements, hasLength(1));
    expect(savedElements[0].type, 'SegmentProfile');
  });

  test('extractToLocalDatabase_whenZipWithInvalidFiles_returnsCorrupted', () async {
    // GIVEN
    final zip = await _makeZip(
      [_testSP, '<invalid'],
      includeDirectoryEntry: true,
      saveTo: tempDir,
    );

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.corrupted);
    verifyNever(mockSferaLocalRepo.saveData(captureAny));
  });

  test('extractToLocalDatabase_whenSaveReturnsFalse_returnsCorrupted', () async {
    // GIVEN
    final zip = await _makeZip([_testJP], saveTo: tempDir);
    when(mockSferaLocalRepo.saveData(any)).thenAnswer((_) => Future.value(false));

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.corrupted);
    final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
    expect(capturesSave, hasLength(1));
  });

  test('extractToLocalDatabase_whenErrorIsThrown_returnsError', () async {
    // GIVEN
    final zip = await _makeZip([_testJP], saveTo: tempDir);
    when(mockSferaLocalRepo.saveData(any)).thenThrow(Exception('Test'));

    // WHEN
    final status = await testee.extractToLocalDatabase(zip);

    // THEN
    expect(status, S3FileSyncStatus.error);
    final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
    expect(capturesSave, hasLength(1));
  });
}

const _testJP =
    '<JourneyProfile JP_Version="1" JP_Status="Valid"><TrainIdentification>'
    '<OTN_ID>'
    '<teltsi_Company>1285</teltsi_Company>'
    '<teltsi_OperationalTrainNumber>T35</teltsi_OperationalTrainNumber>'
    '<teltsi_StartDate>2025-11-13</teltsi_StartDate>'
    '</OTN_ID>'
    '</TrainIdentification>'
    '</JourneyProfile>';

const _testSP =
    '<SegmentProfile SP_ID="T35" SP_VersionMajor="1" SP_VersionMinor="4" SP_Length="800" SP_Status="Valid">'
    '</SegmentProfile>';

const _testTC =
    '<TrainCharacteristics TC_ID="T9999_1" TC_VersionMajor="1" TC_VersionMinor="1">'
    '<TC_RU_ID>1085</TC_RU_ID>'
    '<TC_Features trainCategoryCode="R" brakedWeightPercentage="150"/>'
    '</TrainCharacteristics>';

Future<File> _makeZip(
  List<String> fileContents, {
  required Directory saveTo,
  bool includeDirectoryEntry = false,
  String fileName = 'test.zip',
}) async {
  final archive = Archive();

  if (includeDirectoryEntry) {
    final dirEntry = ArchiveFile('folder/', 0, Uint8List(0))..isFile = false;
    archive.addFile(dirEntry);
  }

  for (var i = 0; i < fileContents.length; i++) {
    final bytes = utf8.encode(fileContents[i]);
    archive.addFile(ArchiveFile('test_file_$i.xml', bytes.length, bytes));
  }

  final zipFile = File(p.join(saveTo.path, fileName));
  await zipFile.writeAsBytes(ZipEncoder().encode(archive), flush: true);
  return zipFile;
}
