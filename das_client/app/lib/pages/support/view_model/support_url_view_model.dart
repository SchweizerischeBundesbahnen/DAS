import 'package:app/launcher/launcher.dart';
import 'package:core_data/component.dart';

class SupportUrlViewModel({required final Launcher _launcher}) {
  static const _privacyPolicyUrl = LocalizedString(
    de: 'https://github.com/SchweizerischeBundesbahnen/DAS/wiki/DAS-Datenschutzerkl%C3%A4rung',
    fr: 'https://github.com/SchweizerischeBundesbahnen/DAS/wiki/DAS-D%C3%A9claration-de-protection-des-donn%C3%A9e',
    it: 'https://github.com/SchweizerischeBundesbahnen/DAS/wiki/DAS-Dichiarazione-relativa-alla-protezione-dei-dati',
  );

  Future<bool> openPrivacyPolicy() => _launcher.launch(_privacyPolicyUrl.localized);
}
