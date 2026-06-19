import 'package:external_links/src/api/external_links_api_service.dart';
import 'package:external_links/src/data/local/external_links_service_impl.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/localized_string.dart';
import 'package:external_links/src/repository/external_links_repository.dart';
import 'package:external_links/src/repository/external_links_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'external_links_repository_test.mocks.dart';

@GenerateMocks([ExternalLinksApiService, ExternalLinksServiceImpl])
void main() {
  group('ExternalLinksRepository', () {
    late ExternalLinksRepository repository;
    late MockExternalLinksApiService mockApiService;
    late MockExternalLinksServiceImpl mockDatabaseService;

    setUp(() {
      mockApiService = MockExternalLinksApiService();
      mockDatabaseService = MockExternalLinksServiceImpl();
      repository = ExternalLinksRepositoryImpl(apiService: mockApiService, databaseService: mockDatabaseService);
    });

    test('reloadExternalLinksByCompanies should fetch and cache data', () async {
      final companies = ['company1', 'company2'];
      final externalLink = ExternalLink(
        id: 1,
        companies: companies,
        title: const LocalizedString(
          de: 'German Title',
          fr: 'French Title',
          it: 'Italian Title',
        ),
        link: const LocalizedString(
          de: 'https://example.de',
          fr: 'https://example.fr',
          it: 'https://example.it',
        ),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      when(mockDatabaseService.findExternalLinksByCompanies(companies)).thenAnswer((_) async => [externalLink]);

      final result = await repository.reloadExternalLinksByCompanies(companies);

      expect(result, equals([externalLink]));
      verify(mockDatabaseService.findExternalLinksByCompanies(companies)).called(1);
    });

    test('watchExternalLinksByCompanies should emit cached data', () async {
      final companies = ['company1'];
      final externalLink = ExternalLink(
        id: 1,
        companies: companies,
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      when(mockDatabaseService.findExternalLinksByCompanies(companies)).thenAnswer((_) async => [externalLink]);
      when(
        mockDatabaseService.watchExternalLinksByCompanies(companies),
      ).thenAnswer((_) => Stream.value([externalLink]));

      final stream = repository.watchExternalLinksByCompanies(companies);

      expect(stream, emits([externalLink]));
    });
  });
}
