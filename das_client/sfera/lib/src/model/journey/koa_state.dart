enum KoaState {
  wait,
  waitCancelled,
  waitHide
  ;

  factory KoaState.from(String value) => values.firstWhere((element) => element.name == value, orElse: () => .waitHide);
}
