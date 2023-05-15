import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'model.dart';

class TdDmgOptionsTab extends StatefulWidget {
  final TdDmgSolver solver;
  final VoidCallback onStart;
  const TdDmgOptionsTab({super.key, required this.solver, required this.onStart});

  @override
  State<TdDmgOptionsTab> createState() => _TdDmgOptionsTabState();
}

class _TdDmgOptionsTabState extends State<TdDmgOptionsTab> {
  TdDamageOptions get options => widget.solver.options;
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
            ValueListenableBuilder(
              valueListenable: widget.solver.running,
              builder: (context, value, child) => ElevatedButton(
                onPressed: value ? null : widget.onStart,
                child: Text(S.current.calculate),
              ),
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
            final supportFull = options.supports.length >= 5;
            if (supportFull) {
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
              content: Wrap(
                children: supports,
              ),
              hideOk: supportFull,
              confirmText: S.current.general_custom,
              onTapOk: () {
                if (!mounted) return;
                router.pushPage(ServantListPage(
                  onSelected: (svt) {
                    options.supports.add(svt);
                    if (mounted) setState(() {});
                  },
                ));
              },
            );
          },
        );
      },
      child: const Text('Add Support'),
    ));
    children.add(const SFooter('Long press to remove support.'));

    children.add(const DividerWithTitle(title: 'Additional Buff'));
    children.add(const Text('TODO'));
    children.add(_buildCEPart());
    children.add(_buildMCPart());
    children.add(const DividerWithTitle(title: "Options"));
    children.addAll([
      ListTile(
        dense: true,
        title: Text(S.current.game_server),
        trailing: DropdownButton<Region>(
          isDense: true,
          value: options.region,
          items: [
            for (final region in Region.values)
              DropdownMenuItem(value: region, child: Text(region.localName, textScaleFactor: 0.9)),
          ],
          onChanged: (v) {
            setState(() {
              if (v != null) options.region = v;
            });
          },
        ),
      ),
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
        title: const Text('Level'),
        trailing: DropdownButton<SvtLv>(
          isDense: true,
          value: options.svtLv,
          items: [
            for (final lv in SvtLv.values)
              DropdownMenuItem(
                value: lv,
                child: Text(
                  lv == SvtLv.maxLv ? 'Lv.MAX' : 'Lv.${lv.lv}',
                  textScaleFactor: 0.9,
                ),
              ),
          ],
          onChanged: !options.usePlayerSvt.isNone
              ? null
              : (v) {
                  setState(() {
                    if (v != null) options.svtLv = v;
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

  Widget _buildCEPart() {
    final ce = db.gameData.craftEssencesById[options.ceId];
    if (ce != null) {
      options.ceLv = options.ceLv.clamp(0, ce.lvMax);
    }
    return SimpleAccordion(
      headerBuilder: (context, _) {
        Widget? trailing;
        if (ce != null) {
          trailing = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ce.iconBuilder(context: context, width: 36),
              Text(' Lv.${options.ceLv}'),
            ],
          );
        }
        return ListTile(
          dense: true,
          leading: const FaIcon(FontAwesomeIcons.streetView),
          title: Text(S.current.craft_essence),
          subtitle: ce == null ? null : Text(ce.lName.l),
          trailing: trailing,
          horizontalTitleGap: 8,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
        );
      },
      contentBuilder: (context) {
        final skill = ce?.getActivatedSkills(options.ceMLB)[1]?.firstOrNull;
        return Column(
          children: [
            ListTile(
              dense: true,
              leading: db.getIconImage(ce?.borderedIcon ?? Atlas.common.emptySvtIcon, width: 32),
              horizontalTitleGap: 8,
              title: Text(ce?.lName.l ?? S.current.select_ce),
              trailing: const Icon(Icons.change_circle),
              onTap: () {
                router.pushPage(CraftListPage(
                  pinged: db.settings.battleSim.pingedCEs.toList(),
                  filterData: CraftFilterData(useGrid: true),
                  onSelected: (ce) {
                    options.ceId = ce.id;
                    options.ceLv = options.ceLv.clamp(0, ce.lvMax);
                    if (mounted) setState(() {});
                  },
                ));
              },
            ),
            if (skill != null)
              Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    skill.lDetail ?? "???",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            SwitchListTile.adaptive(
              dense: true,
              value: options.ceMLB,
              title: Text(S.current.max_limit_break),
              onChanged: (v) {
                setState(() {
                  options.ceMLB = v;
                });
              },
            ),
            ListTile(
              dense: true,
              title: Text(S.current.level),
              subtitle: Text('HP ${ce?.hpGrowth.getOrNull(options.ceLv - 1) ?? 0}'
                  ' / ATK ${ce?.atkGrowth.getOrNull(options.ceLv - 1) ?? 0}'),
              trailing: Text('Lv.${options.ceLv}'),
              minVerticalPadding: 0,
            ),
            if (ce != null && ce.atkGrowth.isNotEmpty)
              Slider(
                value: options.ceLv.toDouble(),
                min: 0,
                max: ce.atkGrowth.length.toDouble(),
                label: options.ceLv.toString(),
                divisions: ce.atkGrowth.length,
                onChanged: (v) {
                  setState(() {
                    options.ceLv = v.round();
                  });
                },
              ),
            if (ce != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    options.ceId = null;
                  });
                },
                child: Text(
                  S.current.remove,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
          ],
        );
      },
    );
  }

  Widget _buildMCPart() {
    final mc = db.gameData.mysticCodes[options.mcId];
    options.mcLv = options.mcLv.clamp(1, 10);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        Widget? trailing;
        if (mc != null) {
          trailing = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              mc.iconBuilder(context: context, width: 36),
              Text(' Lv.${options.mcLv}'),
            ],
          );
        }
        return ListTile(
          dense: true,
          leading: const FaIcon(FontAwesomeIcons.personDotsFromLine),
          title: Text(S.current.mystic_code),
          subtitle: mc == null ? null : Text(mc.lName.l),
          trailing: trailing,
          horizontalTitleGap: 8,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
        );
      },
      contentBuilder: (context) {
        return Column(
          children: [
            ListTile(
              dense: true,
              leading: db.getIconImage(mc?.borderedIcon ?? Atlas.common.emptySvtIcon, width: 32),
              horizontalTitleGap: 8,
              title: Text(mc?.lName.l ?? S.current.select),
              trailing: const Icon(Icons.change_circle),
              onTap: () {
                router.pushPage(MysticCodeListPage(
                  onSelected: (mc) {
                    options.mcId = mc.id;
                    if (mounted) setState(() {});
                  },
                ));
              },
            ),
            ListTile(
              dense: true,
              title: Text(S.current.level),
              trailing: Text('Lv.${options.mcLv}'),
              minVerticalPadding: 0,
            ),
            Slider(
              value: options.mcLv.toDouble(),
              min: 1,
              max: 10,
              label: options.mcLv.toString(),
              divisions: 9,
              onChanged: (v) {
                setState(() {
                  options.mcLv = v.round();
                });
              },
            ),
            if (mc != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    options.mcId = null;
                  });
                },
                child: Text(
                  S.current.remove,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
          ],
        );
      },
    );
  }
}
