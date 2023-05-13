import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../simulation/recorder.dart';
import 'model.dart';

class TdDmgRankingTab extends StatefulWidget {
  final TdDamageOptions options;
  final List<TdDmgResult> results;
  final List errors;
  const TdDmgRankingTab({super.key, required this.options, required this.results, required this.errors});

  @override
  State<TdDmgRankingTab> createState() => _TdDmgRankingTabState();
}

class _TdDmgRankingTabState extends State<TdDmgRankingTab> {
  @override
  Widget build(BuildContext context) {
    List<TdDmgResult> results = widget.results.where((e) => e.totalDamage > 0).toList();
    results.sort2((e) => -e.totalDamage);
    results.sortByList((e) => [-e.totalDamage, -e.totalNp]);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (widget.errors.isEmpty) return const SizedBox.shrink();
          return SimpleAccordion(
            headerBuilder: (context, _) => ListTile(
              dense: true,
              title: Text(
                '${widget.errors.length} ${S.current.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            contentBuilder: (context) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(widget.errors.join('\n\n')),
                ),
              );
            },
          );
        }
        final rank = index;
        final result = results[index - 1];
        return SimpleAccordion(
          headerBuilder: (context, _) => headerBuilder(rank, result),
          contentBuilder: (context) => contentBuilder(result),
        );
      },
    );
  }

  Widget headerBuilder(int rank, TdDmgResult result) {
    final dmgStr = result.totalDamage.format(groupSeparator: ",", compact: false);
    return ListTile(
      dense: true,
      leading: result.svt.iconBuilder(context: context, width: 32),
      title: Text('$rank:   $dmgStr'),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('NP ${(result.attackNp / 100)}'),
      ),
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      trailing: CommandCardWidget(card: result.attacks.first.card!.cardType, width: 28),
    );
  }

  Widget contentBuilder(TdDmgResult result) {
    result.attacks.first.targets.single.damageParams;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: result.attacks.map((attack) {
        final target = attack.targets.single;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DamageParamDialog(
              target.damageParams,
              target.result,
              wrapDialog: false,
            ),
          ),
        );
      }).toList(),
    );
  }
}
