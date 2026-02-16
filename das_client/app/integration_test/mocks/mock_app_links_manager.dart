import 'package:app_links_x/component.dart';
import 'package:rxdart/rxdart.dart';

class MockAppLinksManager implements AppLinksManager {
  final _rxAppLinkIntent = BehaviorSubject<AppLinkIntent>();

  void pushAppLinkIntent(AppLinkIntent intent) {
    _rxAppLinkIntent.add(intent);
  }

  @override
  Stream<AppLinkIntent> get onAppLinkIntent => _rxAppLinkIntent.stream;

  @override
  void dispose() {
    _rxAppLinkIntent.close();
  }
}
