import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_detail.dart';

class BattleRecorderPanel extends StatefulWidget {
  final BattleData battleData;
  const BattleRecorderPanel({super.key, required this.battleData});

  @override
  State<BattleRecorderPanel> createState() => _BattleRecorderPanelState();
}

class _BattleRecorderPanelState extends State<BattleRecorderPanel> {
  bool complete = false;
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: kMinInteractiveDimension * 2),
            Expanded(
              child: Text(
                'Records',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  complete = !complete;
                });
              },
              icon: const Icon(Icons.text_fields),
              color: complete ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).disabledColor,
              tooltip: 'Show svt/skill name',
              visualDensity: VisualDensity.standard,
            ),
            IconButton(
              onPressed: () async {
                if (kIsWeb && !kPlatformMethods.rendererCanvasKit) {
                  EasyLoading.showError('Web html mode is not supported, please change to canvaskit mode.');
                  return;
                }
                EasyLoading.show();
                try {
                  final data = await controller.capture(pixelRatio: MediaQuery.of(context).devicePixelRatio);
                  if (data == null) {
                    EasyLoading.showError('Something went wrong.');
                    return;
                  }
                  EasyLoading.dismiss();
                  if (!mounted) return;
                  final quest = widget.battleData.niceQuest;
                  final t = DateTime.now();
                  String fn =
                      [t.month, t.day, t.hour, t.minute, t.second].map((e) => e.toString().padLeft(2, '0')).join('_');
                  fn = 'battle_log_${quest?.id}_${quest?.phase}_$fn.png';
                  ImageActions.showSaveShare(
                    context: context,
                    data: data,
                    destFp: joinPaths(db.paths.downloadDir, fn),
                  );
                } catch (e) {
                  EasyLoading.showError(e.toString());
                }
              },
              icon: const Icon(Icons.camera_alt),
              tooltip: S.current.screenshots,
              color: Theme.of(context).colorScheme.primaryContainer,
              visualDensity: VisualDensity.standard,
            ),
          ],
        ),
        Screenshot(
          controller: controller,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: BattleRecorderPanelBase(battleData: widget.battleData, complete: complete),
          ),
        ),
      ],
    );
  }
}

class BattleRecorderPanelBase extends StatelessWidget {
  final BattleData battleData;
  final bool complete;
  const BattleRecorderPanelBase({super.key, required this.battleData, required this.complete});

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    List<Widget> cardChildren = [];
    for (final record in battleData.recorder.records) {
      if (record is BattleProgressWaveRecord) {
        if (cardChildren.isNotEmpty) {
          cards.add(createWave(context, cardChildren));
        }
        cardChildren = [];
        cardChildren.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              '${S.current.quest_wave} ${record.wave}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ));
      } else if (record is BattleSkipWaveRecord) {
        cardChildren.add(Text(
          'Skip Wave ${record.wave}',
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
          textScaleFactor: 1.2,
        ));
      } else if (record is BattleProgressTurnRecord) {
        cardChildren.add(Center(
          child: Text(
            '${S.current.battle_turn} ${record.turn}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ));
      } else if (record is BattleSkillRecord) {
        cardChildren.add(buildSkillLog(context, record));
      } else if (record is BattleOrderChangeRecord) {
        cardChildren.add(prefixIndicator(
          context,
          Text.rich(TextSpan(children: [
            const TextSpan(text: 'Order Change', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ': '),
            ...drawSvt(context, record.onField),
            const TextSpan(text: '⇄ '),
            ...drawSvt(context, record.backup),
          ])),
        ));
      } else if (record is BattleAttackRecord) {
        cardChildren.add(_AttackDetailWidget(record: record, battleData: battleData));
      } else if (record is BattleMessageRecord) {
        cardChildren.add(Text(record.message, style: const TextStyle(fontWeight: FontWeight.bold)));
      } else {
        assert(false, record);
      }
    }
    if (cardChildren.isNotEmpty) {
      cards.add(createWave(context, cardChildren));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cards,
    );
  }

  Widget createWave(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.toList(),
        ),
      ),
    );
  }

  Widget prefixIndicator(BuildContext context, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Icon(Icons.circle, color: Colors.green, size: 8),
        ),
        const SizedBox(width: 4),
        Flexible(child: child),
      ],
    );
  }

  Widget buildSkillLog(BuildContext context, BattleSkillRecord record) {
    final actor = record.activator;
    final skill = record.skill;
    List<InlineSpan> spans = [];
    if (actor != null) {
      spans.addAll(drawSvt(context, actor));
    }
    final pskill = skill.proximateSkill;
    spans.addAll([
      TextSpan(text: '${S.current.skill} '),
      if ((pskill?.num ?? 0) > 0) TextSpan(text: '${pskill?.num} '),
      if (pskill?.icon != null)
        CenterWidgetSpan(
          child: db.getIconImage(
            pskill!.icon,
            height: 18,
            aspectRatio: 1,
            onTap: pskill.routeTo,
            padding: const EdgeInsets.symmetric(vertical: 7),
            placeholder: (context) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
          ),
        ),
      if (pskill != null && (pskill.icon == null || complete))
        SharedBuilder.textButtonSpan(
          context: context,
          text: '${pskill.lName.l} ',
          onTap: pskill.routeTo,
          style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.secondaryContainer),
        ),
      if (skill.skillLv != 0 && complete) TextSpan(text: 'Lv.${skill.skillLv} '),
    ]);
    if (pskill != null) {
      final target = findSkillTarget(pskill, record.fromPlayer, record.targetPlayerSvt, record.targetEnemySvt);
      if (target != null) {
        spans.add(TextSpan(text: '  ${S.current.target}: '));
        spans.addAll(drawSvt(context, target));
      }
    }
    return prefixIndicator(context, Text.rich(TextSpan(children: spans)));
  }

  List<InlineSpan> drawSvt(BuildContext context, BattleServantData svt) {
    final TextStyle? style = svt.isEnemy ? const TextStyle(fontStyle: FontStyle.italic) : null;

    return <InlineSpan>[
      TextSpan(text: '${svt.index + 1}-', style: style),
      CenterWidgetSpan(child: svt.iconBuilder(context: context, height: 32, battleData: battleData)),
      if (complete)
        TextSpan(
          text: svt.lBattleName,
          style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).merge(style),
          recognizer: TapGestureRecognizer()..onTap = () => _onTapSvt(svt),
        ),
      const TextSpan(text: '  '),
    ];
  }

  BattleServantData? findSkillTarget(
      SkillOrTd skill, bool isPlayer, BattleServantData? playerSvt, BattleServantData? enemySvt) {
    for (final func in skill.functions) {
      if (func.funcTargetTeam == FuncApplyTarget.enemy && isPlayer) continue;
      if (func.funcTargetTeam == FuncApplyTarget.player && !isPlayer) continue;
      final ally = isPlayer ? playerSvt : enemySvt;
      final enemy = isPlayer ? enemySvt : playerSvt;
      switch (func.funcTargetType) {
        // one ally
        case FuncTargetType.ptOne:
        case FuncTargetType.ptOneOther:
          return ally;
        // one enemy
        case FuncTargetType.enemy:
        case FuncTargetType.enemyOther:
          return enemy;
        // unknown
        case FuncTargetType.ptAnother:
        case FuncTargetType.enemyAnother:
        case FuncTargetType.ptselectOneSub: // order change or shuffle
        case FuncTargetType.ptselectSub:
        // no single target
        case FuncTargetType.self:
        case FuncTargetType.ptAll:
        case FuncTargetType.enemyAll:
        case FuncTargetType.ptFull:
        case FuncTargetType.enemyFull:
        case FuncTargetType.ptOther:
        case FuncTargetType.ptOtherFull:
        case FuncTargetType.enemyOtherFull:
        case FuncTargetType.ptSelfAnotherFirst:
        case FuncTargetType.ptSelfAnotherLast:
        case FuncTargetType.commandTypeSelfTreasureDevice:
        case FuncTargetType.fieldOther:
        case FuncTargetType.enemyOneNoTargetNoAction:
        case FuncTargetType.ptOneHpLowestValue:
        case FuncTargetType.ptOneHpLowestRate:
        // no single target but unused yet
        case FuncTargetType.ptSelfBefore:
        case FuncTargetType.ptSelfAfter:
        // random
        case FuncTargetType.ptRandom:
        case FuncTargetType.enemyRandom:
        case FuncTargetType.ptOneAnotherRandom:
        case FuncTargetType.ptSelfAnotherRandom:
        case FuncTargetType.enemyOneAnotherRandom:
          break;
      }
    }
    return null;
  }

  void _onTapSvt(BattleServantData svt) {
    router.pushPage(BattleSvtDetail(svt: svt, battleData: null));
  }
}

class _AttackDetailWidget extends StatelessWidget {
  final BattleData? battleData;
  final BattleAttackRecord record;
  const _AttackDetailWidget({required this.battleData, required this.record});

  @override
  Widget build(BuildContext context) {
    Map<int, AttackResultDetail> targets = {for (final target in record.targets) target.target.index: target};
    final maxIndex = Maths.max(targets.keys, 0);
    List<Widget> enemies = [
      for (int index = 0; index < max(3, ((maxIndex + 1) / 3).ceil() * 3); index++)
        buildDefender(context, targets[index])
    ];

    Widget enemyParty = ResponsiveLayout(
      rowDirection: TextDirection.rtl,
      reversedColumn: true,
      verticalAlign: CrossAxisAlignment.start,
      children: [
        for (final enemy in enemies) Responsive(small: 4, child: enemy),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(Divider.createBorderSide(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border(right: Divider.createBorderSide(context))),
              child: enemyParty,
            ),
          ),
          Expanded(
            flex: 1,
            child: buildAttacker(context),
          ),
        ],
      ),
    );
  }

  Widget text(String data, Color? color, [VoidCallback? onTap]) {
    Widget child = Text(
      data,
      style: TextStyle(color: color),
      textAlign: TextAlign.center,
      textScaleFactor: 0.9,
    );
    if (onTap != null) {
      child = InkWell(onTap: onTap, child: child);
    }
    return child;
  }

  Widget buildAttacker(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: record.attacker.iconBuilder(context: context, width: 48, battleData: battleData)),
          Text(
            record.attacker.lBattleName,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (record.card != null)
            Text([
              if (record.card?.isNP == true) S.current.np_short,
              record.card!.cardType.name.toTitle(),
            ].join(' ')),
          text('DMG: ${record.damage}', Colors.red),
          text('NP: ${record.attackNp / 100}', Colors.blue),
          text('Star: ${record.star / 1000}', Colors.green),
        ],
      ),
    );
  }

  Widget buildDefender(BuildContext context, AttackResultDetail? detail) {
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final result = detail.result;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: detail.target.iconBuilder(context: context, width: 48, battleData: battleData)),
          Text(
            detail.target.lBattleName,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          text('HP: ${detail.target.hp}', null),
          text('DMG: ${Maths.sum(result.damages)}', Colors.red,
              () => showParams(context, DamageParamDialog(detail.damageParams))),
          text('NP: ${Maths.sum(result.npGains) / 100}', Colors.blue,
              () => showParams(context, AttackerNpParamDialog(detail.attackNpParams))),
          text('Star: ${Maths.sum(result.stars) / 1000}', Colors.green,
              () => showParams(context, StarParamDialog(detail.starParams))),
          text('Overkill: ${result.overkillStates.where((e) => e).length}/${result.overkillStates.length}',
              Colors.yellow.shade900),
        ],
      ),
    );
  }

  void showParams(BuildContext context, Widget child) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => child,
    );
  }
}

extension BattleSvtDataUI on BattleServantData {
  Widget iconBuilder({
    required BuildContext context,
    String? overrideIcon,
    double? width,
    double? height,
    double? aspectRatio,
    VoidCallback? onTap,
    BattleData? battleData,
  }) {
    onTap ??= () => router.pushPage(BattleSvtDetail(svt: this, battleData: battleData));
    return db.getIconImage(
      niceSvt?.ascendIcon(limitCount, true) ?? niceEnemy?.icon ?? Atlas.common.unknownEnemyIcon,
      width: width,
      height: height,
      aspectRatio: aspectRatio ?? (isPlayer ? 132 / 144 : 1),
      onTap: onTap,
      placeholder: (context) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
    );
  }
}

mixin _ParamDialogMixin {
  Widget oneParam(String key, String value, [String? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (icon != null) ...[
            db.getIconImage(icon, width: 18, aspectRatio: 1),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(key, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String buffIcon(int id) => 'https://static.atlasacademy.io/JP/BuffIcons/bufficon_$id.png';
  String skillIcon(int id) => 'https://static.atlasacademy.io/JP/SkillIcons/skill_${id.toString().padLeft(5, '0')}.png';

  Widget buildDialog({required BuildContext context, required String title, required List<Widget> children}) {
    final bgColor = Theme.of(context).hoverColor;
    return SimpleCancelOkDialog(
      title: Text(title),
      scrollable: true,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < children.length; index++)
            Container(
              color: index.isOdd ? bgColor : null,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: children[index],
            )
        ],
      ),
    );
  }
}

class DamageParamDialog extends StatelessWidget with _ParamDialogMixin {
  final DamageParameters params;
  const DamageParamDialog(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return buildDialog(
      context: context,
      title: 'Damage Params',
      children: [
        oneParam('ATK', params.attack.toString()),
        oneParam('RNG', (params.fixedRandom / 1000).toStringAsFixed(3)),
        oneParam('Class Advantage', toModifier(params.classAdvantage).toString()),
        oneParam('Atk Up', toModifier(params.attackBuff).format(percent: true, precision: 2), buffIcon(300)),
        oneParam(
            'Card Performance', toModifier(params.cardBuff - 1000).format(percent: true, precision: 2), skillIcon(317)),
      ],
    );
  }
}

class AttackerNpParamDialog extends StatelessWidget with _ParamDialogMixin {
  final AttackNpGainParameters params;
  const AttackerNpParamDialog(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return buildDialog(
      context: context,
      title: 'Attack NP Params',
      children: [
        oneParam(
            'Card Performance', toModifier(params.cardBuff - 1000).format(percent: true, precision: 2), skillIcon(317)),
      ],
    );
  }
}

class StarParamDialog extends StatelessWidget with _ParamDialogMixin {
  final StarParameters params;
  const StarParamDialog(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return buildDialog(
      context: context,
      title: 'Star Params',
      children: [
        oneParam('StarGen', toModifier(params.attackerStarGen).toString()),
        oneParam(
            'Card Performance', toModifier(params.cardBuff - 1000).format(percent: true, precision: 2), skillIcon(317)),
      ],
    );
  }
}
