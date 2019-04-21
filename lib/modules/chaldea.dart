import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatype/constants.dart';
import 'package:chaldea/modules/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> {
  SpecifiedLocalizationDelegate _localOverrideDelegate;

  void onDataChange({Locale locale}) {
    setState(() {
      if(null!=locale){
        _localOverrideDelegate =
            SpecifiedLocalizationDelegate(locale ?? Locale('zh'));
      }
      db.saveUserData();
    });
  }

  @override
  void initState() {
    db.onDataChange = this.onDataChange;
    db.loadUserData().then((Null a) {
      setState(() {
        if (LangCode.codes.contains(db.data.language)) {
          _localOverrideDelegate = SpecifiedLocalizationDelegate(
              LangCode.getLocale(db.data.language));
        }
      });
    });
    _localOverrideDelegate = SpecifiedLocalizationDelegate(Locale('zh', ''));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chaldea",
      localizationsDelegates: [
        _localOverrideDelegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: HomePage(), //pass a function for exit button with context
    );
  }
}
