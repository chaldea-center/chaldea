import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
    bool showEvent = true,
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
        showEvent: showEvent,
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
  final bool showEvent;

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
    this.showEvent = true,
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
          funcText.write(Transl.buffType(func.buffs.first.type).l);
        } else {
          funcText.write(Transl.buffNames(func.buffs.first.name).l);
        }
      }
    } else {
      funcText.write(Transl.funcPopuptext(func).l);
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

      if (mutatingLvVals.isNotEmpty) {
        funcText.write('<Lv>');
        levels.add(ValListDsc(
          func: func,
          mutaingVals: mutatingLvVals,
          originVals: func.svals,
          selected: level,
        ));
      }
      if (mutatingOCVals.isNotEmpty) {
        funcText.write('<OC>');
        levels.add(ValListDsc(
          func: func,
          mutaingVals: mutatingOCVals,
          originVals: func.ocVals(0),
          selected: null,
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
        final items = db.gameData.items.values
            .where(
                (item) => item.individuality.any((trait) => trait.id == indiv))
            .toList();
        if (items.isEmpty) {
          spans.add(TextSpan(text: '$indiv  '));
        }
        for (final item in items) {
          spans.add(TextSpan(
            children: [
              CenterWidgetSpan(
                  child: Item.iconBuilder(
                      context: context, item: item, width: 20)),
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
                  SharedBuilder.traitSpan(
                    context: context,
                    trait: NiceTrait(id: indiv),
                  )
                ]),
                style: style,
              ));
              return;
            }
            break;
          case FuncType.damageNpIndividualSum:
            if ((vals?.TargetList?.length ?? 0) > 0) {
              spans.addAll(replaceSpanMap(text, RegExp(r'\{[0-1]\}'), (match) {
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
                  return [
                    TextSpan(
                        text: vals?.Target == 0
                            ? M.of(
                                jp: '自身',
                                cn: '自身',
                                tw: '自身',
                                na: 'self',
                                kr: '자신',
                              )
                            : M.of(
                                jp: '対象',
                                cn: '对象',
                                tw: '對象',
                                na: 'target',
                                kr: '대상',
                              )),
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
          spans.addAll(replaceSpan(
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
        _traitSpans.add(replaceSpan(
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
        _traitSpans.add(replaceSpan(Transl.special.funcEventOnly, '{0}', [
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
          return func.routeTo();
          // showDialog(
          //   context: context,
          //   useRootNavigator: false,
          //   builder: (context) {
          //     return Theme(
          //       data: ThemeData.light(),
          //       child: SimpleCancelOkDialog(
          //         title: Text('Func ${func.funcId}'),
          //         content: JsonViewer(_getFuncJson(), defaultOpen: true),
          //         scrollable: true,
          //         hideCancel: true,
          //         contentPadding: const EdgeInsetsDirectional.fromSTEB(
          //             10.0, 10.0, 12.0, 24.0),
          //       ),
          //     );
          //   },
          // );
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
    assert(parts.length > 1, [text, pattern]);
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

  List<InlineSpan> replaceSpanMap(String text, Pattern pattern,
      List<InlineSpan> Function(Match match) replace) {
    List<InlineSpan> spans = [];
    List<String> textParts = text.split(pattern);
    bool mapped = false;
    text.splitMapJoin(pattern, onMatch: (match) {
      assert(textParts.isNotEmpty);
      spans.add(TextSpan(text: textParts.removeAt(0)));
      spans.addAll(replace(match));
      mapped = true;
      return match.group(0)!;
    });
    assert(textParts.length == 1);
    spans.addAll(textParts.map((e) => TextSpan(text: e)));
    assert(mapped, [text, pattern]);
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

  // ignore: unused_element
  Map<String, dynamic> _getFuncJson() {
    List<String> _traitList(List<NiceTrait> traits) {
      return traits.map((e) => e.shownName).toList();
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
