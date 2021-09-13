import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'buff_func_filter.dart';

class EffectSearchPage extends StatefulWidget {
  EffectSearchPage({Key? key}) : super(key: key);

  @override
  _EffectSearchPageState createState() => _EffectSearchPageState();
}

class _EffectSearchPageState
    extends SearchableListState<GameCardMixin, EffectSearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final filterData = BuffFuncFilterData();

  @override
  Iterable<GameCardMixin> get wholeData {
    if (_tabController.index == 0) {
      return db.gameData.servants.values;
    } else if (_tabController.index == 1) {
      return db.gameData.crafts.values;
    } else {
      return db.gameData.cmdCodes.values;
    }
  }

  @override
  void initState() {
    super.initState();
    options = _BuffOptions(onChanged: (_) => safeSetState());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        (options as _BuffOptions).type = _tabController.index == 0
            ? Servant
            : _tabController.index == 1
                ? CraftEssence
                : CommandCode;
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
    filterShownList();
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        titleSpacing: 0,
        title: Text(S.current.effect_search),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'effect_search.md'),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => BuffFuncFilter(
                filterData: filterData,
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

  TabBar get tabBar => TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: S.current.servant),
          Tab(text: S.current.craft_essence),
          Tab(text: S.current.command_code),
        ],
      );

  @override
  bool filter(GameCardMixin card) {
    List<NiceFunction> functions = [];
    if (card is Servant) {
      bool _isScopeEmpty =
          filterData.effectScope.isEmpty(SvtFilterData.buffScope);
      functions = [
        if (_isScopeEmpty || filterData.effectScope.options['0'] == true)
          for (final skill in card.niceSkills) ...skill.functions,
        if (_isScopeEmpty || filterData.effectScope.options['1'] == true)
          for (final np in card.niceNoblePhantasms) ...np.functions,
        if (_isScopeEmpty || filterData.effectScope.options['2'] == true)
          for (final skill in card.niceClassPassive) ...skill.functions,
      ];
    } else if (card is CraftEssence) {
      functions = [
        for (final skill in card.niceSkills) ...skill.functions,
      ];
    } else if (card is CommandCode) {
      functions = [
        for (final skill in card.niceSkills) ...skill.functions,
      ];
    }
    Set<String> funBuffTypes = {
      for (final func in functions) ...[
        func.funcType,
        for (final buff in func.buffs) buff.type,
      ],
    };
    if (!filterData.funcBuff.listValueFilter(funBuffTypes.toList())) {
      return false;
    }
    return true;
  }

  @override
  String getSummary(GameCardMixin card) {
    return options!.getSummary(card);
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
      leading: card.iconBuilder(context: context, width: 42),
      title: AutoSizeText(
        card.lName,
        maxLines: 2,
        maxFontSize: 14,
        minFontSize: 8,
      ),
      subtitle: Text('No.${card.no}'),
      onTap: () {
        SplitRoute.push(context, card.resolveDetailPage(), popDetail: true);
      },
    );
  }
}

class _BuffOptions with SearchOptionsMixin<GameCardMixin> {
  bool servantActiveSkill;
  bool servantNoblePhantasm;
  bool servantPassiveSkill;
  Type type;
  @override
  ValueChanged? onChanged;

  _BuffOptions({
    this.servantActiveSkill = true,
    this.servantNoblePhantasm = true,
    this.servantPassiveSkill = true,
    this.type = Servant,
    this.onChanged,
  });

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: servantActiveSkill,
          label: Text(S.current.active_skill),
          onChanged: (v) {
            servantActiveSkill = v ?? servantActiveSkill;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: servantNoblePhantasm,
          label: Text(S.current.noble_phantasm),
          onChanged: (v) {
            servantNoblePhantasm = v ?? servantNoblePhantasm;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: servantPassiveSkill,
          label: Text(S.current.passive_skill),
          onChanged: (v) {
            servantPassiveSkill = v ?? servantPassiveSkill;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  List<String?> _fromNiceSkills(List<NiceFunction> functions) {
    List<String?> _ss = [];
    for (final func in functions) {
      _ss.addAll([
        func.funcPopupText,
        for (final buff in func.buffs) ...[buff.name, buff.detail]
      ]);
    }
    return _ss;
  }

  @override
  String getSummary(GameCardMixin card) {
    StringBuffer buffer = StringBuffer();
    if (type == Servant && card is Servant) {
      if (servantActiveSkill) {
        buffer.write(getCache(card, 'active', () {
          List<String?> _ss = [];
          for (final skill in [
            for (var active in [...card.activeSkills, ...card.activeSkillsEn])
              ...active.skills
          ]) {
            for (final effect in skill.effects) {
              _ss.addAll([
                effect.description,
                effect.descriptionJp,
                effect.descriptionEn,
              ]);
            }
          }
          for (final skill in card.niceClassPassive) {
            _ss.addAll([skill.detail, ..._fromNiceSkills(skill.functions)]);
          }
          return _ss;
        }));
      }
      if (servantPassiveSkill) {
        buffer.write(getCache(card, 'passive', () {
          List<String?> _ss = [];
          for (final skill in [
            ...card.passiveSkills,
            ...card.passiveSkillsEn
          ]) {
            for (final effect in skill.effects) {
              _ss.addAll([
                effect.description,
                effect.descriptionJp,
                effect.descriptionEn,
              ]);
            }
          }
          for (final skill in card.niceClassPassive) {
            _ss.addAll([skill.detail, ..._fromNiceSkills(skill.functions)]);
          }
          return _ss;
        }));
      }
      if (servantNoblePhantasm) {
        buffer.write(getCache(card, 'np', () {
          List<String?> _ss = [];
          for (final np in [...card.noblePhantasm, ...card.noblePhantasmEn]) {
            for (final effect in np.effects) {
              _ss.addAll([
                effect.description,
                effect.descriptionJp,
                effect.descriptionEn,
              ]);
            }
          }
          for (final np in card.niceNoblePhantasms) {
            _ss.addAll([np.detail, ..._fromNiceSkills(np.functions)]);
          }
          return _ss;
        }));
      }
    } else if (type == CraftEssence && card is CraftEssence) {
      buffer.write(getCache(card, 'passive', () {
        return [
          card.skill,
          card.skillJp,
          card.skillEn,
          card.skillMax,
          card.skillMaxJp,
          card.skillMaxEn,
          for (final skill in card.niceSkills) ...[
            skill.detail,
            ..._fromNiceSkills(skill.functions)
          ]
        ];
      }));
    } else if (type == CommandCode && card is CommandCode) {
      buffer.write(getCache(card, 'passive', () {
        return [
          card.skill,
          card.skillJp,
          card.skillEn,
          for (final skill in card.niceSkills) ...[
            skill.detail,
            ..._fromNiceSkills(skill.functions)
          ]
        ];
      }));
    }
    return buffer.toString();
  }
}
