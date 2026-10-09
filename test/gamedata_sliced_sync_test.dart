// Keeps the frame-sliced GameData builder aligned with generated decoding.
// The sliced builder enumerates top-level fields and delegates entity parsing
// to the generated fromJson methods.
//
// Optional constructor parameters allow omitted fields to compile without
// errors. These tests compare constructor argument names and order, and JSON
// keys in order of first use. After regenerating gamedata.g.dart, synchronize
// only the field enumeration in gamedata_sliced.dart; keep entity parsing in
// the generated code.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _generatedFile = 'lib/generated/models/gamedata/gamedata.g.dart';
const String _slicedFile = 'lib/models/gamedata/gamedata_sliced.dart';

// Match the GameData constructor without matching similarly named models.
// _$GameDataFromJson contains the first matching call in the generated file.
final RegExp _generatedCall = RegExp(r'=>\s*GameData\(');
final RegExp _slicedCall = RegExp(r'return\s+GameData\(');

/// Index of the '(' that opens the call matched by [marker].
int _openParenOf(String source, RegExp marker) {
  final match = marker.firstMatch(source);
  return match == null ? -1 : match.end - 1;
}

/// Text from the opening '(' at [openParen] through its matching ')'.
String _callRegion(String source, int openParen) {
  var depth = 0;
  for (var i = openParen; i < source.length; i++) {
    final c = source[i];
    if (c == "'" || c == '"') {
      i = _skipString(source, i);
      continue;
    }
    if (c == '<' && _looksLikeGenericOpen(source, i)) {
      depth++;
    } else if (c == '>' && depth > 0 && _looksLikeGenericClose(source, i)) {
      depth--;
    } else if (c == '(' || c == '[' || c == '{') {
      depth++;
    } else if (c == ')' || c == ']' || c == '}') {
      depth--;
      if (depth == 0) return source.substring(openParen, i + 1);
    }
  }
  throw StateError('unbalanced call at $openParen');
}

/// Named-argument names of a call region (starting with '('), in source order.
/// Non-named arguments fall back to their raw text so a mismatch is obvious.
List<String> _namedArgs(String region) {
  final raw = <String>[];
  var depth = 0;
  var start = 1;
  for (var i = 1; i < region.length; i++) {
    final c = region[i];
    if (c == "'" || c == '"') {
      i = _skipString(region, i);
      continue;
    }
    if (c == '<' && _looksLikeGenericOpen(region, i)) {
      depth++;
    } else if (c == '>' && depth > 0 && _looksLikeGenericClose(region, i)) {
      depth--;
    } else if (c == '(' || c == '[' || c == '{') {
      depth++;
    } else if (c == ')' || c == ']' || c == '}') {
      if (depth == 0) {
        raw.add(region.substring(start, i));
        break;
      }
      depth--;
    } else if (c == ',' && depth == 0) {
      raw.add(region.substring(start, i));
      start = i + 1;
    }
  }
  return [
    for (final arg in raw.where((a) => a.trim().isNotEmpty))
      RegExp(r'^(\w+)\s*:').firstMatch(arg.trim())?.group(1) ?? arg.trim(),
  ];
}

/// JSON keys in order of first occurrence, ignoring repeated reads of a key.
List<String> _jsonKeys(String text) {
  final keys = <String>[];
  for (final m in RegExp(r"json\['([^']+)'\]").allMatches(text)) {
    final key = m.group(1)!;
    if (!keys.contains(key)) keys.add(key);
  }
  return keys;
}

/// Removes line comments while preserving string literals and line breaks.
String _stripComments(String source) {
  final out = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final c = source[i];
    if (c == "'" || c == '"') {
      final close = _skipString(source, i);
      out.write(source.substring(i, close + 1));
      i = close;
      continue;
    }
    if (c == '/' && i + 1 < source.length && source[i + 1] == '/') {
      final newline = source.indexOf('\n', i);
      i = newline == -1 ? source.length : newline - 1;
      continue;
    }
    out.write(c);
  }
  return out.toString();
}

/// Index of the closing quote of the string starting at [quoteStart].
int _skipString(String source, int quoteStart) {
  final close = source.indexOf(source[quoteStart], quoteStart + 1);
  return close == -1 ? source.length : close;
}

bool _isWordChar(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);

String _prevNonWs(String s, int i) {
  for (var j = i - 1; j >= 0; j--) {
    if (!RegExp(r'\s').hasMatch(s[j])) return s[j];
  }
  return '';
}

String _nextNonWs(String s, int i) {
  for (var j = i + 1; j < s.length; j++) {
    if (!RegExp(r'\s').hasMatch(s[j])) return s[j];
  }
  return '';
}

// Approximate generic delimiters from adjacent identifier/type characters so
// commas within type arguments do not split constructor arguments.
bool _looksLikeGenericOpen(String s, int i) {
  if (!_isWordChar(_prevNonWs(s, i))) return false;
  final next = _nextNonWs(s, i);
  return next == '?' || _isWordChar(next);
}

bool _looksLikeGenericClose(String s, int i) {
  final prev = _prevNonWs(s, i);
  return _isWordChar(prev) || prev == '?' || prev == '>';
}

void main() {
  late List<String> generatedArgs;
  late List<String> slicedArgs;
  late List<String> generatedKeys;
  late List<String> slicedKeys;

  setUpAll(() {
    // Strip comments before scanning so their brackets do not affect nesting.
    final generatedSrc = _stripComments(File(_generatedFile).readAsStringSync());
    final slicedSrc = _stripComments(File(_slicedFile).readAsStringSync());
    final generatedRegion = _callRegion(generatedSrc, _openParenOf(generatedSrc, _generatedCall));
    final slicedRegion = _callRegion(slicedSrc, _openParenOf(slicedSrc, _slicedCall));
    generatedArgs = _namedArgs(generatedRegion);
    slicedArgs = _namedArgs(slicedRegion);
    // Restrict generated keys to GameData; the file contains other models.
    // The sliced source contains only top-level GameData key reads.
    generatedKeys = _jsonKeys(generatedRegion);
    slicedKeys = _jsonKeys(slicedSrc);
  });

  test('parser sanity: both GameData calls yield plain named arguments', () {
    expect(generatedArgs.length, greaterThan(20), reason: 'parse of $_generatedFile failed');
    expect(slicedArgs.length, greaterThan(20), reason: 'parse of $_slicedFile failed');
    for (final name in [...generatedArgs, ...slicedArgs]) {
      expect(name, matches(RegExp(r'^\w+$')), reason: 'not a named argument');
    }
    expect(generatedKeys.length, greaterThan(20));
    expect(slicedKeys.length, greaterThan(20));
  });

  test('sliced assembly mirrors _\$GameDataFromJson (name + order)', () {
    expect(
      slicedArgs,
      generatedArgs,
      reason:
          '$_slicedFile must mirror $_generatedFile: same argument names, '
          'same order. Update the sliced builder (field enumeration only) '
          'whenever gamedata.g.dart changes.',
    );
  });

  test('sliced json reads mirror generated json keys (key + order)', () {
    expect(
      slicedKeys,
      generatedKeys,
      reason:
          '$_slicedFile must read the same top-level json keys, in the same '
          'order, as $_generatedFile.',
    );
  });
}
