import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:external_links/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

final _log = Logger('LinksViewModel');

class LinksViewModel({
  required final ExternalLinksRepository _externalLinksRepository,
  required final UserPropertiesRepository _userPropertiesRepository,
  required final Launcher _launcher,
}) {
  this {
    _watchLinksForCompanies(_userPropertiesRepository.companyCodes);
  }

  final BehaviorSubject<List<ExternalLink>> _rxExternalLinks = BehaviorSubject<List<ExternalLink>>.seeded(const []);

  StreamSubscription<List<ExternalLink>>? _externalLinksSubscription;

  Stream<List<ExternalLink>> get links => _rxExternalLinks.stream;

  List<ExternalLink> get linksValue => _rxExternalLinks.value;

  Future<bool> openExternalLink(String url) => _launcher.launch(url);

  void dispose() {
    _externalLinksSubscription?.cancel();
    _rxExternalLinks.close();
  }

  void _watchLinksForCompanies(List<String> companyCodes) {
    if (companyCodes.isEmpty) return;

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
