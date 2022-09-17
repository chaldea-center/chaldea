import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app/modules/command_code/cmd_code.dart';
import '../../app/modules/craft_essence/craft.dart';
import '../../app/modules/servant/servant.dart';

mixin GameCardMixin implements RouteInfo {
  int get id;

  int get collectionNo;

  String get name;

  int get rarity;

  String? get icon;

  String? get borderedIcon => bordered(icon);

  String? bordered(String? icon) => makeBordered(icon);

  static String? makeBordered(String? icon) {
    if (icon == null) return icon;
    if (icon.contains('bordered')) return icon;
    return icon.replaceAll('.png', '_bordered.png');
  }

  static int bsgColor(int rarity) {
    return const {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 3}[rarity] ?? 3;
  }

  Transl<String, String> get lName;

  @override
  void routeTo({Widget? child, bool popDetails = false}) {
    router.popDetailAndPush(url: route, child: child, popDetail: popDetails);
  }

  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
    String? overrideIcon,
    String? name,
    bool showName = false,
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
        final instance = this as BasicServant;
        onTap = () => router.push(url: instance.routeIfItem);
      } else {
        onTap = () => routeTo();
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
      name: showName ? name ?? lName.l : null,
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
    String? name,
  }) {
    final size = Maths.fitSize(width, height, aspectRatio);
    textPadding ??= size == null
        ? EdgeInsets.zero
        : EdgeInsets.only(right: size.value / 22, bottom: size.value / 12);
    Widget child = ImageWithText(
      image: db.getIconImage(
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
    if (name != null) {
      child = Text.rich(TextSpan(children: [
        CenterWidgetSpan(child: child),
        TextSpan(text: ' $name ')
      ]));
    }
    if (onTap != null) {
      child = InkWell(
        onTap: onTap,
        child: child,
      );
    }
    return child;
  }

  Widget resolveDetailPage() {
    if (this is Servant) {
      return ServantDetailPage(svt: this as Servant);
    } else if (this is CraftEssence) {
      return CraftDetailPage(ce: this as CraftEssence);
    } else if (this is CommandCode) {
      return CmdCodeDetailPage(cc: this as CommandCode);
    } else {
      throw TypeError();
    }
  }

  static Widget anyCardItemBuilder({
    required BuildContext context,
    required int id,
    String? icon,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
    String? name,
    bool showName = false,
    Widget? Function()? onDefault,
  }) {
    return anyCardItem(
      id: id,
      onItem: (item) => Item.iconBuilder(
        context: context,
        item: item,
        icon: icon,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        name: name,
        showName: showName,
      ),
      onSvt: (svt) => svt.iconBuilder(
        context: context,
        overrideIcon: icon,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        name: name,
        showName: showName,
      ),
      onCE: (ce) => ce.iconBuilder(
        context: context,
        overrideIcon: icon,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        name: name,
        showName: showName,
      ),
      onCC: (cc) => cc.iconBuilder(
        context: context,
        overrideIcon: icon,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        name: name,
        showName: showName,
      ),
      onBasicSvt: (svt) => svt.iconBuilder(
        context: context,
        overrideIcon: icon,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap,
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        name: name,
        showName: showName,
      ),
      onCostume: (svt, costume) => svt.iconBuilder(
        context: context,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        text: text,
        padding: padding,
        textPadding: textPadding,
        onTap: onTap ?? () => router.push(url: costume.route),
        jumpToDetail: jumpToDetail,
        popDetail: popDetail,
        overrideIcon: icon ?? costume.icon,
        name: name ?? costume.lName.l,
        showName: showName,
      ),
      onDefault: () {
        if (onDefault != null) {
          final child = onDefault();
          if (child != null) return child;
        }
        if (id == Items.grailToCrystalId) {
          return Item.iconBuilder(
            context: context,
            item: db.gameData.items[Items.grail],
            icon: Atlas.assetItem(id),
            width: width,
            height: height,
            aspectRatio: aspectRatio,
            text: text,
            padding: padding,
            textPadding: textPadding,
            onTap: onTap,
            jumpToDetail: jumpToDetail,
            popDetail: popDetail,
            name: name,
            showName: showName,
          );
        }
        if (icon != null) {
          return cardIconBuilder(
            context: context,
            icon: icon,
            width: width,
            height: height,
            aspectRatio: aspectRatio,
            text: text,
            padding: padding,
            textPadding: textPadding,
            onTap: onTap,
            name: name,
          );
        }
        final size = Maths.fitSize(width, height, aspectRatio);
        return ImageWithText(
          image: SizedBox(
            width: size?.key,
            height: size?.value,
            child: AutoSizeText(
              'ID $id',
              minFontSize: 6,
            ),
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

  static String? getRoute(int id) {
    return anyCardItem(
      id: id,
      onItem: (obj) => Routes.itemI(obj.id),
      onSvt: (obj) => Routes.servantI(obj.id),
      onCE: (obj) => Routes.craftEssenceI(obj.id),
      onCC: (obj) => Routes.commandCodeI(obj.id),
      onBasicSvt: (obj) => Routes.servantI(obj.id),
      onCostume: (svt, costume) => Routes.costumeI(costume.costumeCollectionNo),
      onDefault: () => null,
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
    final gamedata = db.gameData;
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
      final costume = svt?.profile.costume.values
          .firstWhereOrNull((e) => e.id == costumeId);
      if (svt != null && costume != null) {
        result = onCostume?.call(svt, costume);
      }
    }
    return result ?? onDefault();
  }
}
