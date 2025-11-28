import 'package:collection/collection.dart';

enum RailwayUndertaking {
  blsN(companyCode: '0063', displayName: 'BLS N'),
  blsP(companyCode: '1163', displayName: 'BLS Personenverkehr'),
  blsC(companyCode: '3356', displayName: 'BLS Cargo'),
  sbb(companyCode: '1085', displayName: 'SBB'),
  sbbP(companyCode: '1385', displayName: 'SBB Personenverkehr'),
  sbbC(companyCode: '2185', displayName: 'SBB Cargo'),
  sbbCInt(companyCode: '2585', displayName: 'SBB Cargo International'),
  sbbD(companyCode: '5404', displayName: 'SBB D'),
  sbbInfraBuildLog(companyCode: '5184', displayName: 'SBB Infra BuildLog'),
  sbbInfra(companyCode: '5186', displayName: 'SBB Infra'),
  sobT(companyCode: '5458', displayName: 'SOB T'),
  sobInfra(companyCode: '5460', displayName: 'SOB Intra'),
  thu(companyCode: '3917', displayName: 'Thurbo'),
  ra(companyCode: '5680', displayName: 'RA'),
  travys(companyCode: '5227', displayName: 'Travys'),
  transN(companyCode: '5244', displayName: 'TransN'),
  tpfInfra(companyCode: '5234', displayName: 'Tpf Infra'),
  tpfTrafic(companyCode: '5495', displayName: 'Tpf Trafic'),
  tmr(companyCode: '5429', displayName: 'TMR'),
  mbc(companyCode: '5230', displayName: 'MBC'),
  unknown(companyCode: '-1', displayName: 'Unbekannt');

  const RailwayUndertaking({
    required this.companyCode,
    required this.displayName,
  });

  final String companyCode;
  final String displayName;

  static Iterable<RailwayUndertaking> get knownRUs => values.whereNot((ru) => ru == unknown);

  static RailwayUndertaking fromCompanyCode(String companyCode) {
    return RailwayUndertaking.values.firstWhereOrNull((e) => e.companyCode == companyCode) ?? unknown;
  }
}
