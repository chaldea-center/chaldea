import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'filter.dart';

class NpChargePage extends StatefulWidget {
  const NpChargePage({super.key});

  @override
  State<NpChargePage> createState() => _NpChargePageState();
}

class _NpChargePageState extends State<NpChargePage> {
  final filterData = NpFilterData();
  Map<String, List<_ChargeData>> groupedData = {};
  @override
  void initState() {
    super.initState();
    filter();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children =
        filterData.type.radioValue == NpChargeType.instantSum
            ? sumType()
            : normalType();
    return Scaffold(
      appBar: AppBar(title: Text(S.current.np_charge)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => DecoratedBox(
                decoration: BoxDecoration(
                    color: index.isEven ? null : Theme.of(context).cardColor),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: children[index],
                ),
              ),
              itemCount: children.length,
            ),
          ),
          kDefaultDivider,
          InkWell(
            child: SafeArea(child: buttonBar),
            onTap: () {
              FilterPage.show(
                context: context,
                builder: (context) => NpChargeFilterPage(
                  filterData: filterData,
                  onChanged: (v) {
                    if (mounted) {
                      filter();
                      setState(() {});
                    }
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  List<Widget> normalType() {
    List<Widget> children = [];
    final keys = groupedData.keys.toList();
    keys.sort2((e) => groupedData[e]!.first.sortValue, reversed: true);
    for (final key in keys) {
      final details = groupedData[key]!;
      children.add(Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              height: 45,
              width: 45,
              child: Center(
                child: AutoSizeText(
                  details.first.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 12,
                ),
              ),
            ),
          ),
          for (final detail in details)
            Tooltip(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(200),
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                    spreadRadius: 2,
                  )
                ],
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              waitDuration: const Duration(seconds: 1),
              richMessage: WidgetSpan(child: _tooltipMsg(detail)),
              child: detail.svt.iconBuilder(
                context: context,
                width: 45,
                text: detail.pos,
              ),
            )
        ],
      ));
    }
    return children;
  }

  // HOW TERRIBLE!!!
  List<Widget> sumType() {
    if (!filterData.isSvt) return [];
    // svtId, skillId, nps
    Map<int, Map<int, List<int>>> skillDetails = {};
    for (final details in groupedData.values) {
      for (final detail in details) {
        // [self,other,all,special]
        final nps = skillDetails
            .putIfAbsent(detail.svt.collectionNo, () => {})
            .putIfAbsent(detail.skill.id, () => [0, 0, 0, 0]);
        switch (detail.func.effectTarget) {
          case EffectTarget.self:
            nps[0] += detail.sortValue;
            break;
          case EffectTarget.ptAll:
            nps[0] += detail.sortValue;
            nps[1] += detail.sortValue;
            nps[2] += detail.sortValue;
            break;
          case EffectTarget.ptOne:
            nps[0] += detail.sortValue;
            nps[1] += detail.sortValue;
            break;
          case EffectTarget.ptOther:
            nps[1] += detail.sortValue;
            break;
          case EffectTarget.enemy:
          case EffectTarget.enemyAll:
          case EffectTarget.special:
            nps[3] = max(detail.sortValue, nps[3]);
            break;
        }
      }
    }
    // svtId, pos, nps
    Map<int, Map<String, List<int>>> svtDetails = {};
    for (final details in groupedData.values) {
      for (final detail in details) {
        final svtDetail =
            svtDetails.putIfAbsent(detail.svt.collectionNo, () => {});
        final nps = svtDetail[detail.pos] ??= [0, 0, 0, 0];
        final skillNps =
            skillDetails[detail.svt.collectionNo]![detail.skill.id]!;
        for (int index = 0; index < nps.length; index++) {
          nps[index] = max(nps[index], skillNps[index]);
        }
      }
    }
    // svtId, maxNp
    Map<int, int> svtNps = {};
    for (final svtId in svtDetails.keys) {
      final nps = [0, 0, 0, 0];
      for (final detail in svtDetails[svtId]!.values) {
        nps[0] = nps[0] + detail[0];
        nps[1] = nps[1] + detail[1];
        nps[2] = nps[2] + detail[2];
        nps[3] = nps[3] + detail[3];
      }
      svtNps[svtId] = Maths.max(nps, 0);
      if (svtId == 1 && svtNps[svtId] == 4000) {
        // Mash skill2: one is for self, another is for ptOne
        svtNps[svtId] = 2000;
      }
    }
    // maxNp, <servants>
    Map<int, List<int>> groupedServants = {};
    for (final svtId in svtNps.keys) {
      groupedServants.putIfAbsent(svtNps[svtId]!, () => []).add(svtId);
    }
    for (final svts in groupedServants.values) {
      svts.sort((a, b) => SvtFilterData.compare(
          db.gameData.servantsNoDup[a], db.gameData.servantsNoDup[b],
          keys: filterData.svtSortKeys, reversed: filterData.sortReversed));
    }
    List<Widget> children = [];
    final keys = groupedServants.keys.toList()..sort((a, b) => b - a);
    for (final key in keys) {
      final svtIds = groupedServants[key]!;
      children.add(Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              height: 45,
              width: 45,
              child: Center(
                child: AutoSizeText(
                  (key / 100).format(compact: false),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 12,
                ),
              ),
            ),
          ),
          for (final svtId in svtIds)
            db.gameData.servantsNoDup[svtId]
                    ?.iconBuilder(context: context, width: 45) ??
                Text(svtId.toString()),
        ],
      ));
    }

    return children;
  }

  Widget _tooltipMsg(_ChargeData detail) {
    final skill = detail.skill;
    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        detail.svt.iconBuilder(context: context, height: 56),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(TextSpan(
            text: detail.svt.lName.l,
            children: [
              const TextSpan(text: '\n'),
              TextSpan(
                text: detail.isPassive
                    ? S.current.passive_skill
                    : detail.isTd
                        ? S.current.noble_phantasm
                        : "${S.current.skill} ${detail.pos}",
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          )),
        )
      ],
    );
    final skillWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: [
            CenterWidgetSpan(
                child: skill is BaseTd
                    ? CommandCardWidget(card: skill.card, width: 42)
                    : db.getIconImage(skill.icon, width: 24, aspectRatio: 1)),
            TextSpan(text: '  ${skill.lName.l}')
          ]),
        ),
        const SizedBox(height: 2),
        Text(skill.lDetail ?? '???',
            style: Theme.of(context).textTheme.bodySmall),
        const Divider(height: 6, thickness: 1),
        FuncDescriptor(
          func: detail.triggerFunc ?? detail.func,
          level: detail.level,
          showEnemy: true, // in case it is triggered skill
          padding: EdgeInsets.zero,
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: 8),
          skillWidget,
        ],
      ),
    );
  }

  Widget get buttonBar {
    Widget child = Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        optionBuilder(
            text:
                '${S.current.general_type}: ${filterData.type.radioValue!.shownName}'),
        if (!filterData.isSvt && filterData.ceMax.options.isNotEmpty)
          optionBuilder(
            text: [
              if (filterData.ceMax.options.contains(false))
                'NOT ${S.current.ce_max_limit_break}',
              if (filterData.ceMax.options.contains(true))
                S.current.ce_max_limit_break
            ].join(' & '),
          ),
        if (filterData.isSvt) ...[
          if (filterData.skillLv != -1)
            optionBuilder(
              text: NpFilterData.textSkillLv(filterData.skillLv),
            ),
          if (filterData.tdLv != 0)
            optionBuilder(text: NpFilterData.textTdLv(filterData.tdLv)),
          if (filterData.tdLv != 0)
            optionBuilder(text: NpFilterData.textTdOC(filterData.tdOC)),
          if (filterData.favorite.radioValue! != FavoriteState.all)
            optionBuilder(
                child: Text.rich(TextSpan(children: [
              WidgetSpan(
                  child: Icon(
                filterData.favorite.radioValue!.icon,
                size: 16,
              )),
              TextSpan(text: filterData.favorite.radioValue!.shownName)
            ]))),
        ],
        if (filterData.rarity.options.isNotEmpty)
          optionBuilder(
            text: '${S.current.rarity}:'
                '${filterData.rarity.options.toList().sortReturn().join('/')}',
          ),
        if (filterData.isSvt && filterData.svtClass.options.isNotEmpty)
          optionBuilder(
              text: '${S.current.filter_sort_class}:'
                  '${filterData.svtClass.options.map((e) => e.lName).join("/")}'),
        if (filterData.region.radioValue != null)
          optionBuilder(text: (filterData.region.radioValue!).localName),
        if (filterData.isSvt) ...[
          if (filterData.tdColor.radioValue != null)
            optionBuilder(
                text:
                    '${S.current.np_short}:${filterData.tdColor.radioValue!.name.toTitle()}'),
          if (filterData.tdType.radioValue != null)
            optionBuilder(
                text: [
              '${S.current.np_short}:',
              Transl.enums(filterData.tdType.radioValue!,
                  (enums) => enums.tdEffectFlag).l
            ].join()),
        ],
        if (filterData.effectTarget.radioValue != null)
          optionBuilder(text: filterData.effectTarget.radioValue!.shownName),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.background,
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget optionBuilder({String? text, Widget? child}) {
    assert(text != null || child != null);
    return DecoratedBox(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).colorScheme.primaryContainer),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: child ?? Text(text ?? '???'),
      ),
    );
  }

  void filter() {
    groupedData.clear();
    final details = <_ChargeData>[];
    for (final ce in db.gameData.craftEssences.values) {
      if (filterData.isSvt) break;
      // 0-1-2
      if (!filterData.rarity.matchOne(ce.rarity)) continue;
      final region = filterData.region.radioValue ?? Region.jp;
      final released = db.gameData.mappingData.ceRelease
          .ofRegion(region)
          ?.contains(ce.collectionNo);
      if (region == Region.jp || released == true) {
        final skills = ce.skills.where((e) => e.num == 1).toList();
        for (final skill in skills) {
          // some CE has the same skill for all ascensions
          // such as bond CE or campaign CE, though no one yet
          if (skills.length > 1 &&
              !filterData.ceMax.matchOne(skill.priority > 1)) {
            continue;
          }
          details.addAll(checkSkill(ce, skill, 1, 1));
        }
      }
    }
    for (final svt in db.gameData.servantsNoDup.values) {
      if (!filterData.isSvt) break;
      if (!filterData.favorite.radioValue!
          .check(db.curUser.svtStatusOf(svt.collectionNo).favorite)) {
        continue;
      }
      if (!filterData.tdColor.matchAny(svt.noblePhantasms.map((e) => e.card))) {
        continue;
      }
      if (!filterData.tdType
          .matchAny(svt.noblePhantasms.map((e) => e.damageType))) {
        continue;
      }
      if (!filterData.svtClass.matchOne(svt.className, compares: {
        SvtClass.caster: (v, o) =>
            v == SvtClass.caster || v == SvtClass.grandCaster,
        SvtClass.beastII: (v, o) => SvtClassX.beasts.contains(v),
      })) {
        continue;
      }
      if (!filterData.rarity.matchOne(svt.rarity)) continue;

      final region = filterData.region.radioValue ?? Region.jp;

      if (filterData.skillLv >= 0) {
        List<BaseSkill> skills = [];
        if (filterData.skillLv == 0) {
          final released = db.gameData.mappingData.svtRelease
              .ofRegion(region)
              ?.indexOf(svt.collectionNo);
          if (region == Region.jp || (released != null && released >= 0)) {
            skills.addAll(svt.classPassive);
          }
        } else {
          final skillRelease =
              db.gameData.mappingData.skillPriority[svt.id]?.ofRegion(region);
          for (var skill in svt.skills) {
            final priority = skillRelease?[skill.id];
            if (region != Region.jp && priority == null) {
              continue;
            }
            skills.add(skill);
            if (svt.script.skillRankUp != null) {
              final rankupIds = svt.script.skillRankUp?[skill.id];
              for (final id in rankupIds ?? <int>[]) {
                final rskill = db.gameData.baseSkills[id];
                if (rskill != null && skills.every((e) => e.id != rskill.id)) {
                  skills.add(rskill);
                }
              }
            }
          }
        }
        for (final skill in skills) {
          details.addAll(checkSkill(
              svt, skill, filterData.skillLv == 0 ? 1 : filterData.skillLv, 1));
        }
      }
      if (filterData.tdLv > 0) {
        for (final td in svt.noblePhantasms) {
          if (region != Region.jp) {
            final priority = db.gameData.mappingData.tdPriority[svt.id]
                ?.ofRegion(region)?[td.id];
            if (priority == null) {
              continue;
            }
          }
          details.addAll(checkSkill(svt, td, filterData.tdLv, filterData.tdOC));
        }
      }
    }
    for (final detail in details) {
      groupedData.putIfAbsent(detail.value, () => []).add(detail);
    }

    for (final details in groupedData.values) {
      details.sort((a, b) {
        if (a.svt is Servant && b.svt is Servant) {
          return SvtFilterData.compare(a.svt as Servant, b.svt as Servant,
              keys: filterData.svtSortKeys, reversed: filterData.sortReversed);
        } else if (a.svt is CraftEssence && b.svt is CraftEssence) {
          return CraftFilterData.compare(
              a.svt as CraftEssence, b.svt as CraftEssence);
        } else {
          return a.svt.toString().compareTo(b.svt.toString());
        }
      });
    }
  }

  Iterable<_ChargeData> checkSkill(
      GameCardMixin svt, SkillOrTd skill, int lv, int oc) sync* {
    final directFuncs = skill.filteredFunction<NiceFunction>();
    yield* directFuncs
        .map((func) => checkFunc(svt, skill, func, lv, oc, null))
        .whereType();
    for (final func in directFuncs) {
      for (final tFunc
          in NiceFunction.getTriggerFuncs<NiceFunction>(func: func)) {
        final d = checkFunc(svt, skill, tFunc, lv, oc, func);
        if (d == null) continue;
        yield d;
      }
    }
  }

  // FuncType.gainNp,
  // FuncType.gainNpFromTargets,
  // FuncType.gainNpBuffIndividualSum
  // BuffType.regainNp
  _ChargeData? checkFunc(
    GameCardMixin svt,
    SkillOrTd skill,
    NiceFunction func,
    int lv,
    int oc,
    NiceFunction? triggerFunc,
  ) {
    var effectTarget = EffectTargetX.fromFunc(func.funcTargetType);
    if (!NpFilterData.kEffectTargets.contains(effectTarget)) {
      effectTarget = EffectTarget.special;
    }
    if (!filterData.effectTarget.matchOne(effectTarget)) return null;
    final sval = func.svalsList.getOrNull(oc - 1)?.getOrNull(lv - 1);
    if (sval == null) return null;
    String _fmt(int v) => v.format(percent: true, base: 100).trimCharRight('%');
    int? sortValue;
    String? value;
    NpChargeType? type;
    if (func.funcType == FuncType.gainNp && sval.Value != null) {
      sortValue = sval.Value!;
      value = _fmt(sortValue);
      type = NpChargeType.instant;
    } else if (func.buffs.isNotEmpty &&
        func.buffs.first.type == BuffType.regainNp &&
        sval.Value != null) {
      sortValue = sval.Value!;
      value = _fmt(sortValue);
      type = NpChargeType.perTurn;
    } else if (func.funcType == FuncType.gainNpFromTargets) {
      final v = sval.DependFuncVals?.Value2 ?? sval.DependFuncVals?.Value;
      if (v != null) {
        sortValue = v;
        value = '${_fmt(sortValue)}×N';
        type = NpChargeType.special;
      }
    } else if (func.funcType == FuncType.gainNpBuffIndividualSum) {
      if (sval.Value != null) {
        sortValue = sval.Value!;
        value = '${_fmt(sortValue)}×N';
        type = NpChargeType.special;
      }
    }
    if (sortValue == null || value == null || type == null) return null;
    if (triggerFunc != null) type = NpChargeType.special;
    final requiredType = filterData.type.radioValue!;
    if (requiredType != type) {
      if (requiredType == NpChargeType.instantSum &&
          type == NpChargeType.instant) {
        // pass
      } else {
        return null;
      }
    }
    String? pos = skill is BaseTd
        ? 'NP'
        : skill is NiceSkill
            ? skill.type == SkillType.active
                ? skill.num.toString()
                : svt is CraftEssence && skill.priority > 1
                    ? "✧"
                    : " " // passive
            : null;
    if (pos == null && svt is Servant) {
      final rankups = svt.script.skillRankUp ?? {};
      for (final srcSkillId in rankups.keys) {
        if (rankups[srcSkillId]!.contains(skill.id)) {
          final srcSkill =
              svt.skills.firstWhereOrNull((s) => s.id == srcSkillId);
          if (srcSkill != null) {
            pos = srcSkill.num.toString();
          }
        }
      }
    }

    return _ChargeData(
      type: type,
      svt: svt,
      skill: skill,
      func: func,
      triggerFunc: triggerFunc,
      level: lv,
      sortValue: sortValue,
      value: value,
      pos: pos ?? '?',
      // tooltip: buildTooltip(skill),
    );
  }
}

class _ChargeData {
  NpChargeType type;
  GameCardMixin svt;
  SkillOrTd skill;
  NiceFunction func;
  NiceFunction? triggerFunc;
  int? level;
  int sortValue;
  String value;
  String pos;
  // WidgetBuilder tooltip;

  _ChargeData({
    required this.type,
    required this.svt,
    required this.skill,
    required this.level,
    required this.func,
    required this.triggerFunc,
    required this.sortValue,
    required this.value,
    required this.pos,
    // required this.tooltip,
  });

  bool get isTd => skill is BaseTd;
  bool get isSkill => skill is BaseSkill;
  bool get isPassive =>
      skill is BaseSkill && (skill as BaseSkill).type == SkillType.passive;
}

// class _ChargeSkill{
//   SkillOrTd skill;
//   List<NiceFunction> funcs;
//   _ChargeSkill({
//     required this.skill,
//     required this.func,
//   });
// }
