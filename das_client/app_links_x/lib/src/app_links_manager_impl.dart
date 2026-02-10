import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:app_links_x/src/app_links_manager.dart';
import 'package:app_links_x/src/train_journey/train_journey_link_data.dart';
import 'package:app_links_x/src/train_journey/train_journey_parser.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('AppLinksManagerImpl');

/// Processes all deep-links used to open DAS app by using the app_links package.
///
/// see: [AppLinksManager]
class AppLinksManagerImpl implements AppLinksManager {
  static const _expectedHost = 'driveradvisorysystem.sbb.ch';

  final AppLinks _appLinks;

  final _rxJourneys = BehaviorSubject<List<TrainJourneyLinkData>>();
  StreamSubscription<Uri>? _linkSubscription;

  AppLinksManagerImpl({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks() {
    _checkInitialLink();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (err) => _log.severe('Error while listening to deep-links updates: $err'),
      cancelOnError: false,
    );
  }

  @override
  Stream<List<TrainJourneyLinkData>> get onTrainJourneyLink => _rxJourneys.stream;

  void dispose() {
    _linkSubscription?.cancel();
    _rxJourneys.close();
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      _log.severe('Error while checking for initial link: $e');
    }
  }

  /// Uri is expected to be in format https://driveradvisorysystem.sbb.ch/{env}/{version}/PATH+QUERY.
  /// As environment and version aren't used yet, they are ignored when invalid and PATH+QUERY is processed.
  /// If uri can't be handled, it is ignored and the app will just be opened.
  void _handleUri(Uri uri) {
    _log.info('Received a deep-link: $uri');
    if (uri.host.isNotEmpty && uri.host != _expectedHost) {
      _log.info('Deep-link does not match expected host: $_expectedHost. Received: ${uri.host}');
      return;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    if (segments.length < 3) {
      _log.info('Deep-link does not match specification. Opening app home.');
      return;
    }

    final env = segments[0].toLowerCase();
    const allowedEnvs = {'dev', 'inte', 'prod'};
    if (!allowedEnvs.contains(env)) {
      _log.info('Deep-link has environment that is not supported: "$env". Supported: $allowedEnvs');
    }

    final version = segments[1].toLowerCase();
    if (!RegExp(r'^v\d+$').hasMatch(version)) {
      _log.info('Deep-link has a version in an unsupported format: "$version".');
    }

    final page = segments[2].toLowerCase();

    try {
      switch (page) {
        case TrainJourneyParser.page:
          _rxJourneys.add(TrainJourneyParser.parse(uri));
          break;
        default:
          _log.info('Deep-link page "$page" is not supported and ignored.');
          break;
      }
    } catch (e, st) {
      _log.severe('Error while parsing deep-link "$uri": $e', st);
    }
  }
}
