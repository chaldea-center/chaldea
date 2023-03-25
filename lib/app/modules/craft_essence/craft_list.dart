import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../tools/gamedata_loader.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';
import 'craft.dart';
import 'filter.dart';

class CraftListPage extends StatefulWidget {
  final CraftFilterData? filterData;
  final void Function(CraftEssence ce)? onSelected;

  CraftListPage({super.key, this.onSelected, this.filterData});

  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState extends State<CraftListPage> with SearchableListState<CraftEssence, CraftListPage> {
  @override
  Iterable<CraftEssence> get wholeData => db.gameData.craftEssences.values;

  CraftFilterData get filterData => widget.filterData ?? db.settings.craftFilterData;

  @override
  final bool prototypeExtent = true;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter && widget.filterData == null) {
      filterData.reset();
    }
    options = _CraftSearchOptions(onChanged: (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CraftFilterData.compare(a, b, keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.craft_essence, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CraftFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    return RefreshIndicator(
      child: super.buildScrollable(useGrid: useGrid),
      onRefresh: () async {
        await GameDataLoader.instance.reloadAndUpdate();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget listItemBuilder(CraftEssence ce) {
    String additionalText = '';
    switch (filterData.sortKeys.first) {
      case CraftCompare.atk:
        additionalText = '  ATK ${ce.atkMax}';
        break;
      case CraftCompare.hp:
        additionalText = '  HP ${ce.hpMax}';
        break;
      default:
        break;
    }
    String? status;
    if (ce.status.status == CraftStatus.owned) {
      status = '${ce.status.limitCount} - Lv.${ce.status.lv}';
    }
    return CustomTile(
      leading: db.getIconImage(
        ce.borderedIcon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(ce.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(ce.name, maxLines: 1),
          Row(
            children: [Expanded(child: Text('No.${ce.collectionNo}$additionalText')), if (status != null) Text(status)],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(ce, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == ce,
      onTap: () => _onTapCard(ce),
    );
  }

  @override
  Widget gridItemBuilder(CraftEssence ce) {
    String? status;
    if (ce.status.status == CraftStatus.owned) {
      // status = '${ce.status.limitCount}-${ce.status.lv}';
    }
    return ce.iconBuilder(
      context: context,
      width: 72,
      text: status,
      onTap: () => _onTapCard(ce),
    );
  }

  @override
  bool filter(CraftEssence ce) {
    if (!filterData.rarity.matchOne(ce.rarity)) {
      return false;
    }
    final region = filterData.region.radioValue;
    if (region != null && region != Region.jp) {
      final released = db.gameData.mappingData.ceRelease.ofRegion(region);
      if (released?.contains(ce.collectionNo) == false) {
        return false;
      }
    }
    if (!filterData.obtain.matchOne(ce.obtain)) {
      return false;
    }
    if (!filterData.atkType.matchOne(ce.atkType)) {
      return false;
    }
    if (!filterData.limitCount.matchOne(ce.status.limitCount)) {
      return false;
    }
    if (!filterData.status.matchOne(ce.status.status)) {
      return false;
    }

    if (filterData.effectType.isNotEmpty || filterData.targetTrait.isNotEmpty || filterData.effectTarget.isNotEmpty) {
      List<BaseFunction> funcs = [
        for (final skill in ce.skills) ...skill.filteredFunction(includeTrigger: true),
      ];
      if (filterData.effectTarget.options.isNotEmpty) {
        funcs.retainWhere((func) {
          return filterData.effectTarget.matchOne(EffectTarget.fromFunc(func.funcTargetType));
        });
      }
      if (filterData.targetTrait.isNotEmpty) {
        funcs.retainWhere((func) => EffectFilterUtil.checkFuncTraits(func, filterData.targetTrait));
      }
      if (funcs.isEmpty) return false;
      if (filterData.effectType.options.isEmpty) return true;
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

  void _onTapCard(CraftEssence ce, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      Navigator.pop(context);
      widget.onSelected!(ce);
    } else {
      router.popDetailAndPush(
        context: context,
        url: ce.route,
        child: CraftDetailPage(
          ce: ce,
          onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
        ),
        detail: true,
      );
      selected = ce;
    }
    setState(() {});
  }
}

class _CraftSearchOptions with SearchOptionsMixin<CraftEssence> {
  bool basic = true;
  bool skill = true;
  @override
  ValueChanged? onChanged;

  _CraftSearchOptions({this.onChanged});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: basic,
          label: Text(S.current.search_option_basic),
          onChanged: (v) {
            basic = v ?? basic;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: skill,
          label: Text(S.current.skill),
          onChanged: (v) {
            skill = v ?? skill;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  @override
  Iterable<String?> getSummary(CraftEssence ce) sync* {
    if (basic) {
      yield ce.collectionNo.toString();
      yield ce.id.toString();
      yield* getAllKeys(ce.lName);
      yield SearchUtil.getJP(ce.ruby);
      yield* getAllKeys(Transl.cvNames(ce.profile.cv));
      yield* getAllKeys(Transl.illustratorNames(ce.profile.illustrator));
      for (final svtId in [ce.bondEquipOwner, ce.valentineEquipOwner, ...ce.extra.characters]) {
        final svt = db.gameData.servantsById[svtId] ?? db.gameData.servantsWithDup[svtId];
        if (svt == null) continue;
        for (final name in svt.allNames) {
          yield* getAllKeys(Transl.svtNames(name));
        }
      }
      for (final name in ce.extra.unknownCharacters) {
        yield* getAllKeys(Transl.charaNames(name));
      }
    }
    if (skill) {
      for (final skill in ce.skills) {
        yield* getSkillKeys(skill);
      }
    }
  }
}
