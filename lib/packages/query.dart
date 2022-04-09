/// Match string with query patterns.
///
/// Supports 3 kinds of query pattern:
///   - optional: default, without specific prefix
///   - mandatory: with "+" prefix
///   - excluded: with "-" prefix
///
/// Example:
///
/// ```dart
/// final query = Query('hello +flutter -dart', caseSensitive: false);
/// final strings = ['hello Flutter','hello dart', 'hello world'];
/// for(String s in strings){
///   print(query.match(s));
/// }
/// // prints: true, false, false
/// ```

class Query {
  String? _searchString;
  bool _caseSensitive = false;
  // final List<String> _optional = [];
  final List<String> _mandatory = [];
  final List<String> _excluded = [];

  Query({String? queryString, bool caseSensitive = false}) {
    if (queryString != null) {
      parse(queryString, caseSensitive: caseSensitive);
    }
  }

  void parse(String queryString, {bool caseSensitive = false}) {
    if (queryString == _searchString && caseSensitive == _caseSensitive) return;

    _caseSensitive = caseSensitive;
    _searchString = queryString;

    if (!caseSensitive) queryString = queryString.toLowerCase();
    final phrases = queryString.split(RegExp(r'\s+'));
    phrases.removeWhere((item) => ['', '-', '+'].contains(item));

    // parse
    // _optional.clear();
    _mandatory.clear();
    _excluded.clear();
    phrases.forEach((phrase) {
      switch (phrase[0]) {
        case '+':
          _mandatory.add(phrase.substring(1));
          break;
        case '-':
          _excluded.add(phrase.substring(1));
          break;
        default:
          _mandatory.add(phrase);
          break;
      }
    });
  }

  // for performance issue, use generator
  bool match(Iterable<String?> fragments) {
    if (_mandatory.isEmpty && _excluded.isEmpty) {
      return true;
    }

    if (_excluded.isNotEmpty) {
      for (String? string in fragments) {
        if (string == null || string.isEmpty) continue;
        if (!_caseSensitive) string = string.toLowerCase();
        if (_excluded.any((e) => string!.contains(e))) {
          return false;
        }
      }
    }
    List<String> mandatory = _mandatory.toList();
    for (String? string in fragments) {
      if (string == null || string.isEmpty) continue;
      if (!_caseSensitive) string = string.toLowerCase();
      mandatory.removeWhere((e) => string!.contains(e));
      if (mandatory.isEmpty) return true;
    }
    return mandatory.isEmpty;
  }
}
