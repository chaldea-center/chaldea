import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:chaldea/app/modules/item/item_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/img_util.dart';
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
      builder: (context) {
        return db.onUserData((context, snapshot) {
          return SimpleDialog(
            title: Text(S.current.select_plan),
            children: [
              CheckboxListTile(
                value: db.curUser.sameEventPlan,
                title: Text(S.current.same_event_plan),
                onChanged: (v) {
                  if (v != null) db.curUser.sameEventPlan = v;
                  db.itemCenter.calculate();
                },
              ),
              for (int index = 0; index < db.curUser.plans.length; index++)
                ListTile(
                  title: Text(db.curUser.getFriendlyPlanName(index)),
                  subtitle: db.curUser.sameEventPlan && index == 0
                      ? Text(S.current.event_title)
                      : null,
                  selected: index == db.curUser.curSvtPlanNo,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (onChange != null) {
                      onChange(index);
                    }
                  },
                )
            ],
          );
        });
      },
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

  static TextSpan textButtonSpan({
    required BuildContext context,
    required String text,
    List<InlineSpan>? children,
    TextStyle? style,
    VoidCallback? onTap,
    GestureRecognizer? recognizer,
  }) {
    return TextSpan(
      text: text,
      children: children,
      style: style ??
          TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withAlpha(200)),
      recognizer: recognizer ??
          (onTap == null ? null : (TapGestureRecognizer()..onTap = onTap)),
    );
  }

  static Widget trait({
    required BuildContext context,
    required NiceTrait trait,
    TextStyle? style,
    double? textScaleFactor,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Text(
          trait.showName,
          style: style ??
              TextStyle(color: Theme.of(context).colorScheme.secondary),
          textScaleFactor: textScaleFactor,
        ),
      ),
    );
  }

  static Widget traitList({
    required BuildContext context,
    required List<NiceTrait> traits,
    TextStyle? style,
    double? textScaleFactor,
    List<int>? hiddenTraits,
    WrapAlignment alignment = WrapAlignment.center,
  }) {
    hiddenTraits ??= []; // [Trait.canBeInBattle.id!];
    traits = List.of(traits)
      ..removeWhere((t) => t.negative != true && hiddenTraits!.contains(t.id));
    List<Widget> children = traits
        .map((e) => trait(
              context: context,
              trait: e,
              style: style,
              textScaleFactor: textScaleFactor,
            ))
        .toList();
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
    double? textScaleFactor,
    List<int>? hiddenTraits,
  }) {
    hiddenTraits ??= []; //[Trait.canBeInBattle.id!];
    traits = List.of(traits)
      ..removeWhere((t) => t.negative != true && hiddenTraits!.contains(t.id));
    List<InlineSpan> children = divideList(
      traits.map((e) => CenterWidgetSpan(
              child: trait(
            context: context,
            trait: e,
            style: style,
            textScaleFactor: textScaleFactor,
          ))),
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

  static Widget topSvtClassFilter({
    required BuildContext context,
    required double maxWidth,
    required FilterGroupData<SvtClass> data,
    VoidCallback? onChanged,
  }) {
    Widget _oneClsBtn(SvtClass clsName) {
      final extraClasses = [...SvtClassX.extra, SvtClass.beastII];
      int rarity = 1;
      if (clsName == SvtClass.ALL) {
        rarity = data.isEmpty(SvtClassX.regularAllWithB2) ||
                data.isAll(SvtClassX.regularAllWithB2)
            ? 5
            : 1;
      } else if (clsName == SvtClass.EXTRA) {
        if (data.isAll(extraClasses)) {
          rarity = 5;
        } else if (data.isEmpty(extraClasses)) {
          rarity = 1;
        } else {
          rarity = 3;
        }
      } else {
        rarity = data.options.contains(clsName) ? 5 : 1;
      }
      Widget icon = db.getIconImage(
        clsName.icon(rarity),
        aspectRatio: 1,
        width: 32,
      );
      if (rarity != 5 && clsName == SvtClass.beastII) {
        icon = ColorFiltered(
          colorFilter: ImageUtil.greyscalBeast,
          child: icon,
        );
        // icon = Opacity(opacity: 0.7, child: icon);
      }
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: icon,
        ),
        onTap: () {
          if (clsName == SvtClass.ALL) {
            data.options = {};
          } else if (clsName == SvtClass.EXTRA) {
            data.options = Set.from(extraClasses);
          } else {
            data.options = {clsName};
          }
          onChanged?.call();
        },
      );
    }

    final clsRegularBtns = [
      _oneClsBtn(SvtClass.ALL),
      for (var clsName in SvtClassX.regular) _oneClsBtn(clsName),
    ];
    final clsExtraBtns = [
      for (var clsName in [...SvtClassX.extra, SvtClass.beastII])
        _oneClsBtn(clsName),
    ];
    final extraBtn = _oneClsBtn(SvtClass.EXTRA);
    SvtListClassFilterStyle style = db.settings.display.classFilterStyle;
    // full window mode
    if (SplitRoute.isSplit(context) && SplitRoute.of(context)!.detail == null) {
      style = SvtListClassFilterStyle.singleRowExpanded;
    }
    if (style == SvtListClassFilterStyle.auto) {
      double height = MediaQuery.of(context).size.height;
      if (height < 600) {
        // one row
        if (maxWidth < 32 * 10) {
          // fixed
          style = SvtListClassFilterStyle.singleRow;
        } else {
          // expand, scrollable
          style = SvtListClassFilterStyle.singleRowExpanded;
        }
      } else {
        // two rows ok
        if (maxWidth < 32 * 10) {
          // two row
          style = SvtListClassFilterStyle.twoRow;
        } else {
          // expand, scrollable
          style = SvtListClassFilterStyle.singleRowExpanded;
        }
      }
    }
    switch (style) {
      case SvtListClassFilterStyle.auto: // already resolved
        return Container();
      case SvtListClassFilterStyle.singleRow:
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [...clsRegularBtns, extraBtn]
                .map((e) => Expanded(child: e))
                .toList(),
          ),
        );
      case SvtListClassFilterStyle.singleRowExpanded:
        final allBtns = [...clsRegularBtns, ...clsExtraBtns];
        return SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: allBtns,
                ),
              ),
              if (maxWidth < 36 * allBtns.length)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: Icon(
                    DirectionalIcons.keyboard_arrow_forward(context),
                    color: Theme.of(context).disabledColor,
                  ),
                ),
            ],
          ),
        );
      case SvtListClassFilterStyle.twoRow:
        int crossCount = max(clsRegularBtns.length, clsExtraBtns.length);
        clsRegularBtns.addAll(List.generate(
            crossCount - clsRegularBtns.length, (index) => Container()));
        clsExtraBtns.addAll(List.generate(
            crossCount - clsExtraBtns.length, (index) => Container()));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final btns in [clsRegularBtns, clsExtraBtns])
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: btns.map((e) => Expanded(child: e)).toList(),
                ),
              ),
          ],
        );
      case SvtListClassFilterStyle.doNotShow:
        return const SizedBox();
    }
  }
}
