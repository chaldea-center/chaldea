import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import '../../widgets/widget_builders.dart';
import '../modules/common/builders.dart';

class SvtClassWidget extends StatelessWidget {
  final int classId;
  final int? rarity;

  const SvtClassWidget({super.key, required this.classId, this.rarity});

  static TextSpan rich({required BuildContext context, required int classId, int? rarity}) {
    void onTap() => router.push(url: Routes.svtClassI(classId));
    return TextSpan(
      children: [
        CenterWidgetSpan(
          child: db.getIconImage(SvtClassX.clsIcon(classId, rarity ?? 5), width: 20, aspectRatio: 1, onTap: onTap),
        ),
        SharedBuilder.textButtonSpan(context: context, text: ' ${Transl.svtClassId(classId).l}', onTap: onTap),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      rich(context: context, classId: classId, rarity: rarity),
      textAlign: TextAlign.center,
    );
  }
}
