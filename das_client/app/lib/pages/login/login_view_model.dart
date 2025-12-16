import 'package:app/pages/login/login_model.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('LoginViewModel');

class LoginViewModel {
  LoginViewModel({required Authenticator authenticator}) : _authenticator = authenticator;

  final Authenticator _authenticator;

  final _rxModel = BehaviorSubject<LoginModel>.seeded(LoginModel.loggedOut());

  LoginModel get modelValue => _rxModel.value;

  Stream<LoginModel> get model => _rxModel.distinct();

  void dispose() {
    _rxModel.close();
  }

  Future<void> login() async {
    if (modelValue is! LoggedOut && modelValue is! Error) return;

    _rxModel.add(Loading());
    try {
      await _authenticator.login();
      // await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      // await DI.get<ScopeHandler>().push<JourneyScope>();
      // if (context.mounted) {
      //   context.router.replace(const JourneySelectionRoute());
      // }
      _rxModel.add(LoggedIn());
    } catch (e) {
      _log.severe('Login failed', e);
      _rxModel.add(Error(errorMessage: e.toString()));
    }
  }
}
