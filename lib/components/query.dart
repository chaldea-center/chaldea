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
  List<String> _optional = [];
  List<String> _mandatory = [];
  List<String> _excluded = [];

  Query({String? queryString, bool caseSensitive = false}) {
    if (queryString != null) {
      this.parse(queryString, caseSensitive: caseSensitive);
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
    _optional.clear();
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
          _optional.add(phrase);
          break;
      }
    });
  }

  bool match(String string) {
    if (_optional.isEmpty && _mandatory.isEmpty && _excluded.isEmpty) {
      return true;
    }
    if (!_caseSensitive) string = string.toLowerCase();

    // mandatory
    for (String p in _mandatory) {
      if (!string.contains(p)) return false;
    }
    // excluded
    for (String p in _excluded) {
      if (string.contains(p)) return false;
    }
    // optional
    if (_optional.isEmpty) return true;
    int matchedOptional = 0;
    for (String p in _optional) {
      if (string.contains(p)) matchedOptional += 1;
    }
    return matchedOptional > 0;
  }
}
