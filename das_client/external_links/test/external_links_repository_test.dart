import 'package:external_links/src/api/dto/external_links_response_dto.dart';
import 'package:external_links/src/api/endpoint/external_links.dart';
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

@GenerateMocks([ExternalLinksApiService, ExternalLinksServiceImpl, ExternalLinksRequest])
void main() {
  group('ExternalLinksRepository', () {
    late ExternalLinksRepository repository;
    late MockExternalLinksApiService mockApiService;
    late MockExternalLinksServiceImpl mockDatabaseService;
    late MockExternalLinksRequest mockRequest;

    setUp(() {
      mockApiService = MockExternalLinksApiService();
      mockDatabaseService = MockExternalLinksServiceImpl();
      mockRequest = MockExternalLinksRequest();

      when(mockDatabaseService.saveExternalLinks(any)).thenAnswer((_) async {});
      when(mockDatabaseService.deleteExternalLinksNotIn(any)).thenAnswer((_) async {});

      repository = ExternalLinksRepositoryImpl(apiService: mockApiService, databaseService: mockDatabaseService);
    });

    test('database cleanup is called to remove outdated entries', () async {
      final companies = ['company1'];
      final externalLink = ExternalLink(
        id: 1,
        companies: companies,
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      when(mockApiService.externalLinks(companies)).thenReturn(mockRequest);
      when(mockRequest.call()).thenAnswer(
        (_) async => ExternalLinksResponse(
          headers: const {},
          body: ExternalLinksResponseDto(
            data: [
              ExternalLinkDto(
                id: 1,
                companies: companies,
                de: ExternalLinkTranslationDto(title: 'Title', link: 'https://example.com'),
                fr: ExternalLinkTranslationDto(title: 'Titre', link: 'https://example.com/fr'),
                it: ExternalLinkTranslationDto(title: 'Titolo', link: 'https://example.com/it'),
                lastModifiedAt: DateTime(2026, 6, 19),
                lastModifiedBy: 'user',
              ),
            ],
          ),
        ),
      );
      when(mockDatabaseService.findExternalLinksByCompanies(companies)).thenAnswer((_) async => [externalLink]);

      final result = await repository.reloadExternalLinksByCompanies(companies);

      verify(mockDatabaseService.saveExternalLinks(any)).called(1);
      verify(mockDatabaseService.deleteExternalLinksNotIn([1])).called(1);
      expect(result, equals([externalLink]));
    });

    test('database cleanup is not called when request fails', () async {
      final companies = ['company1'];
      when(mockApiService.externalLinks(companies)).thenReturn(mockRequest);
      when(mockRequest.call()).thenThrow(Exception('API Error'));
      when(mockDatabaseService.findExternalLinksByCompanies(companies)).thenAnswer((_) async => []);

      await repository.reloadExternalLinksByCompanies(companies);

      verifyNever(mockDatabaseService.deleteExternalLinksNotIn(any));
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

      when(mockApiService.externalLinks(companies)).thenReturn(mockRequest);
      when(mockRequest.call()).thenThrow(Exception('ignored in watch test'));
      when(mockDatabaseService.findExternalLinksByCompanies(companies)).thenAnswer((_) async => [externalLink]);
      when(
        mockDatabaseService.watchExternalLinksByCompanies(companies),
      ).thenAnswer((_) => Stream.value([externalLink]));

      final stream = repository.watchExternalLinksByCompanies(companies);

      expect(stream, emits([externalLink]));
    });
  });
}
