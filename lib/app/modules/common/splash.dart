import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/after_layout.dart';
import '../../../models/db.dart';
import '../../../packages/logger.dart';
import 'blank_page.dart';

class SplashPage extends StatefulWidget {
  final String? nextPageUrl;

  const SplashPage({Key? key, this.nextPageUrl}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with AfterLayoutMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const BlankPage(showIndicator: !kIsWeb);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await precacheImage(
      const AssetImage("res/img/chaldea.png"),
      context,
      onError: (e, s) async {
        logger.w('pre cache chaldea image error', e, s);
      },
    );
    await Future.delayed(Duration.zero);
    _prepareGameData();
    if (db.settings.tips.starter) {
      await SplitRoute.push(context, const StarterGuidancePage(), detail: null);
    }
  }

  Future<void> _prepareGameData() async {
    //
  }
}

class StarterGuidancePage extends StatefulWidget {
  const StarterGuidancePage({Key? key}) : super(key: key);

  @override
  _StarterGuidancePageState createState() => _StarterGuidancePageState();
}

class _StarterGuidancePageState extends State<StarterGuidancePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
