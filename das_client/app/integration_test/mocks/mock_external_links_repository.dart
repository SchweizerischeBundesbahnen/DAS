import 'package:external_links/component.dart';
import 'package:rxdart/rxdart.dart';

class MockExternalLinksRepository implements ExternalLinksRepository {
  static final _staticLinks = <ExternalLink>[
    ExternalLink(
      id: 1,
      companies: const ['2185'],
      title: const LocalizedString(de: 'Bahnhofportal', fr: 'Portail gare', it: 'Portale stazione'),
      link: const LocalizedString(
        de: 'https://www.bahnhofportal.ch',
        fr: 'https://www.bahnhofportal.ch',
        it: 'https://www.bahnhofportal.ch',
      ),
      lastModifiedAt: DateTime(2025, 1, 1),
      lastModifiedBy: 'test',
    ),
    ExternalLink(
      id: 2,
      companies: const ['2185'],
      title: const LocalizedString(de: 'V-APP', fr: 'V-APP', it: 'V-APP'),
      link: const LocalizedString(
        de: 'https://www.v-app.ch',
        fr: 'https://www.v-app.ch',
        it: 'https://www.v-app.ch',
      ),
      lastModifiedAt: DateTime(2025, 1, 1),
      lastModifiedBy: 'test',
    ),
    ExternalLink(
      id: 3,
      companies: const ['2185', '1080'],
      title: const LocalizedString(de: 'ESQ', fr: 'ESQ', it: 'ESQ'),
      link: const LocalizedString(
        de: 'https://www.esq.ch',
        fr: 'https://www.esq.ch',
        it: 'https://www.esq.ch',
      ),
      lastModifiedAt: DateTime(2025, 1, 1),
      lastModifiedBy: 'test',
    ),
  ];

  final _subjects = <String, BehaviorSubject<List<ExternalLink>>>{};

  List<ExternalLink> _linksForCompanies(List<String> companies) {
    return _staticLinks.where((link) => link.companies.any((c) => companies.contains(c))).toList();
  }

  String _key(List<String> companies) => (companies.toList()..sort()).join(',');

  @override
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) {
    final key = _key(companies);
    _subjects[key] ??= BehaviorSubject<List<ExternalLink>>.seeded(_linksForCompanies(companies));
    return _subjects[key]!.stream;
  }

  @override
  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies) async {
    final links = _linksForCompanies(companies);
    final key = _key(companies);
    if (_subjects.containsKey(key)) {
      _subjects[key]!.add(links);
    }
    return links;
  }
}
