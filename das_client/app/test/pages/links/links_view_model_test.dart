import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:app/pages/links/links_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:external_links/component.dart';
import 'package:external_links/src/model/localized_string.dart' as external_links;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import '../../test_util.dart';
import 'links_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ExternalLinksRepository>(), MockSpec<UserSettings>(), MockSpec<Launcher>()])
void main() {
  late LinksViewModel testee;
  late MockExternalLinksRepository mockExternalLinksRepository;
  late MockUserSettings mockUserSettings;
  late MockLauncher mockLauncher;
  late StreamController<List<ExternalLink>> linksController;

  late StreamSubscription<List<ExternalLink>> subscription;
  final states = <List<ExternalLink>>[];

  LinksViewModel createViewModel() {
    return LinksViewModel(
      externalLinksRepository: mockExternalLinksRepository,
      userSettings: mockUserSettings,
      launcher: mockLauncher,
    );
  }

  setUp(() async {
    mockExternalLinksRepository = MockExternalLinksRepository();
    mockUserSettings = MockUserSettings();
    mockLauncher = MockLauncher();
    linksController = StreamController<List<ExternalLink>>.broadcast();

    when(mockUserSettings.railwayUndertakings).thenReturn(const []);
    when(mockExternalLinksRepository.watchExternalLinksByCompanies(any)).thenAnswer((_) => linksController.stream);
  });

  tearDown(() async {
    await subscription.cancel();
    testee.dispose();
    await linksController.close();
    states.clear();
  });

  test('state_whenNoRailwayUndertakings_thenEmpty', () async {
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    expect(states, [isEmpty]);
  });

  test('state_whenCompanyAndLinksAvailable_thenLoaded', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.sbbCH]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'SBB'),
        link: const external_links.LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(1));
    expect(states.last.single.title.localized, 'SBB');
    expect(states.last.single.link.localized, 'https://www.sbb.ch');
  });

  test('state_whenRailwayUndertakingsConfigured_thenEmitsMatchingCompanyLinks', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.db]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 2,
        companies: const ['1080'],
        title: const external_links.LocalizedString(de: 'DB'),
        link: const external_links.LocalizedString(de: 'https://www.deutschebahn.com'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last.single.title.localized, 'DB');
  });

  test('openExternalLink_whenCalled_thenDelegatesToLauncher', () async {
    when(mockLauncher.launch(any)).thenAnswer((_) async => true);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    final result = await testee.openExternalLink('https://www.sbb.ch');

    expect(result, isTrue);
    verify(mockLauncher.launch('https://www.sbb.ch')).called(1);
  });

  test('state_whenDuplicateLinksWithSameTitleAndLink_thenDeduplicates', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.sbbCH]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'Bahnhofportal'),
        link: const external_links.LocalizedString(de: 'https://www.bahnhofportal.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'user1',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185', '1080'],
        title: const external_links.LocalizedString(de: 'Bahnhofportal'),
        link: const external_links.LocalizedString(de: 'https://www.bahnhofportal.ch'),
        lastModifiedAt: DateTime(2026, 2, 1),
        lastModifiedBy: 'user2',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(1));
    expect(states.last.single.title.localized, 'Bahnhofportal');
  });

  test('state_whenLinksWithSameTitleButDifferentLink_thenKeepsBoth', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.sbbCH]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'Portal'),
        link: const external_links.LocalizedString(de: 'https://www.portal-a.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'Portal'),
        link: const external_links.LocalizedString(de: 'https://www.portal-b.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(2));
  });

  test('state_whenLinksWithSameLinkButDifferentTitle_thenKeepsBoth', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.sbbCH]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'SBB Portal'),
        link: const external_links.LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'SBB Webseite'),
        link: const external_links.LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(2));
  });

  test('state_whenMultipleDuplicates_thenKeepsFirstOccurrence', () async {
    when(mockUserSettings.railwayUndertakings).thenReturn([RailwayUndertaking.sbbCH]);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'ESQ'),
        link: const external_links.LocalizedString(de: 'https://www.esq.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const external_links.LocalizedString(de: 'V-APP'),
        link: const external_links.LocalizedString(de: 'https://www.v-app.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 3,
        companies: const ['1080'],
        title: const external_links.LocalizedString(de: 'ESQ'),
        link: const external_links.LocalizedString(de: 'https://www.esq.ch'),
        lastModifiedAt: DateTime(2026, 2, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 4,
        companies: const ['1080'],
        title: const external_links.LocalizedString(de: 'V-APP'),
        link: const external_links.LocalizedString(de: 'https://www.v-app.ch'),
        lastModifiedAt: DateTime(2026, 2, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(2));
    expect(states.last[0].id, 1);
    expect(states.last[1].id, 2);
  });
}
