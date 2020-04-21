import 'dart:async';

import 'package:catcher/core/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> {
  void onAppUpdate() {
    setState(() {});
  }

  Future<Null> initialApp() async {
    await db.initial();
    db.onAppUpdate = this.onAppUpdate;
    await db.loadZipAssets(kDefaultDatasetAssetKey);
    db.loadGameData();
    db.loadUserData();
    db.itemStat.update();
    db.checkNetwork();
    setState(() {});
  }

  @override
  void initState() {
    // show anything after data loaded in initial()!!!
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => initialApp());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chaldea",
      debugShowCheckedModeBanner: false,
      navigatorKey: Catcher.navigatorKey,
      locale: LangCode.getLocale(db.userData?.language),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback:
          S.delegate.resolution(fallback: Locale('zh', '')),
      builder: (context, widget) {
        Catcher.addDefaultErrorWidget(showStacktrace: true);
        return widget;
      },
      home: db.userData == null ? BlankPage() : HomePage(),
    );
  }
}
