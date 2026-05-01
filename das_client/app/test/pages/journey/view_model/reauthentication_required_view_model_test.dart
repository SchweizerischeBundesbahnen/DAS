import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/reauthentication_required_view_model.dart';
import 'package:auth/component.dart';
import 'package:connectivity_x/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'reauthentication_required_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Authenticator>(),
  MockSpec<NotificationPriorityQueueViewModel>(),
  MockSpec<ConnectivityManager>(),
])
void main() {
  group('ReauthenticationRequiredViewModel', () {
    late ReauthenticationRequiredViewModel testee;
    late MockAuthenticator authenticator;
    late MockNotificationPriorityQueueViewModel notificationViewModel;
    late MockConnectivityManager connectivityManager;
    late BehaviorSubject<bool> authenticationRequiredSubject;
    late BehaviorSubject<bool> connectivityManagerSubject;

    setUp(() {
      authenticator = MockAuthenticator();
      authenticationRequiredSubject = BehaviorSubject.seeded(false);
      connectivityManagerSubject = BehaviorSubject.seeded(false);
      when(authenticator.reauthenticationRequired).thenAnswer((_) => authenticationRequiredSubject.stream);
      notificationViewModel = MockNotificationPriorityQueueViewModel();
      connectivityManager = MockConnectivityManager();
      when(connectivityManager.onConnectivityChanged).thenAnswer((_) => connectivityManagerSubject.stream);
      testee = ReauthenticationRequiredViewModel(
        authenticator: authenticator,
        notificationViewModel: notificationViewModel,
        connectivityManager: connectivityManager,
      );
    });

    tearDown(() {
      testee.dispose();
    });

    test('model_whenReauthenticationNotRequiredAndConnected_thenDoesNotShowNotification', () async {
      // ACT
      connectivityManagerSubject.add(true);
      await Future.delayed(Duration.zero);

      // EXPECT
      verifyNever(notificationViewModel.insert(type: .reauthenticationRequired));
    });

    test('model_whenReauthenticationRequiredAndNotConnected_thenDoesNotShowNotification', () async {
      // ACT
      authenticationRequiredSubject.add(true);
      await Future.delayed(Duration.zero);

      // EXPECT
      verifyNever(notificationViewModel.insert(type: .reauthenticationRequired));
    });

    test('model_whenReauthenticationRequiredAndConnected_thenShowNotification', () async {
      // ACT
      authenticationRequiredSubject.add(true);
      connectivityManagerSubject.add(true);
      await Future.delayed(Duration.zero);

      // EXPECT
      verify(notificationViewModel.insert(type: .reauthenticationRequired)).called(1);
    });

    test('model_whenReauthenticationRequiredAndNoLongerConnected_thenRemoveNotification', () async {
      // ACT
      authenticationRequiredSubject.add(true);
      connectivityManagerSubject.add(true);
      await Future.delayed(Duration.zero);

      when(notificationViewModel.contains(type: .reauthenticationRequired)).thenReturn(true);

      connectivityManagerSubject.add(false);
      await Future.delayed(Duration.zero);

      // EXPECT
      verify(notificationViewModel.insert(type: .reauthenticationRequired)).called(1);
      verify(notificationViewModel.remove(type: .reauthenticationRequired)).called(1);
    });
  });
}
