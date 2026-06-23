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

  final BehaviorSubject<List<ExternalLink>> _rxExternalLinks = BehaviorSubject<List<ExternalLink>>.seeded(const []);

  StreamSubscription<List<ExternalLink>>? _externalLinksSubscription;

  Stream<List<ExternalLink>> get links => _rxExternalLinks.stream;

  List<ExternalLink> get linksValue => _rxExternalLinks.value;

  Future<bool> openExternalLink(String url) => _launcher.launch(url);

  void dispose() {
    _externalLinksSubscription?.cancel();
    _rxExternalLinks.close();
  }

  void _init() {
    final companyCodes = _userSettings.railwayUndertakings.map((undertaking) => undertaking.companyCode).toList();
    _watchLinksForCompanies(companyCodes);
  }

  void _watchLinksForCompanies(List<String> companyCodes) {
    _externalLinksSubscription?.cancel();

    if (companyCodes.isEmpty) {
      _rxExternalLinks.add(const []);
      return;
    }

    _externalLinksSubscription = _externalLinksRepository
        .watchExternalLinksByCompanies(companyCodes)
        .listen(
          (links) => _rxExternalLinks.add(_deduplicateLinks(links)),
          onError: (Object error, StackTrace stackTrace) {
            _log.severe('Unable to load external links', error, stackTrace);
            _rxExternalLinks.add(const []);
          },
        );
  }

  List<ExternalLink> _deduplicateLinks(List<ExternalLink> links) {
    final seen = <(String, String)>{};
    return links.where((link) => seen.add((link.title.localized, link.link.localized))).toList();
  }
}
