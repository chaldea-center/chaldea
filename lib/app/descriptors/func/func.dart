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
  }) {
    funcs = funcs.where((func) {
      if (!showNone && func.funcType == FuncType.none) return false;
      if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy) {
        return true;
      }
      bool player = func.funcTargetTeam == FuncApplyTarget.player;
      if (func.funcTargetType.isEnemy) {
        player = !player;
      }
      return player ? showPlayer : showEnemy;
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
  const FuncDescriptor({
    Key? key,
    required this.func,
    this.lastFuncTarget,
    this.level,
    this.padding,
    this.showPlayer = true,
    this.showEnemy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = StringBuffer();
    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      if (func.buffs.first.name.isEmpty) {
        funcText.write(Transl.buffNames(func.buffs.first.type.name).l);
      } else {
        funcText.write(Transl.buffNames(func.buffs.first.name).l);
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
        if (count > 0)
          M.of(
            jp: '$count回',
            cn: '$count次',
            na: '$count Times',
          ),
        if (turn > 0)
          M.of(
            jp: '$turnターン',
            cn: '$turn回合',
            na: '$turn Turns',
          ),
      ].join(M.of(jp: '·', na: ', ')));
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
          func.funcType == FuncType.eventDropRateUp) {
        int? indiv = func.svals.getOrNull(0)?.Individuality;
        final item = db.gameData.items.values.firstWhereOrNull(
            (item) => item.individuality.any((trait) => trait.id == indiv));
        if (item != null) {
          icon = Item.iconBuilder(context: context, item: item, width: 24);
          spans.add(TextSpan(
            text: item.lName.l + '  ',
            style: const TextStyle(fontSize: 13),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                item.routeTo();
              },
          ));
        } else {
          spans.add(TextSpan(text: indiv.toString() + '  '));
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
      void _addFuncTarget() {
        if ([
          FuncType.eventDropUp,
          FuncType.eventDropRateUp,
          FuncType.eventPointUp,
          FuncType.eventPointRateUp,
        ].contains(func.funcType)) {
          return;
        }
        if (showPlayer && showEnemy) return;
        if (lastFuncTarget == func.funcTargetType) return;
        spans.add(TextSpan(
            text: '[${Transl.funcTargetType(func.funcTargetType).l}] '));
      }

      _addFuncTarget();

      spans.add(TextSpan(text: funcText.toString()));
      DataVals? vals = func.svals.getOrNull(0);

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
        if (prefix != null) spans.add(TextSpan(text: prefix));
        for (final trait in traits) {
          spans.add(CenterWidgetSpan(
              child: SharedBuilder.trait(context: context, trait: trait)));
        }
      }

      switch (func.funcType) {
        case FuncType.subState:
          for (final trait in func.traitVals) {
            spans.add(CenterWidgetSpan(
                child: SharedBuilder.trait(context: context, trait: trait)));
          }
          break;
        case FuncType.damageNpIndividual:
        case FuncType.damageNpStateIndividualFix:
          int? indiv = vals?.Target;
          if (indiv != null) {
            spans.add(CenterWidgetSpan(
              child: SharedBuilder.trait(
                context: context,
                trait: NiceTrait(id: indiv),
              ),
            ));
          }
          break;
        case FuncType.damageNpIndividualSum:
          for (int indiv in vals?.TargetList ?? []) {
            spans.add(CenterWidgetSpan(
              child: SharedBuilder.trait(
                context: context,
                trait: NiceTrait(id: indiv),
              ),
            ));
          }
          break;
        case FuncType.addState:
        case FuncType.addStateShort:
          final buff = func.buffs.first;
          _addTraits('  For:', buff.ckSelfIndv);
          _addTraits('  On:', buff.ckOpIndv);
          break;
        default:
          break;
      }
      _addTraits('  On:', func.functvals);
      _addTraits('  On Field:', func.funcquestTvals);

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
              List<String> _traitList(List<NiceTrait> traits) {
                return traits.map((e) => Transl.trait(e.id).l).toList();
              }

              return Theme(
                data: ThemeData.light(),
                child: SimpleCancelOkDialog(
                  title: const Text('Func Detail'),
                  content: JsonViewer({
                    "ID": func.funcId,
                    "Type": func.funcType.name,
                    "Target": func.funcTargetType.name,
                    "Team": func.funcTargetTeam.name,
                    if (func.functvals.isNotEmpty)
                      "TargetTraits": _traitList(func.functvals),
                    if (func.funcquestTvals.isNotEmpty)
                      "FieldTraits": _traitList(func.funcquestTvals),
                    if (func.traitVals.isNotEmpty)
                      "RemovalTraits": _traitList(func.traitVals),
                    if (func.buffs.isNotEmpty) ...{
                      "BuffId": func.buffs.first.id,
                      "BuffName": func.buffs.first.name,
                      "BuffType": func.buffs.first.type.name
                    }
                  }),
                  scrollable: true,
                  hideCancel: true,
                ),
              );
            },
          );
        },
      );
      child = Row(
        children: [
          Expanded(child: child, flex: perLine - 1),
          Expanded(child: trailing),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
      child: _LazyTrigger(
        trigger: detail,
        isNp: func.svals.first.UseTreasureDevice == 1,
        showPlayer: func.funcTargetType.isEnemy ? showEnemy : showPlayer,
        showEnemy: func.funcTargetType.isEnemy ? showPlayer : showEnemy,
      ),
    );
  }
}

class _LazyTrigger extends StatefulWidget {
  final BuffValueTriggerType trigger;
  final bool isNp;
  final bool showPlayer;
  final bool showEnemy;

  const _LazyTrigger({
    Key? key,
    required this.trigger,
    required this.isNp,
    required this.showPlayer,
    required this.showEnemy,
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
      skill = await AtlasApi.td(skillId);
    } else {
      skill = db.gameData.baseSkills[skillId] ?? await AtlasApi.skill(skillId);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String title = '${widget.trigger.skill}';
    if (skill != null) {
      title += ': ${skill!.lName.l}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $title ',
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(decoration: TextDecoration.underline),
        ),
        ...describeFunctions(
          funcs: skill?.functions ?? [],
          showPlayer: widget.showPlayer,
          showEnemy: widget.showEnemy,
          level: widget.trigger.level,
          padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
        )
      ],
    );
  }
}
