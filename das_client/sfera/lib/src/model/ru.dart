enum RailwayUndertaking {
  sbbP(companyCode: '1085'),
  sbbC(companyCode: '2185'),
  blsP(companyCode: '1163'),
  blsC(companyCode: '3356'),
  sob(companyCode: '5458');

  const RailwayUndertaking({
    required this.companyCode,
  });

  final String companyCode;
}
