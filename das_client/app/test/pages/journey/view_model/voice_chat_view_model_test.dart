import 'dart:async';

import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/voice_chat_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';
import 'package:voice_chat/component.dart';

import 'voice_chat_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>(), MockSpec<VoiceChatRepository>()])
void main() {
  late MockJourneyViewModel journeyViewModel;
  late MockVoiceChatRepository repository;
  late StreamController<Journey?> journeys;
  late VoiceChatViewModel testee;

  setUp(() {
    journeyViewModel = MockJourneyViewModel();
    repository = MockVoiceChatRepository();
    journeys = StreamController<Journey?>.broadcast(sync: true);
    when(journeyViewModel.journey).thenAnswer((_) => journeys.stream);
    testee = VoiceChatViewModel(repository: repository, journeyViewModel: journeyViewModel);
  });

  tearDown(() async {
    await testee.close();
    await journeys.close();
  });

  test('onJourneyChanged_whenTrainChanges_thenConnectsToRoomForTrainAndDate', () async {
    // GIVEN
    final journey = _journey('123', DateTime.utc(2026, 11, 2));

    // WHEN
    journeys.add(journey);
    await Future<void>.delayed(Duration.zero);

    // THEN
    final key = verify(repository.connect(captureAny)).captured.single as VoiceRoomKey;
    expect(key.value, 'das-123-2026-11-02');

    // WHEN
    journeys.add(_journey('123', DateTime.utc(2026, 11, 2)));
    await Future<void>.delayed(Duration.zero);

    // THEN
    verifyNever(repository.connect(any));
  });

  test('onJourneyChanged_whenJourneyIsCleared_thenDisconnects', () async {
    // GIVEN
    journeys.add(_journey('123', DateTime.utc(2026, 11, 2)));
    await Future<void>.delayed(Duration.zero);

    // WHEN
    journeys.add(null);
    await Future<void>.delayed(Duration.zero);

    // THEN
    verify(repository.disconnect()).called(1);
  });

  test('onJourneyChanged_whenAnotherJourneyArrives_thenConnectsToItsRoom', () async {
    // GIVEN
    journeys.add(_journey('123', DateTime.utc(2026, 11, 2)));
    await Future<void>.delayed(Duration.zero);

    // WHEN
    journeys.add(_journey('456', DateTime.utc(2026, 11, 3)));
    await Future<void>.delayed(Duration.zero);

    // THEN
    final keys = verify(repository.connect(captureAny)).captured.cast<VoiceRoomKey>();
    expect(keys.map((key) => key.value), ['das-123-2026-11-02', 'das-456-2026-11-03']);
  });

  test('onJourneyChanged_whenChangesOverlap_thenConnectsOnlyToLatestAfterCurrentCompletes', () async {
    // GIVEN
    final firstConnection = Completer<void>();
    when(repository.connect(any)).thenAnswer((invocation) {
      final key = invocation.positionalArguments.single as VoiceRoomKey;
      return key.value.startsWith('das-123-') ? firstConnection.future : Future.value();
    });
    journeys.add(_journey('123', DateTime.utc(2026, 11, 2)));
    await Future<void>.delayed(Duration.zero);

    // WHEN
    journeys.add(_journey('456', DateTime.utc(2026, 11, 2)));
    journeys.add(_journey('789', DateTime.utc(2026, 11, 2)));
    firstConnection.complete();
    await Future<void>.delayed(Duration.zero);

    // THEN
    final keys = verify(repository.connect(captureAny)).captured.cast<VoiceRoomKey>();
    expect(keys.map((key) => key.value), ['das-123-2026-11-02', 'das-789-2026-11-02']);
  });

  test('close_whenConnectionIsPending_thenWaitsAndDisconnectsWithoutStartingQueuedRoom', () async {
    // GIVEN
    final connection = Completer<void>();
    when(repository.connect(any)).thenAnswer((_) => connection.future);
    journeys.add(_journey('123', DateTime.utc(2026, 11, 2)));
    await Future<void>.delayed(Duration.zero);
    journeys.add(_journey('456', DateTime.utc(2026, 11, 2)));

    // WHEN
    final close = testee.close();
    verifyNever(repository.disconnect());
    connection.complete();
    await close;

    // THEN
    final keys = verify(repository.connect(captureAny)).captured.cast<VoiceRoomKey>();
    expect(keys.map((key) => key.value), ['das-123-2026-11-02']);
    verify(repository.disconnect()).called(1);
  });
}

Journey _journey(String trainNumber, DateTime date) => Journey(
  metadata: Metadata(
    trainIdentification: TrainIdentification(companyCode: '1285', trainNumber: trainNumber, date: date),
  ),
  data: const [],
);
