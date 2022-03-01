import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../app/modules/command_code/cmd_code.dart';
import '../../app/modules/craft_essence/craft.dart';
import '../../app/modules/servant/servant.dart';

mixin GameCardMixin {
  int get id;

  int get collectionNo;

  int get rarity;

  // String get mcLink;

  String? get icon;

  String? get borderedIcon => bordered(icon);

  String? bordered(String? icon) {
    if (icon == null) return null;
    if (icon.contains('bordered.png')) return icon;
    return icon.replaceAll('.png', '_bordered.png');
  }

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
    String? overrideIcon,
  }) {
    if (onTap == null && jumpToDetail) {
      if (this is Servant) {
        final instance = this as Servant;
        onTap = () => router.push(
            url: instance.route,
            child: ServantDetailPage(svt: instance),
            detail: true);
      } else if (this is CraftEssence) {
        final instance = this as CraftEssence;
        onTap = () => router.push(
            url: instance.route,
            child: CraftDetailPage(ce: instance),
            detail: true);
      } else if (this is CommandCode) {
        final instance = this as CommandCode;
        onTap = () => router.push(
            url: instance.route,
            child: CmdCodeDetailPage(cc: instance),
            detail: true);
      } else if (this is BasicServant) {
        //
      }
    }
    return cardIconBuilder(
      context: context,
      icon: overrideIcon ?? borderedIcon,
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
    final size = Maths.fitSize(width, height, aspectRatio);
    textPadding ??= size == null
        ? EdgeInsets.zero
        : EdgeInsets.only(right: size.value / 22, bottom: size.value / 12);
    Widget child = ImageWithText(
      image: db2.getIconImage(
        icon,
        aspectRatio: aspectRatio,
        width: width,
        height: height,
        padding: padding,
      ),
      text: text,
      width: size?.key,
      height: size?.value,
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

  static Widget anyCardItemBuilder({
    required BuildContext context,
    required int id,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
  }) {
    return anyCardItem(
      id: id,
      onItem: (item) => Item.iconBuilder(
        context: context,
        item: item,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
      ),
      onSvt: (svt) => svt.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
      ),
      onCE: (ce) => ce.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
      ),
      onCC: (cc) => cc.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
      ),
      onBasicSvt: (svt) => svt.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
      ),
      onCostume: (svt, costume) => svt.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        overrideIcon: costume.icon,
      ),
      onDefault: () {
        // costume get/unlock: id=svtId*100+costumeId
        final size = Maths.fitSize(width, height, aspectRatio);
        return ImageWithText(
          image: AutoSizeText(
            'ID $id',
            minFontSize: 6,
          ),
          width: size?.key,
          height: size?.value,
          text: text,
          padding: padding ?? EdgeInsets.zero,
          onTap: onTap,
        );
      },
    );
  }

  static Transl<String, String> anyCardItemName(int id) {
    return anyCardItem(
      id: id,
      onItem: (obj) => obj.lName,
      onSvt: (obj) => obj.lName,
      onCE: (obj) => obj.lName,
      onCC: (obj) => obj.lName,
      onBasicSvt: (obj) => obj.lName,
      onCostume: (svt, costume) => costume.lName,
      onDefault: () => Transl({}, 'No.$id', 'No.$id'),
    );
  }

  static T anyCardItem<T>({
    required int id,
    required T? Function(Item item)? onItem,
    required T? Function(Servant svt)? onSvt,
    required T? Function(CraftEssence ce)? onCE,
    required T? Function(CommandCode svt)? onCC,
    required T? Function(BasicServant basicSvt)? onBasicSvt,
    required T? Function(Servant svt, NiceCostume costume)? onCostume,
    required T Function() onDefault,
  }) {
    T? result;
    final gamedata = db2.gameData;
    if (gamedata.items.containsKey(id)) {
      result = onItem?.call(gamedata.items[id]!);
    } else if (gamedata.servantsById.containsKey(id)) {
      result = onSvt?.call(gamedata.servantsById[id]!);
    } else if (gamedata.craftEssencesById.containsKey(id)) {
      result = onCE?.call(gamedata.craftEssencesById[id]!);
    } else if (gamedata.commandCodesById.containsKey(id)) {
      result = onCC?.call(gamedata.commandCodesById[id]!);
    } else if (gamedata.entities.containsKey(id)) {
      result = onBasicSvt?.call(gamedata.entities[id]!);
    } else {
      int svtId = id ~/ 100, costumeId = id % 100;
      final svt = gamedata.servantsById[svtId];
      final costume = svt?.profile?.costume.values
          .firstWhereOrNull((e) => e.id == costumeId);
      if (svt != null && costume != null) {
        result = onCostume?.call(svt, costume);
      }
    }
    return result ?? onDefault();
  }
}
