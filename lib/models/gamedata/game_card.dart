import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../app/modules/craft_essence/craft.dart';
import '../../app/modules/servant/servant.dart';

mixin GameCardMixin {
  int get id;

  int get collectionNo;

  int get rarity;

  // String get mcLink;

  String? get icon;

  String? get borderedIcon => icon?.replaceFirst('.png', '_bordered.png');

  // String get lName;

  // Widget charactersToButtons(BuildContext context, List<String> characters) {
  //   if (characters.isEmpty) return const Text('-');
  //   List<Widget> children = [];
  //   for (final name in characters) {
  //     final svt =
  //         db2.gameData.servants.values.firstWhereOrNull((s) => s.mcLink == name);
  //     if (svt == null) {
  //       children.add(Text(name));
  //     } else {
  //       children.add(InkWell(
  //         child: Text(
  //           svt.info.localizedName,
  //           style: TextStyle(color: Theme.of(context).colorScheme.secondary),
  //         ),
  //         onTap: () => svt.pushDetail(context),
  //       ));
  //     }
  //   }
  //   children = divideTiles(children, divider: const Text('/'));
  //   return Wrap(
  //     spacing: 4,
  //     runSpacing: 4,
  //     alignment: WrapAlignment.center,
  //     runAlignment: WrapAlignment.center,
  //     crossAxisAlignment: WrapCrossAlignment.center,
  //     children: children,
  //   );
  // }

  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
  }) {
    if (onTap == null && jumpToDetail) {
      if (this is Servant) {
        final instance = this as Servant;
        onTap = () => router.push(
            url: instance.route, child: ServantDetailPage(svt: instance));
      } else if (this is CraftEssence) {
        final instance = this as CraftEssence;
        onTap = () => router.push(
            url: instance.route, child: CraftDetailPage(ce: instance));
      } else if (this is CommandCode) {
        // final instance = this as CommandCode;
        // onTap = () => router.push(
        //     url: instance.route, child: CraftDetailPage(ce: instance));
      }
    }
    return cardIconBuilder(
      context: context,
      icon: borderedIcon,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text,
      padding: padding,
      textPadding: textPadding,
      onTap: onTap,
    );
  }

  static Widget cardIconBuilder({
    required BuildContext context,
    required String? icon,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
  }) {
    if (textPadding == null) {
      final size = Maths.fitSize(width, height, aspectRatio);
      textPadding = size == null
          ? EdgeInsets.zero
          : EdgeInsets.only(right: size.value / 22, bottom: size.value / 12);
    }
    Widget child = ImageWithText(
      image: db2.getIconImage(
        icon,
        aspectRatio: aspectRatio,
        width: width,
        height: height,
        padding: padding,
      ),
      text: text,
      width: width,
      padding: textPadding,
    );
    if (onTap != null) {
      child = InkWell(
        child: child,
        onTap: onTap,
      );
    }
    return child;
  }

  Widget resolveDetailPage() {
    if (this is Servant) {
      return ServantDetailPage(svt: this as Servant);
    } else if (this is CraftEssence) {
      return CraftDetailPage(ce: this as CraftEssence);
      // } else if (this is CommandCode) {
      // return CmdCodeDetailPage(code: this as CommandCode);
    } else {
      throw TypeError();
    }
  }
}
