import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';
import 'quest_enemy_summary.dart';

class EnemyListPage extends StatefulWidget {
  EnemyListPage({super.key});

  @override
  State<StatefulWidget> createState() => EnemyListPageState();
}

class EnemyListPageState extends State<EnemyListPage>
    with SearchableListState<BasicServant, EnemyListPage> {
  @override
  Iterable<BasicServant> get wholeData =>
      db.gameData.entities.values.where((svt) => svt.collectionNo <= 0);
  final Map<int, List<QuestEnemy>> _allEnemies = {};

  final filterData = EnemyFilterData();

  @override
  final bool prototypeExtent = true;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
    for (final quest in db.gameData.questPhases.values) {
      for (final stage in quest.stages) {
        for (final enemy in stage.enemies) {
          assert(db.gameData.entities.containsKey(enemy.svt.id), enemy.svt.id);
          if (enemy.svt.collectionNo > 0 &&
              [SvtType.normal, SvtType.heroine].contains(enemy.svt.type)) {
            continue;
          }
          _allEnemies.putIfAbsent(enemy.svt.id, () => []).add(enemy);
        }
      }
    }
    for (final enemies in _allEnemies.values) {
      enemies.sort2((e) => e.svt.icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => EnemyFilterData.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.enemy_list, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => EnemyFilterPage(
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
    if (db.settings.display.classFilterStyle ==
        SvtListClassFilterStyle.doNotShow) {
      return super.buildScrollable(useGrid: useGrid);
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  SharedBuilder.topSvtClassFilter(
                context: context,
                maxWidth: constraints.maxWidth,
                data: filterData.svtClass,
                onChanged: () {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(child: super.buildScrollable(useGrid: useGrid)),
        ],
      );
    }
  }

  @override
  Widget listItemBuilder(BasicServant svt) {
    return CustomTile(
      leading: db.getIconImage(
        svt.icon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(svt.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(svt.name, maxLines: 1),
          Text('No.${svt.id} ${Transl.svtClass(svt.className).l}'),
        ],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(svt, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == svt,
      onTap: () => _onTapCard(svt),
    );
  }

  @override
  Widget gridItemBuilder(BasicServant svt) {
    return svt.iconBuilder(
      context: context,
      width: 72,
      onTap: () => _onTapCard(svt),
    );
  }

  @override
  bool filter(BasicServant svt) {
    final enemies = _allEnemies[svt.id] ?? <QuestEnemy>[];
    if (filterData.onlyShowQuestEnemy && enemies.isEmpty) {
      return false;
    }
    if (!filterData.svtClass.matchOne(svt.className, compares: {
      SvtClass.caster: (v, o) =>
          v == SvtClass.caster || v == SvtClass.grandCaster,
      SvtClass.beastII: (v, o) => SvtClassX.beasts.contains(v),
    })) {
      return false;
    }
    if (!filterData.attribute.matchOne(svt.attribute)) {
      return false;
    }
    if (!filterData.svtType.matchOne(svt.type)) {
      return false;
    }
    if (filterData.trait.options.isNotEmpty) {
      if (enemies.every((enemy) =>
          !filterData.trait.matchAny(enemy.traits.map((e) => e.name)))) {
        return false;
      }
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(BasicServant svt) sync* {
    yield svt.id.toString();
    final enemies = _allEnemies[svt.id] ?? [];
    yield* SearchUtil.getAllKeys(svt.lName);
    for (final name in enemies.map((e) => e.name).toSet()) {
      yield SearchUtil.getJP(name);
    }
  }

  void _onTapCard(BasicServant svt, [bool forcePush = false]) {
    final enemies = _allEnemies[svt.id] ?? [];
    if (enemies.isEmpty) {
      svt.routeTo(popDetails: true);
    } else {
      router.pushPage(
        QuestEnemySummaryPage(svt: enemies.first.svt, enemies: enemies),
        popDetail: true,
      );
    }
    selected = svt;
    setState(() {});
  }
}
