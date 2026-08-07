import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:settings/component.dart';

const companyBLSC = Company(code: '3356', shortName: 'BLSC');
const companyBLSI = Company(code: '2263', shortName: 'BLSI');
const companyBLSP = Company(code: '1163', shortName: 'BLSP');
const companySBBP = Company(code: '1285', shortName: 'SBBP');
const companySBBCH = Company(code: '2185', shortName: 'SBBCH');
const companySOB = Company(code: '9058', shortName: 'SOB');
const companyDB = Company(code: '1080', shortName: 'DB');
const availableCompanies = [companyBLSC, companyBLSI, companySBBP, companySBBCH, companySOB, companyDB];

class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository() : _appVersionExpiration = AppVersionExpiration(expired: false);

  AppVersionExpiration? _appVersionExpiration;

  @override
  AppVersionExpiration? get appVersionExpiration => _appVersionExpiration;

  set appVersionExpiration(AppVersionExpiration? value) => _appVersionExpiration = value;

  @override
  Future<bool> loadSettings() async => true;

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode) async => true;

  @override
  String? get loggingUrl => '';

  @override
  String? get loggingToken => '';

  @override
  Future<List<Company>> loadCompanies() async => availableCompanies;

  @override
  Future<Company?> getCompanyForCode(String companyCode) async {
    return availableCompanies.firstWhereOrNull((company) => company.code == companyCode);
  }
}
