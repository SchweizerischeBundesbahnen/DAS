import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/localized_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalLink', () {
    test('should create external link with all fields', () {
      final externalLink = ExternalLink(
        id: 1,
        companies: ['company1', 'company2'],
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
        lastModifiedBy: 'user@example.com',
      );

      expect(externalLink.id, equals(1));
      expect(externalLink.companies, equals(['company1', 'company2']));
      expect(externalLink.title.de, equals('German Title'));
      expect(externalLink.link.de, equals('https://example.de'));
    });

    test('should have correct equality', () {
      final link1 = ExternalLink(
        id: 1,
        companies: ['company1'],
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      final link2 = ExternalLink(
        id: 1,
        companies: ['company1'],
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      expect(link1, equals(link2));
    });

    test('should have correct hash code equality', () {
      final link1 = ExternalLink(
        id: 1,
        companies: ['company1'],
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      final link2 = ExternalLink(
        id: 1,
        companies: ['company1'],
        title: const LocalizedString(de: 'Title'),
        link: const LocalizedString(de: 'https://example.com'),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'user',
      );

      expect(link1.hashCode, equals(link2.hashCode));
    });

    test('should handle multi-language titles and links', () {
      final link = ExternalLink(
        id: 1,
        companies: ['company1'],
        title: const LocalizedString(
          de: 'Deutscher Titel',
          fr: 'Titre Français',
          it: 'Titolo Italiano',
        ),
        link: const LocalizedString(
          de: 'https://example.de',
          fr: 'https://example.fr',
          it: 'https://example.it',
        ),
        lastModifiedAt: DateTime(2026, 6, 19),
        lastModifiedBy: 'admin',
      );

      expect(link.title.de, equals('Deutscher Titel'));
      expect(link.title.fr, equals('Titre Français'));
      expect(link.title.it, equals('Titolo Italiano'));
      expect(link.link.de, equals('https://example.de'));
    });
  });

  group('ExternalLinkTranslation', () {
    test('should create translation with title and link', () {
      final translation = ExternalLinkTranslation(
        title: 'Test Title',
        link: 'https://example.com',
      );

      expect(translation.title, equals('Test Title'));
      expect(translation.link, equals('https://example.com'));
    });

    test('should have correct equality', () {
      final translation1 = ExternalLinkTranslation(title: 'Title', link: 'https://example.com');
      final translation2 = ExternalLinkTranslation(title: 'Title', link: 'https://example.com');

      expect(translation1, equals(translation2));
    });
  });
}
