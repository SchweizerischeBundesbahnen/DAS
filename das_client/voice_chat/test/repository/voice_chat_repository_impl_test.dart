import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:voice_chat/component.dart';
import 'package:voice_chat/src/mic_permission/permission_service.dart';
import 'package:voice_chat/src/repository/voice_chat_repository_impl.dart';
import 'package:voice_chat/src/token/token_provider.dart';

import 'voice_chat_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PermissionService>(),
  MockSpec<UserIdProviderVoiceChat>(),
  MockSpec<TokenProvider>(),
])
void main() {
  const roomKey = VoiceRoomKey('das-123-2026-11-02');
  late MockPermissionService permissionService;
  late MockUserIdProviderVoiceChat userIdProvider;
  late MockTokenProvider tokenProvider;
  late VoiceChatRepositoryImpl testee;
  late List<VoiceSession> sessions;

  setUp(() {
    permissionService = MockPermissionService();
    userIdProvider = MockUserIdProviderVoiceChat();
    tokenProvider = MockTokenProvider();
    when(permissionService.microphoneStatus()).thenAnswer((_) async => MicPermission.granted);
    when(userIdProvider.call()).thenAnswer((_) async => 'driver-123');
    testee = VoiceChatRepositoryImpl(
      userIdProvider: userIdProvider,
      liveKitUrl: 'wss://example.invalid',
      tokenProvider: tokenProvider,
      permissionService: permissionService,
    );
    sessions = [];
    final subscription = testee.session.listen(sessions.add);
    addTearDown(subscription.cancel);
  });

  tearDown(() {
    testee.dispose();
  });

  for (final permission in [MicPermission.denied, MicPermission.permanentlyDenied]) {
    test('connect_whenPermissionIs${permission.name}_thenFailsBeforeRequestingToken', () async {
      // GIVEN
      when(permissionService.microphoneStatus()).thenAnswer((_) async => permission);

      // WHEN
      await testee.connect(roomKey);

      // THEN
      expect(testee.current.roomKey, roomKey);
      expect(testee.current.permission, permission);
      expect(testee.current.connection, VoiceConnectionState.failed);
      expect(testee.current.error, VoiceError.permissionDenied);
      verify(permissionService.microphoneStatus()).called(1);
      verifyZeroInteractions(userIdProvider);
      verifyZeroInteractions(tokenProvider);
    });
  }

  test('connect_whenUrlIsEmpty_thenIsDisabledAndDoesNotRequestToken', () async {
    // GIVEN
    testee.dispose();
    testee = VoiceChatRepositoryImpl(
      userIdProvider: userIdProvider,
      liveKitUrl: '',
      tokenProvider: tokenProvider,
      permissionService: permissionService,
    );

    // WHEN
    await testee.connect(roomKey);

    // THEN
    expect(testee.isEnabled, isFalse);
    expect(testee.current.connection, VoiceConnectionState.disconnected);
    expect(testee.current.error, isNull);
    verifyZeroInteractions(tokenProvider);
  });

  test('connect_whenTokenRequestFails_thenEmitsConnectingAndFailedWithCorrectIdentity', () async {
    // GIVEN
    when(tokenProvider.getToken(roomKey, 'driver-123')).thenThrow(StateError('Token request failed'));

    // WHEN
    await testee.connect(roomKey);

    // THEN
    verify(tokenProvider.getToken(roomKey, 'driver-123')).called(1);
    expect(sessions.first.connection, VoiceConnectionState.connecting);
    expect(testee.current.connection, VoiceConnectionState.failed);
    expect(testee.current.error, VoiceError.unknown);
  });

  test('init_whenPermissionIsGranted_thenStoresAndPublishesPermission', () async {
    // GIVEN
    when(permissionService.microphoneStatus()).thenAnswer((_) async => MicPermission.granted);
    final nextSession = testee.session.first;

    // WHEN
    await testee.init();

    // THEN
    expect(testee.current.permission, MicPermission.granted);
    expect((await nextSession).permission, MicPermission.granted);
    verify(permissionService.microphoneStatus()).called(1);
  });

  test('refreshMicrophonePermission_whenGrantedAfterDenial_thenClearsPermissionError', () async {
    // GIVEN
    when(permissionService.microphoneStatus()).thenAnswer((_) async => MicPermission.denied);
    await testee.connect(roomKey);
    expect(testee.current.error, VoiceError.permissionDenied);
    when(permissionService.microphoneStatus()).thenAnswer((_) async => MicPermission.granted);
    final nextSession = testee.session.first;

    // WHEN
    await testee.refreshMicrophonePermission();

    // THEN
    expect(testee.current.permission, MicPermission.granted);
    expect(testee.current.error, isNull);
    expect((await nextSession).error, isNull);
    verifyNever(permissionService.requestMicrophone());
  });

  test('refreshMicrophonePermission_whenUnchanged_thenDoesNotEmitAgain', () async {
    // GIVEN
    final firstSession = testee.session.first;
    await testee.refreshMicrophonePermission();
    await firstSession;
    final previousCount = sessions.length;

    // WHEN
    await testee.refreshMicrophonePermission();

    // THEN
    expect(sessions, hasLength(previousCount));
    verify(permissionService.microphoneStatus()).called(2);
  });

  test('setMuted_whenToggled_thenStoresAndPublishesMuteState', () async {
    // GIVEN
    final mutedSession = testee.session.first;

    // WHEN
    await testee.setMuted(true);

    // THEN
    expect(testee.current.isMuted, isTrue);
    expect((await mutedSession).isMuted, isTrue);

    // WHEN
    final unmutedSession = testee.session.first;
    await testee.setMuted(false);

    // THEN
    expect(testee.current.isMuted, isFalse);
    expect((await unmutedSession).isMuted, isFalse);
  });

  test('disconnect_whenConnectionFailedBeforeRoomCreation_thenClearsRoomAndError', () async {
    // GIVEN
    when(permissionService.microphoneStatus()).thenAnswer((_) async => MicPermission.denied);
    await testee.connect(roomKey);

    // WHEN
    await testee.disconnect();

    // THEN
    expect(testee.current.roomKey, isNull);
    expect(testee.current.connection, VoiceConnectionState.disconnected);
    expect(testee.current.error, isNull);
  });
}
