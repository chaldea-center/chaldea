import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import '../common/builders.dart';

class AiTable extends StatelessWidget {
  final AiType type;
  final List<NiceAi> ais;
  final Region? region;
  final EnemySkill? skills;
  final EnemyTd? td;
  final void Function(int nextAiId) onClickNextAi;
  final bool expanded;

  const AiTable({
    super.key,
    required this.type,
    required this.ais,
    required this.onClickNextAi,
    this.region,
    this.skills,
    this.td,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) {
        return ListTile(title: Text("${type.name.toUpperCase()} AI ${ais.first.id}"));
      },
      contentBuilder: getTable,
    );
  }

  Widget sized(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Center(child: child),
      ),
    );
  }

  List<Widget> toRow(String header, {String Function(NiceAi ai)? text, Widget Function(NiceAi ai)? child}) {
    return [
      Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
      if (text != null)
        for (final ai in ais) Text(text(ai)),
      if (child != null)
        for (final ai in ais) child(ai),
    ];
  }

  Widget getTable(BuildContext context) {
    List<List<Widget>> rows = [
      toRow("Sub ID", text: (e) => e.infoText.isEmpty ? e.idx.toString() : '${e.idx} ${e.infoText}'),
      toRow("ActNum", text: (e) => _desActNum(e.actNumInt, e.actNum)),
      if (type == AiType.field) toRow("Timing", text: (e) => _desTiming(e.timing, e.timingDescription)),
      toRow("Cond", child: (e) => _desCond(context, e.cond, e.condNegative, e.vals)),
      toRow("Priority", text: (e) => e.priority.toString()),
      toRow("Weight", text: (e) => e.probability.toString()),
      toRow("ActId", text: (e) => e.id.toString()),
      toRow("ActType", text: (e) => _desActType(context, e.aiAct)),
      toRow("ActTarget", child: (e) => _desActTarget(context, e.aiAct.target, e.aiAct.targetIndividuality)),
      toRow("Act", child: (e) => _desActSkill(context, e)),
      toRow("Next AI", child: (e) => _desNextAi(context, e.avals)),
    ];
    final borderSide = Divider.createBorderSide(context);
    final table = Table(
      children: [
        for (int index = 0; index < rows.length; index++)
          TableRow(
            children: rows[index].map(sized).toList(),
            decoration: index == 0
                ? BoxDecoration(color: Theme.of(context).highlightColor)
                : index.isEven
                ? BoxDecoration(color: Theme.of(context).highlightColor.withAlpha(25))
                : null,
          ),
      ],
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        left: borderSide,
        right: borderSide,
        bottom: borderSide,
        top: borderSide,
        verticalInside: borderSide,
      ),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: DefaultTextStyle.merge(child: table, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  String _desActNum(int actNumInt, NiceAiActNum actNum) {
    return Transl.md.enums.aiActNum[actNumInt]?.l ??
        (actNum == NiceAiActNum.unknown ? actNumInt.toString() : actNum.name);
  }

  String _desTiming(int? timing, AiTiming? timingDescription) {
    if (timing == null) return '';
    return Transl.md.enums.aiTiming[timing]?.l ??
        (timingDescription == AiTiming.unknown || timingDescription == null
            ? timing.toString()
            : timingDescription.name);
  }

  String _desActType(BuildContext context, NiceAiAct aiAct) {
    return Transl.enums(aiAct.type, (enums) => enums.aiActType).l;
  }

  Widget _desActTarget(BuildContext context, NiceAiActTarget target, List<int> traits) {
    return Text.rich(
      TextSpan(
        text: Transl.enums(target, (enums) => enums.aiActTarget).l,
        children: traits.isEmpty
            ? null
            : [const TextSpan(text: ' - '), ...SharedBuilder.traitSpans(context: context, traits: traits)],
      ),
    );
  }

  Widget _desActSkill(BuildContext context, NiceAi ai) {
    final NiceAiAct aiAct = ai.aiAct;
    List<InlineSpan> spans = [];

    // skill
    NiceSkill? skill;
    int? skillId;
    if (aiAct.skillId != null && aiAct.skillId != 0) {
      skillId = aiAct.skillId!;
      skill = aiAct.skill;
    } else if (skills != null) {
      if (aiAct.type == NiceAiActType.skill1) {
        skill = skills!.skill1;
      } else if (aiAct.type == NiceAiActType.skill2) {
        skill = skills!.skill2;
      } else if (aiAct.type == NiceAiActType.skill3) {
        skill = skills!.skill3;
      }
    }

    if (skill != null) {
      spans.add(
        SharedBuilder.textButtonSpan(
          context: context,
          text: skill.dispName,
          onTap: () => skill!.routeTo(region: region),
        ),
      );
    } else if (skillId != null) {
      spans.add(
        SharedBuilder.textButtonSpan(
          context: context,
          text: skillId.toString(),
          onTap: () => router.push(url: Routes.skillI(skillId!), region: region),
        ),
      );
    }
    if (aiAct.skillLv != null) {
      spans.add(TextSpan(text: ' Lv.${aiAct.skillLv}'));
    }

    // td
    if (aiAct.type == NiceAiActType.noblePhantasm) {
      NiceTd? _td;
      int? _tdId;
      if (aiAct.noblePhantasmId != null && aiAct.noblePhantasmId != 0) {
        _td = aiAct.noblePhantasm;
        _tdId = aiAct.noblePhantasmId!;
      } else if (aiAct.type == NiceAiActType.noblePhantasm && td != null) {
        _td = td!.noblePhantasm;
        _tdId = td!.noblePhantasmId;
      }
      if (_td != null) {
        spans.add(
          SharedBuilder.textButtonSpan(
            context: context,
            text: _td.dispName,
            onTap: () => _td!.routeTo(region: region),
          ),
        );
      } else if (_tdId != null) {
        spans.add(
          SharedBuilder.textButtonSpan(
            context: context,
            text: _tdId.toString(),
            onTap: () => router.push(url: Routes.tdI(_tdId!), region: region),
          ),
        );
      }
      if (aiAct.noblePhantasmLv != null) {
        spans.add(TextSpan(text: ' Lv.${aiAct.noblePhantasmLv}'));
      }
      if (aiAct.noblePhantasmOc != null) {
        spans.add(TextSpan(text: ' OC${aiAct.noblePhantasmOc! ~/ 100}%'));
      }
    }

    // message
    if (aiAct.type == NiceAiActType.message) {
      final msgId = ai.avals.getOrNull(1) ?? 0;
      spans.add(
        SharedBuilder.textButtonSpan(
          context: context,
          text: 'message',
          onTap: msgId == 0
              ? null
              : () {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => BattleMessageDialog(msgId: msgId, region: region),
                  );
                },
        ),
      );
    } else if (aiAct.type == NiceAiActType.messageGroup) {
      final groupId = ai.avals.getOrNull(1) ?? 0;
      spans.add(
        SharedBuilder.textButtonSpan(
          context: context,
          text: 'messageGroup',
          onTap: groupId == 0
              ? null
              : () {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => _BattleMessageGroupDialog(groupId: groupId, region: region),
                  );
                },
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }

  Widget _desNextAi(BuildContext context, List<int> avals) {
    if (avals.isEmpty || avals.first == 0) return const SizedBox.shrink();
    return Text.rich(
      SharedBuilder.textButtonSpan(context: context, text: '[${avals.first}]', onTap: () => onClickNextAi(avals.first)),
    );
  }

  // cond descriptor

  Widget _desCond(BuildContext context, NiceAiCond cond, bool isNegative, List<int> vals) {
    List<InlineSpan> spans = [
      if (isNegative) TextSpan(text: "(${Transl.special.not()})"),
      ...SharedBuilder.replaceSpanMaps(
        Transl.enums(cond, (enums) => enums.aiCond).l,
        _getCondVals(context, cond, isNegative, vals),
        ifAbsent: (missing) {
          return [
            if (vals.isNotEmpty)
              SharedBuilder.textButtonSpan(
                context: context,
                text: "[${vals.join('/')}]",
                onTap: () {
                  _AiCondDialog(cond: cond, isNegative: isNegative, vals: vals).showDialog(context);
                },
              ),
          ];
        },
      ),
    ];
    return InkWell(
      onTap: () {
        _AiCondDialog(cond: cond, isNegative: isNegative, vals: vals).showDialog(context);
      },
      child: Text.rich(TextSpan(children: spans)),
    );
  }

  Map<String, List<InlineSpan> Function(String match)> _getCondVals(
    BuildContext context,
    NiceAiCond cond,
    bool isNegative,
    List<int> vals,
  ) {
    if (vals.isEmpty) return const {};
    Map<String, List<InlineSpan> Function(String match)> _repl0(List<InlineSpan> v) => {"{0}": (_) => v};
    switch (cond) {
      // int
      case NiceAiCond.actcount:
      case NiceAiCond.actcountMultiple:
      case NiceAiCond.turn:
      case NiceAiCond.turnMultiple:
      case NiceAiCond.beforeActId:
      case NiceAiCond.beforeNotActId:
      case NiceAiCond.checkSelfNpturn:
      case NiceAiCond.checkPtLowerNpturn:
      case NiceAiCond.fieldturn:
      case NiceAiCond.fieldturnMultiple:
      case NiceAiCond.checkPtLowerTdturn:
      case NiceAiCond.checkSpace:
      case NiceAiCond.turnHigher:
      case NiceAiCond.turnLower:
      case NiceAiCond.charactorTurnHigher:
      case NiceAiCond.charactorTurnLower:
      case NiceAiCond.countAlivePt:
      case NiceAiCond.countAliveOpponent:
      case NiceAiCond.countPtRestLower:
      case NiceAiCond.countOpponentRestHigher:
      case NiceAiCond.countOpponentRestLower:
      case NiceAiCond.starHigher:
      case NiceAiCond.starLower:
      case NiceAiCond.checkTargetPosition:
      case NiceAiCond.countAlivePtAll:
      case NiceAiCond.countAliveOpponentAll:
      case NiceAiCond.ptFrontDeadEqual:
      case NiceAiCond.ptCenterDeadEqual:
      case NiceAiCond.ptBackDeadEqual:
      case NiceAiCond.countHigherRemainTurn:
      case NiceAiCond.checkSelfNpturnHigher:
      case NiceAiCond.checkSelfNpturnLower:
      case NiceAiCond.countPlayerNpHigher:
      case NiceAiCond.countPlayerNpLower:
      case NiceAiCond.countPlayerNpEqual:
      case NiceAiCond.countPlayerSkillHigher:
      case NiceAiCond.countPlayerSkillLower:
      case NiceAiCond.countPlayerSkillEqual:
      case NiceAiCond.countPlayerSkillHigherIncludeMasterSkill:
      case NiceAiCond.countPlayerSkillLowerIncludeMasterSkill:
      case NiceAiCond.countPlayerSkillEqualIncludeMasterSkill:
      case NiceAiCond.totalTurnHigher:
      case NiceAiCond.totalTurnLower:
      case NiceAiCond.totalTurnEqual:
        return _repl0([TextSpan(text: vals.join('/'))]);
      // percent 1000
      case NiceAiCond.hpHigher:
      case NiceAiCond.hpLower:
        return _repl0([TextSpan(text: vals.map((e) => e.format(percent: true, compact: false, base: 10)).join('/'))]);
      // indiv
      case NiceAiCond.checkSelfIndividuality:
      case NiceAiCond.checkPtIndividuality:
      case NiceAiCond.checkOpponentIndividuality:
      case NiceAiCond.checkSelfBuffIndividuality:
      case NiceAiCond.checkPtBuffIndividuality:
      case NiceAiCond.checkOpponentBuffIndividuality:
      case NiceAiCond.checkPtAllIndividuality:
      case NiceAiCond.checkOpponentAllIndividuality:
      case NiceAiCond.checkSelfBuffActiveAndPassiveIndividuality:
      case NiceAiCond.checkPtBuffActiveAndPassiveIndividuality:
      case NiceAiCond.checkOpponentBuffActiveAndPassiveIndividuality:
      case NiceAiCond.checkPtAllBuffIndividuality:
      case NiceAiCond.checkOpponentAllBuffIndividuality:
      case NiceAiCond.existIndividualityOpponentFront:
      case NiceAiCond.existIndividualityOpponentCenter:
      case NiceAiCond.existIndividualityOpponentBack:
        return _repl0(SharedBuilder.traitSpans(context: context, traits: vals));
      // Buff
      case NiceAiCond.checkSelfBuff:
      case NiceAiCond.checkPtBuff:
      case NiceAiCond.checkOpponentBuff:
      case NiceAiCond.checkSelfBuffActive:
      case NiceAiCond.checkPtBuffActive:
      case NiceAiCond.checkOpponentBuffActive:
      case NiceAiCond.checkPtAllBuff:
      case NiceAiCond.checkOpponentAllBuff:
      case NiceAiCond.checkPtAllBuffActive:
      case NiceAiCond.checkOpponentAllBuffActive:
        return _repl0([
          for (final val in vals)
            SharedBuilder.textButtonSpan(context: context, text: db.gameData.baseBuffs[val]?.lName.l ?? val.toString()),
        ]);
      // [count,trait]
      case NiceAiCond.checkSelfBuffcountIndividuality:
      case NiceAiCond.checkPtBuffcountIndividuality:
      case NiceAiCond.countHigherBuffIndividualitySumPt:
      case NiceAiCond.countHigherBuffIndividualitySumPtAll:
      case NiceAiCond.countHigherBuffIndividualitySumOpponent:
      case NiceAiCond.countHigherBuffIndividualitySumOpponentAll:
      case NiceAiCond.countHigherBuffIndividualitySumSelf:
      case NiceAiCond.countLowerBuffIndividualitySumPt:
      case NiceAiCond.countLowerBuffIndividualitySumPtAll:
      case NiceAiCond.countLowerBuffIndividualitySumOpponent:
      case NiceAiCond.countLowerBuffIndividualitySumOpponentAll:
      case NiceAiCond.countLowerBuffIndividualitySumSelf:
      case NiceAiCond.countEqualBuffIndividualitySumPt:
      case NiceAiCond.countEqualBuffIndividualitySumPtAll:
      case NiceAiCond.countEqualBuffIndividualitySumOpponent:
      case NiceAiCond.countEqualBuffIndividualitySumOpponentAll:
      case NiceAiCond.countEqualBuffIndividualitySumSelf:
      case NiceAiCond.totalCountHigherIndividualityPt:
      case NiceAiCond.totalCountHigherIndividualityPtAll:
      case NiceAiCond.totalCountHigherIndividualityOpponent:
      case NiceAiCond.totalCountHigherIndividualityOpponentAll:
      case NiceAiCond.totalCountHigherIndividualityAllField:
      case NiceAiCond.totalCountLowerIndividualityPt:
      case NiceAiCond.totalCountLowerIndividualityPtAll:
      case NiceAiCond.totalCountLowerIndividualityOpponent:
      case NiceAiCond.totalCountLowerIndividualityOpponentAll:
      case NiceAiCond.totalCountLowerIndividualityAllField:
      case NiceAiCond.totalCountEqualIndividualityPt:
      case NiceAiCond.totalCountEqualIndividualityPtAll:
      case NiceAiCond.totalCountEqualIndividualityOpponent:
      case NiceAiCond.totalCountEqualIndividualityOpponentAll:
      case NiceAiCond.totalCountEqualIndividualityAllField:
      case NiceAiCond.countHigherIndividualityPtFront:
      case NiceAiCond.countHigherIndividualityPtCenter:
      case NiceAiCond.countHigherIndividualityPtBack:
      case NiceAiCond.countHigherIndividualityOpponentFront:
      case NiceAiCond.countHigherIndividualityOpponentCenter:
      case NiceAiCond.countHigherIndividualityOpponentBack:
      case NiceAiCond.countLowerIndividualityPtFront:
      case NiceAiCond.countLowerIndividualityPtCenter:
      case NiceAiCond.countLowerIndividualityPtBack:
      case NiceAiCond.countLowerIndividualityOpponentFront:
      case NiceAiCond.countLowerIndividualityOpponentCenter:
      case NiceAiCond.countLowerIndividualityOpponentBack:
      case NiceAiCond.countEqualIndividualityPtFront:
      case NiceAiCond.countEqualIndividualityPtCenter:
      case NiceAiCond.countEqualIndividualityPtBack:
      case NiceAiCond.countEqualIndividualityOpponentFront:
      case NiceAiCond.countEqualIndividualityOpponentCenter:
      case NiceAiCond.countEqualIndividualityOpponentBack:
        final count = vals.getOrNull(0) ?? 0, trait = vals.getOrNull(1) ?? 0;
        return {
          "{count}": (_) => [TextSpan(text: ' $count ')],
          "{trait}": (_) => [SharedBuilder.traitSpan(context: context, trait: trait)],
        };
      // [count, itemId]
      case NiceAiCond.countItemHigher:
      case NiceAiCond.countItemLower:
        final count = vals.getOrNull(0) ?? 0, itemId = vals.getOrNull(1) ?? 0;
        return {
          "{count}": (_) => [TextSpan(text: ' $count ')],
          "{trait}": (_) => [
            SharedBuilder.textButtonSpan(
              context: context,
              text: db.gameData.items[itemId]?.lName.l ?? 'Item $itemId',
              onTap: () {
                router.push(url: Routes.itemI(itemId));
              },
            ),
          ],
        };
      // unknown
      case NiceAiCond.none:
      case NiceAiCond.checkSelfNotBuffIndividuality:
      case NiceAiCond.beforeActType:
      case NiceAiCond.beforeNotActType:
      case NiceAiCond.checkOpponentHeightNpgauge:
      case NiceAiCond.actcountThisturn:
      case NiceAiCond.checkPtHpHigher:
      case NiceAiCond.checkPtHpLower:
      case NiceAiCond.turnAndActcountThisturn:
      case NiceAiCond.raidHpHigher:
      case NiceAiCond.raidHpLower:
      case NiceAiCond.raidCountHigher:
      case NiceAiCond.raidCountLower:
      case NiceAiCond.raidCountValueHigher:
      case NiceAiCond.raidCountValueLower:
      case NiceAiCond.countPtRestHigher:
      case NiceAiCond.countEnemyCommandSpellHigher:
      case NiceAiCond.checkOpponentHpHigher:
      case NiceAiCond.checkOpponentHpLower:
      case NiceAiCond.checkPrecedingEnemy:
      case NiceAiCond.countLowerRemainTurn:
      case NiceAiCond.countHigherPlayerCommandSpell:
      case NiceAiCond.countLowerPlayerCommandSpell:
      case NiceAiCond.countEqualPlayerCommandSpell:
      case NiceAiCond.checkMasterSkillThisturn:
      case NiceAiCond.checkUseSkillThisturn:
      case NiceAiCond.countChainHigher:
      case NiceAiCond.countChainLower:
      case NiceAiCond.countChainEqual:
      case NiceAiCond.checkSelectChain:
      case NiceAiCond.checkWarBoardSquareIndividuality:
      case NiceAiCond.checkPtHigherNpgauge:
      case NiceAiCond.checkSelfHigherNpgauge:
      case NiceAiCond.checkBattleValueAbove:
      case NiceAiCond.checkBattleValueEqual:
      case NiceAiCond.checkBattleValueNotEqual:
      case NiceAiCond.checkBattleValueBelow:
      case NiceAiCond.checkBattleValueBetween:
      case NiceAiCond.checkBattleValueNotBetween:
        return {};
      case NiceAiCond.checkUseMasterSkillIndex:
      case NiceAiCond.checkUseMasterSkillIndexThisTurn:
      case NiceAiCond.countMasterSkillHigherThisTurn:
      case NiceAiCond.countMasterSkillLowerThisTurn:
      case NiceAiCond.countMasterSkillEqualThisTurn:
      case NiceAiCond.countMasterSkillHigherThisWave:
      case NiceAiCond.countMasterSkillLowerThisWave:
      case NiceAiCond.countMasterSkillEqualThisWave:
      case NiceAiCond.countAvailablePlayerAndMasterSkillHigher:
      case NiceAiCond.countAvailablePlayerAndMasterSkillLower:
      case NiceAiCond.countAvailablePlayerAndMasterSkillEqual:
      case NiceAiCond.countAvailablePlayerSkillHigher:
      case NiceAiCond.countAvailablePlayerSkillLower:
      case NiceAiCond.countAvailablePlayerSkillEqual:
      case NiceAiCond.countAvailableMasterSkillHigher:
      case NiceAiCond.countAvailableMasterSkillLower:
      case NiceAiCond.countAvailableMasterSkillEqual:
      case NiceAiCond.commonReleaseId:
      case NiceAiCond.existRemainChargeTurnMasterSkill:
        return {};
    }
  }
}

class _AiCondDialog extends StatelessWidget {
  final NiceAiCond cond;
  final bool isNegative;
  final List<int> vals;
  const _AiCondDialog({required this.cond, required this.isNegative, required this.vals});

  @override
  Widget build(BuildContext context) {
    String condText = '';
    if (isNegative) {
      condText += '(${Transl.special.not()})';
    }
    condText += '${cond.name}: ';
    condText += Transl.enums(cond, (enums) => enums.aiCond).l;
    return SimpleConfirmDialog(
      title: Text(S.current.condition),
      scrollable: true,
      showCancel: false,
      contentPadding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(dense: true, title: Text(condText), contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
          ListTile(dense: true, title: Text('vals: $vals')),
          const Divider(indent: 16, endIndent: 16),
          guessType(context, "Trait?", (v) => Transl.traitName(v), (v) => router.push(url: Routes.traitI(v))),
          guessType(
            context,
            "Buff?",
            (v) => db.gameData.baseBuffs[v]?.lName.l,
            (v) => router.push(url: Routes.buffI(v)),
          ),
        ],
      ),
    );
  }

  Widget guessType(BuildContext context, String title, String? Function(int v) text, void Function(int v) onTap) {
    return ListTile(
      title: Text(title),
      // tileColor: Colors.amber,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      subtitle: Text.rich(
        TextSpan(
          children: divideList([
            for (final v in vals)
              SharedBuilder.textButtonSpan(context: context, text: text(v) ?? v.toString(), onTap: () => onTap(v)),
          ], const TextSpan(text: ' / ')),
        ),
      ),
    );
  }
}

class BattleMessageDialog extends StatelessWidget {
  final int msgId;
  final Region? region;
  const BattleMessageDialog({super.key, required this.msgId, this.region});

  @override
  Widget build(BuildContext context) {
    return SimpleConfirmDialog(
      title: Text('Message $msgId'),
      scrollable: true,
      showCancel: false,
      content: FutureBuilder2(
        id: msgId,
        loader: () => AtlasApi.battleMessage(msgId, region: region ?? Region.jp),
        builder: (context, messages) {
          if (messages == null) return Text(S.current.error);
          if (messages.isEmpty) return Text(S.current.not_found);
          messages = messages.toList()..sort2((e) => e.priority);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final msg in messages) buildMessage(context, msg)],
          );
        },
        onFailed: (context) => const Text("Load Failed"),
        onLoading: (context) => const Text("Loading..."),
      ),
    );
  }

  static Widget buildMessage(BuildContext context, BattleMessage msg) {
    return TileGroup(
      header: 'No.${msg.idx}',
      children: [
        ListTile(
          dense: true,
          selected: true,
          title: Text(msg.message),
          onLongPress: () {
            copyToClipboard(msg.message, toast: true);
          },
        ),
        for (final release in msg.releaseConditions)
          CondTargetValueDescriptor.commonRelease(
            commonRelease: release,
            leading: const TextSpan(text: '$kULLeading '),
            style: Theme.of(context).textTheme.bodySmall,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        if (msg.script.isNotEmpty)
          ListTile(
            dense: true,
            title: Text('$kULLeading script: ${msg.script}', style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _BattleMessageGroupDialog extends StatelessWidget {
  final int groupId;
  final Region? region;
  const _BattleMessageGroupDialog({required this.groupId, this.region});

  @override
  Widget build(BuildContext context) {
    return SimpleConfirmDialog(
      title: Text('Message Group $groupId'),
      scrollable: true,
      showCancel: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      content: FutureBuilder2(
        id: groupId,
        loader: () => AtlasApi.battleMessageGroup(groupId, region: region ?? Region.jp),
        builder: (context, groups) {
          if (groups == null) return Text(S.current.error);
          if (groups.isEmpty) return Text(S.current.not_found);
          groups = groups.toList()..sort2((e) => -e.probability);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final group in groups) ...buildGroup(context, group)],
          );
        },
        onFailed: (context) => const Text("Load Failed"),
        onLoading: (context) => const Text("Loading..."),
      ),
    );
  }

  List<Widget> buildGroup(BuildContext context, BattleMessageGroup group) {
    return [
      DividerWithTitle(title: 'Message ${group.messages.firstOrNull?.id} (${group.probability}%)'),
      for (final msg in group.messages) BattleMessageDialog.buildMessage(context, msg),
    ];
  }
}
