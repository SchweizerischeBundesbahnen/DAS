import 'package:app/pages/journey/warn_app_view_model.dart';

class MockWarnAppViewModel extends WarnAppViewModel {
  MockWarnAppViewModel({
    required super.flavor,
    required super.sferaRemoteRepo,
    required super.warnappRepo,
    required super.ruFeatureProvider,
  });

  bool _isWaraInstalled = false;

  void setWaraAppInstalled(bool isInstalled) {
    _isWaraInstalled = isInstalled;
  }

  @override
  Future<bool> get isWaraAppInstalled => Future.value(_isWaraInstalled);
}
