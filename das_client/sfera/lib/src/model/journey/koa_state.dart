enum KoaState {
  wait,
  waitCancelled,
  waitHide;

  factory KoaState.from(String value) {
    return values.firstWhere((element) => element.name == value, orElse: () => KoaState.waitHide);
  }
}
