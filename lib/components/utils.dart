// @dart=2.12
import 'dart:convert';
import 'dart:math' show min;

import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Math related
///

/// Format number
///
/// If [compact] is true, other parameters are not used.
String formatNumber(num number,
    {bool compact = false,
    bool percent = false,
    bool omit = true,
    int precision = 3,
    String? groupSeparator = ',',
    num? minVal}) {
  assert(!compact || !percent);

  if (minVal != null && number.abs() < minVal.abs()) {
    return number.toString();
  }

  if (compact) {
    return NumberFormat.compact(locale: 'en').format(number);
  }

  final pattern = [
    if (groupSeparator != null) '###' + groupSeparator,
    '###',
    if (precision > 0) '.' + (omit ? '#' : '0') * precision,
    if (percent) '%'
  ].join();
  return NumberFormat(pattern).format(number);
}

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    print(jsonEncode(newValue.text));
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    int? value = int.tryParse(newValue.text);
    if (value == null) {
      return newValue;
    }
    String newText = formatNumber(value);
    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

/// Sum a list of number, list item defaults to 0 if null
T sum<T extends num>(Iterable<T?> x) {
  if (0 is T) {
    return x.fold(0 as T, (p, c) => (p + (c ?? 0)) as T);
  } else {
    return x.fold(0.0 as T, (p, c) => (p + (c ?? 0.0)) as T);
  }
}

/// Sum a list of maps, map value must be number.
/// iI [inPlace], the result is saved to the first map.
/// null elements will be skipped.
/// throw error if sum an empty list in place.
Map<K, V> sumDict<K, V extends num>(Iterable<Map<K, V>?> operands,
    {bool inPlace = false}) {
  final _operands = operands.toList();

  Map<K, V> res;
  if (inPlace) {
    assert(_operands[0] != null);
    res = _operands.removeAt(0)!;
  } else {
    res = {};
  }

  for (var m in _operands) {
    m?.forEach((k, v) {
      res[k] = ((res[k] ?? 0) + v) as V;
    });
  }
  return res;
}

/// Multiply the values of map with a number.
Map<K, V> multiplyDict<K, V extends num>(Map<K, V> d, V multiplier,
    {bool inPlace = false}) {
  Map<K, V> res = inPlace ? d : {};
  d.forEach((k, v) {
    res[k] = (v * multiplier) as V;
  });
  return res;
}

/// If invalid index or null data passed, return default value.
T? getListItem<T>(List<T>? data, int index, [k()?]) {
  if (data == null || data.length <= index) {
    return k?.call();
  } else {
    return data[index];
  }
}

/// Flutter related
///

void showInformDialog(BuildContext context,
    {String? title,
    String? content,
    List<Widget> actions = const [],
    bool showOk = true,
    bool showCancel = false}) {
  assert(title != null || content != null);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: content == null ? null : Text(content),
      actions: <Widget>[
        if (showOk)
          FlatButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        if (showCancel)
          FlatButton(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ...actions
      ],
    ),
  );
}

typedef SheetBuilder = Widget Function(BuildContext, StateSetter);

void showSheet(BuildContext context,
    {required SheetBuilder builder, double size = 0.65}) {
  assert(size >= 0.25 && size <= 1);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        return DraggableScrollableSheet(
          initialChildSize: size,
          minChildSize: 0.25,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) =>
              builder(sheetContext, setSheetState),
        );
      },
    ),
  );
}

double defaultDialogWidth(BuildContext context) {
  return min(420, MediaQuery.of(context).size.width * 0.8);
}

double defaultDialogHeight(BuildContext context) {
  return min(420, MediaQuery.of(context).size.width * 0.8);
}
