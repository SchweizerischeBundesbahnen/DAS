import 'package:sfera/component.dart';

enum ServicePointPortal(final String url) {
  sbb('https://sbb.sharepoint.com/sites/app-bahnhofportal#/Betriebspunkt/{abbreviation}'),
  bls(
    'https://bls.sharepoint.com/sites/Lokpersonal_/SitePages/Anzeigeseiten/Bahnh%C3%B6fe.aspx?BLSParam00={abbreviation}',
  );

  String urlFor(ServicePoint servicePoint) {
    return url.replaceAll('{abbreviation}', servicePoint.abbreviation);
  }
}
