import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/blank_page.dart';
import 'package:chaldea/utils/utils.dart';

class StartupErrorPage extends StatelessWidget {
  final dynamic initError;
  final dynamic initStack;

  const StartupErrorPage({Key? key, this.initError, this.initStack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      themeMode: ThemeMode.light,
      home: BlankPage(
        showIndicator: true,
        indicatorBuilder: (context) {
          return Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: RichText(
                text: TextSpan(
                  text: 'Error: $initError\n\n',
                  style: Theme.of(context).textTheme.subtitle1,
                  children: [
                    TextSpan(
                      text: initStack.toString(),
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
                overflow: TextOverflow.fade,
              )),
            ),
          );
        },
      ),
    );
  }
}
