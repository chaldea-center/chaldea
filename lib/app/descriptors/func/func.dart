import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'vals.dart';

mixin FuncsDescriptor {
  List<Widget> describeFunctions({
    required List<NiceFunction> funcs,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
  }) =>
      describe(
        funcs: funcs,
        showPlayer: showPlayer,
        showEnemy: showEnemy,
        showNone: showNone,
        level: level,
        padding: padding,
        showBuffDetail: showBuffDetail,
        owner: owner,
      );

  static List<Widget> describe({
    required List<NiceFunction> funcs,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
  }) {
    funcs = funcs.where((func) {
      if (!showNone && func.funcType == FuncType.none) return false;
      if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy) {
        return true;
      }
      return func.isPlayerOnlyFunc ? showPlayer : showEnemy;
    }).toList();
    List<Widget> children = [];

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
      ));
    }
    return children;
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
  const FuncDescriptor({
    Key? key,
    required this.func,
    this.lastFuncTarget,
    this.level,
    this.padding,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showBuffDetail = false,
    this.owner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = StringBuffer();
    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      if (showBuffDetail) {
        funcText.write(Transl.buffDetail(func.buffs.first.detail).l);
      } else {
        if (func.buffs.first.name.isEmpty) {
          funcText.write(Transl.buffNames(func.buffs.first.type.name).l);
        } else {
          funcText.write(Transl.buffNames(func.buffs.first.name).l);
        }
      }
    } else {
      funcText.write(Transl.funcPopuptext(func.funcPopupText, func.funcType).l);
    }

    final staticVal = func.getStaticVal();
    final crossVals = func.crossVals;
    final mutatingVals = func.getMutatingVals(staticVal);

    int turn = staticVal.Turn ?? -1, count = staticVal.Count ?? -1;
    if (turn > 0 || count > 0) {
      funcText.write(' (');
      funcText.write([
        if (count > 0) Transl.special.funcValCountTimes(count),
        if (turn > 0) Transl.special.funcValTurns(turn),
      ].join(M.of(jp: '·', cn: '·', tw: '·', na: ', ', kr: ', ')));
      funcText.write(')');
    }
    final lvVals = func.svals;
    final ocVals = func.ocVals(0);
    final int lvNum = lvVals.toSet().length, ocNum = ocVals.toSet().length;

    if (func.svals.length == 5) {
      if (lvNum > 1) {
        funcText.write('<Lv>');
      }
      if (ocNum > 1) {
        funcText.write('<OC>');
      }
    }
    return LayoutBuilder(builder: (context, constraints) {
      int perLine =
          constraints.maxWidth > 600 && func.svals.length > 5 ? 10 : 5;
      Widget trailing;
      List<Widget> levels = [];
      trailing = ValDsc(
        func: func,
        vals: staticVal,
        originVals: func.svals.getOrNull(0),
        ignoreRate: true,
        ignoreCount: true,
      );

      if (mutatingVals.isNotEmpty) {
        levels.add(ValListDsc(
          func: func,
          mutaingVals: mutatingVals,
          originVals: crossVals,
          selected: ocNum > 1 ? null : level,
        ));
      }
      List<InlineSpan> spans = [];
      Widget? icon;
      if (func.funcPopupIcon != null) {
        icon = db.getIconImage(func.funcPopupIcon, width: 18);
      } else if (func.funcType == FuncType.eventDropUp ||
          func.funcType == FuncType.eventDropRateUp ||
          func.funcType == FuncType.eventPointUp) {
        int? indiv = func.svals.getOrNull(0)?.Individuality;
        final item = db.gameData.items.values.firstWhereOrNull(
            (item) => item.individuality.any((trait) => trait.id == indiv));
        if (item != null) {
          icon = Item.iconBuilder(context: context, item: item, width: 24);
          spans.add(TextSpan(
            text: '${item.lName.l}  ',
            style: const TextStyle(fontSize: 13),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                item.routeTo();
              },
          ));
        } else {
          spans.add(TextSpan(text: '$indiv  '));
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
      DataVals? vals = func.svals.getOrNull(0);

      if ((vals?.Rate != null && vals!.Rate! < 0) ||
          (vals?.UseRate != null && vals!.UseRate! < 0)) {
        print(vals.Rate);
        final hint =
            Transl.string(Transl.md.enums.funcTargetType, "ifPrevFuncSucceed");
        spans.add(TextSpan(text: '(${hint.l})'));
      }

      void _addFuncTarget() {
        if ([
          FuncType.eventDropUp,
          FuncType.eventDropRateUp,
          FuncType.eventPointUp,
          FuncType.eventPointRateUp,
        ].contains(func.funcType)) {
          return;
        }
        // if (showPlayer && showEnemy) return;
        if (lastFuncTarget == func.funcTargetType) return;
        spans.add(TextSpan(
            text: '[${Transl.funcTargetType(func.funcTargetType).l}] '));
      }

      _addFuncTarget();

      void _addFuncText() {
        final text = funcText.toString();
        final style = func.isEnemyOnlyFunc
            ? const TextStyle(fontStyle: FontStyle.italic)
            : null;
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpStateIndividualFix:
            int? indiv = vals?.Target;
            if (indiv != null) {
              spans.add(TextSpan(
                children: replaceSpan(text, '{0}', [
                  CenterWidgetSpan(
                    child: SharedBuilder.trait(
                      context: context,
                      trait: NiceTrait(id: indiv),
                      textScaleFactor: 0.85,
                    ),
                  )
                ]),
                style: style,
              ));
              return;
            }
            break;
          case FuncType.damageNpIndividualSum:
            if ((vals?.TargetList?.length ?? 0) > 0) {
              spans.add(TextSpan(
                children: replaceSpan(text, '{0}', [
                  for (int indiv in vals?.TargetList ?? [])
                    CenterWidgetSpan(
                      child: SharedBuilder.trait(
                        context: context,
                        trait: NiceTrait(id: indiv),
                        textScaleFactor: 0.85,
                      ),
                    )
                ]),
                style: style,
              ));
              return;
            }
            break;
          default:
            break;
        }
        spans.add(TextSpan(
          text: text,
          style: style,
        ));
      }

      _addFuncText();

      List<List<InlineSpan>> _traitSpans = [];
      void _addTraits(String? prefix, List<NiceTrait> traits) {
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
          for (final trait in traits)
            CenterWidgetSpan(
              child: SharedBuilder.trait(
                  context: context, trait: trait, textScaleFactor: 0.85),
            )
        ]);
      }

      switch (func.funcType) {
        case FuncType.addState:
        case FuncType.addStateShort:
          final buff = func.buffs.first;
          _addTraits(Transl.special.buffCheckSelf, buff.ckSelfIndv);
          _addTraits(Transl.special.buffCheckOpposite, buff.ckOpIndv);
          break;
        default:
          break;
      }
      if (func.traitVals.isNotEmpty) {
        _addTraits(Transl.special.funcTraitRemoval, func.traitVals);
      }
      if (func.funcType != FuncType.subState ||
          func.traitVals.map((e) => e.id).join(',') !=
              func.functvals.map((e) => e.id).join(',')) {
        _addTraits(Transl.special.funcTargetVals, func.functvals);
      }

      if (func.funcquestTvals.isNotEmpty) {
        _traitSpans.add(replaceSpan(
          Transl.special.funcTraitOnField,
          '{0}',
          SharedBuilder.traitSpans(
              context: context,
              traits: func.funcquestTvals,
              textScaleFactor: 0.85),
        ));
      }
      for (int index = 0; index < _traitSpans.length; index++) {
        spans.add(TextSpan(
            text: index == _traitSpans.length - 1 ? '\n ┗ ' : '\n ┣ '));
        spans.addAll(_traitSpans[index]);
      }

      Widget child = Text.rich(
        TextSpan(children: spans),
        style: Theme.of(context).textTheme.caption,
      );
      child = InkWell(
        child: child,
        onTap: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return Theme(
                data: ThemeData.light(),
                child: SimpleCancelOkDialog(
                  title: Text('Func ${func.funcId}'),
                  content: JsonViewer(_getFuncJson()),
                  scrollable: true,
                  hideCancel: true,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      10.0, 10.0, 12.0, 24.0),
                ),
              );
            },
          );
        },
      );
      double maxWidth = 80;
      if (constraints.maxWidth != double.infinity) {
        maxWidth = max(maxWidth, constraints.maxWidth / 3);
        maxWidth = min(maxWidth, constraints.maxWidth / 2.5);
      }
      child = Row(
        children: [
          Expanded(flex: perLine - 1, child: child),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 20),
            child: trailing,
          ),
        ],
      );
      if (levels.isNotEmpty) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [child, ...levels],
        );
      }

      final triggerSkill = _buildTrigger(context);
      if (triggerSkill != null) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [child, triggerSkill],
        );
      }
      child = Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      );
      return child;
    });
  }

  List<InlineSpan> replaceSpan(
      String text, Pattern pattern, List<InlineSpan> replace) {
    final parts = text.split(pattern);
    if (parts.length == 1) return [TextSpan(text: text), ...replace];
    List<InlineSpan> spans = [];
    for (int index = 0; index < parts.length; index++) {
      spans.add(TextSpan(text: parts[index]));
      if (index != parts.length - 1) {
        spans.addAll(replace);
      }
    }
    return spans;
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
      ),
    );
  }

  Map<String, dynamic> _getFuncJson() {
    List<String> _traitList(List<NiceTrait> traits) {
      return traits.map((e) => e.shownName).toList();
    }

    final buff = func.buffs.getOrNull(0);
    final script = buff?.script;
    return {
      "type": '${func.funcType.name}(${Transl.funcType(func.funcType).l})',
      "target":
          '${func.funcTargetType.name}(${Transl.funcTargetType(func.funcTargetType).l})',
      "team": func.funcTargetTeam.name,
      "popupText": Transl.funcPopuptext(func.funcPopupText).l,
      if (func.functvals.isNotEmpty) "targetTraits": _traitList(func.functvals),
      if (func.funcquestTvals.isNotEmpty)
        "fieldTraits": _traitList(func.funcquestTvals),
      if (func.traitVals.isNotEmpty)
        "removalTraits": _traitList(func.traitVals),
      if (buff != null) ...{
        "----buff----": "↓",
        "id": buff.id,
        "name": Transl.buffNames(buff.name).l,
        "buffType": '${buff.type.name}(${Transl.buffType(buff.type).l})',
        "detail": Transl.buffDetail(buff.detail).l,
        "buffGroup": buff.buffGroup,
        if (buff.vals.isNotEmpty) "buffTraits": _traitList(buff.vals),
        if (buff.ckSelfIndv.isNotEmpty)
          "ckSelfIndv": _traitList(buff.ckSelfIndv),
        if (buff.ckOpIndv.isNotEmpty) "ckOpIndv": _traitList(buff.ckOpIndv),
        "maxRate": buff.maxRate,
        if (script != null) ...{
          "----script----": "",
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
            "INDIVIDUALITIE": script.INDIVIDUALITIE?.shownName,
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

  const _LazyTrigger({
    Key? key,
    required this.trigger,
    required this.buff,
    required this.isNp,
    required this.showPlayer,
    required this.showEnemy,
    required this.endlessLoop,
  }) : super(key: key);

  @override
  State<_LazyTrigger> createState() => __LazyTriggerState();
}

class __LazyTriggerState extends State<_LazyTrigger> with FuncsDescriptor {
  SkillOrTd? skill;

  @override
  void initState() {
    super.initState();
    if (!widget.isNp) {
      skill = db.gameData.baseTds[widget.trigger.skill];
    } else {
      skill = db.gameData.baseSkills[widget.trigger.skill];
    }
    if (skill == null) _fetchSkill();
  }

  @override
  void didUpdateWidget(covariant _LazyTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger.skill != oldWidget.trigger.skill) {
      _fetchSkill();
    }
  }

  void _fetchSkill() async {
    final skillId = widget.trigger.skill;
    if (skillId == null) {
      skill = null;
    } else if (widget.isNp) {
      skill = db.gameData.baseTds[skillId] ?? await AtlasApi.td(skillId);
    } else {
      skill = db.gameData.baseSkills[skillId] ?? await AtlasApi.skill(skillId);
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
        Text.rich(TextSpan(
          style: Theme.of(context).textTheme.caption,
          children: [
            TextSpan(
              text: '  $title ',
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
            TextSpan(
                text: ' [${Transl.funcPopuptext(widget.buff.type.name).l}]')
          ],
        )),
        if (!widget.endlessLoop)
          ...describeFunctions(
            funcs: skill?.functions ?? [],
            showPlayer: widget.showPlayer,
            showEnemy: widget.showEnemy,
            level: widget.trigger.level,
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
            owner: skill,
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
