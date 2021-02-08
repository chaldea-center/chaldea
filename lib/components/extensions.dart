//@dart=2.12
/// Some convenient extensions on build-in classes

extension GetOrNull<T> on List<T> {
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return elementAt(index);
    }
    return null;
  }
}
