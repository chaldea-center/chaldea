import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
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

  const AiTable({
    super.key,
    required this.type,
    required this.ais,
    required this.onClickNextAi,
    this.region,
    this.skills,
    this.td,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) {
        return ListTile(title: Text("${type.name.toUpperCase()} AI ${ais.first.id}"));
      },
      contentBuilder: getTable,
    );
  }

  Widget sized(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Padding(padding: const EdgeInsets.all(4), child: Center(child: child)),
    );
  }

  List<Widget> toRow(String header, {Iterable<String>? texts, Iterable<Widget>? children}) {
    return [
      Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
      if (texts != null)
        for (final text in texts) Text(text),
      if (children != null) ...children,
    ];
  }

  Widget getTable(BuildContext context) {
    List<List<Widget>> rows = [
      toRow("Sub ID", texts: ais.map((e) => e.infoText.isEmpty ? e.idx.toString() : '${e.idx} ${e.infoText}')),
      toRow("ActNum", texts: ais.map((e) => _desActNum(e.actNumInt, e.actNum))),
      if (type == AiType.field) toRow("Timing", texts: ais.map((e) => _desTiming(e.timing, e.timingDescription))),
      toRow("Cond", children: ais.map((e) => _desCond(context, e.cond, e.condNegative, e.vals))),
      toRow("Priority", texts: ais.map((e) => e.priority.toString())),
      toRow("Weight", texts: ais.map((e) => e.probability.toString())),
      toRow("ActType", children: ais.map((e) => _desActType(context, e.aiAct.type))),
      toRow("ActTarget", children: ais.map((e) => _desActTarget(context, e.aiAct.target, e.aiAct.targetIndividuality))),
      toRow("ActSkill", children: ais.map((e) => _desActSkill(context, e.aiAct))),
      toRow("Next AI", children: ais.map((e) => _desNextAi(context, e.avals))),
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
                    ? BoxDecoration(color: Theme.of(context).highlightColor.withOpacity(0.1))
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
    return actNum == NiceAiActNum.unknown ? actNumInt.toString() : actNum.name;
  }

  String _desTiming(int? timing, AiTiming? timingDescription) {
    if (timing == null) return "";
    if (timingDescription == null || timingDescription == AiTiming.unknown) return timing.toString();
    return timingDescription.name;
  }

  Widget _desCond(BuildContext context, NiceAiCond cond, bool isNegative, List<int> vals) {
    List<InlineSpan> spans = [
      if (isNegative) const TextSpan(text: "(NOT)"),
      TextSpan(text: cond.name),
    ];
    if (vals.isNotEmpty) {
      spans.addAll([
        const TextSpan(text: ': '),
        TextSpan(text: vals.toString()),
      ]);
    }
    return InkWell(
      onTap: () {
        _AiCondDialog(cond: cond, isNegative: isNegative, vals: vals).showDialog(context);
      },
      child: Text.rich(TextSpan(children: spans)),
    );
  }

  Widget _desActType(BuildContext context, NiceAiActType actType) {
    List<InlineSpan> spans = [TextSpan(text: actType.name)];
    NiceSkill? skill;
    if (skills != null) {
      if (actType == NiceAiActType.skill1) {
        skill = skills!.skill1;
      } else if (actType == NiceAiActType.skill2) {
        skill = skills!.skill2;
      } else if (actType == NiceAiActType.skill3) {
        skill = skills!.skill3;
      }
    }
    if (skill != null) {
      spans.addAll([
        const TextSpan(text: '\n'),
        SharedBuilder.textButtonSpan(
            context: context, text: skill.lName.l, onTap: () => skill?.routeTo(region: region)),
      ]);
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _desActTarget(BuildContext context, NiceAiActTarget target, List<NiceTrait> traits) {
    return Text.rich(TextSpan(
      text: target.name,
      children: traits.isEmpty
          ? null
          : [
              const TextSpan(text: ' - '),
              ...SharedBuilder.traitSpans(context: context, traits: traits),
            ],
    ));
  }

  Widget _desActSkill(BuildContext context, NiceAiAct aiAct) {
    List<InlineSpan> spans = [];
    if (aiAct.skillId != null) {
      if (aiAct.skill != null) {
        spans.add(SharedBuilder.textButtonSpan(
            context: context, text: aiAct.skill!.dispName, onTap: () => aiAct.skill!.routeTo(region: region)));
      } else {
        spans.add(SharedBuilder.textButtonSpan(
          context: context,
          text: aiAct.skillId.toString(),
          onTap: () => router.push(url: Routes.skillI(aiAct.skillId!), region: region),
        ));
      }
      if (aiAct.skillLv != null) {
        spans.add(TextSpan(text: ' Lv.${aiAct.skillLv}'));
      }
    }
    if (aiAct.noblePhantasmId != null) {
      if (aiAct.noblePhantasm != null) {
        spans.add(SharedBuilder.textButtonSpan(
          context: context,
          text: aiAct.noblePhantasm!.dispName,
          onTap: () => aiAct.noblePhantasm!.routeTo(region: region),
        ));
      } else {
        spans.add(SharedBuilder.textButtonSpan(
          context: context,
          text: aiAct.noblePhantasmId.toString(),
          onTap: () => router.push(url: Routes.tdI(aiAct.noblePhantasmId!), region: region),
        ));
      }
      if (aiAct.noblePhantasmLv != null) {
        spans.add(TextSpan(text: ' Lv.${aiAct.noblePhantasmLv}'));
      }
      if (aiAct.noblePhantasmOc != null) {
        spans.add(TextSpan(text: ' OC${aiAct.noblePhantasmOc! ~/ 100}%'));
      }
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _desNextAi(BuildContext context, List<int> avals) {
    if (avals.isEmpty || avals.first == 0) return const SizedBox.shrink();
    return Text.rich(SharedBuilder.textButtonSpan(
      context: context,
      text: '[${avals.first}]',
      onTap: () => onClickNextAi(avals.first),
    ));
  }
}

class _AiCondDialog extends StatelessWidget {
  final NiceAiCond cond;
  final bool isNegative;
  final List<int> vals;
  const _AiCondDialog({required this.cond, required this.isNegative, required this.vals});

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text((isNegative ? '(NOT)' : '') + cond.name, textScaleFactor: 0.85),
      scrollable: true,
      hideCancel: true,
      contentPadding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          guessType(context, "Trait?", (v) => Transl.trait(v).l, (v) => router.push(url: Routes.traitI(v))),
          guessType(
              context, "Buff?", (v) => db.gameData.baseBuffs[v]?.lName.l, (v) => router.push(url: Routes.buffI(v))),
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
      subtitle: Text.rich(TextSpan(
        children: divideList(
          [
            for (final v in vals)
              SharedBuilder.textButtonSpan(
                context: context,
                text: text(v) ?? v.toString(),
                onTap: () => onTap(v),
              )
          ],
          const TextSpan(text: ' / '),
        ),
      )),
    );
  }
}
