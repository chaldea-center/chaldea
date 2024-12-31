import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';

class BlankPage extends StatelessWidget {
  final bool showIndicator;
  final WidgetBuilder indicatorBuilder;

  const BlankPage({
    super.key,
    this.showIndicator = false,
    this.indicatorBuilder = _defaultIndicatorBuilder,
  });

  static Widget _defaultIndicatorBuilder(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double w = min(50, min(constraints.maxHeight, constraints.maxWidth) - 40);
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w, maxHeight: w),
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double imgWidth = min(270, constraints.biggest.width * 0.5);
      double imgHeight = min(270, constraints.biggest.height * 0.5);
      Widget img = const Image(
        image: AssetImage("res/img/chaldea.png"),
        filterQuality: FilterQuality.high,
      );
      if (Utility.isDarkMode(context)) {
        // assume r=g=b
        int b = Theme.of(context).scaffoldBackgroundColor.intBlue;
        double v = (255 - b) / 255;
        if (!kIsWeb) {
          img = ColorFiltered(
            colorFilter: ColorFilter.matrix([
              //R G  B  A  Const
              -v, 0, 0, 0, 255,
              0, -v, 0, 0, 255,
              0, 0, -v, 0, 255,
              0, 0, 0, 0.8, 0,
            ]),
            child: img,
          );
        }
      }
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: imgWidth,
                  maxHeight: imgHeight,
                ),
                child: img,
              ),
              if (showIndicator) indicatorBuilder(context),
            ],
          ),
        ),
      );
    });
  }
}
