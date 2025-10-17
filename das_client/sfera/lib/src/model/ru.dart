enum RailwayUndertaking {
  blsN(companyCode: '0063'),
  blsP(companyCode: '1163'),
  blsNEvu(companyCode: '2263'),
  blsC(companyCode: '3356'),
  sbb(companyCode: '1085'),
  sbbP(companyCode: '1385'),
  sbbEPA(companyCode: '1285'),
  sbbC(companyCode: '2185'),
  sbbCInt(companyCode: '2585'),
  sbbD(companyCode: '5404'),
  sbbInfraBuildLog(companyCode: '5184'),
  sbbInfraPath(companyCode: '5186'),
  sobT(companyCode: '5458'),
  sobInfra(companyCode: '5459'),
  sobInfraTi(companyCode: '5460'),
  thu(companyCode: '3917'),
  ra(companyCode: '5680'),
  travys(companyCode: '5227'),
  transN(companyCode: '5244'),
  tpfInfra(companyCode: '5234'),
  tpfTrafic(companyCode: '5495'),
  tmr(companyCode: '5429'),
  mbc(companyCode: '5230');

  const RailwayUndertaking({
    required this.companyCode,
  });

  final String companyCode;

  static RailwayUndertaking fromCompanyCode(String companyCode) {
    return RailwayUndertaking.values.firstWhere((e) => e.companyCode == companyCode);
  }
}
