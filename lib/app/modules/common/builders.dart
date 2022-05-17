import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chaldea/app/modules/item/item_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/widgets.dart';

class SharedBuilder {
  SharedBuilder._();

  static Color? appBarForeground(BuildContext context) {
    final theme = Theme.of(context);
    return theme.appBarTheme.foregroundColor ??
        (theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onPrimary);
  }

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
    List<PopupMenuItem<T>> items = [];
    for (final region in Region.values) {
      final v = noticeLink.ofRegion(region);
      if (v != null) {
        items.add(PopupMenuItem<T>(
          child: Text(S.current.region_notice(region.localName)),
          onTap: () {
            if (region == Region.cn) {
              final url = PlatformU.isTargetMobile
                  ? 'https://game.bilibili.com/fgo/h5/news.html#detailId=$v'
                  : 'https://game.bilibili.com/fgo/news.html#!news/0/1/$v';
              launch(url);
            } else {
              launch(v);
            }
          },
        ));
      }
    }
    return items;
  }

  static Future showSwitchPlanDialog(
      {required BuildContext context, ValueChanged<int>? onChange}) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => SimpleDialog(
        title: Text(S.current.select_plan),
        children: List.generate(db.curUser.svtPlanGroups.length, (index) {
          return ListTile(
            title: Text(db.curUser.getFriendlyPlanName(index)),
            selected: index == db.curUser.curSvtPlanNo,
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
      tooltip: '${S.current.plan_title} ${db.curUser.curSvtPlanNo + 1}',
      icon: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            const Icon(Icons.list),
            ImageWithText.paintOutline(
              text: (db.curUser.curSvtPlanNo + 1).toString(),
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
    return db.onUserData(
      (context, _) => IconButton(
        icon: Icon(
          Icons.low_priority,
          color: db.settings.svtFilterData.priority.isEmpty([1, 2, 3, 4, 5])
              ? null
              : Colors.yellowAccent,
        ),
        tooltip: S.of(context).priority,
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => ItemFilterDialog(),
          );
        },
      ),
    );
  }

  static Widget trait({
    required BuildContext context,
    required NiceTrait trait,
    TextStyle? style,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Text(
          trait.showName,
          style: style ??
              TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  static Widget traitList({
    required BuildContext context,
    required List<NiceTrait> traits,
    TextStyle? style,
    List<int>? hiddenTraits,
    WrapAlignment alignment = WrapAlignment.center,
  }) {
    hiddenTraits ??= [Trait.canBeInBattle.id!];
    traits = List.of(traits)
      ..removeWhere((t) => t.negative != true && hiddenTraits!.contains(t.id));
    List<Widget> children =
        traits.map((e) => trait(context: context, trait: e)).toList();
    children = divideTiles(children, divider: const Text('/'));
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: alignment,
      children: children,
    );
  }

  static List<InlineSpan> traitSpans({
    required BuildContext context,
    required List<NiceTrait> traits,
    TextStyle? style,
    List<int>? hiddenTraits,
  }) {
    hiddenTraits ??= []; //[Trait.canBeInBattle.id!];
    traits = List.of(traits)
      ..removeWhere((t) => t.negative != true && hiddenTraits!.contains(t.id));
    List<InlineSpan> children = divideList(
      traits.map(
          (e) => CenterWidgetSpan(child: trait(context: context, trait: e))),
      TextSpan(text: '/', style: TextStyle(color: Theme.of(context).hintColor)),
    );
    return children;
  }

  static Future<FilePickerResult?> pickImageOrFiles({
    required BuildContext context,
    bool allowMultiple = true,
    bool withData = false,
  }) async {
    FileType? fileType;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => SimpleDialog(
        title: Text(S.current.import_image),
        contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 0.0, 16.0),
        children: [
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.photo_library),
            title: Text(S.current.attach_from_photos),
            onTap: () {
              fileType = FileType.image;
              Navigator.pop(context);
            },
          ),
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.file_copy),
            title: Text(S.current.attach_from_files),
            onTap: () {
              fileType = FileType.any;
              Navigator.pop(context);
            },
          ),
          SFooter(S.current.attach_help),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
    if (fileType == null) return null;
    return FilePicker.platform.pickFiles(
        type: fileType!, allowMultiple: allowMultiple, withData: withData);
  }
}
