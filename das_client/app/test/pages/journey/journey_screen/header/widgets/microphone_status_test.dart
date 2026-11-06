import 'dart:async';

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/microphone_status.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exclamation_icon_button.dart';
import 'package:app/widgets/microphone_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:voice_chat/component.dart';

import 'microphone_status_test.mocks.dart';

@GenerateNiceMocks([MockSpec<VoiceChatRepository>()])
void main() {
  late MockVoiceChatRepository repository;
  late StreamController<VoiceSession> sessions;

  setUp(() {
    repository = MockVoiceChatRepository();
    sessions = StreamController<VoiceSession>.broadcast();
    when(repository.isEnabled).thenReturn(true);
    when(repository.current).thenReturn(const VoiceSession(permission: MicPermission.granted));
    when(repository.session).thenAnswer((_) => sessions.stream);
    GetIt.I.registerSingleton<VoiceChatRepository>(repository);
  });

  tearDown(() async {
    await sessions.close();
    await GetIt.I.reset();
  });

  Future<void> pumpMicrophone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: SBBTheme.light(),
        localizationsDelegates: localizationDelegates,
        supportedLocales: supportedLocales,
        locale: const Locale('de', 'CH'),
        home: const Scaffold(body: Center(child: MicrophoneStatus())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('onTap_whenSessionChangesMuteState_thenUpdatesIconAndTogglesMute', (tester) async {
    // GIVEN
    await pumpMicrophone(tester);
    expect(tester.widget<MicrophoneIconButton>(find.byType(MicrophoneIconButton)).icon, AppAssets.iconMicNormal);

    // WHEN
    await tester.tap(find.byKey(MicrophoneStatus.iconKey));

    // THEN
    verify(repository.setMuted(true)).called(1);

    // WHEN
    sessions.add(const VoiceSession(permission: MicPermission.granted, isMuted: true));
    await tester.pumpAndSettle();

    // THEN
    expect(tester.widget<MicrophoneIconButton>(find.byType(MicrophoneIconButton)).icon, AppAssets.iconMicMuted);

    // WHEN
    await tester.tap(find.byKey(MicrophoneStatus.iconKey));

    // THEN
    verify(repository.setMuted(false)).called(1);
    expect(find.byType(ExclamationIconButton), findsNothing);
  });

  testWidgets('build_whenPermissionIsUnknown_thenShowsNormalButtonWithoutWarning', (tester) async {
    // GIVEN
    when(repository.current).thenReturn(const VoiceSession.initial());

    // WHEN
    await pumpMicrophone(tester);

    // THEN
    expect(tester.widget<MicrophoneIconButton>(find.byType(MicrophoneIconButton)).icon, AppAssets.iconMicNormal);
    expect(find.byType(ExclamationIconButton), findsNothing);
  });

  for (final permission in [MicPermission.denied, MicPermission.permanentlyDenied]) {
    testWidgets('onTap_whenPermissionIs${permission.name}_thenShowsPermissionHelpInsteadOfMuting', (tester) async {
      // GIVEN
      when(repository.current).thenReturn(
        VoiceSession(permission: permission, isMuted: true, error: VoiceError.serverUnreachable),
      );
      await pumpMicrophone(tester);
      final l10n = AppLocalizations.of(tester.element(find.byType(MicrophoneStatus)))!;

      // WHEN
      await tester.tap(find.byKey(MicrophoneStatus.iconKey));
      await tester.pumpAndSettle();

      // THEN
      expect(tester.widget<ExclamationIconButton>(find.byType(ExclamationIconButton)).icon, AppAssets.iconMicAlert);
      expect(find.text(l10n.w_microphone_status_title), findsOneWidget);
      expect(find.text(l10n.w_microphone_status_text), findsOneWidget);
      verifyNever(repository.setMuted(any));
    });
  }

  for (final error in VoiceError.values) {
    testWidgets('onTap_whenErrorIs${error.name}_thenShowsMatchingErrorMessage', (tester) async {
      // GIVEN
      when(repository.current).thenReturn(VoiceSession(permission: MicPermission.granted, error: error));
      await pumpMicrophone(tester);
      final l10n = AppLocalizations.of(tester.element(find.byType(MicrophoneStatus)))!;
      final expectedText = switch (error) {
        VoiceError.permissionDenied => l10n.w_microphone_status_text,
        VoiceError.serverUnreachable => l10n.w_microphone_status_error_server_unreachable,
        VoiceError.tokenInvalid => l10n.w_microphone_status_error_token_invalid,
        VoiceError.duplicateIdentity => l10n.w_microphone_status_error_duplicate_identity,
        VoiceError.unknown => l10n.w_microphone_status_error_unknown,
      };

      // WHEN
      await tester.tap(find.byKey(MicrophoneStatus.iconKey));
      await tester.pumpAndSettle();

      // THEN
      expect(find.text(expectedText), findsOneWidget);
      verifyNever(repository.setMuted(any));
    });
  }
}
