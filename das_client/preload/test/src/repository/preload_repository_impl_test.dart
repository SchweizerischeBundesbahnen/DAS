import 'dart:async';

import 'package:archive/archive.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:preload/component.dart';
import 'package:preload/src/aws/dto/contents_dto.dart';
import 'package:preload/src/aws/dto/list_bucket_result_dto.dart';
import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/model/s3file.dart';
import 'package:preload/src/repository/preload_repository_impl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import 'preload_repository_impl_test.mocks.dart';
import 's3_client_overridden_preload_repository.dart';

@GenerateNiceMocks([
  MockSpec<PreloadLocalDatabaseService>(),
  MockSpec<S3Client>(),
  MockSpec<SferaLocalRepo>(),
  MockSpec<ListBucketResultDto>(),
  MockSpec<ContentsDto>(),
])
void main() {
  late PreloadRepository testee;
  late MockPreloadLocalDatabaseService mockDatabaseService;
  late MockSferaLocalRepo mockSferaLocalRepo;
  late MockS3Client mockS3Client;
  late List<PreloadDetails> preloadDetailsRegister;
  late StreamSubscription preloadDetailsSubscription;
  late BehaviorSubject<List<S3File>> databaseSubject;

  setUp(() {
    mockDatabaseService = MockPreloadLocalDatabaseService();
    mockSferaLocalRepo = MockSferaLocalRepo();
    mockS3Client = MockS3Client();
    preloadDetailsRegister = [];
    databaseSubject = BehaviorSubject.seeded([]);
    when(mockDatabaseService.watchAll()).thenAnswer((_) => databaseSubject.stream);

    testee = S3ClientOverriddenPreloadRepository(
      databaseService: mockDatabaseService,
      sferaLocalRepo: mockSferaLocalRepo,
      s3Client: mockS3Client,
    );
    preloadDetailsSubscription = testee.preloadDetails.listen(preloadDetailsRegister.add);
  });

  tearDown(() {
    preloadDetailsSubscription.cancel();
    preloadDetailsRegister.clear();
    testee.dispose();
  });

  test('preloadDetails_whenInitializedWithoutAwsConfiguration_emitsMissingConfiguration', () async {
    // ACT
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    expect(preloadDetailsRegister, hasLength(1));
    expect(preloadDetailsRegister[0].status, PreloadStatus.missingConfiguration);
  });

  test('preloadDetails_whenAwsConfigurationUpdated_startsAndCompletesPreload', () async {
    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    expect(preloadDetailsRegister, hasLength(3));
    expect(preloadDetailsRegister[0].status, PreloadStatus.missingConfiguration);
    expect(preloadDetailsRegister[1].status, PreloadStatus.running);
    expect(preloadDetailsRegister[2].status, PreloadStatus.idle);
  });

  test('preloadDetails_whenAwsConfigurationUpdated_startsPeriodicTimerForPreload', () async {
    await Future.delayed(const Duration(milliseconds: 1));
    testee.dispose();
    preloadDetailsRegister.clear();
    late FakeAsync testAsync;

    fakeAsync((fakeAsync) {
      testAsync = fakeAsync;
      testee = S3ClientOverriddenPreloadRepository(
        databaseService: mockDatabaseService,
        sferaLocalRepo: mockSferaLocalRepo,
        s3Client: mockS3Client,
      );
      preloadDetailsSubscription.cancel();
      preloadDetailsSubscription = testee.preloadDetails.listen(preloadDetailsRegister.add);
      fakeAsync.elapse(const Duration(seconds: 1));
      testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
      fakeAsync.elapse(const Duration(seconds: 1));

      expect(preloadDetailsRegister, hasLength(3));
      expect(preloadDetailsRegister[0].status, PreloadStatus.missingConfiguration);
      expect(preloadDetailsRegister[1].status, PreloadStatus.running);
      expect(preloadDetailsRegister[2].status, PreloadStatus.idle);

      testAsync.elapse(Duration(minutes: PreloadRepositoryImpl.syncInterval.inMinutes + 1));

      expect(preloadDetailsRegister, hasLength(5));
      expect(preloadDetailsRegister[0].status, PreloadStatus.missingConfiguration);
      expect(preloadDetailsRegister[1].status, PreloadStatus.running);
      expect(preloadDetailsRegister[2].status, PreloadStatus.idle);
      expect(preloadDetailsRegister[3].status, PreloadStatus.running);
      expect(preloadDetailsRegister[4].status, PreloadStatus.idle);
    });
  });

  test('preload_whenTriggered_loadsBucketContentAndUpdatesDb', () async {
    // WHEN
    when(mockS3Client.listBucket()).thenAnswer(
      (_) => Future.value(
        _createMockListBucketResultDto([
          _createMockContentsDto(name: '2026-02-10T16-35-36Z.zip', etag: 'etag', size: 100),
          _createMockContentsDto(name: '2026-02-10T16-35-35Z.zip', etag: 'etag', size: 100),
          _createMockContentsDto(name: '2026-02-10T16-35-34Z.zip', etag: 'etag', size: 100),
        ]),
      ),
    );
    when(mockDatabaseService.findAll()).thenAnswer(
      (_) => Future.value([
        S3File(name: '2026-02-10T16-35-35Z.zip', eTag: 'etag', size: 100, status: S3FileSyncStatus.downloaded),
        S3File(name: '2026-02-10T16-35-34Z.zip', eTag: 'etag2', size: 125, status: S3FileSyncStatus.downloaded),
        S3File(name: '2026-02-10T15-35-34Z.zip', eTag: 'old', size: 125, status: S3FileSyncStatus.downloaded),
      ]),
    );

    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    verify(mockS3Client.listBucket()).called(1);
    final captured = verify(mockDatabaseService.saveS3File(captureAny)).captured;
    expect(captured, hasLength(2));
    expect((captured[0] as S3File).status, S3FileSyncStatus.initial);
    expect((captured[0] as S3File).name, '2026-02-10T16-35-36Z.zip');
    expect((captured[1] as S3File).status, S3FileSyncStatus.initial);
    expect((captured[1] as S3File).name, '2026-02-10T16-35-34Z.zip');
    verify(mockDatabaseService.deleteS3File(any)).called(1);
  });

  test('preload_whenTriggered_callsSferaLocalRepoCleanup', () async {
    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    verify(mockSferaLocalRepo.cleanup()).called(1);
  });

  test('preload_whenTriggered_loadS3FilesProcessAndUpdateStatus', () async {
    // WHEN
    when(mockDatabaseService.findAll()).thenAnswer(
      (_) => Future.value([
        S3File(name: '2026-02-10T17-35-35Z.zip', eTag: 'inital', size: 100, status: S3FileSyncStatus.initial),
        S3File(name: '2026-02-10T16-35-35Z.zip', eTag: 'inital', size: 100, status: S3FileSyncStatus.initial),
        S3File(name: '2026-02-10T15-35-35Z.zip', eTag: 'downloaded', size: 110, status: S3FileSyncStatus.downloaded),
        S3File(name: '2026-02-10T14-35-35Z.zip', eTag: 'error', size: 120, status: S3FileSyncStatus.error),
        S3File(name: '2026-02-10T13-35-35Z.zip', eTag: 'corruped', size: 120, status: S3FileSyncStatus.corrupted),
      ]),
    );

    final zip1 = _createZipBytes({'jp_valid.xml': 'valid'});
    final zip2 = _createZipBytes({'jp_invalid.xml': 'invalid'});

    when(mockS3Client.getObject('2026-02-10T17-35-35Z.zip')).thenAnswer((_) => Future.value(null));
    when(mockS3Client.getObject('2026-02-10T16-35-35Z.zip')).thenAnswer((_) => Future.value(zip1));
    when(mockS3Client.getObject('2026-02-10T14-35-35Z.zip')).thenAnswer((_) => Future.value(zip2));

    when(mockSferaLocalRepo.saveData('valid')).thenAnswer((_) => Future.value(true));
    when(mockSferaLocalRepo.saveData('invalid')).thenAnswer((_) => Future.value(false));

    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    final captured = verify(mockS3Client.getObject(captureAny)).captured;
    expect(captured, hasLength(3));
    expect(captured[0], '2026-02-10T17-35-35Z.zip');
    expect(captured[1], '2026-02-10T16-35-35Z.zip');
    expect(captured[2], '2026-02-10T14-35-35Z.zip');

    final capturesSave = verify(mockSferaLocalRepo.saveData(captureAny)).captured;
    expect(capturesSave, hasLength(2));
    expect(capturesSave[0], 'valid');
    expect(capturesSave[1], 'invalid');

    final capturedDb = verify(mockDatabaseService.saveS3File(captureAny)).captured;
    expect(capturedDb, hasLength(3));
    expect((capturedDb[0] as S3File).name, '2026-02-10T17-35-35Z.zip');
    expect((capturedDb[0] as S3File).status, S3FileSyncStatus.error);
    expect((capturedDb[1] as S3File).name, '2026-02-10T16-35-35Z.zip');
    expect((capturedDb[1] as S3File).status, S3FileSyncStatus.downloaded);
    expect((capturedDb[2] as S3File).name, '2026-02-10T14-35-35Z.zip');
    expect((capturedDb[2] as S3File).status, S3FileSyncStatus.corrupted);
  });
}

MockContentsDto _createMockContentsDto({required String name, required String etag, required int size}) {
  final mock = MockContentsDto();
  when(mock.key).thenReturn(name);
  when(mock.size).thenReturn(size);
  when(mock.eTag).thenReturn(etag);
  return mock;
}

MockListBucketResultDto _createMockListBucketResultDto(List<ContentsDto> contents) {
  final mock = MockListBucketResultDto();
  when(mock.contents).thenReturn(contents);
  return mock;
}

List<int> _createZipBytes(Map<String, String> fileNameToContent) {
  final archive = Archive();
  fileNameToContent.forEach((fileName, content) {
    archive.add(ArchiveFile.string(fileName, content));
  });
  final zipEncoder = ZipEncoder();
  return zipEncoder.encode(archive);
}
