import 'package:app/di/scopes/authenticated_scope.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/voice_chat_view_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';
import 'package:voice_chat/component.dart';

import '../../integration_test/mocks/mock_voice_chat_repository.dart';
import '../nav/app_link_navigator_test.mocks.dart' as navigation;
import '../pages/journey/selection/journey_selection_view_model_test.mocks.dart' as selection;
import '../pages/journey/view_model/voice_chat_view_model_test.mocks.dart' as voice;

void main() {
  tearDown(() async {
    await GetIt.I.reset();
  });

  test('registerJourneySelectionViewModel_whenDependenciesAreReady_thenBecomesReady', () async {
    // GIVEN
    final getIt = GetIt.I;
    getIt.registerSingletonAsync<SferaRepository>(() async => selection.MockSferaRepository());
    getIt.registerSingletonAsync<JourneyNavigationViewModel>(
      () async => navigation.MockJourneyNavigationViewModel(),
    );
    getIt.registerSingleton<SettingsRepository>(selection.MockSettingsRepository());
    getIt.registerSingleton<TrainIdentificationRepository>(selection.MockTrainIdentificationRepository());
    getIt.registerSingleton<LocalKeyValueStore>(selection.MockLocalKeyValueStore());

    // WHEN
    getIt.registerJourneySelectionViewModel();
    await getIt.allReady();

    // THEN
    expect(getIt<JourneySelectionViewModel>(), isA<JourneySelectionViewModel>());
  });

  test('registerVoiceChatViewModel_whenDependenciesAreAsync_thenBecomesReady', () async {
    // GIVEN
    final getIt = GetIt.I;
    final journey = voice.MockJourneyViewModel();
    getIt.registerSingletonAsync<JourneyViewModel>(() async => journey);
    getIt.registerSingletonAsync<VoiceChatRepository>(
      () async => MockVoiceChatRepository(),
      dispose: (repo) => repo.dispose(),
    );

    // WHEN
    getIt.registerVoiceChatViewModel();
    await getIt.allReady();

    // THEN
    expect(getIt<VoiceChatViewModel>(), isA<VoiceChatViewModel>());
  });
}
