import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/launcher/service_point_portal.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:url_launcher/url_launcher.dart';

final _log = Logger('LauncherImpl');

class LauncherImpl implements Launcher {
  LauncherImpl({required this._userSettings, required this.flavor});

  final Flavor flavor;
  final LocalKeyValueStore _userSettings;

  static const _blsCompanyCodes = [
    '3356', // BLSC
    '2263', // BLSI
    '1163', // BLSP
  ];

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
    return returnUrl ?? flavor.tourSystemUrls[_userSettings.tourSystem];
  }

  @override
  Future<bool> launchServicePointPortal(ServicePoint servicePoint) {
    final companyCodes = _userSettings.companyCodes;
    if (companyCodes.isNotEmpty && companyCodes.every((it) => _blsCompanyCodes.contains(it))) {
      return launch(ServicePointPortal.bls.urlFor(servicePoint));
    } else {
      return launch(ServicePointPortal.sbb.urlFor(servicePoint));
    }
  }
}
