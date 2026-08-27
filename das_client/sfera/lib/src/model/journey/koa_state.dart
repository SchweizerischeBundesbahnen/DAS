enum KoaState {
  wait,
  waitCancelled,
  waitHide,
  call;

  factory from(String value) => values.firstWhere((element) => element.name == value, orElse: () => .waitHide);
}
