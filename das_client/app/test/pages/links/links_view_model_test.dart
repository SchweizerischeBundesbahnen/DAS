import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:app/pages/links/links_view_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:core_data/component.dart';
import 'package:external_links/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../test_util.dart';
import 'links_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ExternalLinksRepository>(), MockSpec<LocalKeyValueStore>(), MockSpec<Launcher>()])
void main() {
  late LinksViewModel testee;
  late MockExternalLinksRepository mockExternalLinksRepository;
  late MockLocalKeyValueStore mockLocalKeyValueStore;
  late MockLauncher mockLauncher;
  late StreamController<List<ExternalLink>> linksController;

  late StreamSubscription<List<ExternalLink>> subscription;
  final states = <List<ExternalLink>>[];

  LinksViewModel createViewModel() {
    return LinksViewModel(
      externalLinksRepository: mockExternalLinksRepository,
      userSettings: mockLocalKeyValueStore,
      launcher: mockLauncher,
    );
  }

  setUp(() async {
    mockExternalLinksRepository = MockExternalLinksRepository();
    mockLocalKeyValueStore = MockLocalKeyValueStore();
    mockLauncher = MockLauncher();
    linksController = StreamController<List<ExternalLink>>.broadcast();

    when(mockLocalKeyValueStore.companyCodes).thenReturn(const []);
    when(mockExternalLinksRepository.watchExternalLinksByCompanies(any)).thenAnswer((_) => linksController.stream);
  });

  tearDown(() async {
    await subscription.cancel();
    testee.dispose();
    await linksController.close();
    states.clear();
  });

  test('state_whenNoCompanies_thenEmpty', () async {
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    expect(states, [isEmpty]);
  });

  test('state_whenCompanyAndLinksAvailable_thenLoaded', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['2185']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const LocalizedString(de: 'SBB'),
        link: const LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(1));
    expect(states.last.single.title.localized, 'SBB');
    expect(states.last.single.link.localized, 'https://www.sbb.ch');
  });

  test('state_whenCompaniesConfigured_thenEmitsMatchingCompanyLinks', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['1080']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 2,
        companies: const ['1080'],
        title: const LocalizedString(de: 'DB'),
        link: const LocalizedString(de: 'https://www.deutschebahn.com'),
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
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['2185']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const LocalizedString(de: 'Bahnhofportal'),
        link: const LocalizedString(de: 'https://www.bahnhofportal.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'user1',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185', '1080'],
        title: const LocalizedString(de: 'Bahnhofportal'),
        link: const LocalizedString(de: 'https://www.bahnhofportal.ch'),
        lastModifiedAt: DateTime(2026, 2, 1),
        lastModifiedBy: 'user2',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(1));
    expect(states.last.single.title.localized, 'Bahnhofportal');
  });

  test('state_whenLinksWithSameTitleButDifferentLink_thenKeepsBoth', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['2185']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const LocalizedString(de: 'Portal'),
        link: const LocalizedString(de: 'https://www.portal-a.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const LocalizedString(de: 'Portal'),
        link: const LocalizedString(de: 'https://www.portal-b.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(2));
  });

  test('state_whenLinksWithSameLinkButDifferentTitle_thenKeepsBoth', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['2185']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const LocalizedString(de: 'SBB Portal'),
        link: const LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const LocalizedString(de: 'SBB Webseite'),
        link: const LocalizedString(de: 'https://www.sbb.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
    ]);
    await processStreams();

    expect(states.last, hasLength(2));
  });

  test('state_whenMultipleDuplicates_thenKeepsFirstOccurrence', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['2185']);

    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    linksController.add([
      ExternalLink(
        id: 1,
        companies: const ['2185'],
        title: const LocalizedString(de: 'ESQ'),
        link: const LocalizedString(de: 'https://www.esq.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 2,
        companies: const ['2185'],
        title: const LocalizedString(de: 'V-APP'),
        link: const LocalizedString(de: 'https://www.v-app.ch'),
        lastModifiedAt: DateTime(2026, 1, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 3,
        companies: const ['1080'],
        title: const LocalizedString(de: 'ESQ'),
        link: const LocalizedString(de: 'https://www.esq.ch'),
        lastModifiedAt: DateTime(2026, 2, 1),
        lastModifiedBy: 'test',
      ),
      ExternalLink(
        id: 4,
        companies: const ['1080'],
        title: const LocalizedString(de: 'V-APP'),
        link: const LocalizedString(de: 'https://www.v-app.ch'),
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
