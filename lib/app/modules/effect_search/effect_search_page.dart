import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'filter.dart';

class EffectSearchPage extends StatefulWidget {
  EffectSearchPage({Key? key}) : super(key: key);

  @override
  _EffectSearchPageState createState() => _EffectSearchPageState();
}

class _EffectSearchPageState extends State<EffectSearchPage>
    with
        SearchableListState<GameCardMixin, EffectSearchPage>,
        SingleTickerProviderStateMixin {
  late TabController _tabController;
  final filterData = BuffFuncFilterData();

  @override
  Iterable<GameCardMixin> get wholeData {
    if (_tabController.index == 0) {
      return db.gameData.servants.values;
    } else if (_tabController.index == 1) {
      return db.gameData.craftEssences.values;
    } else {
      return db.gameData.commandCodes.values;
    }
  }

  @override
  void initState() {
    super.initState();
    options = _BuffOptions(onChanged: (_) {
      if (mounted) setState(() {});
    });
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        (options as _BuffOptions).type =
            SearchCardType.values.getOrNull(_tabController.index) ??
                SearchCardType.svt;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => a.collectionNo - b.collectionNo);
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        titleSpacing: 0,
        title: Text(S.current.effect_search),
        actions: [
          SharedBuilder.docsHelpBtn('buff_filter.html'),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => BuffFuncFilter(
                filterData: filterData,
                type: (options as _BuffOptions).type,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
        bottom: showSearchBar ? searchBar : tabBar,
      ),
    );
  }

  PreferredSizeWidget get tabBar => FixedHeight.tabBar(TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: S.current.servant),
          Tab(text: S.current.craft_essence),
          Tab(text: S.current.command_code),
        ],
      ));

  @override
  bool filter(GameCardMixin card) {
    List<NiceFunction> functions = [];
    if (!filterData.rarity.matchOne(card.rarity)) {
      return false;
    }

    final region = filterData.region.radioValue;
    if (region != null && region != Region.jp) {
      MappingList<int>? release;
      if (card is Servant) {
        release = db.gameData.mappingData.svtRelease;
      } else if (card is CraftEssence) {
        release = db.gameData.mappingData.ceRelease;
      } else if (card is CommandCode) {
        release = db.gameData.mappingData.ccRelease;
      }
      if (release?.ofRegion(region)?.contains(card.collectionNo) != true) {
        return false;
      }
    }
    if (card is Servant) {
      if (!filterData.svtClass.matchOne(card.className, compares: {
        SvtClass.caster: (v, o) =>
            v == SvtClass.caster || v == SvtClass.grandCaster,
        SvtClass.beastII: (v, o) => SvtClassX.beasts.contains(v),
      })) {
        return false;
      }
    }

    if (card is Servant) {
      bool _isScopeEmpty = filterData.effectScope.options.isEmpty;
      functions = [
        if (_isScopeEmpty ||
            filterData.effectScope.options.contains(SvtEffectScope.active))
          for (final skill in card.skills)
            ...skill.filteredFunction(includeTrigger: true),
        if (_isScopeEmpty ||
            filterData.effectScope.options.contains(SvtEffectScope.td))
          for (final np in card.noblePhantasms)
            ...np.filteredFunction(includeTrigger: true),
        if (_isScopeEmpty ||
            filterData.effectScope.options.contains(SvtEffectScope.append))
          for (final skill in card.appendPassive)
            ...skill.skill.filteredFunction(includeTrigger: true),
        if (_isScopeEmpty ||
            filterData.effectScope.options.contains(SvtEffectScope.passive))
          for (final skill in card.classPassive)
            ...skill.filteredFunction(includeTrigger: true),
      ];
    } else if (card is CraftEssence) {
      functions = [
        for (final skill in card.skills)
          ...skill.filteredFunction(includeTrigger: true),
      ];
    } else if (card is CommandCode) {
      functions = [
        for (final skill in card.skills)
          ...skill.filteredFunction(includeTrigger: true),
      ];
    }
    functions.retainWhere((func) => filterData.effectTarget
            .matchOne(func.funcTargetType, compares: {
          null: (value, option) =>
              BuffFuncFilterData.specialFuncTarget.contains(value)
        }));
    if (filterData.targetTrait.options.isNotEmpty) {
      final traits = filterData.targetTrait.options;
      functions.retainWhere((func) {
        if (func.functvals.any((e) => traits.contains(e.id)) ||
            func.traitVals.any((e) => traits.contains(e.id))) return true;
        for (final buff in func.buffs) {
          if (buff.ckSelfIndv.any((e) => traits.contains(e.id)) ||
              buff.ckOpIndv.any((e) => traits.contains(e.id))) {
            return true;
          }
        }
        return false;
      });
    }
    if (functions.isEmpty) return false;

    Set<FuncType> funcTypes = {
      for (final func in functions) func.funcType,
    };
    Set<BuffType> buffTypes = {
      for (final func in functions)
        for (final buff in func.buffs) buff.type,
    };
    if (!FilterGroupData<dynamic>(
        matchAll: filterData.funcAndBuff.matchAll,
        invert: filterData.funcAndBuff.invert,
        options: {
          ...filterData.funcType.options,
          ...filterData.buffType.options,
        }).matchAny({...funcTypes, ...buffTypes})) {
      return false;
    }
    return true;
  }

  @override
  Widget gridItemBuilder(GameCardMixin card) {
    return card.iconBuilder(
      context: context,
      padding: const EdgeInsets.all(2),
      jumpToDetail: true,
    );
  }

  @override
  Widget listItemBuilder(GameCardMixin card) {
    return ListTile(
      leading: card.iconBuilder(context: context, height: 48),
      visualDensity: VisualDensity.compact,
      title: AutoSizeText(
        card.lName.l,
        maxLines: 2,
        maxFontSize: 14,
        minFontSize: 8,
      ),
      subtitle: Text('No.${card.collectionNo}'),
      onTap: () {
        card.routeTo();
      },
    );
  }
}

class _BuffOptions with SearchOptionsMixin<GameCardMixin> {
  bool svtActiveSkill = true;
  bool svtNoblePhantasm = true;
  bool svtClassPassive = false;
  bool svtAppendSkill = false;
  SearchCardType type = SearchCardType.svt;
  @override
  ValueChanged? onChanged;

  _BuffOptions({this.onChanged});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: svtActiveSkill,
          label: Text(S.current.active_skill),
          onChanged: (v) {
            svtActiveSkill = v ?? svtActiveSkill;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: svtNoblePhantasm,
          label: Text(S.current.noble_phantasm),
          onChanged: (v) {
            svtNoblePhantasm = v ?? svtNoblePhantasm;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: svtClassPassive,
          label: Text(S.current.passive_skill),
          onChanged: (v) {
            svtClassPassive = v ?? svtClassPassive;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  @override
  Iterable<String?> getSummary(GameCardMixin card) sync* {
    if (type == SearchCardType.svt && card is Servant) {
      if (svtActiveSkill) {
        for (final skill in card.skills) {
          yield* getSkillKeys(skill);
        }
      }
      if (svtNoblePhantasm) {
        for (final skill in card.noblePhantasms) {
          yield* getSkillKeys(skill);
        }
      }
      if (svtClassPassive) {
        for (final skill in card.classPassive) {
          yield* getSkillKeys(skill);
        }
      }
      if (svtAppendSkill) {
        for (final skill in card.appendPassive) {
          yield* getSkillKeys(skill.skill);
        }
      }
    } else if (type == SearchCardType.ce && card is CraftEssence) {
      for (final skill in card.skills) {
        yield* getSkillKeys(skill);
      }
    } else if (type == SearchCardType.cc && card is CommandCode) {
      for (final skill in card.skills) {
        yield* getSkillKeys(skill);
      }
    }
  }
}
