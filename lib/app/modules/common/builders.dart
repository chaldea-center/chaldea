import 'package:chaldea/app/modules/item/item_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedBuilder {
  SharedBuilder._();

  static Widget groupItems({
    required BuildContext context,
    required Map<int, int> items,
    String? header,
    String? footer,
    bool showCategoryName = false,
    double? width,
    double? height,
    ValueChanged<int>? onTap,
  }) {
    List<Widget> children = [];
    for (final group in Item.groupItems(items).entries) {
      if (group.value.isEmpty) continue;
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: itemGrid(
          context: context,
          items: group.value.entries,
          width: width,
          height: height,
          onTap: onTap,
        ),
      ));
    }
    return TileGroup(
      header: header,
      footer: footer,
      children: children,
    );
  }

  static Widget itemGrid({
    required BuildContext context,
    required Iterable<MapEntry<int, int>> items,
    double? width,
    double? height,
    ValueChanged<int>? onTap,
  }) {
    if (width == null && height == null) {
      width = 48;
    }
    return Wrap(
      spacing: 1,
      runSpacing: 1,
      children: [
        for (final entry in items)
          if (entry.value != 0)
            GameCardMixin.anyCardItemBuilder(
              context: context,
              id: entry.key,
              text: entry.value.format(),
              height: height,
              width: width,
              onTap: onTap == null ? null : () => onTap(entry.key),
            ),
      ],
    );
  }

  static Widget giftGrid({
    required BuildContext context,
    required Iterable<Gift> gifts,
    double? width,
    double? height,
  }) {
    return Wrap(
      spacing: 1,
      runSpacing: 1,
      children: [
        for (final gift in gifts)
          gift.iconBuilder(
            context: context,
            width: width ?? 36,
            height: height,
          ),
      ],
    );
  }

  static List<PopupMenuItem<T>> websitesPopupMenuItems<T>({
    String? atlas,
    String? mooncell,
    String? fandom,
  }) {
    return [
      if (atlas != null)
        PopupMenuItem<T>(
          child: Text(S.current.jump_to('Atlas')),
          onTap: () {
            launch(atlas);
          },
        ),
      if (mooncell != null)
        PopupMenuItem<T>(
          child: Text(S.current.jump_to('Mooncell')),
          onTap: () {
            launch(WikiTool.mcFullLink(mooncell));
          },
        ),
      if (fandom != null)
        PopupMenuItem<T>(
          child: Text(S.current.jump_to('Fandom')),
          onTap: () {
            launch(WikiTool.fandomFullLink(fandom));
          },
        ),
    ];
  }

  static List<PopupMenuItem<T>> noticeLinkPopupMenuItems<T>({
    required MappingBase<String> noticeLink,
  }) {
    if (noticeLink.cn != null) {
      assert(int.parse(noticeLink.cn!) > 0);
    }
    return [
      if (noticeLink.jp != null)
        PopupMenuItem<T>(
          child: const Text('JP Notice'),
          onTap: () {
            launch(noticeLink.jp!);
          },
        ),
      if (noticeLink.cn != null)
        PopupMenuItem<T>(
          child: const Text('CN Notice'),
          onTap: () {
            final url = PlatformU.isTargetMobile
                ? 'https://game.bilibili.com/fgo/h5/news.html#detailId=${noticeLink.cn}'
                : 'https://game.bilibili.com/fgo/news.html#!news/0/1/${noticeLink.cn}';
            launch(url);
          },
        ),
      if (noticeLink.na != null)
        PopupMenuItem<T>(
          child: const Text('NA Notice'),
          onTap: () {
            launch(noticeLink.na!);
          },
        ),
      if (noticeLink.tw != null)
        PopupMenuItem<T>(
          child: const Text('TW Notice'),
          onTap: () {
            launch(noticeLink.tw!);
          },
        ),
      if (noticeLink.kr != null)
        PopupMenuItem<T>(
          child: const Text('KR Notice'),
          onTap: () {
            launch(noticeLink.kr!);
          },
        ),
    ];
  }

  static Future showSwitchPlanDialog(
      {required BuildContext context, ValueChanged<int>? onChange}) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(S.current.select_plan),
        children: List.generate(db2.curUser.svtPlanGroups.length, (index) {
          return ListTile(
            title: Text(db2.curUser.getFriendlyPlanName(index)),
            selected: index == db2.curUser.curSvtPlanNo,
            onTap: () {
              Navigator.of(context).pop();
              if (onChange != null) {
                onChange(index);
              }
            },
          );
        }),
      ),
    );
  }

  static Widget buildSwitchPlanButton(
      {required BuildContext context, ValueChanged<int>? onChange}) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        showSwitchPlanDialog(context: context, onChange: onChange);
      },
      tooltip: '${S.current.plan_title} ${db2.curUser.curSvtPlanNo + 1}',
      icon: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            const Icon(Icons.list),
            ImageWithText.paintOutline(
              text: (db2.curUser.curSvtPlanNo + 1).toString(),
              shadowSize: 5,
              shadowColor: colorScheme.brightness == Brightness.light
                  ? colorScheme.primary
                  : colorScheme.surface,
            )
          ],
        ),
      ),
    );
  }

  static Widget priorityIcon({required BuildContext context}) {
    return db2.onUserData(
      (context, _) => IconButton(
        icon: Icon(
          Icons.low_priority,
          color: db2.settings.svtFilterData.priority.isEmpty([1, 2, 3, 4, 5])
              ? null
              : Colors.yellowAccent,
        ),
        tooltip: S.of(context).priority,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ItemFilterDialog(),
          );
        },
      ),
    );
  }
}
