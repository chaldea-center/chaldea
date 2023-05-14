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
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

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
    children.addAll([
      TextButton(
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
      ),
      kIndentDivider,
      ListTile(
        dense: true,
        title: const Text('Enemy Count'),
        subtitle: const Text('ST NP will only attack 1st enemy'),
        trailing: DropdownButton<int>(
          value: options.enemyCount.clamp(1, 6),
          items: [
            for (int count = 1; count <= 6; count++) DropdownMenuItem(value: count, child: Text(count.toString())),
          ],
          onChanged: (v) {
            setState(() {
              if (v != null) options.enemyCount = v;
            });
          },
        ),
      ),
      CheckboxListTile(
        dense: true,
        value: options.addDebuffImmuneEnemy,
        title: const Text('AddDebuffImmune to Enemy'),
        onChanged: (value) {
          setState(() {
            options.addDebuffImmuneEnemy = !options.addDebuffImmuneEnemy;
          });
        },
      ),
    ]);

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
      ListTile(
        dense: true,
        title: const Text('Use Player Data'),
        subtitle: const Text('Non-favorite svt will be skipped'),
        trailing: DropdownButton<PreferPlayerSvtDataSource>(
          isDense: true,
          value: options.usePlayerSvt,
          items: PreferPlayerSvtDataSource.values.map((source) {
            String text;
            switch (source) {
              case PreferPlayerSvtDataSource.none:
                text = S.current.disabled;
                break;
              case PreferPlayerSvtDataSource.current:
                text = S.current.current_;
                break;
              case PreferPlayerSvtDataSource.target:
                text = S.current.target;
                break;
            }
            return DropdownMenuItem(
              value: source,
              child: Text(text, textScaleFactor: 0.9),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              if (v != null) options.usePlayerSvt = v;
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        enabled: options.usePlayerSvt.isNone,
        title: const Text('NP Lv: R0-3 or event svt'),
        trailing: DropdownButton<int>(
          isDense: true,
          value: options.tdR3,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: !options.usePlayerSvt.isNone
              ? null
              : (v) {
                  setState(() {
                    if (v != null) options.tdR3 = v;
                  });
                },
        ),
      ),
      ListTile(
        dense: true,
        enabled: options.usePlayerSvt.isNone,
        title: const Text('NP Lv: R4'),
        trailing: DropdownButton<int>(
          value: options.tdR4,
          isDense: true,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: !options.usePlayerSvt.isNone
              ? null
              : (v) {
                  setState(() {
                    if (v != null) options.tdR4 = v;
                  });
                },
        ),
      ),
      ListTile(
        dense: true,
        enabled: options.usePlayerSvt.isNone,
        title: const Text('NP Lv: R5'),
        trailing: DropdownButton<int>(
          isDense: true,
          value: options.tdR5,
          items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('Lv.${index + 1}'))),
          onChanged: !options.usePlayerSvt.isNone
              ? null
              : (v) {
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
      SwitchListTile.adaptive(
        dense: true,
        title: const Text('Fixed OC'),
        subtitle: const Text('"OC Lv. Up" buff no effect'),
        value: options.fixedOC,
        onChanged: (v) {
          setState(() {
            options.fixedOC = v;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.enableActiveSkills,
        title: const Text('Enable Active Skills'),
        onChanged: (value) {
          setState(() {
            options.enableActiveSkills = !options.enableActiveSkills;
          });
        },
      ),
      CheckboxListTile(
        enabled: options.enableActiveSkills,
        dense: true,
        value: options.twiceActiveSkill,
        title: const Text('Twice skills if Cool Down after 2 turns'),
        subtitle: const Text('Usually for w-Koyan at Turn3'),
        onChanged: (value) {
          setState(() {
            options.twiceActiveSkill = !options.twiceActiveSkill;
          });
        },
      ),
      CheckboxListTile(
        dense: true,
        value: options.enableAppendSkills,
        title: const Text('Enable Append Passives'),
        onChanged: (value) {
          setState(() {
            options.enableAppendSkills = !options.enableAppendSkills;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.addDebuffImmune,
        title: const Text('AddDebuffImmune'),
        onChanged: (value) {
          setState(() {
            options.addDebuffImmune = !options.addDebuffImmune;
          });
        },
      ),
      CheckboxListTile(
        enabled: false,
        dense: true,
        value: options.upResistSubState,
        title: const Text('Up Resist SubState 500%'),
        onChanged: (value) {
          setState(() {
            options.upResistSubState = !options.upResistSubState;
          });
        },
      ),
    ]);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 64),
      children: children,
    );
  }
}
