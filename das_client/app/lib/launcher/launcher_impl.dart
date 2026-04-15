import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

final _log = Logger('LauncherImpl');

class LauncherImpl implements Launcher {
  LauncherImpl({required UserSettings userSettings}) : _userSettings = userSettings;

  final UserSettings _userSettings;

  @override
  Future<bool> launch(String url) async {
    _log.info('Launching url: $url');

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    return launchUrl(uri, mode: .externalApplication);
  }

  @override
  bool hasTourSystemConfigured() => _tourSystemUrl() != null;

  @override
  Future<bool> launchTourSystem() async {
    final tourSystemUrl = _tourSystemUrl();
    if (tourSystemUrl == null) return false;
    return launch(tourSystemUrl);
  }

  String? _tourSystemUrl() {
    final journeyNavigationViewModel = DI.getOrNull<JourneyNavigationViewModel>();
    final returnUrl = journeyNavigationViewModel?.modelValue?.trainIdentification.returnUrl;
    if (returnUrl != null) return returnUrl;

    final tourSystemUrl = DI.get<Flavor>().tourSystemUrls[_userSettings.tourSystem];
    if (tourSystemUrl == null) {
      _log.warning('Tour system url not defined for selected tour system ${_userSettings.tourSystem}');
    }
    return tourSystemUrl;
  }
}
