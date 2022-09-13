import 'package:flutter/material.dart';

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
  Map<int, List<_ChargeData>> groupedData = {};
  @override
  void initState() {
    super.initState();
    filter();
  }

  void _debugPrint(Servant svt, int? collectionNo, Object msg) {
    if (collectionNo != null && svt.collectionNo != collectionNo) return;
    print('No.${svt.collectionNo}-${svt.lName.l}: $msg');
  }

  @override
  Widget build(BuildContext context) {
    final keys = groupedData.keys.toList();
    keys.sort2((e) => e, reversed: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.np_charge),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemBuilder: (context, index) =>
                  rowBuilder(index, groupedData[keys[index]]!),
              itemCount: keys.length,
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

  Widget rowBuilder(int index, List<_ChargeData> servants) {
    Widget child = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SizedBox(
            height: 45,
            width: 45,
            child: Center(
              child: AutoSizeText(
                servants.first.value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                minFontSize: 8,
                maxFontSize: 12,
              ),
            ),
          ),
        ),
        for (final svt in servants)
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
            richMessage: WidgetSpan(child: _tooltip(svt)),
            child: svt.svt.iconBuilder(
              context: context,
              width: 45,
              text: svt.pos,
            ),
          )
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
          color: index.isEven ? null : Theme.of(context).cardColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );
  }

  Widget _tooltip(_ChargeData svt) {
    final skill = svt.skill;
    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        svt.svt.iconBuilder(context: context, height: 56),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(TextSpan(
            text: svt.svt.lName.l,
            children: [
              const TextSpan(text: '\n'),
              TextSpan(
                text: svt.isPassive
                    ? S.current.passive_skill
                    : svt.isTd
                        ? S.current.noble_phantasm
                        : "${S.current.skill} ${svt.pos}",
                style: Theme.of(context).textTheme.caption,
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
            style: Theme.of(context).textTheme.caption),
        const SizedBox(height: 2),
        FuncDescriptor(
            func: svt.func, level: svt.level, padding: EdgeInsets.zero),
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
        if (filterData.skillLv != -1)
          optionBuilder(
            text: NpFilterData.textSkillLv(filterData.skillLv),
          ),
        if (filterData.tdLv != 0)
          optionBuilder(text: NpFilterData.textTdLv(filterData.tdLv)),
        if (filterData.tdLv != 0)
          optionBuilder(text: NpFilterData.textTdOC(filterData.tdOC)),
        if (filterData.region.radioValue != null)
          optionBuilder(text: (filterData.region.radioValue!).localName),
        if (filterData.tdColor.radioValue != null)
          optionBuilder(
              text:
                  '${S.current.np_short}:${filterData.tdColor.radioValue!.name.toTitle()}'),
        if (filterData.tdType.radioValue != null)
          optionBuilder(
              text: [
            '${S.current.np_short}:',
            Transl.enums(
                filterData.tdType.radioValue!, (enums) => enums.tdEffectFlag).l
          ].join()),
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

  Map<int, List<_ChargeData>> filter() {
    groupedData.clear();
    for (final svt in db.gameData.servantsNoDup.values) {
      if (!filterData.tdColor.matchAny(svt.noblePhantasms.map((e) => e.card))) {
        continue;
      }
      if (!filterData.tdType
          .matchAny(svt.noblePhantasms.map((e) => e.damageType))) {
        continue;
      }
      final region = filterData.region.radioValue ?? Region.jp;

      final details = <_ChargeData>[];
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
        _debugPrint(svt, 351, '${skills.length} skills');
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
      for (final detail in details) {
        groupedData.putIfAbsent(detail.sortValue, () => []).add(detail);
      }
    }

    for (final details in groupedData.values) {
      details.sort((a, b) => SvtFilterData.compare(a.svt, b.svt,
          keys: filterData.sortKeys, reversed: filterData.sortReversed));
    }
    return groupedData;
  }

  Iterable<_ChargeData> checkSkill(
      Servant svt, SkillOrTd skill, int lv, int oc) sync* {
    final directFuncs = skill.filteredFunction<NiceFunction>();
    yield* directFuncs
        .map((func) => checkFunc(svt, skill, func, lv, oc, false))
        .whereType();
    final triggerFuncs = skill
        .filteredFunction<NiceFunction>(includeTrigger: true)
        .where((e) => !directFuncs.contains(e));
    for (final func in triggerFuncs) {
      final d = checkFunc(svt, skill, func, lv, oc, true);
      if (d == null) continue;
      yield d;
    }
  }

  // FuncType.gainNp,
  // FuncType.gainNpFromTargets,
  // FuncType.gainNpBuffIndividualSum
  // BuffType.regainNp
  _ChargeData? checkFunc(
    Servant svt,
    SkillOrTd skill,
    NiceFunction func,
    int lv,
    int oc,
    bool isTrigger,
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
    if (isTrigger) type = NpChargeType.special;
    if (!filterData.type.matchOne(type)) return null;
    return _ChargeData(
      type: type,
      svt: svt,
      skill: skill,
      func: func,
      level: lv,
      sortValue: sortValue,
      value: value,
      pos: skill is BaseTd
          ? 'NP'
          : skill is NiceSkill
              ? skill.type == SkillType.active
                  ? skill.num.toString()
                  : ""
              : '?',
      // tooltip: buildTooltip(skill),
    );
  }
}

class _ChargeData {
  NpChargeType type;
  Servant svt;
  SkillOrTd skill;
  NiceFunction func;
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
