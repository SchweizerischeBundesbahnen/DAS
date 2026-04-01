import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:preload/component.dart';
import 'package:preload/src/aws/dto/contents_dto.dart';
import 'package:preload/src/aws/dto/list_bucket_result_dto.dart';
import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/repository/preload_repository_impl.dart';
import 'package:preload/src/repository/preload_zip_processor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import 'preload_repository_impl_test.mocks.dart';
import 's3_client_overridden_preload_repository.dart';

@GenerateNiceMocks([
  MockSpec<PreloadZipProcessor>(),
  MockSpec<PreloadLocalDatabaseService>(),
  MockSpec<S3Client>(),
  MockSpec<SferaLocalRepo>(),
  MockSpec<ListBucketResultDto>(),
  MockSpec<ContentsDto>(),
])
void main() {
  late PreloadRepository testee;
  late MockPreloadZipProcessor mockPreloadZipProcessor;
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
    mockPreloadZipProcessor = MockPreloadZipProcessor();
    preloadDetailsRegister = [];
    databaseSubject = BehaviorSubject.seeded([]);
    when(mockDatabaseService.watchAll()).thenAnswer((_) => databaseSubject.stream);
    when(mockPreloadZipProcessor.processZip(any)).thenAnswer((_) => Future.value(.downloaded));
    when(mockPreloadZipProcessor.preloadFolder()).thenAnswer((_) => Future.value(Directory('test')));

    testee = S3ClientOverriddenPreloadRepository(
      preloadZipProcessor: mockPreloadZipProcessor,
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
      // WHEN
      testAsync = fakeAsync;
      mockPreloadZipProcessor = MockPreloadZipProcessor();
      testee = S3ClientOverriddenPreloadRepository(
        preloadZipProcessor: mockPreloadZipProcessor,
        databaseService: mockDatabaseService,
        sferaLocalRepo: mockSferaLocalRepo,
        s3Client: mockS3Client,
      );
      preloadDetailsSubscription.cancel();
      preloadDetailsSubscription = testee.preloadDetails.listen(preloadDetailsRegister.add);
      when(mockPreloadZipProcessor.processZip(any)).thenAnswer((_) => Future.value(.downloaded));
      when(mockPreloadZipProcessor.cleanup()).thenAnswer((_) => Future.value());
      when(mockPreloadZipProcessor.preloadFolder()).thenAnswer((_) => Future.value(Directory('Test')));

      // ACT
      fakeAsync.elapse(const Duration(seconds: 1));
      testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
      fakeAsync.elapse(const Duration(seconds: 1));
      testAsync.flushMicrotasks();

      // VERIFY
      expect(preloadDetailsRegister, hasLength(3));
      expect(preloadDetailsRegister[0].status, PreloadStatus.missingConfiguration);
      expect(preloadDetailsRegister[1].status, PreloadStatus.running);
      expect(preloadDetailsRegister[2].status, PreloadStatus.idle);

      testAsync.elapse(Duration(minutes: PreloadRepositoryImpl.syncInterval.inMinutes + 1));
      testAsync.flushMicrotasks();

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
        S3File(name: '2026-02-10T16-35-35Z.zip', eTag: 'etag', size: 100, status: .downloaded),
        S3File(name: '2026-02-10T16-35-34Z.zip', eTag: 'etag2', size: 125, status: .downloaded),
        S3File(name: '2026-02-10T15-35-34Z.zip', eTag: 'old', size: 125, status: .downloaded),
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

  test('preload_whenTriggered_callsCleanup', () async {
    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    verify(mockSferaLocalRepo.cleanup()).called(1);
    verify(mockPreloadZipProcessor.cleanup()).called(1);
  });

  test('preload_whenTriggered_loadS3FilesProcessAndUpdateStatus', () async {
    // WHEN
    when(mockDatabaseService.findAll()).thenAnswer(
      (_) => Future.value([
        S3File(name: '2026-02-10T17-35-35Z.zip', eTag: 'initial', size: 100, status: .initial),
        S3File(name: '2026-02-10T16-35-35Z.zip', eTag: 'initial', size: 100, status: .initial),
        S3File(name: '2026-02-10T15-35-35Z.zip', eTag: 'downloaded', size: 110, status: .downloaded),
        S3File(name: '2026-02-10T14-35-35Z.zip', eTag: 'error', size: 120, status: .error),
        S3File(name: '2026-02-10T13-35-35Z.zip', eTag: 'corrupted', size: 120, status: .corrupted),
      ]),
    );

    final zip1 = File('test1.zip');
    final zip2 = File('test2.zip');
    when(
      mockS3Client.downloadFile('2026-02-10T17-35-35Z.zip', saveTo: anyNamed('saveTo')),
    ).thenThrow(Exception('Failed'));
    when(
      mockS3Client.downloadFile('2026-02-10T16-35-35Z.zip', saveTo: anyNamed('saveTo')),
    ).thenAnswer((_) {
      return Future.value(zip1);
    });
    when(
      mockS3Client.downloadFile('2026-02-10T14-35-35Z.zip', saveTo: anyNamed('saveTo')),
    ).thenAnswer((_) {
      return Future.value(zip2);
    });

    when(mockPreloadZipProcessor.processZip(zip1)).thenAnswer((_) => Future.value(.corrupted));
    when(mockPreloadZipProcessor.processZip(zip2)).thenAnswer((_) => Future.value(.downloaded));

    // ACT
    await Future.delayed(const Duration(milliseconds: 1));
    testee.updateConfiguration(AwsConfiguration(bucketUrl: 'https://www.dummy.ch', accessKey: '', accessSecret: ''));
    await Future.delayed(const Duration(milliseconds: 1));

    // VERIFY
    final captured = verify(mockS3Client.downloadFile(captureAny, saveTo: anyNamed('saveTo'))).captured;
    expect(captured, hasLength(3));
    expect(captured[0], '2026-02-10T17-35-35Z.zip');
    expect(captured[1], '2026-02-10T16-35-35Z.zip');
    expect(captured[2], '2026-02-10T14-35-35Z.zip');

    final capturesZip = verify(mockPreloadZipProcessor.processZip(captureAny)).captured;
    expect(capturesZip, hasLength(2));
    expect(capturesZip[0], zip1);
    expect(capturesZip[1], zip2);

    final capturedDb = verify(mockDatabaseService.saveS3File(captureAny)).captured;
    expect(capturedDb, hasLength(3));
    expect((capturedDb[0] as S3File).name, '2026-02-10T17-35-35Z.zip');
    expect((capturedDb[0] as S3File).status, S3FileSyncStatus.error);
    expect((capturedDb[1] as S3File).name, '2026-02-10T16-35-35Z.zip');
    expect((capturedDb[1] as S3File).status, S3FileSyncStatus.corrupted);
    expect((capturedDb[2] as S3File).name, '2026-02-10T14-35-35Z.zip');
    expect((capturedDb[2] as S3File).status, S3FileSyncStatus.downloaded);
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
