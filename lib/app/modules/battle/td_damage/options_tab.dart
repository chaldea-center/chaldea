import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/select_skill_page.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/enemy_edit.dart';
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
        SafeArea(
          child: ButtonBar(
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
        ),
      ],
    );
  }

  Widget buildOptions() {
    List<Widget> children = [
      Text(
        'Testing, feedback/suggestion welcomed!\n测试中，欢迎反馈&建议！',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
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
      subtitle: Text(
          '${Transl.svtClassId(enemy.svt.classId).l}  ${Transl.svtAttribute(enemy.svt.attribute).l}  HP ${enemy.hp} '
          '\n${S.current.info_death_rate} ${enemy.deathRate.format(percent: true, base: 10)}'
          ' ${S.current.defense_np_rate} ${enemy.serverMod.tdRate.format(percent: true, base: 10)}'),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        await router.pushPage(QuestEnemyEditPage(
          enemy: enemy,
          onReset: (_) {
            options.enemy = QuestEnemy.blankEnemy();
            if (mounted) setState(() {});
            return options.enemy;
          },
        ));
        if (mounted) setState(() {});
      },
    ));
    children.addAll([
      TextButton(
        onPressed: () {
          final enemy2 = db.runtimeData.clipBoard.questEnemy;
          if (enemy2 == null) {
            SimpleCancelOkDialog(
              title: Text(S.current.paste),
              content: Text(S.current.paste_enemy_hint),
              hideCancel: true,
            ).showDialog(context);
          } else {
            SimpleCancelOkDialog(
              title: Text(S.current.paste),
              content: Text("${enemy2.lShownName}(${enemy2.svt.lName.l})\n${Transl.svtClassId(enemy2.svt.classId).l}"),
              onTapOk: () {
                options.enemy = TdDmgSolver.copyEnemy(enemy2);
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          }
        },
        child: Text(S.current.paste),
      ),
      kIndentDivider,
      ListTile(
        dense: true,
        title: Text(S.current.enemy_count),
        subtitle: Text(S.current.only_usuable_for_aoe_np),
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
        title: Text("${S.current.debuff_immune} (${S.current.enemy})"),
        onChanged: (value) {
          setState(() {
            options.addDebuffImmuneEnemy = !options.addDebuffImmuneEnemy;
          });
        },
      ),
    ]);

    children.add(DividerWithTitle(title: S.current.support_servant));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          if (options.supports.isEmpty) const Text('None'),
          ...List.generate(options.supports.length, (index) {
            final svtId = options.supports[index];
            final svt = db.gameData.servantsById[svtId];
            return GestureDetector(
              onLongPress: () {
                setState(() {
                  options.supports.removeAt(index);
                });
              },
              child: svt?.iconBuilder(context: context, width: 48) ?? Text("ID $svtId"),
            );
          })
        ],
      ),
    ));
    if (options.supports.isNotEmpty) children.add(SFooter(S.current.long_press_to_remove));

    children.add(TextButton(
      onPressed: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            if (options.supports.length >= 5) {
              return SimpleCancelOkDialog(
                title: Text(S.current.support_servant),
                content: const Text('Max 5 supports'),
                hideCancel: true,
              );
            }
            List<Widget> supports = [];
            for (final int svtId in TdDamageOptions.optionalSupports) {
              final svt = db.gameData.servantsNoDup[svtId];
              if (svt != null) {
                supports.add(svt.iconBuilder(
                  context: context,
                  width: 56,
                  padding: const EdgeInsets.all(2),
                  onTap: () {
                    options.supports.add(svt.id);
                    Navigator.pop(context);
                    if (mounted) setState(() {});
                  },
                ));
              }
            }
            return SimpleCancelOkDialog(
              title: Text(S.current.support_servant),
              scrollable: true,
              content: Wrap(
                children: supports,
              ),
              confirmText: S.current.general_custom,
              onTapOk: () {
                if (!mounted) return;
                router.pushPage(ServantListPage(
                  pinged: db.settings.battleSim.pingedSvts.toList(),
                  onSelected: (svt) {
                    options.supports.add(svt.id);
                    if (mounted) setState(() {});
                  },
                ));
              },
            );
          },
        );
      },
      child: Text(S.current.add),
    ));

    children.add(DividerWithTitle(title: '${S.current.craft_essence}/${S.current.mystic_code}'));
    children.add(_buildCEPart());
    children.add(_buildMCPart());
    children.add(_buildCustomBuff());
    children.add(DividerWithTitle(title: S.current.servant));
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
        title: Text(S.current.player_data),
        subtitle: Text(S.current.non_favorite_svt_be_skipped),
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
        title: Text(S.current.level),
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
      kIndentDivider,
      ListTile(
        dense: true,
        enabled: options.usePlayerSvt.isNone,
        title: const Text('NP Lv: ${kStarChar}5'),
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
        title: const Text('NP Lv: ${kStarChar}4'),
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
        title: const Text('NP Lv: ${kStarChar}0-3'),
        subtitle: Text(Transl.svtObtain(SvtObtain.eventReward).l),
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
      kIndentDivider,
      ListTile(
        dense: true,
        title: const Text('OverCharge (OC)'),
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
      CheckboxListTile(
        dense: true,
        title: Text(S.current.fixed_oc),
        subtitle: Text('${S.current.disable}: "${Transl.buffType(BuffType.upChagetd).l}" buff'),
        value: options.fixedOC,
        onChanged: (v) {
          setState(() {
            if (v != null) options.fixedOC = v;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.enableActiveSkills,
        title: Text(S.current.active_skill),
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
        title: Text(S.current.twice_skill_if_cd2),
        subtitle: Text(S.current.twice_skill_hint),
        onChanged: (value) {
          setState(() {
            options.twiceActiveSkill = !options.twiceActiveSkill;
          });
        },
      ),
      CheckboxListTile(
        dense: true,
        value: options.enableAppendSkills,
        title: Text(S.current.append_skill),
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
        title: Text(S.current.debuff_immune),
        onChanged: (value) {
          setState(() {
            options.addDebuffImmune = !options.addDebuffImmune;
          });
        },
      ),
      DividerWithTitle(title: S.current.np_se, indent: 16),
      ..._buildSEPart(),
      // CheckboxListTile(
      //   enabled: false,
      //   dense: true,
      //   value: options.upResistSubState,
      //   title: const Text('Up Resist SubState 500%'),
      //   onChanged: (value) {
      //     setState(() {
      //       options.upResistSubState = !options.upResistSubState;
      //     });
      //   },
      // ),
      kIndentDivider,
      const SizedBox(height: 8),
      SliderWithTitle(
        leadingText: S.current.battle_random,
        min: ConstData.constants.attackRateRandomMin,
        max: ConstData.constants.attackRateRandomMax - 1,
        value: options.fixedRandom,
        label: (options.fixedRandom / 1000).toStringAsFixed(3),
        onChange: (v) {
          options.fixedRandom = v.round();
          if (mounted) setState(() {});
        },
        padding: const EdgeInsetsDirectional.only(start: 16),
        maxWidth: double.infinity,
      ),
      SliderWithTitle(
        leadingText: S.current.battle_probability_threshold,
        min: 0,
        max: 10,
        value: options.probabilityThreshold ~/ 100,
        label: '${options.probabilityThreshold / 10} %',
        onChange: (v) {
          options.probabilityThreshold = v.round() * 100;
          if (mounted) setState(() {});
        },
        padding: const EdgeInsetsDirectional.only(start: 16),
        maxWidth: double.infinity,
      ),
      kDefaultDivider,
      TextButton(
        onPressed: () {
          setState(() {
            db.settings.battleSim.tdDmgOptions = TdDamageOptions();
          });
        },
        child: Text(S.current.reset),
      ),
    ]);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildCustomBuff() {
    return SimpleAccordion(
      headerBuilder: (context, _) {
        List<InlineSpan> spans = [];
        for (final effect in options.extraBuffs.effects) {
          if (!effect.isValid) continue;
          if (effect.icon != null) {
            spans.add(CenterWidgetSpan(child: db.getIconImage(effect.icon, width: 18)));
          } else {
            spans.add(TextSpan(text: effect.popupText));
          }
          spans.add(TextSpan(text: ' ${effect.getValueText(true)}  '));
        }
        if (spans.isEmpty) spans.add(const TextSpan(text: 'Buffs'));
        return ListTile(
          dense: true,
          leading: const Icon(Icons.auto_fix_high),
          title: Text.rich(TextSpan(children: spans)),
          horizontalTitleGap: 8,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
        );
      },
      contentBuilder: (context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomSkillForm(
            skillData: options.extraBuffs,
            valueOnly: true,
            showInfo: false,
            showTarget: false,
            onChanged: () {
              if (mounted) setState(() {});
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildSEPart() {
    final List<Servant> indivSumSvts = [], hpRatioSvts = [];
    for (final svt in db.gameData.servantsNoDup.values) {
      if (svt.collectionNo != 153 &&
          svt.noblePhantasms.any((td) => td.functions.any((func) => func.funcType == FuncType.damageNpIndividualSum))) {
        indivSumSvts.add(svt);
      }
      if (svt.noblePhantasms.any((td) => td.functions.any(
          (func) => func.funcType == FuncType.damageNpHpratioLow || func.funcType == FuncType.damageNpHpratioHigh))) {
        hpRatioSvts.add(svt);
      }
    }
    indivSumSvts.sort2((e) => e.collectionNo);
    hpRatioSvts.sort2((e) => e.collectionNo);
    List<Widget> children = [
      CheckboxListTile(
        dense: true,
        value: options.forceDamageNpSe,
        title: Text(S.current.force_enable_np_se),
        onChanged: (value) {
          setState(() {
            if (value != null) options.forceDamageNpSe = value;
          });
        },
      ),
      ListTile(
        enabled: options.forceDamageNpSe,
        dense: true,
        title: Text(S.current.damage_np_indiv_sum_count),
        subtitle: Text.rich(
          TextSpan(children: [
            for (final svt in indivSumSvts) CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
          ]),
          maxLines: 1,
        ),
        trailing: DropdownButton<int?>(
          value: options.damageNpIndivSumCount,
          items: [
            for (final count in <int?>[null, ...List.generate(12, (index) => index + 1)])
              DropdownMenuItem(
                value: count,
                child: Text(
                  count?.toString() ?? "MAX",
                  textScaleFactor: 0.8,
                ),
              )
          ],
          onChanged: options.forceDamageNpSe
              ? (v) {
                  setState(() {
                    options.damageNpIndivSumCount = v;
                  });
                }
              : null,
        ),
      ),
      CheckboxListTile(
        dense: true,
        value: options.damageNpHpRatioMax,
        title: Text(S.current.damage_np_hp_ratio_max_rate),
        subtitle: Text.rich(
          TextSpan(children: [
            for (final svt in hpRatioSvts) CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
          ]),
          maxLines: 1,
        ),
        onChanged: (value) {
          setState(() {
            if (value != null) options.damageNpHpRatioMax = value;
          });
        },
      ),
    ];
    return children;
  }
}
