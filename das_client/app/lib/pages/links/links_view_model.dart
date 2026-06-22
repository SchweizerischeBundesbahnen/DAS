import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:app/provider/user_settings.dart';
import 'package:external_links/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('LinksViewModel');

class LinksViewModel {
  LinksViewModel({
    required this._externalLinksRepository,
    required this._userSettings,
    required this._launcher,
  }) {
    _init();
  }

  final ExternalLinksRepository _externalLinksRepository;
  final UserSettings _userSettings;
  final Launcher _launcher;

  final BehaviorSubject<List<ExternalLink>> _rxState = BehaviorSubject<List<ExternalLink>>.seeded(const []);

  StreamSubscription<List<ExternalLink>>? _externalLinksSubscription;

  Stream<List<ExternalLink>> get links => _rxState.stream;

  List<ExternalLink> get linksValue => _rxState.value;

  Future<bool> openExternalLink(String url) => _launcher.launch(url);

  void dispose() {
    _externalLinksSubscription?.cancel();
    _rxState.close();
  }

  void _init() {
    _watchLinksForCurrentSettings();
  }

  void _watchLinksForCurrentSettings() {
    final companyCodes = _userSettings.railwayUndertakings.map((undertaking) => undertaking.companyCode).toList();
    _watchLinksForCompanies(companyCodes);
  }

  void _watchLinksForCompanies(List<String> companyCodes) {
    _externalLinksSubscription?.cancel();

    if (companyCodes.isEmpty) {
      _rxState.add(const []);
      return;
    }

    _externalLinksSubscription = _externalLinksRepository
        .watchExternalLinksByCompanies(companyCodes)
        .listen(
          (links) => _rxState.add(_deduplicateLinks(links)),
          onError: (Object error, StackTrace stackTrace) {
            _log.severe('Unable to load external links', error, stackTrace);
            _rxState.add(const []);
          },
        );
  }

  List<ExternalLink> _deduplicateLinks(List<ExternalLink> links) {
    final seen = <(String, String)>{};
    return links.where((link) => seen.add((link.title.localized, link.link.localized))).toList();
  }
}
