import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/constants.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings_language),
          leading: BackButton(),
        ),
        body: TileGroup(
          tiles: LangCode.codes.map((code) {
            bool _isCurLang = S.of(context).language == code;
            return ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Icon(
                      Icons.check,
                      color: _isCurLang
                          ? Theme.of(context).primaryColor
                          : Color(0x00),
                    ),
                  ),
                  Text(LangCode.getName(code))
                ],
              ),
              onTap: () {
                db.appData.language = code;
                db.onLocaleChange(locale: LangCode.getLocale(code));
              },
            );
          }).toList(),
        ));
  }
}
