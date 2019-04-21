import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatype/constants.dart';
import 'package:chaldea/modules/home/settings_item.dart';
import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    final List<String> labels = LangCode.names;
    final List<String> codes = LangCode.codes;
    final String _curCode = S.of(context).language;
    final selected = codes.indexOf(_curCode);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings_language),
        leading: BackButton(),
      ),
      body: SSelect(
        labels: labels,
        selected: selected,
        callback: (int _selected) {
          print('Change language from ${codes[selected]} to ${codes[_selected]}');
          db.data..language=codes[_selected];
          db.onDataChange(locale:LangCode.getLocale(codes[_selected]));
        },
      ),
    );
  }
}
