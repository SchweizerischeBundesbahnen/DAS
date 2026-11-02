import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_chat/component.dart';
import 'package:voice_chat/src/mic_permission/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late PermissionService testee;
  late List<MethodCall> calls;
  late int permissionStatus;

  setUp(() {
    testee = PermissionService();
    calls = [];
    permissionStatus = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'requestPermissions' => {7: permissionStatus},
        'checkPermissionStatus' => permissionStatus,
        _ => throw UnsupportedError(call.method),
      };
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  for (final (status, expected) in [
    (0, MicPermission.denied),
    (1, MicPermission.granted),
    (2, MicPermission.denied),
    (4, MicPermission.permanentlyDenied),
  ]) {
    test('requestMicrophone_whenStatusIs${status}_thenReturns${expected.name}', () async {
      // GIVEN
      permissionStatus = status;

      // WHEN
      final result = await testee.requestMicrophone();

      // THEN
      expect(result, expected);
      expect(calls.single.method, 'requestPermissions');
      expect(calls.single.arguments, [7]);
    });

    test('microphoneStatus_whenStatusIs${status}_thenReturns${expected.name}', () async {
      // GIVEN
      permissionStatus = status;

      // WHEN
      final result = await testee.microphoneStatus();

      // THEN
      expect(result, expected);
      expect(calls.single.method, 'checkPermissionStatus');
      expect(calls.single.arguments, 7);
    });
  }

  test('requestMicrophonePermission_whenNoRepositoryExists_thenRequestsMicrophone', () async {
    // GIVEN
    permissionStatus = 1;

    // WHEN
    await VoiceChatComponent.requestMicrophonePermission();

    // THEN
    expect(calls.single.method, 'requestPermissions');
    expect(calls.single.arguments, [7]);
  });

  test('refreshMicrophonePermission_whenGrantedAtStartup_thenStoresPermissionInSession', () async {
    // GIVEN
    permissionStatus = 1;
    await VoiceChatComponent.requestMicrophonePermission();
    final repository = VoiceChatComponent.createRepository(userIdProvider: _UserIdProvider());
    addTearDown(repository.dispose);
    final session = repository.session.first;

    // WHEN
    await repository.refreshMicrophonePermission();

    // THEN
    expect(repository.current.permission, MicPermission.granted);
    expect((await session).permission, MicPermission.granted);
    expect(calls.map((call) => call.method), ['requestPermissions', 'checkPermissionStatus']);
  });

  test('refreshMicrophonePermission_whenRevokedInSettings_thenUpdatesSession', () async {
    // GIVEN
    permissionStatus = 1;
    final repository = VoiceChatComponent.createRepository(userIdProvider: _UserIdProvider());
    addTearDown(repository.dispose);
    await repository.refreshMicrophonePermission();
    permissionStatus = 4;
    final session = repository.session.first;

    // WHEN
    await repository.refreshMicrophonePermission();

    // THEN
    expect(repository.current.permission, MicPermission.permanentlyDenied);
    expect((await session).permission, MicPermission.permanentlyDenied);
    expect(calls.every((call) => call.method == 'checkPermissionStatus'), isTrue);
  });
}

class _UserIdProvider implements UserIdProviderVoiceChat {
  @override
  Future<String> call() async => 'test-user';
}
