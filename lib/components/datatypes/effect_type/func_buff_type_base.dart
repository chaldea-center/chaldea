import '../../constants.dart';

typedef FuncBuffTest = bool Function(FuncBuffTypeBase);

class FuncBuffTypeBase<T> {
  final bool isFunc;
  final int index;
  final String type;
  final String nameCn;
  final String nameJp;
  final String nameEn;
  final bool Function(T)? test;

  FuncBuffTypeBase(
      this.isFunc, this.index, this.type, this.nameCn, this.nameJp, this.nameEn,
      [this.test]);

  String get shownName {
    String name = localizeNoun(nameCn, nameJp, nameEn);
    if (name.isNotEmpty) return name;
    return type;
  }

  @override
  String toString() {
    return '$runtimeType($index,$type,$nameCn,$nameJp,$nameEn)';
  }
}
