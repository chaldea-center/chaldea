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

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool test(E element)) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }
}

extension DateTimeEnhance on DateTime {
  static DateTime? tryParse(String? formattedString) {
    if (formattedString == null) return null;
    var date = DateTime.tryParse(formattedString);
    if (date != null) return date;
    // replace 2020-2-2 to 2020-02-02
    final _reg = RegExp(r'^([+-]?\d{4})-?(\d{1,2})-?(\d{1,2})');
    final match = _reg.firstMatch(formattedString);
    if (match != null) {
      String year = match.group(1)!;
      String month = match.group(2)!.padLeft(2, '0');
      String day = match.group(3)!.padLeft(2, '0');
      // print('replace ${match.group(0)} to ${'$year-$month-$day'}');
      return DateTime.tryParse(
          formattedString.replaceFirst(match.group(0)!, '$year-$month-$day'));
    }
  }
}
