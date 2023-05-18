import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../servant/filter.dart';
import '../simulation/recorder.dart';
import 'model.dart';

class TdDmgRankingTab extends StatefulWidget {
  final TdDmgSolver solver;
  final SvtFilterData svtFilterData;

  const TdDmgRankingTab({
    super.key,
    required this.solver,
    required this.svtFilterData,
  });

  @override
  State<TdDmgRankingTab> createState() => _TdDmgRankingTabState();
}

class _TdDmgRankingTabState extends State<TdDmgRankingTab> {
  _SortType _sortType = _SortType.damage;

  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: listView),
        kDefaultDivider,
        SafeArea(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${S.current.sort_order}: '),
                  DropdownButton<_SortType>(
                    // https://github.com/flutter/flutter/issues/101575
                    // isDense: true,
                    value: _sortType,
                    items: [
                      for (final type in _SortType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(type.shownName),
                        )
                    ],
                    onChanged: (v) {
                      setState(() {
                        if (v != null) _sortType = v;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  bool filter(TdDmgResult result) {
    final filterData = widget.svtFilterData;
    if (!ServantFilterPage.filter(filterData, result.svt)) {
      return false;
    }

    final td = result.actor?.playerSvtData?.td;
    if (filterData.npColor.isNotEmpty || filterData.npType.isNotEmpty) {
      if (td == null) return false;
      if (!filterData.npColor.matchOne(td.card)) {
        return false;
      }
      if (!filterData.npType.matchOne(td.damageType)) {
        return false;
      }
    }

    return true;
  }

  Widget get listView {
    List<TdDmgResult> results = widget.solver.results.where(filter).toList();
    switch (_sortType) {
      case _SortType.damage:
        results.sortByList((e) => [e.hasInstantDeathSuccess ? 0 : 1, -e.totalDamage, -e.attackNp, -e.totalNp]);
        break;
      case _SortType.attackNp:
        results.sortByList((e) => [-e.attackNp, -e.totalNp, -e.totalDamage]);
        break;
      case _SortType.totalNp:
        results.sortByList((e) => [-e.totalNp, -e.attackNp, -e.totalDamage]);
        break;
      case _SortType.id:
        results.sort2((e) => e.svt.collectionNo);
        break;
    }
    return ListView.separated(
      controller: scrollController,
      itemCount: results.length,
      separatorBuilder: (context, index) => kDefaultDivider,
      itemBuilder: (context, index) {
        if (index == 0) {
          final errors = widget.solver.errors;
          if (errors.isEmpty) return const SizedBox.shrink();
          return SimpleAccordion(
            headerBuilder: (context, _) => ListTile(
              dense: true,
              title: Text(
                '${errors.length} ${S.current.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            contentBuilder: (context) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(errors.join('\n\n')),
                ),
              );
            },
          );
        }
        final rank = index;
        final result = results[index - 1];
        return SimpleAccordion(
          key: Key('Ranking_${index}_${result.svt.id}'),
          headerBuilder: (context, _) => headerBuilder(rank, result),
          contentBuilder: (context) => _ResultDetail(
            key: Key('ResultDetail_${index}_${_sortType}_${result.svt.id}'),
            result: result,
            tab: result.hasInstantDeathSuccess
                ? _ParamType.instantDeath
                : _sortType.isNp
                    ? _ParamType.refund
                    : _ParamType.damage,
          ),
        );
      },
    );
  }

  Widget headerBuilder(int rank, TdDmgResult result) {
    final dmgStr = result.totalDamage.format(groupSeparator: ",", compact: false);
    String npStr = '${S.current.np_refund_short} ${result.attackNp / 100}';
    if (result.attackNp != result.totalNp) {
      npStr += ' → ${result.totalNp / 100}';
    }
    String prefix = (_sortType == _SortType.id ? result.svt.collectionNo : rank).toString().padRight(2);
    List<Widget> cardIcons = [];
    for (final record in result.attacks) {
      if (record is BattleAttackRecord && record.card != null) {
        cardIcons.add(CommandCardWidget(card: record.card!.cardType, width: 28));
      } else if (record is BattleInstantDeathRecord) {
        cardIcons.add(db.getIconImage(AssetURL.i.buffIcon(record.hasSuccess ? 337 : 532), width: 20, height: 20));
      }
    }
    return ListTile(
      dense: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$prefix ', style: kMonoStyle, textScaleFactor: 0.8),
          result.svt.iconBuilder(
            context: context,
            width: 36,
            overrideIcon: result.svt.ascendIcon(result.originalSvtData.limitCount),
          ),
        ],
      ),
      // title: Text('${S.current.damage} $dmgStr'),
      title: Text(dmgStr),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(npStr),
      ),
      horizontalTitleGap: 16,
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      trailing: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: cardIcons,
      ),
    );
  }
}

class _ResultDetail extends StatefulWidget {
  final TdDmgResult result;
  final _ParamType? tab;
  const _ResultDetail({super.key, required this.result, this.tab});

  @override
  State<_ResultDetail> createState() => _ResultDetailState();
}

class _ResultDetailState extends State<_ResultDetail> {
  _ParamType? _tab;

  @override
  Widget build(BuildContext context) {
    final tab = _tab ?? widget.tab ?? _ParamType.damage;

    List<Widget> children = [
      FilterGroup<_ParamType>(
        combined: true,
        options: widget.result.hasInstantDeath
            ? _ParamType.values
            : (_ParamType.values.toList()..remove(_ParamType.instantDeath)),
        values: FilterRadioData.nonnull(tab),
        optionBuilder: (v) => Text(v.shownName),
        onFilterChanged: (v, _) {
          setState(() {
            _tab = v.radioValue;
          });
        },
      )
    ];

    for (final attack in widget.result.attacks) {
      Widget? paramsCard;
      if (attack is BattleAttackRecord) {
        final target = attack.targets.first;
        switch (tab) {
          case _ParamType.damage:
            paramsCard = DamageParamDialog(
              target.damageParams,
              target.result,
              wrapDialog: false,
            );
            break;
          case _ParamType.refund:
            paramsCard = AttackerNpParamDialog(
              target.attackNpParams,
              target.result,
              wrapDialog: false,
            );
            break;
          case _ParamType.star:
            paramsCard = StarParamDialog(
              target.starParams,
              target.result,
              wrapDialog: false,
            );
            break;
          case _ParamType.instantDeath:
            break;
        }
      } else if (attack is BattleInstantDeathRecord) {
        if (tab == _ParamType.instantDeath) {
          paramsCard = InstantDeathParamDialog(
            attack.targets.first.params,
            wrapDialog: false,
          );
        }
      }
      if (paramsCard == null) continue;
      children.add(Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: paramsCard,
        ),
      ));
    }
    children.add(TextButton(
      onPressed: () {
        router.pushPage(Scaffold(
          appBar: AppBar(title: Text(widget.result.svt.lName.l)),
          body: SingleChildScrollView(child: BattleRecorderPanel(records: widget.result.originalRecords)),
        ));
      },
      child: Text(S.current.details),
    ));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

enum _SortType {
  damage,
  attackNp,
  totalNp,
  id,
  ;

  bool get isNp => this == _SortType.attackNp || this == _SortType.totalNp;

  String get shownName {
    switch (this) {
      case _SortType.damage:
        return S.current.damage;
      case _SortType.attackNp:
        return S.current.np_refund;
      case _SortType.totalNp:
        return S.current.total_np;
      case _SortType.id:
        return 'ID';
    }
  }
}

enum _ParamType {
  damage,
  refund,
  star,
  instantDeath,
  ;

  String get shownName {
    switch (this) {
      case _ParamType.damage:
        return S.current.damage;
      case _ParamType.refund:
        return S.current.np_refund_short;
      case _ParamType.star:
        return S.current.critical_star;
      case _ParamType.instantDeath:
        return S.current.instant_death;
    }
  }
}
