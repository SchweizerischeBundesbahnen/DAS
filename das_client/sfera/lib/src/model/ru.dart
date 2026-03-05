import 'package:collection/collection.dart';

enum RailwayUndertaking {
  blsC(companyCode: '3356'),
  blsI(companyCode: '2263'),
  blsP(companyCode: '1163'),
  brag(companyCode: '9007'),
  cj(companyCode: '9013'),
  db(companyCode: '1080'),
  dbcch(companyCode: '3096'),
  dbcde(companyCode: '2180'),
  dvzo(companyCode: '9020'),
  edg(companyCode: '3527'),
  gtsr(companyCode: '3513'),
  hsl(companyCode: '3127'),
  hstb(companyCode: '9027'),
  mbc(companyCode: '9034'),
  oebb(companyCode: '9043'),
  ra(companyCode: '9048'),
  railh(companyCode: '9088'),
  rca(companyCode: '2181'),
  rcch(companyCode: '4045'),
  rlc(companyCode: '3538'),
  sbbCH(companyCode: '2185'),
  sbbCInt(companyCode: '2585'),
  sbbD(companyCode: '2385'),
  sbbI(companyCode: '5184'),
  sbbP(companyCode: '1285'),
  sersa(companyCode: '3579'),
  sncff(companyCode: '2187'),
  sob(companyCode: '9058'),
  srt(companyCode: '3373'),
  stag(companyCode: '9086'),
  szu(companyCode: '9062'),
  thurbo(companyCode: '3917'),
  ti(companyCode: '9067'),
  tmr(companyCode: '9068'),
  tpf(companyCode: '9070'),
  tr(companyCode: '3471'),
  travys(companyCode: '9071'),
  trn(companyCode: '9072'),
  txlch(companyCode: '3552'),
  utl(companyCode: '9074'),
  vdbb(companyCode: '9076'),
  wrsch(companyCode: '3466'),
  zb(companyCode: '9083'),
  unknown(companyCode: '-1')
  ;

  const RailwayUndertaking({
    required this.companyCode,
  });

  final String companyCode;

  static Iterable<RailwayUndertaking> get knownRUs => values.whereNot((ru) => ru == unknown);

  static RailwayUndertaking fromCompanyCode(String companyCode) {
    return .values.firstWhereOrNull((e) => e.companyCode == companyCode) ?? unknown;
  }
}
