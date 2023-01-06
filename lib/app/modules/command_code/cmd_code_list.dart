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
import 'cmd_code.dart';
import 'filter.dart';

class CmdCodeListPage extends StatefulWidget {
  final void Function(CommandCode)? onSelected;

  CmdCodeListPage({super.key, this.onSelected});

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage>
    with SearchableListState<CommandCode, CmdCodeListPage> {
  @override
  Iterable<CommandCode> get wholeData => db.gameData.commandCodes.values;

  CmdCodeFilterData get filterData => db.settings.cmdCodeFilterData;

  @override
  final bool prototypeExtent = true;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
    options = _CmdCodeSearchOptions(onChanged: (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CmdCodeFilterData.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.command_code, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CmdCodeFilterPage(
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
        await GameDataLoader.instance.fetchUpdates();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget listItemBuilder(CommandCode cc) {
    return CustomTile(
      leading: db.getIconImage(
        cc.borderedIcon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(cc.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(cc.name, maxLines: 1),
          Text('No.${cc.collectionNo}'),
        ],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(cc, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == cc,
      onTap: () => _onTapCard(cc),
    );
  }

  @override
  Widget gridItemBuilder(CommandCode cc) {
    return cc.iconBuilder(
      context: context,
      width: 72,
      onTap: () => _onTapCard(cc),
    );
  }

  @override
  bool filter(CommandCode cc) {
    if (!filterData.rarity.matchOne(cc.rarity)) {
      return false;
    }
    final region = filterData.region.radioValue;
    if (region != null && region != Region.jp) {
      final released = db.gameData.mappingData.ccRelease.ofRegion(region);
      if (released?.contains(cc.collectionNo) != true) {
        return false;
      }
    }
    if (filterData.effectType.options.isNotEmpty ||
        filterData.effectTarget.options.isNotEmpty) {
      List<BaseFunction> funcs = [
        for (final skill in cc.skills)
          ...skill.filteredFunction(includeTrigger: true),
      ];
      if (filterData.effectTarget.options.isNotEmpty) {
        funcs.retainWhere((func) {
          return filterData.effectTarget
              .matchOne(EffectTarget.fromFunc(func.funcTargetType));
        });
      }
      if (funcs.isEmpty) return false;
      if (filterData.effectType.options.isEmpty) return true;
      if (filterData.effectType.matchAll) {
        if (!filterData.effectType.options
            .every((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      } else {
        if (!filterData.effectType.options
            .any((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      }
    }
    return true;
  }

  void _onTapCard(CommandCode cc, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      widget.onSelected!(cc);
    } else {
      router.popDetailAndPush(
        url: cc.route,
        child: CmdCodeDetailPage(
          cc: cc,
          onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
        ),
        detail: true,
      );
      selected = cc;
    }
    setState(() {});
  }
}

class _CmdCodeSearchOptions with SearchOptionsMixin<CommandCode> {
  bool basic = true;
  bool skill = true;
  @override
  ValueChanged? onChanged;

  _CmdCodeSearchOptions({this.onChanged});

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
  Iterable<String?> getSummary(CommandCode code) sync* {
    if (basic) {
      yield code.collectionNo.toString();
      yield code.id.toString();
      yield* getAllKeys(code.lName);
      yield SearchUtil.getJP(code.ruby);
      yield* getAllKeys(Transl.illustratorNames(code.illustrator));
      for (final svtId in code.extra.characters) {
        final svt =
            db.gameData.servantsById[svtId] ?? db.gameData.servantsNoDup[svtId];
        if (svt == null) continue;
        for (final name in svt.allNames) {
          yield* getAllKeys(Transl.svtNames(name));
        }
      }
      for (final name in code.extra.unknownCharacters) {
        yield* getAllKeys(Transl.charaNames(name));
      }
    }
    if (skill) {
      for (final skill in code.skills) {
        yield* getSkillKeys(skill);
      }
    }
  }
}
