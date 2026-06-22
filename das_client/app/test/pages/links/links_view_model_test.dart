import 'dart:async';

import 'package:app/launcher/launcher.dart';
import 'package:app/model/tour_system.dart';
import 'package:app/pages/links/links_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:external_links/component.dart';
import 'package:external_links/src/model/localized_string.dart' as external_links;
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

import '../../test_util.dart';

void main() {
  late LinksViewModel testee;
  late _FakeExternalLinksRepository externalLinksRepository;
  late _FakeUserSettings userSettings;
  late _FakeLauncher launcher;

  late StreamSubscription<List<ExternalLink>> subscription;
  final states = <List<ExternalLink>>[];

  LinksViewModel createViewModel() {
    return LinksViewModel(
      externalLinksRepository: externalLinksRepository,
      userSettings: userSettings,
      launcher: launcher,
    );
  }

  setUp(() async {
    externalLinksRepository = _FakeExternalLinksRepository();
    userSettings = _FakeUserSettings();
    launcher = _FakeLauncher();

    testee = createViewModel();

    subscription = testee.links.listen(states.add);
    await processStreams();
  });

  tearDown(() async {
    await subscription.cancel();
    testee.dispose();
    await externalLinksRepository.dispose();
    states.clear();
  });

  test('state_whenNoConnectedTrain_thenEmpty', () {
    expect(states, [isEmpty]);
  });

  test('state_whenCompanyAndLinksAvailable_thenLoaded', () async {
    // Recreate with pre-set undertakings
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.sbbCH];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.db];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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
    launcher.result = true;

    final result = await testee.openExternalLink('https://www.sbb.ch');

    expect(result, isTrue);
    expect(launcher.lastUrl, 'https://www.sbb.ch');
  });

  test('state_whenDuplicateLinksWithSameTitleAndLink_thenDeduplicates', () async {
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.sbbCH];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.sbbCH];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.sbbCH];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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
    await subscription.cancel();
    testee.dispose();
    states.clear();

    userSettings.railwayUndertakings = [RailwayUndertaking.sbbCH];
    testee = createViewModel();
    subscription = testee.links.listen(states.add);
    await processStreams();

    externalLinksRepository.emitLinks([
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

class _FakeLauncher implements Launcher {
  String? lastUrl;
  bool result = false;

  @override
  bool hasTourSystemConfigured() => false;

  @override
  Future<bool> launch(String url) async {
    lastUrl = url;
    return result;
  }

  @override
  Future<bool> launchTourSystem() async => false;
}

class _FakeExternalLinksRepository implements ExternalLinksRepository {
  final _controller = StreamController<List<ExternalLink>>.broadcast();

  void emitLinks(List<ExternalLink> links) => _controller.add(links);

  Future<void> dispose() => _controller.close();

  @override
  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies) async => const [];

  @override
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) => _controller.stream;
}

class _FakeUserSettings implements UserSettings {
  final _controller = StreamController<UserSettingKeys?>.broadcast();

  List<RailwayUndertaking> railwayUndertakings = const [];

  @override
  Stream<UserSettingKeys?> get model => _controller.stream;

  @override
  bool get showDecisiveGradient => true;

  @override
  bool get showStationSignals => true;

  @override
  TourSystem? get tourSystem => null;

  void emitRailwayUndertakings(List<RailwayUndertaking> value) {
    railwayUndertakings = value;
    _controller.add(UserSettingKeys.railwayUndertakings);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
