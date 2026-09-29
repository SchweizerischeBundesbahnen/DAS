import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:external_links/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

final _log = Logger('LinksViewModel');

class LinksViewModel({
  required final ExternalLinksRepository _externalLinksRepository,
  required final LocalKeyValueStore _userSettings,
  required final Launcher _launcher,
}) {
  this {
    _init();
  }

  final BehaviorSubject<List<ExternalLink>> _rxExternalLinks = BehaviorSubject<List<ExternalLink>>.seeded(const []);

  StreamSubscription<List<ExternalLink>>? _externalLinksSubscription;
  StreamSubscription<LocalKeyValueStoreKeys?>? _userSettingsSubscription;
  List<String> _currentCompanyCodes = const [];

  Stream<List<ExternalLink>> get links => _rxExternalLinks.stream;

  List<ExternalLink> get linksValue => _rxExternalLinks.value;

  Future<bool> openExternalLink(String url) => _launcher.launch(url);

  void dispose() {
    _externalLinksSubscription?.cancel();
    _userSettingsSubscription?.cancel();
    _rxExternalLinks.close();
  }

  void _init() {
    _watchLinksForCompanies(_userSettings.companyCodes);
    _userSettingsSubscription = _userSettings.model.listen((_) => _handleUserSettingsChanged());
  }

  void _handleUserSettingsChanged() {
    final updatedCompanyCodes = _userSettings.companyCodes;
    if (_listEquals(_currentCompanyCodes, updatedCompanyCodes)) return;
    _watchLinksForCompanies(updatedCompanyCodes);
  }

  void _watchLinksForCompanies(List<String> companyCodes) {
    _externalLinksSubscription?.cancel();
    _currentCompanyCodes = List.unmodifiable(companyCodes);

    if (companyCodes.isEmpty) {
      _rxExternalLinks.add(const []);
      return;
    }

    _externalLinksRepository.reloadExternalLinksByCompanies(companyCodes);

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

  bool _listEquals(List<String> left, List<String> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;

    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }

    return true;
  }
}
