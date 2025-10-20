import 'package:collection/collection.dart';

enum RailwayUndertaking {
  sbbP(companyCode: '1185'),
  sbbC(companyCode: '2185'),
  blsP(companyCode: '1163'),
  blsC(companyCode: '3356'),
  sob(companyCode: '5458'),
  unknown(companyCode: '-1');

  const RailwayUndertaking({
    required this.companyCode,
  });

  final String companyCode;

  static RailwayUndertaking fromCompanyCode(String companyCode) {
    return RailwayUndertaking.values.firstWhereOrNull((e) => e.companyCode == companyCode) ?? unknown;
  }
}
