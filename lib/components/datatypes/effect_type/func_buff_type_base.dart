typedef FuncBuffTest = bool Function(FuncBuffTypeBase);
mixin FuncBuffTypeBase {
  String get type;

  String get shownName;
}
