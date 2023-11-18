import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img_lib;
import 'package:screenshot/screenshot.dart';
import 'package:tuple/tuple.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../quest/quest_card.dart';
import '../formation/formation_card.dart';
import 'svt_detail.dart';

class BattleRecorderPanel extends StatefulWidget {
  final BattleData? battleData;
  final List<BattleRecord>? records;
  final QuestPhase? quest;
  final BattleOptions? options;
  final BattleTeamSetup? team;
  final bool initShowTeam;
  final bool initShowQuest;
  const BattleRecorderPanel({
    super.key,
    this.battleData,
    this.records,
    this.quest,
    this.options,
    this.team,
    this.initShowTeam = false,
    this.initShowQuest = false,
  });

  @override
  State<BattleRecorderPanel> createState() => _BattleRecorderPanelState();
}

class _BattleRecorderPanelState extends State<BattleRecorderPanel> {
  bool showDetail = false;
  late bool showQuest = widget.initShowQuest;
  late bool showTeam = widget.initShowTeam;
  bool get showTwoColumn => db.settings.battleSim.recordShowTwoColumn;

  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    // one column: max width 640
    // two columns: fixed at 512*2=1024
    Widget panel = DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: BattleRecorderPanelBase(
        battleData: widget.battleData,
        records: widget.records,
        showDetail: showDetail,
        quest: showQuest ? widget.quest : null,
        options: widget.options,
        team: showTeam ? widget.team : null,
        showTwoColumn: showTwoColumn,
      ),
    );
    if (showTwoColumn) {
      panel = FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 1024,
          child: panel,
        ),
      );
    } else {
      panel = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: panel);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildActions(),
        Screenshot(
          controller: controller,
          child: panel,
        ),
        if ((widget.records ?? widget.battleData?.recorder.records)?.any((e) => e is BattleAttackRecord) == true)
          SFooter.rich(TextSpan(children: [
            const TextSpan(text: 'DMG', style: TextStyle(color: Colors.red)),
            const TextSpan(text: '/'),
            const TextSpan(text: 'NP', style: TextStyle(color: Colors.blue)),
            const TextSpan(text: '/'),
            const TextSpan(text: 'Star', style: TextStyle(color: Colors.green)),
            const TextSpan(text: ': '),
            TextSpan(text: S.current.damage_recorder_param_hint),
          ])),
      ],
    );
  }

  Widget buildActions() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            S.current.battle_records,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.underline),
            // textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              db.settings.battleSim.recordShowTwoColumn = !showTwoColumn;
            });
          },
          icon: const FaIcon(FontAwesomeIcons.tableColumns, size: 16),
          color: showTwoColumn ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).disabledColor,
          tooltip: 'Two Columns',
          visualDensity: VisualDensity.standard,
        ),
        if (widget.quest != null)
          IconButton(
            onPressed: () {
              setState(() {
                showQuest = !showQuest;
              });
            },
            icon: const FaIcon(FontAwesomeIcons.dragon, size: 16),
            color: showQuest ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).disabledColor,
            tooltip: 'Show Quest',
            visualDensity: VisualDensity.standard,
          ),
        if (widget.team != null)
          IconButton(
            onPressed: () {
              setState(() {
                showTeam = !showTeam;
              });
            },
            icon: const Icon(Icons.groups_3),
            color: showTeam ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).disabledColor,
            tooltip: 'Show Team',
            visualDensity: VisualDensity.standard,
          ),
        IconButton(
          onPressed: () {
            setState(() {
              showDetail = !showDetail;
            });
          },
          icon: const Icon(Icons.text_fields),
          color: showDetail ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).disabledColor,
          tooltip: 'Show svt/skill name',
          visualDensity: VisualDensity.standard,
        ),
        IconButton(
          onPressed: onTapScreenshot,
          icon: const Icon(Icons.camera_alt),
          tooltip: S.current.screenshots,
          color: Theme.of(context).colorScheme.primaryContainer,
          visualDensity: VisualDensity.standard,
        ),
      ],
    );
  }

  Future<void> onTapScreenshot() async {
    if (kIsWeb && !kPlatformMethods.rendererCanvasKit) {
      EasyLoading.showError('Web html mode is not supported, please change to canvaskit mode.');
      return;
    }
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.screenshots),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                showQuest = true;
                showTeam = true;
                showDetail = true;
                if (mounted) setState(() {});
                Navigator.pop(context);
                EasyLoading.show();
                // in case image is evicted from memory and needs reload
                await Future.delayed(const Duration(milliseconds: 500));
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  doScreenshot();
                });
              },
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Text(S.current.recorder_screenshot_full_view),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                doScreenshot();
              },
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Text(S.current.recorder_screenshot_current_view),
            ),
            kIndentDivider,
            StatefulBuilder(
              builder: (context, update) {
                return ListTileTheme.merge(
                  horizontalTitleGap: 0,
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    title: const Text("Compress to JPG"),
                    subtitle: PlatformU.supportCopyImage ? const Text("Only for save, don't check for copy") : null,
                    value: db.settings.battleSim.recordScreenshotJpg,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      db.settings.battleSim.recordScreenshotJpg = v!;
                      update(() {});
                    },
                  ),
                );
              },
            ),
            StatefulBuilder(
              builder: (context, update) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 24),
                  child: SliderWithPrefix(
                    titled: true,
                    label: S.current.resolution,
                    min: 10,
                    max: 30,
                    value: db.settings.battleSim.recordScreenshotRatio.clamp(10, 30),
                    valueFormatter: (v) => '×${v / 10}',
                    onChange: (v) {
                      db.settings.battleSim.recordScreenshotRatio = v.round();
                      update(() {});
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> doScreenshot() async {
    if (!mounted) {
      EasyLoading.dismiss();
      return;
    }
    if (!EasyLoading.isShow) EasyLoading.show();
    try {
      final box = context.findRenderObject() as RenderBox?;
      double ratio = db.settings.battleSim.recordScreenshotRatio / 10;
      ratio = ratio.clamp(1.0, 3.0);
      if (showTwoColumn && box != null && box.hasSize) {
        final width = box.size.width;
        if (width < 1024 && width > 0) {
          ratio *= 1024 / width;
        }
      }
      Uint8List? data = await controller.capture(pixelRatio: ratio * MediaQuery.of(context).devicePixelRatio);
      if (data == null) {
        EasyLoading.showError('Something went wrong.');
        return;
      }
      EasyLoading.dismiss();
      if (!mounted) return;
      bool useJpg = false;
      if (db.settings.battleSim.recordScreenshotJpg) {
        try {
          data = img_lib.encodeJpg(img_lib.decodePng(data)!, quality: 70);
          useJpg = true;
        } catch (e) {
          useJpg = false;
          print(e);
        }
      }

      final quest = widget.battleData?.niceQuest;
      final t = DateTime.now();
      String fn = [t.month, t.day, t.hour, t.minute, t.second].map((e) => e.toString().padLeft(2, '0')).join('_');
      fn = "battle_log_${quest?.id}_${quest?.phase}_$fn.${useJpg ? 'jpg' : 'png'}";

      ImageActions.showSaveShare(
        context: context,
        data: data,
        destFp: joinPaths(db.paths.downloadDir, fn),
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }
}

class BattleRecorderPanelBase extends StatelessWidget {
  final BattleData? battleData;
  final List<BattleRecord>? records;
  final QuestPhase? quest;
  final BattleOptions? options;
  final BattleTeamSetup? team;
  final bool showDetail;
  final bool showTwoColumn;

  const BattleRecorderPanelBase({
    super.key,
    this.battleData,
    this.records,
    this.quest,
    this.options,
    this.team,
    required this.showDetail,
    required this.showTwoColumn,
  });

  @override
  Widget build(BuildContext context) {
    List<(double, Widget)> children = [
      if (quest != null) (308.0, getQuest(quest!)),
      if (team != null) (115.0, getTeam(context, team!)),
      if (options != null) getOptions(context, options!),
      ...getRecordCards(context),
    ];
    if (battleData?.isBattleWin == true) {
      children.add((
        21,
        Center(
          child: Text(
            'Created by Chaldea App v${AppInfo.versionString}'
            '\n${HostsX.appHost}/laplace',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        )
      ));
    }
    if (showTwoColumn) {
      final totalHeight = Maths.sum(children.map((e) => e.$1));
      int leftCount = 0;
      double leftHeight = 0.0;
      double rightHeight = totalHeight - leftHeight;
      for (int index = 0; index < children.length; index++) {
        final height = children[index].$1;
        if (max(leftHeight + height, rightHeight - height) <= max(leftHeight, rightHeight)) {
          leftCount += 1;
          leftHeight += height;
          rightHeight -= height;
        } else {
          break;
        }
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final cards in [children.take(leftCount), children.skip(leftCount)])
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards.map((e) => e.$2).toList(),
              ),
            ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((e) => e.$2).toList(),
      );
    }
  }

  List<(double, Widget)> getRecordCards(BuildContext context) {
    final cards = <(double height, Widget child)>[];
    final records = this.records ?? battleData?.recorder.records ?? [];
    if (records.length == 2 && records[0] is BattleProgressWaveRecord && records[1] is BattleProgressTurnRecord) {
      return [];
    }
    List<(double, Widget)> cardChildren = [];
    for (final record in records) {
      if (record is BattleProgressWaveRecord) {
        if (cardChildren.isNotEmpty) {
          cards.add(createWave(context, cardChildren));
        }
        cardChildren = [];

        cardChildren.add((
          record.estimatedHeight,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                '${S.current.quest_wave} ${record.wave}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
        ));
      } else if (record is BattleSkipWaveRecord) {
        cardChildren.add((
          record.estimatedHeight,
          Text(
            'Skip Wave ${record.wave}',
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            textScaler: const TextScaler.linear(1.2),
          )
        ));
      } else if (record is BattleProgressTurnRecord) {
        cardChildren.add((
          record.estimatedHeight,
          Center(
            child: Text(
              '${S.current.battle_turn} ${record.turn}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        ));
      } else if (record is BattleSkillRecord) {
        cardChildren.add((record.estimatedHeight, buildSkillLog(context, record)));
      } else if (record is BattleOrderChangeRecord) {
        cardChildren.add((
          record.estimatedHeight,
          prefixIndicator(
            context,
            Text.rich(TextSpan(children: [
              const TextSpan(text: 'Order Change', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ': '),
              ...drawSvt(context, record.onField),
              const TextSpan(text: '⇄ '),
              ...drawSvt(context, record.backup),
            ])),
          )
        ));
      } else if (record is BattleAttackRecord) {
        cardChildren.add((record.estimatedHeight, _AttackDetailWidget(record: record, battleData: battleData)));
      } else if (record is BattleInstantDeathRecord) {
        cardChildren.add((record.estimatedHeight, _InstantDeathDetailWidget(record: record, battleData: battleData)));
      } else if (record is BattleMessageRecord) {
        Widget child = Text.rich(
          TextSpan(children: [
            TextSpan(text: record.message, style: record.style),
            if (record.target != null) ...[
              const TextSpan(text: ': '),
              ...drawSvt(context, record.target!),
            ],
          ]),
          textAlign: record.textAlign,
        );
        if (record.alignment != null) {
          child = Align(alignment: record.alignment!, child: child);
        }
        cardChildren.add((
          record.estimatedHeight,
          child,
        ));
      } else if (record is BattleAttacksInitiationRecord) {
        cardChildren.add((
          record.estimatedHeight,
          prefixIndicator(
            context,
            Text.rich(TextSpan(children: [
              TextSpan(text: S.current.battle_attack, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ': '),
              for (final attack in record.attacks) ...drawSvt(context, attack.actor, attack.cardData),
            ])),
          )
        ));
      } else if (record is BattleSkillActivationRecord) {
        // noop
      } else {
        assert(false, record);
      }
    }
    if (cardChildren.isNotEmpty) {
      cards.add(createWave(context, cardChildren));
    }
    return cards;
  }

  (double, Widget) createWave(BuildContext context, List<(double, Widget)> children) {
    return (
      Maths.sum(children.map((e) => e.$1)) + 12,
      createCard(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((e) => e.$2).toList(),
      ))
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
    List<InlineSpan> spans = [
      const CenterWidgetSpan(
        child: SizedBox(height: 32, width: 1),
      )
    ];
    if (record.prefix != null) {
      spans.add(TextSpan(text: record.prefix));
    }
    if (actor != null) {
      spans.addAll(drawSvt(context, actor));
    }
    final pskill = skill.proximateSkill;
    String? prefix;
    switch (record.skill.type) {
      case SkillInfoType.masterEquip:
        prefix = S.current.mystic_code;
        break;
      case SkillInfoType.commandSpell:
        prefix = S.current.command_spell;
        break;
      case SkillInfoType.custom:
        prefix = S.current.general_custom;
        break;
      default:
        break;
    }
    spans.addAll([
      if (record.skill.type == SkillInfoType.commandSpell)
        CenterWidgetSpan(child: CachedImage(imageUrl: AssetURL.i.buffIcon(387), width: 18, height: 18)),
      if (prefix != null) TextSpan(text: '$prefix: '),
      TextSpan(text: '${S.current.skill} '),
      if (skill.skillNum > 0) TextSpan(text: '${skill.skillNum} ', style: kMonoStyle),
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
      if (pskill != null &&
          (pskill.icon == null ||
              showDetail ||
              !const [SkillInfoType.svtSelf, SkillInfoType.masterEquip].contains(record.skill.type)))
        SharedBuilder.textButtonSpan(
          context: context,
          text: '${pskill.lName.l} ',
          onTap: pskill.routeTo,
          style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.secondaryContainer),
        ),
      if (skill.skillLv != 0 && showDetail) TextSpan(text: 'Lv.${skill.skillLv} '),
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

  List<InlineSpan> drawSvt(BuildContext context, BattleServantData svt, [CommandCardData? card]) {
    final TextStyle? style = svt.isEnemy ? const TextStyle(fontStyle: FontStyle.italic) : null;

    return <InlineSpan>[
      TextSpan(text: '${svt.fieldIndex + 1}-', style: const TextStyle(fontFamily: kMonoFont).merge(style)),
      CenterWidgetSpan(child: svt.iconBuilder(context: context, height: 32, battleData: battleData)),
      if (card != null) ...[
        CenterWidgetSpan(child: CommandCardWidget(card: card.cardType, width: 32)),
        if (card.isTD) TextSpan(text: '${S.current.np_short} ', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
      if (showDetail)
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
        case FuncTargetType.enemyRange:
          continue;
      }
    }
    return null;
  }

  void _onTapSvt(BattleServantData svt) {
    router.pushPage(BattleSvtDetail(svt: svt, battleData: null));
  }

  Widget getQuest(QuestPhase quest) {
    return QuestCard(
      offline: false,
      quest: quest,
      displayPhases: [quest.phase],
      battleOnly: true,
      showFace: !quest.isLaplaceSharable,
      preferredPhases: [quest],
    );
  }

  Widget getTeam(BuildContext context, BattleTeamSetup team) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormationCard(formation: team.toFormationData(), showAllMysticCodeIcon: true),
            // TeamSetupCard(
            //   onFieldSvts: team.onFieldSvtDataList,
            //   backupSvts: team.backupSvtDataList,
            //   team: team,
            //   quest: quest,
            //   enableEdit: false,
            //   showEmptyBackup: false,
            // ),
            // if (team.mysticCodeData.enabled)
            //   getMysticCode(context, team.mysticCodeData.mysticCode!, team.mysticCodeData.level),
          ],
        ),
      ),
    );
  }

  (double, Widget) getOptions(BuildContext context, BattleOptions options) {
    List<Widget> children = [];
    double height = 0;
    if (options.pointBuffs.isNotEmpty) {
      final groupIds = options.pointBuffs.keys.toList();
      groupIds.sort();
      children.add(Text.rich(TextSpan(
        text: '${S.current.event_point}: ',
        children: groupIds.map<InlineSpan>((groupId) {
          final pointBuff = options.pointBuffs[groupId]!;
          final group = db.gameData.others.eventPointBuffGroups[groupId];
          final icon = group?.icon ?? pointBuff.icon;
          return TextSpan(children: [
            CenterWidgetSpan(child: db.getIconImage(icon, width: 18)),
            TextSpan(text: group?.lName.l ?? "Group $groupId ", style: Theme.of(context).textTheme.bodySmall),
            if (pointBuff.skillIcon != null) CenterWidgetSpan(child: db.getIconImage(pointBuff.skillIcon, width: 18)),
            if (pointBuff.lv > 0)
              TextSpan(text: ' Lv${pointBuff.lv}; ')
            else
              TextSpan(text: ' ${pointBuff.eventPoint}; '),
          ]);
        }).toList(),
      )));
      height += 26;
    }
    if (children.isEmpty) return (height, const SizedBox.shrink());
    return (height, createCard(Column(mainAxisSize: MainAxisSize.min, children: children)));
  }

  Widget createCard(Widget child) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: child,
      ),
    );
  }

  Widget getMysticCode(BuildContext context, MysticCode mysticCode, int level) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context))),
      child: ListTile(
        leading: db.getIconImage(mysticCode.icon, width: 56, aspectRatio: 1),
        title: Text('${mysticCode.lName.l}  Lv.$level', textScaler: const TextScaler.linear(0.9)),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final skill in mysticCode.skills)
              db.getIconImage(
                skill.icon ?? Atlas.common.unknownSkillIcon,
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2),
              )
          ],
        ),
      ),
    );
  }
}

mixin MultiTargetsWrapper {
  Widget buildContent({
    required BuildContext context,
    required bool isActorEnemy,
    required bool isTargetEnemy,
    required WidgetBuilder actorBuilder,
    // <isEnemy, index, builder>
    required List<Tuple3<bool, int, WidgetBuilder>> targets,
    WidgetBuilder placeholder = _defaultPlaceholder,
  }) {
    Map<int, WidgetBuilder> enemyBuilders = {
      for (final target in targets)
        if (target.item1) target.item2: target.item3
    };
    final maxEnemyIndex = Maths.max(enemyBuilders.keys, -1);

    List<Widget> enemies = [
      for (int index = 0; index < ((maxEnemyIndex + 1) / 3).ceil() * 3; index++)
        enemyBuilders[index]?.call(context) ?? placeholder(context),
    ];

    Map<int, WidgetBuilder> playerBuilders = {
      for (final target in targets)
        if (!target.item1) target.item2: target.item3
    };
    final maxPlayerIndex = Maths.max(playerBuilders.keys, -1);

    List<Widget> players = [
      for (int index = 0; index < ((maxPlayerIndex + 1) / 3).ceil() * 3; index++)
        playerBuilders[index]?.call(context) ?? placeholder(context),
    ];

    List<Widget> allEntities = [
      ...enemies,
      ...players.reversed,
    ];
    if (allEntities.isEmpty) allEntities.addAll(List.generate(3, (index) => placeholder(context)));

    Widget enemyParty = ResponsiveLayout(
      rowDirection: TextDirection.rtl, // enemy rtl
      verticalDirection: VerticalDirection.up,
      verticalAlign: CrossAxisAlignment.center,
      children: [
        for (final enemy in allEntities) Responsive(small: 4, child: enemy),
      ],
    );
    final borderSide = Divider.createBorderSide(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(borderSide),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(2),
      child: Row(
        textDirection: isActorEnemy ? TextDirection.ltr : TextDirection.rtl,
        children: [
          Expanded(
            flex: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.symmetric(vertical: borderSide)),
              child: actorBuilder(context),
            ),
          ),
          Expanded(
            flex: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.symmetric(vertical: borderSide)),
              child: enemyParty,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _defaultPlaceholder(BuildContext context) {
    Widget child = CachedImage(
      imageUrl: 'https://static.atlasacademy.io/JP/Enemys/0.png',
      height: 72,
      placeholder: (context, url) => const SizedBox.shrink(),
    );
    if (!Theme.of(context).isDarkMode) {
      // invert color
      child = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          //R G  B  A  Const
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
        child: child,
      );
    }
    // child = Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: child);
    return child;
  }

  Widget coloredText(String data, Color? color, [VoidCallback? onTap]) {
    Widget child = Text(
      data,
      style: TextStyle(color: color),
      textAlign: TextAlign.center,
      textScaler: const TextScaler.linear(0.85),
    );
    if (onTap != null) {
      child = InkWell(onTap: onTap, child: child);
    }
    return child;
  }
}

class _AttackDetailWidget extends StatelessWidget with MultiTargetsWrapper {
  final BattleData? battleData;
  final BattleAttackRecord record;
  const _AttackDetailWidget({required this.battleData, required this.record});

  String fmtHp(int value) {
    return value.format(compact: false, groupSeparator: ",");
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(
      context: context,
      isActorEnemy: record.attacker.isEnemy,
      isTargetEnemy: record.targets.any((e) => e.target.isEnemy),
      actorBuilder: buildAttacker,
      targets: [
        for (final target in record.targets)
          Tuple3(target.target.isEnemy, target.target.fieldIndex, (context) => buildDefender(context, target))
      ],
    );
  }

  Widget buildAttacker(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: buildAttackerCard(context)),
          Text(
            '${record.attacker.fieldIndex + 1}-${record.attacker.lBattleName}',
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (record.card != null)
            Text.rich(
              TextSpan(
                children: divideList([
                  if (record.card?.isTD == true) TextSpan(text: '${S.current.np_short} Lv.${record.attacker.tdLv}'),
                  if (record.attacker.isPlayer && record.card?.isTD == true)
                    TextSpan(text: (record.card?.np ?? 0).format(percent: true, base: 100)),
                  TextSpan(
                    text: record.card!.cardType.name.toTitle(),
                    style: TextStyle(
                      color: {
                        CardType.quick: Colors.green,
                        CardType.arts: Colors.blue,
                        CardType.buster: Colors.red,
                      }[record.card!.cardType],
                    ),
                  ),
                  if (record.card?.critical == true) TextSpan(text: S.current.critical_attack)
                ], const TextSpan(text: ' ')),
              ),
              style: const TextStyle(decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(0.8),
            ),
          if (record.targets.isNotEmpty || record.damage != 0) ...[
            record.targets.any((e) => e.damageParams.isNotMinRoll)
                ? coloredText('DMG ${fmtHp(record.damage)}*', Colors.red)
                : coloredText('DMG ${fmtHp(record.damage)}', Colors.red),
            if (record.attacker.isPlayer) coloredText('NP ${record.attackNp / 100}', Colors.blue),
            if (record.attacker.isPlayer) coloredText('Star ${record.star / 1000}', Colors.green),
          ],
        ],
      ),
    );
  }

  Widget buildAttackerCard(BuildContext context) {
    final card = record.card;
    assert(card != null);
    if (card == null) {
      return record.attacker.iconBuilder(
        context: context,
        width: 48,
        battleData: battleData,
      );
    }
    List<Widget> stackChildren = [
      Positioned.fill(
        child: record.attacker.iconBuilder(
          context: context,
          width: 48,
          battleData: battleData,
          showClsIcon: true,
        ),
      ),
    ];
    if (card.cardType.isQAB) {
      stackChildren.add(Positioned(
        left: -2,
        right: -2,
        bottom: -6,
        child: Image.asset(
          'res/assets/card_icon_${card.cardType.name}.png',
          fit: BoxFit.fitWidth,
        ),
      ));
      if (card.isTD) {
        final td = card.td;
        if (td != null && td.icon != null) {
          stackChildren.add(Positioned(
            left: -2,
            right: -2,
            bottom: -4,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.5,
                child: CachedImage(
                  imageUrl: td.icon,
                  cachedOption: CachedImageOption(
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => Text(S.current.noble_phantasm),
                  ),
                ),
              ),
            ),
          ));
        } else {
          stackChildren.add(Positioned.fill(child: Text(S.current.noble_phantasm)));
        }
      } else {
        stackChildren.add(Positioned(
          left: 2,
          right: 2,
          bottom: 0,
          child: Image.asset(
            'res/assets/card_txt_${card.cardType.name}.png',
            fit: BoxFit.fitWidth,
          ),
        ));
      }
    } else {
      // stackChildren.add(Positioned.fill(
      //   child: ImageWithText.paintOutline(text: card.cardType.name),
      // ));
    }
    final oc = card.oc;
    if (oc != null && oc > 1 && oc <= 5) {
      stackChildren.add(Positioned(
        top: -2,
        right: -16,
        child: CachedImage(
          imageUrl:
              "https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/BattleUIAtlas/icon_oc_0${oc - 1}.png",
          width: 32,
          aspectRatio: 108 / 65,
        ),
      ));
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 50, maxHeight: 56),
      child: InkWell(
        onTap: () => router.pushPage(BattleSvtDetail(svt: record.attacker, battleData: battleData)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: stackChildren,
        ),
      ),
    );
  }

  Widget buildDefender(BuildContext context, AttackResultDetail detail) {
    final result = detail.result;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: detail.target.iconBuilder(
              context: context,
              width: 42,
              battleData: battleData,
              showClsIcon: true,
            ),
          ),
          Text(
            detail.target.lBattleName,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          coloredText('HP ${fmtHp(detail.target.hp)}', null),
          coloredText(
            "DMG ${fmtHp(result.totalDamage)}${detail.damageParams.isNotMinRoll ? '*' : ''}",
            Colors.red,
            () => showParams(
              context,
              DamageParamDialog(
                detail.damageParams,
                detail.result,
                minResult: detail.minResult,
                maxResult: detail.maxResult,
              ),
            ),
          ),
          if (detail.target.isEnemy)
            coloredText(
              'NP ${Maths.sum(result.npGains) / 100}',
              Colors.blue,
              () => showParams(
                context,
                AttackerNpParamDialog(
                  detail.attackNpParams,
                  detail.result,
                  minResult: detail.minResult,
                  maxResult: detail.maxResult,
                ),
              ),
            )
          else
            coloredText(
              'NP ${Maths.sum(result.defNpGains) / 100}',
              Colors.blue,
              () => showParams(
                context,
                DefenseNpParamDialog(
                  detail.defenseNpParams,
                  detail.result,
                  minResult: detail.minResult,
                  maxResult: detail.maxResult,
                ),
              ),
            ),
          if (detail.target.isEnemy)
            coloredText(
              'Star ${Maths.sum(result.stars) / 1000}',
              Colors.green,
              () => showParams(
                context,
                StarParamDialog(
                  detail.starParams,
                  detail.result,
                  minResult: detail.minResult,
                  maxResult: detail.maxResult,
                ),
              ),
            ),
          if (detail.target.isEnemy)
            coloredText('Overkill ${result.overkillCount}/${result.overkillStates.length}', Colors.yellow.shade900),
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
    String? text,
    VoidCallback? onTap,
    BattleData? battleData,
    bool showClsIcon = false,
  }) {
    final icon = niceEnemy?.icon ?? niceSvt?.ascendIcon(limitCount, true) ?? Atlas.common.unknownEnemyIcon;
    onTap ??= () => router.pushPage(BattleSvtDetail(svt: this, battleData: battleData));
    Widget child = GameCardMixin.cardIconBuilder(
      context: context,
      icon: icon,
      width: width,
      height: height,
      aspectRatio: aspectRatio ?? (isPlayer ? 132 / 144 : 1),
      onTap: onTap,
      text: text,
      option: ImageWithTextOption(
          errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon)),
    );
    final dim = width ?? height;
    if (showClsIcon && (dim != null) && !icon.contains('_bordered.png')) {
      child = Stack(
        children: [
          child,
          Positioned(
            left: 0,
            top: 0,
            child: db.getIconImage(SvtClassX.clsIcon(classId, rarity), width: dim / 3.2),
          ),
        ],
      );
    }
    return child;
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
          Text(value, style: const TextStyle(fontSize: 14), textAlign: TextAlign.end),
        ],
      ),
    );
  }

  Widget listValueWithOverkill(List<int> values, List<bool> overskills, String Function(int v) format) {
    const style = TextStyle(fontSize: 13);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Wrap(
          alignment: WrapAlignment.end,
          children: divideList(
            List.generate(values.length, (index) {
              final value = values[index], ok = overskills.getOrNull(index);
              assert(ok != null, [values, overskills]);
              return Text(
                format(value),
                style: style.merge(ok == true ? TextStyle(color: Colors.yellow.shade900) : null),
              );
            }),
            const Text(',', style: style),
          ),
        ),
      ),
    );
  }

  String cardBuffIcon(final CardType cardType) {
    switch (cardType) {
      case CardType.arts:
        return buffIcon(313);
      case CardType.buster:
        return buffIcon(314);
      case CardType.quick:
        return buffIcon(312);
      case CardType.extra:
        return buffIcon(388);
      case CardType.none:
      case CardType.blank:
      case CardType.weak:
      case CardType.strength:
        return buffIcon(302);
    }
  }

  String buffIcon(int id) => 'https://static.atlasacademy.io/JP/BuffIcons/bufficon_$id.png';
  String skillIcon(int id) => 'https://static.atlasacademy.io/JP/SkillIcons/skill_${id.toString().padLeft(5, '0')}.png';

  Widget buildDialog({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    bool wrapDialog = true,
  }) {
    final bgColor = Theme.of(context).hoverColor;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < children.length; index++)
          Container(
            color: index.isOdd ? bgColor : null,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: children[index],
          )
      ],
    );
    if (!wrapDialog) return content;

    return SimpleCancelOkDialog(
      title: Text(title),
      scrollable: true,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 24.0),
      hideCancel: true,
      content: content,
    );
  }
}

class DamageParamDialog extends StatelessWidget with _ParamDialogMixin {
  final DamageParameters params;
  final DamageResult result;
  final DamageResult? minResult;
  final DamageResult? maxResult;
  final bool wrapDialog;

  const DamageParamDialog(this.params, this.result,
      {super.key, this.wrapDialog = true, this.minResult, this.maxResult});

  @override
  Widget build(BuildContext context) {
    final classAttackCorrection = toModifier(ConstData.classInfo[params.attackerClass]?.attackRate ?? 1000);
    final damageRate = toModifier(params.damageRate);
    final isNpSpecificDamage = params.isNp &&
        {
          FuncType.damageNpIndividual,
          FuncType.damageNpIndividualSum,
          FuncType.damageNpStateIndividualFix,
          FuncType.damageNpRare,
        }.contains(params.damageFunction?.funcType);
    final npSpecificAttackRate = toModifier(params.npSpecificAttackRate);
    final hitsPercent = params.totalHits / 100.0;
    final random = toModifier(params.random);
    final classAdvantage = toModifier(params.classAdvantage);
    final attributeAdvantage =
        toModifier(ConstData.getAttributeRelation(params.attackerAttribute, params.defenderAttribute));
    final firstCardBonus = shouldIgnoreFirstCardBonus(params.isNp, params.firstCardType)
        ? 0
        : params.isMightyChain
            ? toModifier(ConstData.cardInfo[CardType.buster]![1]!.addAtk)
            : toModifier(ConstData.cardInfo[params.firstCardType]![1]!.addAtk);
    final busterChainMod = (!params.isNp && params.currentCardType == CardType.buster && params.isTypeChain
            ? toModifier(ConstData.constants.chainbonusBusterRate) * params.attack
            : 0)
        .toInt();
    final extraModifier = toModifier(
        params.isTypeChain ? ConstData.constants.extraAttackRateGrand : ConstData.constants.extraAttackRateSingle);
    final atkSum = max(toModifier(params.attackBuff - params.defenseBuff), -1);
    final cardSum = max(toModifier(params.cardBuff - params.cardResist), -1);
    final specificSum = max(
        toModifier(params.specificAttackBuff -
            params.specificDefenseBuff +
            (params.critical ? params.criticalDamageBuff : 0) +
            (params.isNp ? params.npDamageBuff : 0)),
        0.001 - 1);
    final percentAttack = max(toModifier(params.percentAttackBuff), 0.01 - 1);
    final percentDefense = min(toModifier(params.percentDefenseBuff), 1);
    final damageAdd = params.damageAdditionBuff + params.damageReceiveAdditionBuff;

    return buildDialog(
      context: context,
      title: S.current.battle_damage_parameters,
      wrapDialog: wrapDialog,
      children: [
        oneParam(S.current.battle_damage, result.totalDamage.toString()),
        if (minResult != null && maxResult != null)
          oneParam('', '(${minResult!.totalDamage}~${maxResult!.totalDamage})'),
        if (result.damages.any((e) => e > 0))
          listValueWithOverkill(result.damages, result.overkillStates, (v) => v.toString()),
        oneParam(S.current.battle_random, random.toStringAsFixed(3)),
        oneParam('ATK', params.attack.toString()),
        oneParam(S.current.class_attack_rate, classAttackCorrection.format(precision: 3)),
        if (params.damageRate != 1000)
          oneParam(S.current.battle_damage_rate, damageRate.format(percent: true, precision: 3)),
        if (isNpSpecificDamage)
          oneParam(S.current.np_sp_damage_rate, npSpecificAttackRate.format(percent: true, precision: 3)),
        if (params.totalHits != 100) oneParam('Hits', hitsPercent.format(percent: true, precision: 3)),
        oneParam(S.current.class_advantage, classAdvantage.format(precision: 3)),
        oneParam(S.current.attribute_advantage, attributeAdvantage.format(precision: 3)),
        if (firstCardBonus != 0) oneParam(S.current.battle_first_card_bonus, firstCardBonus.format(precision: 1)),
        if (busterChainMod != 0) oneParam(S.current.battle_buster_chain, busterChainMod.toString()),
        if (params.currentCardType == CardType.extra)
          oneParam(S.current.battle_extra_rate, extraModifier.format(precision: 1)),
        oneParam(Transl.buffNames('攻撃力アップ').l, atkSum.format(percent: true, precision: 3), buffIcon(300)),
        oneParam(Transl.buffNames('カード性能アップ').l, cardSum.format(percent: true, precision: 3),
            cardBuffIcon(params.currentCardType)),
        oneParam(Transl.buffNames('威力アップ').l, specificSum.format(percent: true, precision: 3), buffIcon(302)),
        if (params.percentAttackBuff != 0)
          oneParam(Transl.buffNames('特殊威力アップ').l, percentAttack.format(percent: true, precision: 3), buffIcon(359)),
        if (params.percentDefenseBuff != 0)
          oneParam(Transl.buffNames('特殊耐性アップ').l, percentDefense.format(percent: true, precision: 3), buffIcon(334)),
        oneParam(Transl.buffNames('ダメージプラス').l, damageAdd.toString(), buffIcon(302)),
      ],
    );
  }
}

class AttackerNpParamDialog extends StatelessWidget with _ParamDialogMixin {
  final AttackNpGainParameters params;
  final DamageResult result;
  final bool wrapDialog;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  const AttackerNpParamDialog(this.params, this.result,
      {super.key, this.wrapDialog = true, this.minResult, this.maxResult});

  @override
  Widget build(BuildContext context) {
    final attackerNpCharge = params.attackerNpCharge / 10000;
    final defenderNpRate = toModifier(params.defenderNpRate);
    final cardRate = toModifier(params.cardAttackNpRate);
    final cardSum = max(toModifier(params.cardBuff - params.cardResist), -1);
    final npGainBuff = toModifier(params.npGainBuff - 1000);

    return buildDialog(
      context: context,
      title: S.current.battle_atk_np_parameters,
      wrapDialog: wrapDialog,
      children: [
        oneParam(S.current.np_refund, (result.totalNpGains / 100).format(precision: 2)),
        if (minResult != null && maxResult != null)
          oneParam('', '(${minResult!.totalNpGains / 100}~${maxResult!.totalNpGains / 100})'),
        if (result.npGains.any((e) => e > 0))
          listValueWithOverkill(result.npGains, result.overkillStates, (v) => (v / 100).format(precision: 2)),
        oneParam(S.current.attack_np_rate, attackerNpCharge.format(percent: true, precision: 2)),
        oneParam(S.current.np_gain_mod, defenderNpRate.format(precision: 3)),
        if (params.cardAttackNpRate != 1000)
          oneParam(S.current.battle_card_np_rate, cardRate.format(percent: true, precision: 3)),
        oneParam(Transl.buffNames('カード性能アップ').l, cardSum.format(percent: true, precision: 3),
            cardBuffIcon(params.currentCardType)),
        oneParam(Transl.buffNames('NP獲得アップ').l, npGainBuff.format(percent: true, precision: 3), buffIcon(303)),
      ],
    );
  }
}

class DefenseNpParamDialog extends StatelessWidget with _ParamDialogMixin {
  final DefendNpGainParameters params;
  final DamageResult result;
  final bool wrapDialog;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  const DefenseNpParamDialog(this.params, this.result,
      {super.key, this.wrapDialog = true, this.minResult, this.maxResult});

  @override
  Widget build(BuildContext context) {
    final defenderNpGainRate = params.defenderNpGainRate / 100;
    final attackerNpRate = params.attackerNpRate / 1000;
    final npGainBuff = toModifier(params.npGainBuff - 1000);
    final defenseNpGainBuff = toModifier(params.defenseNpGainBuff - 1000);
    return buildDialog(
      context: context,
      title: "Defend NP Params",
      wrapDialog: wrapDialog,
      children: [
        oneParam("NP Gain", (result.totalDefNpGains / 100).format(precision: 2)),
        if (minResult != null && maxResult != null)
          oneParam('', '(${minResult!.totalDefNpGains / 100}~${maxResult!.totalDefNpGains / 100})'),
        if (result.defNpGains.any((e) => e > 0))
          listValueWithOverkill(result.defNpGains, result.overkillStates, (v) => (v / 100).format(precision: 2)),
        oneParam(S.current.defense_np_rate, defenderNpGainRate.format(precision: 2)),
        oneParam(S.current.attack_np_rate, attackerNpRate.format(precision: 3)),
        if (params.cardDefNpRate != 1000)
          oneParam(S.current.battle_card_np_rate, params.cardDefNpRate.format(percent: true, precision: 3, base: 10)),
        oneParam(
            Transl.buffNames('被ダメージ時NP獲得アップ').l, defenseNpGainBuff.format(percent: true, precision: 3), buffIcon(335)),
        oneParam(Transl.buffNames('NP獲得アップ').l, npGainBuff.format(percent: true, precision: 3), buffIcon(303)),
      ],
    );
  }
}

class StarParamDialog extends StatelessWidget with _ParamDialogMixin {
  final StarParameters params;
  final DamageResult result;
  final bool wrapDialog;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  const StarParamDialog(this.params, this.result, {super.key, this.wrapDialog = true, this.minResult, this.maxResult});

  @override
  Widget build(BuildContext context) {
    final attackerStarGen = toModifier(params.attackerStarGen);
    final defenderStarRate = toModifier(params.defenderStarRate);
    final cardRate = toModifier(params.cardDropStarRate);
    final cardSum = max(toModifier(params.cardBuff - params.cardResist), -1);
    final starGenBuff = toModifier(params.starGenBuff - params.enemyStarGenResist);

    return buildDialog(
      context: context,
      title: S.current.battle_star_parameters,
      wrapDialog: wrapDialog,
      children: [
        oneParam(S.current.critical_star, (result.totalStars / 1000).format(precision: 3)),
        if (minResult != null && maxResult != null)
          oneParam('', '(${minResult!.totalStars / 1000}~${maxResult!.totalStars / 1000})'),
        if (result.stars.any((e) => e > 0))
          listValueWithOverkill(result.stars, result.overkillStates, (v) => (v / 1000).format(precision: 3)),
        oneParam(S.current.info_star_rate, attackerStarGen.format(precision: 3)),
        oneParam(S.current.crit_star_mod, defenderStarRate.format(precision: 3)),
        if (params.cardDropStarRate != 1000)
          oneParam(S.current.battle_card_star_rate, cardRate.format(percent: true, precision: 3)),
        oneParam(Transl.buffNames('カード性能アップ').l, cardSum.format(percent: true, precision: 3),
            cardBuffIcon(params.currentCardType)),
        oneParam(Transl.buffNames('スター発生アップ').l, starGenBuff.format(percent: true, precision: 3), buffIcon(321)),
      ],
    );
  }
}

class _InstantDeathDetailWidget extends StatelessWidget with MultiTargetsWrapper {
  final BattleData? battleData;
  final BattleInstantDeathRecord record;

  const _InstantDeathDetailWidget({this.battleData, required this.record});

  @override
  Widget build(BuildContext context) {
    return buildContent(
      context: context,
      isActorEnemy: record.activator?.isEnemy == true,
      isTargetEnemy: record.targets.any((e) => e.target.isEnemy),
      actorBuilder: buildActor,
      targets: [
        for (final target in record.targets)
          Tuple3(target.target.isEnemy, target.target.fieldIndex, (context) => buildTarget(context, target))
      ],
    );
  }

  Widget buildActor(BuildContext context) {
    final actor = record.activator;
    if (actor == null) return MultiTargetsWrapper._defaultPlaceholder(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: actor.iconBuilder(context: context, width: 48, battleData: battleData)),
          Text(
            actor.lBattleName,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          coloredText(S.current.instant_death, null),
        ],
      ),
    );
  }

  Widget buildTarget(BuildContext context, InstantDeathResultDetail detail) {
    final params = detail.params;

    VoidCallback? onTap;
    if (!params.isForce) {
      onTap = () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) => InstantDeathParamDialog(params),
        );
      };
    }

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
          if (params.success)
            coloredText(
              params.isForce
                  ? S.current.force_instant_death
                  : params.isManualSuccess
                      ? '${S.current.instant_death}※'
                      : S.current.instant_death,
              Colors.red,
              onTap,
            )
          else
            coloredText(params.resultString, Colors.blue, onTap),
          if (!params.isForce) coloredText('${detail.params.activateRate / 10}%', null, onTap),
        ],
      ),
    );
  }
}

class InstantDeathParamDialog extends StatelessWidget with _ParamDialogMixin {
  final InstantDeathParameters params;
  final bool wrapDialog;
  const InstantDeathParamDialog(this.params, {super.key, this.wrapDialog = true});

  @override
  Widget build(BuildContext context) {
    return buildDialog(
      context: context,
      title: S.current.instant_death_params,
      wrapDialog: wrapDialog,
      children: [
        oneParam('[${S.current.target}]${S.current.info_death_rate}',
            params.deathRate.format(percent: true, precision: 3, base: 10)),
        oneParam(S.current.death_effect_rate, params.functionRate.format(percent: true, precision: 3, base: 10)),
        oneParam(Transl.buffNames('即死付与率アップ').l, params.buffRate.format(percent: true, precision: 3, base: 10),
            buffIcon(337)),
        DividerWithTitle(title: S.current.results, height: 12),
        oneParam(S.current.death_chance, params.activateRate.format(percent: true, precision: 3, base: 10)),
        oneParam(
          '',
          [params.resultString, if (params.isManualSuccess) '(${S.current.battle_tailored_execution})'].join('\n'),
        ),
      ],
    );
  }
}
