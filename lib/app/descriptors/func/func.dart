import 'dart:math';

import 'package:flutter/gestures.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'vals.dart';

mixin FuncsDescriptor {
  List<Widget> describeFunctions({
    required List<NiceFunction> funcs,
    required SkillScript? script,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
    bool showEvent = true,
    Region? region,
  }) =>
      describe(
        funcs: funcs,
        script: script,
        showPlayer: showPlayer,
        showEnemy: showEnemy,
        showNone: showNone,
        level: level,
        padding: padding,
        showBuffDetail: showBuffDetail,
        owner: owner,
        showEvent: showEvent,
        region: region,
      );

  static List<Widget> describe({
    required List<NiceFunction> funcs,
    required SkillScript? script,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
    bool showEvent = true,
    Region? region,
  }) {
    funcs = funcs.where((func) {
      if (!showNone && func.funcType == FuncType.none) return false;
      if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy) {
        return true;
      }
      return func.isPlayerOnlyFunc ? showPlayer : showEnemy;
    }).toList();
    List<Widget> children = [];
    final actIndiv =
        owner is BaseSkill ? owner.actIndividuality : <NiceTrait>[];
    if (script?.isNotEmpty == true || actIndiv.isNotEmpty) {
      children.add(
          SkillScriptDescriptor(script: script, actIndividuality: actIndiv));
    }

    for (int index = 0; index < funcs.length; index++) {
      children.add(FuncDescriptor(
        func: funcs[index],
        lastFuncTarget: funcs.getOrNull(index - 1)?.funcTargetType,
        level: level,
        padding: padding,
        showPlayer: showPlayer,
        showEnemy: showEnemy,
        showBuffDetail: showBuffDetail,
        owner: owner,
        showEvent: showEvent,
        region: region,
      ));
    }
    return children;
  }
}

class _DescriptorWrapper extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final List<Widget> lvCells;
  final List<Widget> ocCells;
  final List<Widget> supportCells;
  final int? selected;

  const _DescriptorWrapper({
    required this.title,
    required this.trailing,
    this.lvCells = const [],
    this.ocCells = const [],
    this.supportCells = const [],
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = 80;
      if (constraints.maxWidth != double.infinity) {
        maxWidth = max(maxWidth, constraints.maxWidth / 3);
        maxWidth = min(maxWidth, constraints.maxWidth / 2.5);
      }
      int perLine = constraints.maxWidth > 600 && lvCells.length > 5 ? 10 : 5;

      List<Widget> children = [];
      if (trailing == null) {
        children.add(title);
      } else {
        children.add(Row(
          children: [
            Expanded(flex: perLine - 1, child: title),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 20),
              child: trailing,
            ),
          ],
        ));
      }
      final cellsList = [lvCells, ocCells, supportCells];
      for (int cellIndex = 0; cellIndex < cellsList.length; cellIndex++) {
        final _cells = cellsList[cellIndex];
        if (_cells.isEmpty) continue;
        List<Widget> rows = [];
        int _perLine = perLine;
        if (_cells.length == 1) _perLine = 1;
        int rowCount = (_cells.length / _perLine).ceil();
        for (int i = 0; i < rowCount; i++) {
          List<Widget> cols = [];
          for (int j = i * _perLine; j < (i + 1) * _perLine; j++) {
            Widget cell = _cells.getOrNull(j) ?? const SizedBox();
            cell = Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: cell,
            );
            if (cellIndex == 0 && selected != null && selected! - 1 == j) {
              cell = DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withAlpha(180)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: cell,
              );
            }
            cols.add(cell);
          }
          rows.add(Row(children: cols.map((e) => Expanded(child: e)).toList()));
        }
        children.addAll(rows);
      }
      if (children.length == 1) return children.first;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    });
  }
}

class SkillScriptDescriptor extends StatelessWidget {
  final SkillScript? script;
  final List<NiceTrait> actIndividuality;
  const SkillScriptDescriptor(
      {super.key, required this.script, this.actIndividuality = const []});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (actIndividuality.isNotEmpty) {
      final isSvt = actIndividuality
          .any((indiv) => db.gameData.servantsById.containsKey(indiv));
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: _DescriptorWrapper(
          title: Text.rich(
            TextSpan(children: [
              ...SharedBuilder.replaceSpan(
                Transl.misc(isSvt
                        ? 'Skill.actIndividuality'
                        : 'Skill.actIndividuality2')
                    .l,
                '{0}',
                actIndividuality.map((indiv) {
                  final svt = db.gameData.servantsById[indiv.id];
                  String name = indiv.shownName(addSvtId: false);
                  if (svt != null) {
                    name += '(${svt.className.lName})';
                  }
                  return SharedBuilder.textButtonSpan(
                    context: context,
                    text: name,
                    onTap: svt?.routeTo ?? indiv.routeTo,
                  );
                }).toList(),
              )
            ]),
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: null,
        ),
      ));
    }
    if (script?.NP_HIGHER?.isNotEmpty == true) {
      children.add(
          _lvBased(context, 'NP_HIGHER', script!.NP_HIGHER!, (v) => '$v%'));
    }
    if (script?.NP_LOWER?.isNotEmpty == true) {
      children
          .add(_lvBased(context, 'NP_LOWER', script!.NP_LOWER!, (v) => '$v%'));
    }
    if (script?.STAR_HIGHER?.isNotEmpty == true) {
      children.add(
          _lvBased(context, 'STAR_HIGHER', script!.STAR_HIGHER!, (v) => '$v'));
    }
    if (script?.STAR_LOWER?.isNotEmpty == true) {
      children.add(
          _lvBased(context, 'STAR_LOWER', script!.STAR_LOWER!, (v) => '$v'));
    }
    if (script?.HP_VAL_HIGHER?.isNotEmpty == true) {
      children.add(_lvBased(
          context, 'HP_VAL_HIGHER', script!.HP_VAL_HIGHER!, (v) => '$v'));
    }
    if (script?.HP_VAL_LOWER?.isNotEmpty == true) {
      children.add(_lvBased(
          context, 'HP_VAL_LOWER', script!.HP_VAL_LOWER!, (v) => '$v'));
    }
    if (script?.HP_PER_HIGHER?.isNotEmpty == true) {
      children.add(_lvBased(context, 'HP_PER_HIGHER', script!.HP_PER_HIGHER!,
          (v) => v.format(compact: false, percent: true, base: 10)));
    }
    if (script?.HP_PER_LOWER?.isNotEmpty == true) {
      children.add(_lvBased(context, 'HP_PER_LOWER', script!.HP_PER_LOWER!,
          (v) => v.format(compact: false, percent: true, base: 10)));
    }
    if (script?.additionalSkillId?.isNotEmpty == true) {
      children.add(_pad(Text.rich(
        TextSpan(children: [
          TextSpan(text: Transl.misc('SkillScript.additionalSkillId').l),
          ...divideList(
            List.generate(script!.additionalSkillId!.length, (index) {
              final skillId = script!.additionalSkillId![index];
              final lv = script!.additionalSkillLv?.getOrNull(index);
              // final actorType=script!.additionalSkillActorType?.getOrNull(index);
              return SharedBuilder.textButtonSpan(
                context: context,
                text: [skillId, if (lv != null) '($lv)'].join(),
                onTap: () {
                  router.push(url: Routes.skillI(skillId));
                },
              );
            }),
            const TextSpan(text: ', '),
          ),
        ]),
        style: Theme.of(context).textTheme.caption,
      )));
    }
    if (script?.tdTypeChangeIDs?.isNotEmpty == true) {
      children.add(_pad(Text.rich(
        TextSpan(children: [
          TextSpan(text: Transl.misc('SkillScript.tdTypeChangeIDs').l),
          ...divideList(
            List.generate(script!.tdTypeChangeIDs!.length, (index) {
              final tdId = script!.tdTypeChangeIDs![index];
              return SharedBuilder.textButtonSpan(
                context: context,
                text: '$tdId',
                onTap: () {
                  router.push(url: Routes.tdI(tdId));
                },
              );
            }),
            const TextSpan(text: ' / '),
          ),
        ]),
        style: Theme.of(context).textTheme.caption,
      )));
    }
    if (children.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).hoverColor,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _lvBased(BuildContext context, String key, List<int> vals,
      String Function(int v) builder) {
    String title = Transl.misc('SkillScript.$key').l;
    Widget? trailing;
    List<Widget> cells = [];
    if (vals.toSet().length == 1) {
      title = title.replaceAll('{0}', builder(vals.first));
      trailing = Text(
        builder(vals.first),
        style: const TextStyle(fontSize: 13),
      );
    } else {
      for (final v in vals) {
        cells.add(Text(
          builder(v),
          style: const TextStyle(fontSize: 13),
        ));
      }
    }

    return _pad(
      _DescriptorWrapper(
        title: Text(title, style: Theme.of(context).textTheme.caption),
        trailing: trailing,
        lvCells: cells,
      ),
    );
  }

  Widget _pad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}

class FuncDescriptor extends StatelessWidget {
  final NiceFunction func;
  final FuncTargetType? lastFuncTarget;
  final int? level; // 1-10
  final EdgeInsetsGeometry? padding;
  final bool showPlayer;
  final bool showEnemy;
  final bool showBuffDetail;
  final SkillOrTd? owner;
  final bool showEvent;
  final Region? region;

  const FuncDescriptor({
    super.key,
    required this.func,
    this.lastFuncTarget,
    this.level,
    this.padding,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showBuffDetail = false,
    this.owner,
    this.showEvent = true,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = StringBuffer();
    if ((func.funcType == FuncType.addState ||
            func.funcType == FuncType.addStateShort ||
            func.funcType == FuncType.addFieldChangeToField) &&
        func.buffs.isNotEmpty) {
      final buff = func.buffs.first;
      if (showBuffDetail) {
        funcText.write(Transl.buffDetail(buff.detail).l);
      } else {
        if ([
          BuffType.fieldIndividuality,
          BuffType.addIndividuality,
          BuffType.subIndividuality,
          BuffType.toFieldChangeField
        ].contains(buff.type)) {
          funcText.write(Transl.buffNames(buff.type.name).l);
        } else if (buff.name.isEmpty) {
          funcText.write(Transl.buffType(buff.type).l);
        } else {
          funcText.write(Transl.buffNames(buff.name).l);
        }
      }
      // } else if ([
      //   FuncType.enemyEncountRateUp,
      //   FuncType.enemyEncountCopyRateUp,
      // ].contains(func.funcType)) {
      //   funcText.write(Transl.funcPopuptext(func).l);
    } else {
      funcText.write(Transl.funcPopuptext(func).l);
    }

    if ([
      FuncType.gainHpFromTargets,
      FuncType.absorbNpturn,
      FuncType.gainNpFromTargets,
    ].contains(func.funcType)) {
      funcText.write(Transl.special.funcAbsorbFrom);
    }

    final staticVal = func.getStaticVal();
    final mutatingLvVals = func.getMutatingVals(null, levelOnly: true);
    final mutatingOCVals = func.getMutatingVals(null, ocOnly: true);

    int turn = staticVal.Turn ?? -1, count = staticVal.Count ?? -1;
    if (turn > 0 || count > 0) {
      funcText.write(' (');
      funcText.write([
        if (count > 0) Transl.special.funcValCountTimes(count),
        if (turn > 0) Transl.special.funcValTurns(turn),
      ].join(M.of(jp: '·', cn: '·', tw: '·', na: ', ', kr: ', ')));
      funcText.write(')');
    }
    Widget trailing;
    List<Widget> lvCells = [];
    List<Widget> ocCells = [];
    List<Widget> supportCells = [];
    trailing = ValDsc(
      func: func,
      vals: staticVal,
      originVals: func.svals.getOrNull(0),
      ignoreRate: true,
      ignoreCount: true,
    );

    Widget _listVal(DataVals mVals, DataVals? oVals, int? index,
        {bool support = false}) {
      Widget cell = ValDsc(
        func: func,
        vals: mVals,
        originVals: oVals,
        color: index == 5 || index == 9
            ? Theme.of(context).colorScheme.secondary
            : null,
        inList: true,
        supportOnly: support,
      );
      return cell;
    }

    if (mutatingLvVals.isNotEmpty) {
      funcText.write('<Lv>');
      lvCells.addAll(List.generate(
          mutatingLvVals.length,
          (index) => _listVal(
              mutatingLvVals[index], func.svals.getOrNull(index), index)));
    }
    if (mutatingOCVals.isNotEmpty) {
      funcText.write('<OC>');
      ocCells.addAll(List.generate(
          mutatingOCVals.length,
          (index) => _listVal(
              mutatingOCVals[index], func.ocVals(0).getOrNull(index), index)));
    }
    if (func.followerVals?.isNotEmpty == true) {
      // doesn't split static or mutating vals, it is rarely used.
      supportCells.addAll(List.generate(
          func.followerVals!.length,
          (index) =>
              _listVal(func.followerVals![index], null, index, support: true)));
    }

    DataVals? vals = func.svals.getOrNull(0);

    List<InlineSpan> spans = [];
    Widget? icon;
    String? _iconUrl = func.funcPopupIcon ?? func.buffs.getOrNull(0)?.icon;
    if (_iconUrl != null) {
      icon = db.getIconImage(_iconUrl, width: 18);
      if (vals?.SetPassiveFrame == 1) {
        icon = DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).hintColor),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: icon,
          ),
        );
      }
    } else if (func.funcType == FuncType.eventFortificationPointUp) {
      int? indiv = func.svals.getOrNull(0)?.Individuality;
      EventWorkType? workType;
      if (indiv != null) workType = EventWorkType.values.getOrNull(indiv - 1);
      String indivName;
      indivName = workType != null
          ? Transl.enums(workType, (enums) => enums.eventWorkType).l
          : '$indiv';
      if (indiv != null) {
        spans.add(CenterWidgetSpan(
          child: db.getIconImage(
            EventWorkTypeX.getIcon(indiv),
            width: 20,
            aspectRatio: 1,
          ),
        ));
      }
      spans.add(TextSpan(text: '〔$indivName〕'));
    } else if ([
      FuncType.eventDropUp,
      FuncType.eventDropRateUp,
      FuncType.eventPointUp,
      FuncType.eventPointRateUp,
    ].contains(func.funcType)) {
      int? indiv = func.svals.getOrNull(0)?.Individuality;
      final items = db.gameData.items.values
          .where((item) => item.individuality.any((trait) => trait.id == indiv))
          .toList();
      if (items.isEmpty) {
        spans.add(TextSpan(text: '$indiv  '));
      }
      for (final item in items) {
        spans.add(TextSpan(
          children: [
            CenterWidgetSpan(
                child:
                    Item.iconBuilder(context: context, item: item, width: 20)),
            TextSpan(text: ' ${item.lName.l}  ')
          ],
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              item.routeTo();
            },
        ));
      }
    }
    if (icon != null) {
      spans.insert(
        0,
        CenterWidgetSpan(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: icon,
          ),
        ),
      );
    }

    if ((vals?.Rate != null && vals!.Rate! < 0) ||
        (vals?.UseRate != null && vals!.UseRate! < 0)) {
      // print(vals.Rate);
      final hint = Transl.misc('Func.ifPrevFuncSucceed');
      spans.add(TextSpan(text: '(${hint.l})'));
    }

    void _addFuncTarget() {
      if ([
        FuncType.eventDropUp,
        FuncType.eventDropRateUp,
        FuncType.eventPointUp,
        FuncType.eventPointRateUp,
        FuncType.eventFortificationPointUp,
      ].contains(func.funcType)) {
        return;
      }
      // if (showPlayer && showEnemy) return;
      if (lastFuncTarget == func.funcTargetType) return;
      spans.add(
          TextSpan(text: '[${Transl.funcTargetType(func.funcTargetType).l}] '));
    }

    _addFuncTarget();

    void _addFuncText() {
      final text = funcText.toString();
      final style = func.isEnemyOnlyFunc
          ? const TextStyle(fontStyle: FontStyle.italic)
          : null;

      InlineSpan _replaceTrait(int trait) {
        return TextSpan(
          children: SharedBuilder.replaceSpan(text, '{0}', [
            SharedBuilder.traitSpan(
              context: context,
              trait: NiceTrait(id: trait),
            )
          ]),
          style: style,
        );
      }

      switch (func.funcType) {
        case FuncType.damageNpIndividual:
        case FuncType.damageNpStateIndividualFix:
          int? indiv = vals?.Target;
          if (indiv != null) {
            spans.add(_replaceTrait(indiv));
            return;
          }
          break;
        case FuncType.damageNpIndividualSum:
          if ((vals?.TargetList?.length ?? 0) > 0) {
            spans.addAll(SharedBuilder.replaceSpanMap(
                text, RegExp(r'\{[0-1]\}'), (match) {
              final s = match[0]!;
              if (s == "{0}") {
                return [
                  TextSpan(
                    children: SharedBuilder.traitSpans(
                      context: context,
                      traits: [
                        for (int indiv in vals?.TargetList ?? [])
                          NiceTrait(id: indiv),
                      ],
                    ),
                    style: style,
                  )
                ];
              } else if (s == "{1}") {
                final target = vals?.Target == 0
                    ? M.of(jp: '自身', cn: '自身', tw: '自身', na: 'self', kr: '자신')
                    : M.of(
                        jp: '対象', cn: '对象', tw: '對象', na: 'target', kr: '대상');
                return [
                  TextSpan(text: target),
                ];
              } else {
                return [TextSpan(text: s)];
              }
            }));
            return;
          }
          break;
        default:
          break;
      }
      if (func.buffs.isNotEmpty) {
        final buff = func.buffs.first;
        switch (buff.type) {
          case BuffType.addIndividuality:
          case BuffType.subIndividuality:
          case BuffType.fieldIndividuality:
            int? indiv = vals?.Value;
            if (indiv != null) {
              spans.add(_replaceTrait(indiv));
              return;
            }
            break;
          case BuffType.toFieldChangeField:
            int? indiv = vals?.FieldIndividuality;
            if (indiv != null) {
              spans.add(_replaceTrait(indiv));
              return;
            }
            break;
          default:
            break;
        }
      }
      spans.add(TextSpan(
        text: text,
        style: style,
      ));
    }

    _addFuncText();

    if (func.funcType == FuncType.transformServant) {
      final transformId = vals?.Value, transformLimit = vals?.SetLimitCount;
      if (transformId != null) {
        spans.add(SharedBuilder.textButtonSpan(
          context: context,
          text: transformLimit == null
              ? ' $transformId '
              : ' $transformId[${S.current.ascension_short}$transformLimit] ',
          onTap: () {
            router.push(url: Routes.servantI(transformId));
          },
        ));
      }
    } else if ([
          FuncType.enemyEncountRateUp,
          FuncType.enemyEncountCopyRateUp,
        ].contains(func.funcType) &&
        vals?.Individuality != null) {
      spans.add(TextSpan(children: [
        const TextSpan(text: ' '),
        SharedBuilder.traitSpan(
          context: context,
          trait: NiceTrait(id: vals!.Individuality!),
        ),
      ]));
    }

    if (vals?.AddLinkageTargetIndividualty != null &&
        vals?.BehaveAsFamilyBuff == 1) {
      final color = Theme.of(context).textTheme.caption?.color;
      spans.add(const TextSpan(text: '('));
      spans.add(CenterWidgetSpan(
        child: FaIcon(
          FontAwesomeIcons.link,
          size: 12,
          color: color,
        ),
      ));
      if (vals?.UnSubStateWhileLinkedToOthers == 1) {
        spans.add(CenterWidgetSpan(
          child: FaIcon(
            FontAwesomeIcons.linkSlash,
            size: 12,
            color: color,
          ),
        ));
      }
      spans.add(TextSpan(text: '${vals?.AddLinkageTargetIndividualty}'));
      spans.add(const TextSpan(text: ')'));
    }

    List<List<InlineSpan>> _traitSpans = [];
    void _addTraits(String? prefix, List<NiceTrait> traits,
        [bool useAnd = false]) {
      if ([BuffType.upCommandall, BuffType.downCommandall]
          .contains(func.buffs.getOrNull(0)?.type)) {
        traits = traits
            .where((e) => ![
                  Trait.cardQuick,
                  Trait.cardArts,
                  Trait.cardBuster,
                  Trait.cardExtra
                ].contains(e.name))
            .toList();
      }
      if (traits.isEmpty) return;
      _traitSpans.add([
        if (prefix != null) TextSpan(text: prefix),
        ...SharedBuilder.traitSpans(
          context: context,
          traits: traits,
          useAndJoin: useAnd,
        ),
        const TextSpan(text: ' '), // not let recognizer extends its width
      ]);
    }

    switch (func.funcType) {
      case FuncType.addState:
      case FuncType.addStateShort:
      case FuncType.addFieldChangeToField:
        final buff = func.buffs.first;
        _addTraits(Transl.special.buffCheckSelf, buff.ckSelfIndv,
            buff.script?.checkIndvType == 1);
        _addTraits(Transl.special.buffCheckOpposite, buff.ckOpIndv,
            buff.script?.checkIndvType == 1);
        break;
      default:
        break;
    }
    if (func.traitVals.isNotEmpty) {
      if (func.funcType == FuncType.subState) {
        _addTraits(Transl.special.funcTraitRemoval, func.traitVals);
      } else if (func.funcType == FuncType.gainNpBuffIndividualSum) {
        spans.addAll(SharedBuilder.replaceSpan(
            Transl.special.funcTraitPerBuff,
            '{0}',
            SharedBuilder.traitSpans(
                context: context, traits: func.traitVals)));
      } else if (func.funcType == FuncType.eventDropUp) {
        _addTraits(Transl.special.buffCheckSelf, func.traitVals);
      }
    }
    if (func.funcType != FuncType.subState ||
        func.traitVals.map((e) => e.id).join(',') !=
            func.functvals.map((e) => e.id).join(',')) {
      _addTraits(Transl.special.funcTargetVals, func.functvals);
    }

    if (func.funcquestTvals.isNotEmpty) {
      _traitSpans.add(SharedBuilder.replaceSpan(
        Transl.special.funcTraitOnField,
        '{0}',
        SharedBuilder.traitSpans(
          context: context,
          traits: func.funcquestTvals,
        ),
      ));
    }
    if (vals?.EventId != null && vals?.EventId != 0 && showEvent) {
      final eventName = db.gameData.events[vals?.EventId]?.lShortName.l
              .replaceAll('\n', ' ') ??
          'Event ${vals?.EventId}';
      _traitSpans
          .add(SharedBuilder.replaceSpan(Transl.special.funcEventOnly, '{0}', [
        TextSpan(
          text: eventName,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              router.push(url: Routes.eventI(vals!.EventId!));
            },
        ),
      ]));
    }

    final ownerIndiv = func.buffs.getOrNull(0)?.script?.INDIVIDUALITIE;
    if (ownerIndiv != null) {
      _addTraits(Transl.special.buffCheckSelf, [ownerIndiv]);
    }

    for (int index = 0; index < _traitSpans.length; index++) {
      spans.add(
          TextSpan(text: index == _traitSpans.length - 1 ? '\n ┗ ' : '\n ┣ '));
      spans.addAll(_traitSpans[index]);
    }

    Widget title = Text.rich(
      TextSpan(children: spans),
      style: Theme.of(context).textTheme.caption,
    );
    title = InkWell(
      onTap: () => func.routeTo(region: region),
      child: title,
    );
    Widget last = _DescriptorWrapper(
      title: title,
      trailing: trailing,
      lvCells: lvCells,
      ocCells: ocCells,
      supportCells: supportCells,
      selected: level,
    );

    final triggerSkill = _buildTrigger(context);
    final dependFunc = _buildDependFunc(context);
    if (triggerSkill != null || dependFunc != null) {
      last = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [last, triggerSkill, dependFunc].whereType<Widget>().toList(),
      );
    }
    last = Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: last,
    );
    return last;
  }

  Widget? _buildTrigger(BuildContext context) {
    final trigger = kBuffValueTriggerTypes[func.buffs.getOrNull(0)?.type];
    if (trigger == null) return null;

    DataVals? vals;
    vals = func.svals.getOrNull((level ?? 1) - 1);
    bool noLevel = vals == null;

    vals ??= func.svals.getOrNull(0);
    final detail = vals == null ? null : trigger(vals);
    if (detail == null) return null;

    if (noLevel) detail.level = null;
    final isNp = func.svals.first.UseTreasureDevice == 1;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
      child: _LazyTrigger(
        trigger: detail,
        buff: func.buffs.first,
        isNp: isNp,
        showPlayer: func.funcTargetType.isEnemy ? showEnemy : showPlayer,
        showEnemy: func.funcTargetType.isEnemy ? showPlayer : showEnemy,
        endlessLoop: owner?.id == detail.skill &&
            (isNp ? owner is BaseTd : owner is BaseSkill),
        region: region,
      ),
    );
  }

  Widget? _buildDependFunc(BuildContext context) {
    final dependFuncId = func.svals.getOrNull(0)?.DependFuncId;
    if (dependFuncId == null) return null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
      child: _LazyFunc(
        dependFuncId: dependFuncId,
        trigger: func,
        level: level,
        endlessLoop: func.funcId == dependFuncId,
        region: region,
      ),
    );
  }

  // ignore: unused_element
  Map<String, dynamic> _getFuncJson() {
    List<String> _traitList(List<NiceTrait> traits) {
      return traits.map((e) => e.shownName()).toList();
    }

    final buff = func.buffs.getOrNull(0);
    final script = buff?.script;
    return {
      "type": '${Transl.funcType(func.funcType).l}/${func.funcType.name}',
      "target":
          '${Transl.funcTargetType(func.funcTargetType).l}/${func.funcTargetType.name}',
      "team": func.funcTargetTeam.name,
      "popupText": func.lPopupText.l,
      if (func.functvals.isNotEmpty) "targetTraits": _traitList(func.functvals),
      if (func.funcquestTvals.isNotEmpty)
        "fieldTraits": _traitList(func.funcquestTvals),
      if (func.traitVals.isNotEmpty)
        "funcTargetTraits": _traitList(func.traitVals),
      if (buff != null) ...{
        "----buff----": "↓",
        "id": buff.id,
        "name": Transl.buffNames(buff.name).l,
        "buffType": '${Transl.buffType(buff.type).l}/${buff.type.name}',
        "detail": Transl.buffDetail(buff.detail).l,
        if (buff.ckSelfIndv.isNotEmpty)
          "ckSelfIndv": _traitList(buff.ckSelfIndv),
        if (buff.ckOpIndv.isNotEmpty) "ckOpIndv": _traitList(buff.ckOpIndv),
        "buffGroup": buff.buffGroup,
        if (buff.vals.isNotEmpty) "buffTraits": _traitList(buff.vals),
        "maxRate": buff.maxRate,
        if (script != null) ...{
          "----script----": "↓",
          if (script.checkIndvType != null)
            "checkIndvType": script.checkIndvType,
          if (script.CheckOpponentBuffTypes != null)
            "CheckOpponentBuffTypes": script.CheckOpponentBuffTypes!
                .map((e) => '${e.name}(${Transl.buffType(e).l})')
                .toList(),
          if (script.relationId != null)
            "relationId": "!BuffRelationOverwrite!",
          if (script.ReleaseText != null) "ReleaseText": script.ReleaseText,
          if (script.DamageRelease != null)
            "DamageRelease": script.DamageRelease,
          if (script.INDIVIDUALITIE != null)
            "INDIVIDUALITIE": script.INDIVIDUALITIE?.shownName(),
          if (script.UpBuffRateBuffIndiv != null)
            "UpBuffRateBuffIndiv": _traitList(script.UpBuffRateBuffIndiv!),
          if (script.HP_LOWER != null) "HP_LOWER": script.HP_LOWER,
        }
      }
    };
  }
}

class _LazyTrigger extends StatefulWidget {
  final BuffValueTriggerType trigger;
  final Buff buff;
  final bool isNp;
  final bool showPlayer;
  final bool showEnemy;
  final bool endlessLoop;
  final Region? region;

  const _LazyTrigger({
    required this.trigger,
    required this.buff,
    required this.isNp,
    required this.showPlayer,
    required this.showEnemy,
    required this.endlessLoop,
    required this.region,
  });

  @override
  State<_LazyTrigger> createState() => __LazyTriggerState();
}

class __LazyTriggerState extends State<_LazyTrigger> with FuncsDescriptor {
  SkillOrTd? skill;

  @override
  void initState() {
    super.initState();
    _fetchSkill();
  }

  @override
  void didUpdateWidget(covariant _LazyTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger.skill != oldWidget.trigger.skill) {
      _fetchSkill();
    }
  }

  void _fetchSkill() async {
    skill = null;
    if (widget.region == null || widget.region == Region.jp) {
      if (!widget.isNp) {
        skill = db.gameData.baseTds[widget.trigger.skill];
      } else {
        skill = db.gameData.baseSkills[widget.trigger.skill];
      }
    }
    if (skill != null) return;

    final skillId = widget.trigger.skill;
    if (skillId == null) {
      skill = null;
    } else if (widget.isNp) {
      skill = db.gameData.baseTds[skillId] ??
          await AtlasApi.td(skillId, region: widget.region ?? Region.jp);
    } else {
      skill = db.gameData.baseSkills[skillId] ??
          await AtlasApi.skill(skillId, region: widget.region ?? Region.jp);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String title = 'ID ${widget.trigger.skill}';
    if (skill != null) {
      title += ': ${skill!.lName.l}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => skill?.routeTo(),
          child: Text.rich(TextSpan(
            style: Theme.of(context).textTheme.caption,
            children: [
              TextSpan(
                text: '  $title ',
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
              TextSpan(
                  text:
                      ' [${Transl.funcPopuptextBase(widget.buff.type.name).l}]')
            ],
            // recognizer: TapGestureRecognizer()..onTap = () => skill?.routeTo(),
          )),
        ),
        if (!widget.endlessLoop)
          ...describeFunctions(
            funcs: skill?.functions ?? [],
            script: skill?.script,
            showPlayer: widget.showPlayer,
            showEnemy: widget.showEnemy,
            level: widget.trigger.level,
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
            owner: skill,
            region: widget.region,
          ),
        if (widget.endlessLoop)
          Center(
            child: Text(
              '∞',
              style: Theme.of(context).textTheme.caption,
            ),
          )
      ],
    );
  }
}

class _LazyFunc extends StatefulWidget {
  final int dependFuncId;
  final NiceFunction trigger;
  final int? level;
  final bool endlessLoop;
  final Region? region;

  const _LazyFunc({
    required this.dependFuncId,
    required this.trigger,
    required this.level,
    required this.endlessLoop,
    required this.region,
  });

  @override
  State<_LazyFunc> createState() => ___LazyFuncState();
}

class ___LazyFuncState extends State<_LazyFunc> with FuncsDescriptor {
  BaseFunction? func;

  @override
  void initState() {
    super.initState();
    _fetchFunc();
  }

  @override
  void didUpdateWidget(covariant _LazyFunc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dependFuncId != oldWidget.dependFuncId) {
      _fetchFunc();
    }
  }

  void _fetchFunc() async {
    func = null;
    if (widget.region == null || widget.region == Region.jp) {
      func = db.gameData.baseFunctions[widget.dependFuncId];
    }
    func ??= await AtlasApi.func(widget.dependFuncId,
        region: widget.region ?? Region.jp);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _func = func;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.endlessLoop)
          ...describeFunctions(
            funcs: [
              if (_func != null)
                NiceFunction(
                  funcId: _func.funcId,
                  funcType: _func.funcType,
                  funcTargetType: _func.funcTargetType,
                  funcTargetTeam: _func.funcTargetTeam,
                  funcPopupText: _func.funcPopupText,
                  funcPopupIcon: _func.funcPopupIcon,
                  functvals: _func.functvals,
                  funcquestTvals: _func.funcquestTvals,
                  funcGroup: _func.funcGroup,
                  traitVals: _func.traitVals,
                  buffs: _func.buffs,
                  svals: _getDependVals(widget.trigger.svals),
                  svals2: _getDependVals(widget.trigger.svals2),
                  svals3: _getDependVals(widget.trigger.svals3),
                  svals4: _getDependVals(widget.trigger.svals4),
                  svals5: _getDependVals(widget.trigger.svals5),
                ),
            ],
            script: null,
            level: widget.level,
            showPlayer: true,
            showEnemy: true,
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
            region: widget.region,
          ),
        if (widget.endlessLoop)
          Center(
            child: Text(
              '∞',
              style: Theme.of(context).textTheme.caption,
            ),
          )
      ],
    );
  }

  List<DataVals>? _getDependVals(List<DataVals>? svals) {
    if (svals == null) return null;
    final dependsvals = svals.map((e) => e.DependFuncVals).toList();
    if (dependsvals.any((e) => e == null)) return null;
    if (widget.trigger.funcType == FuncType.gainNpFromTargets ||
        widget.trigger.funcType == FuncType.absorbNpturn) {
      return dependsvals
          .map((e) => DataVals(e!.toJson()..remove('Value2')))
          .toList();
    }
    return List.from(dependsvals);
  }
}
