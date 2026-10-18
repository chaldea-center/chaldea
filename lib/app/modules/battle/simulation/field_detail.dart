import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'svt_detail.dart';

class FieldBuffDetailPage extends StatefulWidget {
  final BattleData battleData;
  const FieldBuffDetailPage({super.key, required this.battleData});

  @override
  State<FieldBuffDetailPage> createState() => _FieldBuffDetailPageState();
}

class _FieldBuffDetailPageState extends State<FieldBuffDetailPage> {
  BattleData get battleData => widget.battleData;

  // a representative servant used only to resolve dynamic buff values, e.g. ParamAddValue
  BattleServantData? get _referenceAllySvt => battleData.nonnullPlayers.firstOrNull;
  BattleServantData? get _referenceEnemySvt => battleData.nonnullEnemies.firstOrNull;

  @override
  Widget build(BuildContext context) {
    final allyBuffs = battleData.getFieldBuffs(true, true);
    final enemyBuffs = battleData.getFieldBuffs(false, true);
    return Scaffold(
      appBar: AppBar(title: AutoSizeText(S.current.quest_field_buffs, maxLines: 1)),
      body: ListView(
        children: [
          ...[
            ListTile(
              title: Text(
                '${S.current.quest_field_buffs} - ${S.current.battle_ally}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final buff in allyBuffs) buildBuff(buff, allyBuffs, _referenceAllySvt),
          ],
          ...[
            ListTile(
              title: Text(
                '${S.current.quest_field_buffs} - ${S.current.enemy}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final buff in enemyBuffs) buildBuff(buff, enemyBuffs, _referenceEnemySvt),
          ],
        ],
      ),
    );
  }

  Widget buildBuff(BuffData buff, List<BuffData> buffList, BattleServantData? self) {
    final valueSpans = <InlineSpan>[
      if (buff.vals.UseRate != null)
        TextSpan(text: Transl.special.funcValChance(buff.vals.UseRate!.format(base: 10, percent: true))),
      if (buff.count >= 0) TextSpan(text: Transl.special.funcValCountTimes(buff.count)),
      if (buff.logicTurn >= 0) TextSpan(text: Transl.special.funcValTurns(buff.dispTurn)),
      if (buff.param != 0 && !kBuffValueTriggerTypes.containsKey(buff.buff.type))
        TextSpan(
          text: Buff.formatRate(buff.buff.type, self == null ? buff.param : buff.getValue(self)),
          style: (buff.buff.percentBase == null) ? const TextStyle(fontStyle: FontStyle.italic) : null,
        ),
    ];
    if (valueSpans.isEmpty) valueSpans.add(const TextSpan(text: ' - '));
    final bool showActor = buff.vals.OnField == 1;
    final buffName = buff.buff.name.isEmpty
        ? FuncDescriptor.buildBasicFuncText(
            NiceFunction(
              funcId: 0,
              funcType: FuncType.addState,
              funcTargetType: FuncTargetType.self,
              funcTargetTeam: FuncApplyTarget.all,
              buffs: [buff.buff],
              svals: [DataVals(buff.vals.toJson(sort: false)..['Value'] = buff.param)],
            ),
          ).toString()
        : buff.buff.lName.l;
    return ListTile(
      dense: true,
      minLeadingWidth: 24,
      leading: BattleBuffIcon(buff: buff, size: 24),
      title: Text(buffName),
      isThreeLine: showActor,
      subtitle: Text.rich(
        TextSpan(
          text: buff.buff.lDetail.l,
          children: showActor
              ? [
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: Transl.special.actorOnField.replaceAll(
                      '{0}',
                      buff.activatorName ?? buff.activatorUniqueId?.toString() ?? '???',
                    ),
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ]
              : null,
        ),
      ),
      trailing: InkWell(
        onTap: () {
          Map<String, dynamic> vals = buff.vals.toJson(sort: false);
          if (vals['Value'] != buff.param) {
            vals = {'param': buff.param, ...vals};
          }
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return Theme(
                data: ThemeData.light(),
                child: SimpleConfirmDialog(
                  title: const Text('Data Vals'),
                  content: JsonViewer(vals, defaultOpen: true),
                  scrollable: true,
                  showCancel: false,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 12.0, 24.0),
                ),
              );
            },
          );
        },
        child: AutoSizeText.rich(
          TextSpan(children: divideList(valueSpans, const TextSpan(text: '\n'))),
          textAlign: TextAlign.end,
          textScaleFactor: 0.9,
          maxLines: valueSpans.length,
          minFontSize: 10,
        ),
      ),
      onTap: () {
        buff.buff.routeTo();
      },
    );
  }
}
