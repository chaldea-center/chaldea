import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'model.dart';

class TdDmgOptionsTab extends StatefulWidget {
  final TdDamageOptions options;
  final VoidCallback onStart;
  const TdDmgOptionsTab({super.key, required this.options, required this.onStart});

  @override
  State<TdDmgOptionsTab> createState() => _TdDmgOptionsTabState();
}

class _TdDmgOptionsTabState extends State<TdDmgOptionsTab> {
  TdDamageOptions get options => widget.options;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildOptions()),
        kDefaultDivider,
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.onStart,
              child: Text(S.current.calculate),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildOptions() {
    List<Widget> children = [
      const SHeader('Testing, feedback/suggestion welcomed!\n测试中，欢迎反馈&建议！'),
    ];
    children.add(DividerWithTitle(title: S.current.enemy));
    final enemy = options.enemy;
    children.add(ListTile(
      dense: true,
      isThreeLine: true,
      leading: db.getIconImage(
        enemy.icon,
        width: 40,
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
      title: Text(enemy.lShownName),
      subtitle: Text('${Transl.svtClassId(enemy.svt.classId).l} ${Transl.svtAttribute(enemy.svt.attribute).l}'
          '\nHP ${enemy.hp}  DR ${enemy.deathRate.format(percent: true, base: 10)}'
          ' N/D ${enemy.serverMod.tdRate.format(percent: true, base: 10)}'),
      trailing: const Icon(Icons.edit),
      onTap: () {
        // router.pushPage(child);
      },
    ));
    children.add(TextButton(
      onPressed: () {
        final enemy2 = db.runtimeData.clipBoard.questEnemy;
        if (enemy2 == null) {
          const SimpleCancelOkDialog(
            title: Text('Hint'),
            content: Text('Choose one Quest Enemy and copy in popup menun'),
          ).showDialog(context);
        } else {
          SimpleCancelOkDialog(
            title: const Text("Paste Enemy"),
            content: Text("${enemy2.lShownName}(${enemy2.svt.lName.l})\n${Transl.svtClassId(enemy2.svt.classId).l}"),
            onTapOk: () {
              options.enemy = TdDamageOptions.copyEnemy(enemy2);
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }
      },
      child: const Text('Paste Enemy'),
    ));
    children.add(const DividerWithTitle(title: 'Supports'));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          if (options.supports.isEmpty) const Text('None'),
          for (int index = 0; index < options.supports.length; index++)
            GestureDetector(
              onLongPress: () {
                setState(() {
                  options.supports.removeAt(index);
                });
              },
              child: options.supports[index].iconBuilder(context: context, width: 48),
            )
        ],
      ),
    ));
    children.add(TextButton(
      onPressed: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            List<Widget> supports = [];
            if (options.supports.length >= 5) {
              supports.add(const Text('Max 5 supports'));
            } else {
              for (final int svtId in TdDamageOptions.optionalSupports) {
                final svt = db.gameData.servantsNoDup[svtId];
                if (svt != null) {
                  supports.add(svt.iconBuilder(
                    context: context,
                    width: 48,
                    padding: const EdgeInsets.all(2),
                    onTap: () {
                      options.supports.add(svt);
                      Navigator.pop(context);
                      if (mounted) setState(() {});
                    },
                  ));
                }
              }
            }
            return SimpleCancelOkDialog(
              title: const Text('Support'),
              scrollable: true,
              hideOk: true,
              content: Wrap(
                children: supports,
              ),
            );
          },
        );
      },
      child: const Text('Add Support'),
    ));
    children.add(const SFooter('Long press to remove support.'));

    children.add(const DividerWithTitle(title: 'Additional Buff'));
    children.add(const Text('TODO'));
    children.add(const DividerWithTitle(title: "Options"));
    children.addAll([
      CheckboxListTile(
        value: options.usePlayerSvt,
        dense: true,
        title: const Text('Use Player Favorite Servants'),
        onChanged: (value) {
          setState(() {
            options.usePlayerSvt = !options.usePlayerSvt;
          });
        },
      ),
      CheckboxListTile(
        value: options.addDebuffImmune,
        dense: true,
        title: const Text('AddDebuffImmune'),
        onChanged: (value) {
          setState(() {
            options.addDebuffImmune = !options.addDebuffImmune;
          });
        },
      ),
      CheckboxListTile(
        value: options.upResistSubState,
        dense: true,
        title: const Text('Up Resist SubState 500%'),
        onChanged: (value) {
          setState(() {
            options.upResistSubState = !options.upResistSubState;
          });
        },
      ),
      CheckboxListTile(
        value: options.doubleActiveSkillIfCD6,
        dense: true,
        title: const Text('Twice skills if CD<=6 (pls only if w-koyan)'),
        onChanged: (value) {
          setState(() {
            options.doubleActiveSkillIfCD6 = !options.doubleActiveSkillIfCD6;
          });
        },
      ),
      // CheckboxListTile(
      //   value: options.includeRefundAfterTd,
      //   dense: true,
      //   title: const Text('Include NP Gain After TD(e.g. Arthur)'),
      //   onChanged: (value) {
      //     setState(() {
      //       options.includeRefundAfterTd = !options.includeRefundAfterTd;
      //     });
      //   },
      // ),
      ListTile(
        dense: true,
        title: const Text('NP Lv: R0-3 or event svt'),
        trailing: DropdownButton<int>(
          isDense: true,
          value: options.tdR3,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: (v) {
            setState(() {
              if (v != null) options.tdR3 = v;
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('NP Lv: R4'),
        trailing: DropdownButton<int>(
          value: options.tdR4,
          isDense: true,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: (v) {
            setState(() {
              if (v != null) options.tdR4 = v;
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('NP Lv: R5'),
        trailing: DropdownButton<int>(
          isDense: true,
          value: options.tdR5,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: (v) {
            setState(() {
              if (v != null) options.tdR5 = v;
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('NP OC'),
        trailing: DropdownButton<int>(
          isDense: true,
          value: options.oc,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: (v) {
            setState(() {
              if (v != null) options.oc = v;
            });
          },
        ),
      ),
    ]);

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 64),
      children: children,
    );
  }
}
