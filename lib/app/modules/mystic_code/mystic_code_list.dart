import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/searchable_list_state.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';
import 'filter.dart';
import 'mystic_code.dart';

class MysticCodeListPage extends StatefulWidget {
  final void Function(MysticCode)? onSelected;
  final MysticCodeFilterData? filterData;

  MysticCodeListPage({super.key, this.onSelected, this.filterData});

  @override
  State<StatefulWidget> createState() => MysticCodeListPageState();
}

class MysticCodeListPageState extends State<MysticCodeListPage>
    with SearchableListState<MysticCode, MysticCodeListPage> {
  @override
  Iterable<MysticCode> get wholeData => db.gameData.mysticCodes.values;

  MysticCodeFilterData get filterData => widget.filterData ?? db.settings.filters.mysticCodeFilterData;

  @override
  final bool prototypeExtent = true;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter && widget.filterData == null) {
      filterData.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) {
        return filterData.ascending ? a.id - b.id : b.id - a.id;
      },
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.mystic_code, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            onPressed: () => setState(() => db.curUser.isGirl = !db.curUser.isGirl),
            icon: FaIcon(db.curUser.isGirl ? FontAwesomeIcons.venus : FontAwesomeIcons.mars, size: 20),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed:
                () => FilterPage.show(
                  context: context,
                  builder:
                      (context) => MysticCodeFilterPage(
                        filterData: filterData,
                        onChanged: (_) {
                          if (mounted) setState(() {});
                        },
                      ),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(MysticCode mc) {
    return CustomTile(
      leading: db.getIconImage(mc.icon, width: 56, aspectRatio: 132 / 144),
      title: AutoSizeText(mc.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [if (!Language.isJP) AutoSizeText(mc.name, maxLines: 1), Text('No.${mc.id}')],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(mc, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == mc,
      onTap: () => _onTapCard(mc),
    );
  }

  @override
  Widget gridItemBuilder(MysticCode mc) {
    return InkWell(onTap: () => _onTapCard(mc), onLongPress: mc.routeTo, child: db.getIconImage(mc.borderedIcon));
  }

  @override
  bool filter(MysticCode mc) {
    final region = filterData.region.radioValue;
    if (region != null && region != Region.jp) {
      final released = db.gameData.mappingData.mcRelease.ofRegion(region);
      if (released?.contains(mc.id) == false) {
        return false;
      }
    }

    if (filterData.effectType.isNotEmpty || filterData.effectTarget.isNotEmpty || filterData.targetTrait.isNotEmpty) {
      List<BaseFunction> funcs = [for (final skill in mc.skills) ...skill.filteredFunction(includeTrigger: true)];
      if (filterData.effectTarget.isNotEmpty) {
        funcs.retainWhere((func) {
          return filterData.effectTarget.matchOne(EffectTarget.fromFunc(func.funcTargetType));
        });
      }
      if (filterData.targetTrait.isNotEmpty) {
        funcs.retainWhere((func) => EffectFilterUtil.checkFuncTraits(func, filterData.targetTrait));
      }
      if (funcs.isEmpty) return false;
      if (filterData.effectType.isEmpty) return true;
      if (filterData.effectType.matchAll) {
        if (!filterData.effectType.options.every((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      } else {
        if (!filterData.effectType.options.any((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      }
    }
    return true;
  }

  void _onTapCard(MysticCode mc, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      Navigator.pop(context);
      widget.onSelected!(mc);
    } else {
      router.popDetailAndPush(context: context, url: mc.route, child: MysticCodePage(id: mc.id), detail: true);
      selected = mc;
    }
    setState(() {});
  }
}
