import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('LoginViewModel');

class LoginViewModel {
  final _rxModel = BehaviorSubject<LoginModel>.seeded(LoggedOut(connectToTmsVad: false));

  LoginModel get modelValue => _rxModel.value;

  Stream<LoginModel> get model => _rxModel.distinct();

  void dispose() {
    _rxModel.add(LoggedOut(connectToTmsVad: false));
    _rxModel.close();
  }

  void setConnectToTmsVad(bool update) {
    if (modelValue.connectToTmsVad == update) return;

    DI.resetToUnauthenticatedScope(useTms: update);
    _rxModel.add(modelValue.copyWith(connectToTmsVad: update));
  }

  Future<void> login() async {
    if (modelValue is! LoggedOut && modelValue is! Error) return;

    _rxModel.add(Loading(connectToTmsVad: modelValue.connectToTmsVad));
    final authenticator = DI.get<Authenticator>();
    try {
      await authenticator.login();
      await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      await DI.get<ScopeHandler>().push<JourneyScope>();
      _rxModel.add(LoggedIn(connectToTmsVad: modelValue.connectToTmsVad));
    } catch (e) {
      _log.severe('Login failed', e);
      _rxModel.add(Error(connectToTmsVad: modelValue.connectToTmsVad, errorMessage: e.toString()));
    }
  }

  void logout() {
    DI.get<Authenticator>().logout();
    DI.resetToUnauthenticatedScope(useTms: modelValue.connectToTmsVad);
    _rxModel.add(LoggedOut(connectToTmsVad: modelValue.connectToTmsVad));
  }
}
