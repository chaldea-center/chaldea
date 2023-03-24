import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/command_code/cmd_code_list.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../enemy/support_servant.dart';
import '../servant/servant_list.dart';
import 'simulation_preview.dart';

class ServantOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final List<SupportServant> supportServants;
  final VoidCallback onChange;

  ServantOptionEditPage({
    super.key,
    required this.playerSvtData,
    required this.supportServants,
    required this.onChange,
  });

  @override
  State<ServantOptionEditPage> createState() => _ServantOptionEditPageState();

  static Widget buildSlider({
    required final String leadingText,
    required final int min,
    required final int max,
    required final int value,
    required final String label,
    required final ValueChanged<double> onChange,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 8),
          child: Text('$leadingText: $label'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 24,
            maxWidth: 300,
          ),
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            value: value.toDouble(),
            label: label,
            onChanged: (v) {
              onChange(v);
            },
          ),
        )
      ],
    );
  }

  static Widget buildSlider2({
    required BuildContext context,
    required String label,
    required String? valueText,
    required int min,
    required int max,
    required int value,
    required ValueChanged<double> onChange,
    double leadingWidth = 48,
  }) {
    Widget slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
      child: Slider(
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max - min,
        value: value.toDouble(),
        label: label,
        onChanged: (v) {
          onChange(v);
        },
      ),
    );
    return Row(
      children: [
        SizedBox(
          width: leadingWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AutoSizeText(
                label,
                maxLines: 1,
                minFontSize: 10,
                maxFontSize: 16,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (valueText != null)
                AutoSizeText(
                  valueText,
                  maxLines: 1,
                  minFontSize: 10,
                  maxFontSize: 14,
                ),
            ],
          ),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 24),
            child: Stack(
              children: [
                Positioned(
                  left: -16,
                  right: -16,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 24),
                    child: slider,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _ServantOptionEditPageState extends State<ServantOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;

  Servant get svt => playerSvtData.svt!;

  @override
  void initState() {
    super.initState();
    if (playerSvtData.svt == null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        selectSvt();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (playerSvtData.svt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.current.battle_edit_servant_option)),
        body: Column(
          children: [
            const Spacer(),
            SafeArea(child: buttonBar),
          ],
        ),
      );
    }
    const divider = Divider(height: 8, thickness: 1);
    final List<Widget> children = [
      _header(context),
      divider,
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        child: _buildSliderGroup(),
      ),
      divider,
      SHeader(S.current.details),
      const Divider(thickness: 1, height: 1),
      _buildTdDescriptor(context),
      kDefaultDivider,
      for (final skillNum in kActiveSkillNums) _buildActiveSkill(context, skillNum),
      kDefaultDivider,
      for (final skillNum in kAppendSkillNums) _buildAppendSkill(context, skillNum),
      divider,
      _buildCmdCodePlanner()
    ];

    return Scaffold(
      appBar: AppBar(title: Text(S.current.battle_edit_servant_option)),
      body: Column(
        children: [
          Expanded(
            child: ListView(children: children),
          ),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget _buildSliderGroup() {
    final commonSliders = <Widget>[
      ServantOptionEditPage.buildSlider2(
        context: context,
        label: S.current.noble_phantasm_level,
        min: 1,
        max: 5,
        value: playerSvtData.tdLv,
        valueText: 'Lv.${playerSvtData.tdLv}',
        onChange: (v) {
          playerSvtData.tdLv = v.round();
          _updateState();
        },
      ),
      ServantOptionEditPage.buildSlider2(
        context: context,
        label: 'Lv',
        min: 1,
        max: svt.atkGrowth.length,
        value: playerSvtData.lv,
        valueText: playerSvtData.lv.toString(),
        onChange: (v) {
          playerSvtData.lv = v.round();
          _updateState();
        },
      ),
      ServantOptionEditPage.buildSlider2(
        context: context,
        label: 'ATK ${S.current.foukun}',
        min: 0,
        max: 200,
        value: playerSvtData.atkFou ~/ 10,
        valueText: '+${playerSvtData.atkFou}',
        onChange: (v) {
          final int fou = v.round() * 10;
          if (fou > 1000 && fou % 20 == 10) {
            playerSvtData.atkFou = fou - 10;
          } else {
            playerSvtData.atkFou = fou;
          }
          _updateState();
        },
      ),
      ServantOptionEditPage.buildSlider2(
        context: context,
        label: 'HP ${S.current.foukun}',
        min: 0,
        max: 200,
        value: playerSvtData.hpFou ~/ 10,
        valueText: '+${playerSvtData.hpFou}',
        onChange: (v) {
          final int fou = v.round() * 10;
          if (fou > 1000 && fou % 20 == 10) {
            playerSvtData.hpFou = fou - 10;
          } else {
            playerSvtData.hpFou = fou;
          }
          _updateState();
        },
      ),
    ];
    final activeSkills = [
      for (int skillNum in kActiveSkillNums)
        ServantOptionEditPage.buildSlider2(
          context: context,
          label: '${S.current.active_skill_short} $skillNum',
          min: 1,
          max: 10,
          value: playerSvtData.skillLvs[skillNum - 1],
          valueText: 'Lv.${playerSvtData.skillLvs[skillNum - 1]}',
          onChange: (v) {
            playerSvtData.skillLvs[skillNum - 1] = v.round();
            _updateState();
          },
        ),
    ];
    final appendSkills = [
      for (int skillNum in kAppendSkillNums)
        ServantOptionEditPage.buildSlider2(
          context: context,
          label: '${S.current.append_skill_short} $skillNum',
          min: 0,
          max: 10,
          value: playerSvtData.appendLvs[skillNum - 1],
          valueText: 'Lv.${playerSvtData.appendLvs[skillNum - 1]}',
          onChange: (v) {
            playerSvtData.appendLvs[skillNum - 1] = v.round();
            _updateState();
          },
        )
    ];

    return ResponsiveLayout.builder(
      sm: 480,
      builder: (context, type) {
        List<Widget> children = [...commonSliders];
        switch (type) {
          case ResponsiveSizeType.small:
            children
              ..addAll(activeSkills)
              ..addAll(appendSkills);
            break;
          case ResponsiveSizeType.middle:
          case ResponsiveSizeType.large:
            for (int index in [0, 1, 2]) {
              children
                ..add(activeSkills[index])
                ..add(appendSkills[index]);
            }
            break;
        }
        return children.map((e) => Responsive(small: 12, middle: 6, child: e)).toList();
      },
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      children: [
        TextButton(
          onPressed: playerSvtData.svt == null
              ? null
              : () {
                  playerSvtData.svt = null;
                  _updateState();
                },
          child: Text(
            S.current.clear,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: selectSvt,
          child: const Text('Select Servant'),
        ),
        if (widget.supportServants.isNotEmpty)
          TextButton(
            onPressed: selectSupport,
            child: const Text('Select Support'),
          ),
      ],
    );
  }

  Widget _header(final BuildContext context) {
    final faces = svt.extraAssets.faces;
    final ascensionText = svt.getCostume(playerSvtData.limitCount)?.lName.l ??
        '${S.current.ascension} ${playerSvtData.limitCount == 0 ? 1 : playerSvtData.limitCount}';
    final atk = svt.atkGrowth[playerSvtData.lv - 1] + playerSvtData.atkFou,
        hp = svt.hpGrowth[playerSvtData.lv - 1] + playerSvtData.hpFou;
    return CustomTile(
      leading: svt.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: svt.ascendIcon(playerSvtData.limitCount, true),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(svt.lBattleName(playerSvtData.limitCount).l),
          Text(
            'No.${svt.collectionNo > 0 ? svt.collectionNo : svt.id}'
            '  ${Transl.svtClassId(svt.classId).l}',
          ),
          Text('ATK $atk  HP $hp'),
          const SizedBox(height: 4),
        ],
      ),
      trailing: TextButton(
        child: Text(ascensionText, textScaleFactor: 0.9),
        onPressed: () async {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              final List<Widget> children = [];
              void _addOne(final int ascension, final String name, final String? icon) {
                if (icon == null) return;
                final borderedIcon = svt.bordered(icon);
                children.add(ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: db.getIconImage(
                    borderedIcon,
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  title: Text(name, textScaleFactor: 0.9),
                  onTap: () {
                    final ascensionPhase = ascension == 1 ? 0 : ascension;

                    for (final skillNum in kActiveSkillNums) {
                      final List<NiceSkill> previousShownSkills =
                          ServantSelector.getShownSkills(svt, playerSvtData.limitCount, skillNum);
                      final List<NiceSkill> shownSkills = ServantSelector.getShownSkills(svt, ascensionPhase, skillNum);
                      if (!listEquals(previousShownSkills, shownSkills)) {
                        playerSvtData.skills[skillNum - 1] = shownSkills.lastOrNull;
                        logger.d('Changing skill ID: ${playerSvtData.skills[skillNum - 1]?.id}');
                      }
                    }

                    final List<NiceTd> previousShownTds = ServantSelector.getShownTds(svt, playerSvtData.limitCount);
                    final List<NiceTd> shownTds = ServantSelector.getShownTds(svt, ascensionPhase);
                    playerSvtData.limitCount = ascensionPhase;
                    if (!listEquals(previousShownTds, shownTds)) {
                      playerSvtData.td = shownTds.last;
                      logger.d('Capping npId: ${playerSvtData.td?.id}');
                    }
                    Navigator.pop(context);
                    _updateState();
                  },
                ));
              }

              if (faces.ascension != null) {
                faces.ascension!.forEach((key, value) {
                  _addOne(key, '${S.current.ascension} $key', value);
                });
              }
              if (faces.costume != null) {
                faces.costume!.forEach((key, value) {
                  _addOne(
                    key,
                    svt.profile.costume[key]?.lName.l ?? '${S.current.costume} $key',
                    value,
                  );
                });
              }

              return SimpleCancelOkDialog(
                title: Text(S.current.battle_change_ascension),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
                hideOk: true,
              );
            },
          );
          _updateState();
        },
      ),
    );
  }

  Widget _buildTdDescriptor(final BuildContext context) {
    final int ascension = playerSvtData.limitCount;
    final List<NiceTd> shownTds = ServantSelector.getShownTds(svt, ascension);
    if (playerSvtData.td != null && !shownTds.contains(playerSvtData.td)) {
      // custom td
      shownTds.add(playerSvtData.td!);
    }

    return SimpleAccordion(
      headerBuilder: (context, _) {
        final td = playerSvtData.td;
        String title = S.current.noble_phantasm;
        if (td != null) {
          title += ' Lv.${playerSvtData.tdLv}';
        }
        String subtitle = td == null ? Transl.tdTypes('なし').l : '${td.id} ${td.lName.l}';
        return ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: td == null ? db.getIconImage(null, width: 24) : CommandCardWidget(card: td.card, width: 28),
          title: Text(title),
          subtitle: Text(subtitle),
        );
      },
      contentBuilder: (context) {
        return Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: FilterGroup<NiceTd?>(
                    options: [null, ...shownTds],
                    values: FilterRadioData(playerSvtData.td),
                    combined: true,
                    optionBuilder: (td) {
                      if (td == null) {
                        return const Text('Disable');
                      }
                      return Text('${td.id} ${td.nameWithRank}');
                    },
                    onFilterChanged: (v, _) {
                      playerSvtData.td = v.radioValue;
                      _updateState();
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    InputCancelOkDialog(
                      title: '${S.current.noble_phantasm} ID',
                      validate: (s) {
                        final v = int.tryParse(s);
                        return v != null && v > 0;
                      },
                      onSubmit: (s) async {
                        final v = int.tryParse(s);
                        NiceTd? td;
                        if (v != null && v > 0) {
                          EasyLoading.show();
                          td = await AtlasApi.td(v);
                          EasyLoading.dismiss();
                        }
                        if (td == null) {
                          EasyLoading.showError(S.current.not_found);
                          return;
                        }
                        playerSvtData.td = td;
                        _updateState();
                      },
                    ).showDialog(context);
                  },
                  child: Text(S.current.general_custom),
                )
              ],
            ),
            if (playerSvtData.td != null)
              TdDescriptor(
                td: playerSvtData.td!,
                showEnemy: !svt.isUserSvt,
                level: playerSvtData.tdLv,
              )
          ],
        );
      },
    );
  }

  Widget _buildActiveSkill(final BuildContext context, final int skillNum) {
    final index = skillNum - 1;
    final int ascension = playerSvtData.limitCount;
    final List<NiceSkill> shownSkills = ServantSelector.getShownSkills(svt, ascension, skillNum);

    if (playerSvtData.skills[index] != null && !shownSkills.contains(playerSvtData.skills[index])) {
      // custom skill
      shownSkills.add(playerSvtData.skills[index]!);
    }

    return SimpleAccordion(
      headerBuilder: (context, _) {
        final skill = playerSvtData.skills[index];
        String title = '${S.current.active_skill_short} $skillNum';
        if (skill != null) {
          title += ' Lv.${playerSvtData.skillLvs[index]}';
        }
        String subtitle = skill == null ? Transl.tdTypes('なし').l : '${skill.id} ${skill.lName.l}';
        return ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: db.getIconImage(skill?.icon, width: 24),
          title: Text(title),
          subtitle: Text(subtitle),
        );
      },
      contentBuilder: (context) {
        return Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: FilterGroup<NiceSkill?>(
                    options: [null, ...shownSkills],
                    values: FilterRadioData(playerSvtData.skills[index]),
                    combined: true,
                    optionBuilder: (skill) {
                      if (skill == null) {
                        return const Text('Disable');
                      }
                      return Text('${skill.id} ${skill.lName.l}');
                    },
                    onFilterChanged: (v, _) {
                      playerSvtData.skills[index] = v.radioValue;
                      _updateState();
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    InputCancelOkDialog(
                      title: '${S.current.skill} ID',
                      validate: (s) {
                        final v = int.tryParse(s);
                        return v != null && v > 0;
                      },
                      onSubmit: (s) async {
                        final v = int.tryParse(s);
                        NiceSkill? skill;
                        if (v != null && v > 0) {
                          EasyLoading.show();
                          skill = await AtlasApi.skill(v);
                          if (skill?.type != SkillType.active) {
                            skill = null;
                          }
                          EasyLoading.dismiss();
                        }
                        if (skill == null) {
                          EasyLoading.showError('${S.current.not_found} or not active skill');
                          return;
                        }
                        playerSvtData.skills[index] = skill;
                        _updateState();
                      },
                    ).showDialog(context);
                  },
                  child: Text(S.current.general_custom),
                )
              ],
            ),
            if (playerSvtData.skills[index] != null)
              SkillDescriptor(
                skill: playerSvtData.skills[index]!,
                showEnemy: !svt.isUserSvt,
                level: playerSvtData.skillLvs[index],
              )
          ],
        );
      },
    );
  }

  Widget _buildAppendSkill(final BuildContext context, final int skillNum) {
    final index = skillNum - 1;
    final skill = playerSvtData.svt?.appendPassive.firstWhereOrNull((e) => e.num == skillNum + 99)?.skill;
    return SimpleAccordion(
      headerBuilder: (context, _) {
        String title = '${S.current.append_skill_short} $skillNum';
        if (skill != null) {
          title += ' Lv.${playerSvtData.appendLvs[index]}';
        }
        String subtitle = skill == null ? Transl.tdTypes('なし').l : '${skill.id} ${skill.lName.l}';
        return ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: db.getIconImage(skill?.icon, width: 24),
          title: Text(title),
          subtitle: Text(subtitle),
        );
      },
      contentBuilder: (context) {
        if (skill == null) return Center(child: Text('\n${S.current.not_found}\n'));
        return SkillDescriptor(
          skill: skill,
          showEnemy: !svt.isUserSvt,
          level: playerSvtData.appendLvs[index],
        );
      },
    );
  }

  Widget _buildCmdCodePlanner() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHeader(S.current.command_code),
        Material(
          color: Theme.of(context).cardColor,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(svt.cards.length, (index) {
              final code = playerSvtData.commandCodes[index];
              return TableRow(children: [
                Center(child: CommandCardWidget(card: svt.cards[index], width: 60)),
                InkWell(
                  onTap: () async {
                    router.pushBuilder(
                      builder: (context) => CmdCodeListPage(
                        onSelected: (selectedCode) {
                          playerSvtData.commandCodes[index] = db.gameData.commandCodes[selectedCode.collectionNo];
                          _updateState();
                        },
                        filterData: db.settings.cmdCodeFilterData,
                      ),
                      detail: false,
                    );
                  },
                  onLongPress: code?.routeTo,
                  child: db.getIconImage(code?.icon ?? Atlas.asset('SkillIcons/skill_999999.png'),
                      height: 60, aspectRatio: 132 / 144, padding: const EdgeInsets.all(4)),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      playerSvtData.commandCodes[index] = null;
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  tooltip: S.current.remove,
                ),
                ServantOptionEditPage.buildSlider(
                  leadingText: S.current.card_strengthen,
                  min: 0,
                  max: 25,
                  value: playerSvtData.cardStrengthens[index] ~/ 20,
                  label: playerSvtData.cardStrengthens[index].toString(),
                  onChange: (v) {
                    playerSvtData.cardStrengthens[index] = v.round() * 20;
                    _updateState();
                  },
                ),
              ]);
            }),
            columnWidths: const {
              0: FixedColumnWidth(56),
              1: FixedColumnWidth(56),
              2: FixedColumnWidth(32)
              // 3:
            },
            border: TableBorder.all(color: const Color.fromRGBO(162, 169, 177, 1), width: 0.25),
          ),
        ),
      ],
    );
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
      widget.onChange();
    }
  }

  void selectSvt() {
    router.pushPage(
      ServantListPage(
        planMode: false,
        onSelected: (selectedSvt) {
          _onSelectServant(selectedSvt);
          _updateState();
        },
        filterData: db.settings.svtFilterData,
      ),
      detail: true,
    );
  }

  void selectSupport() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.support_servant),
          children: [
            for (final svt in widget.supportServants)
              SimpleDialogOption(
                child: SupportServantTile(
                  svt: svt,
                  onTap: null,
                  hasLv100: widget.supportServants.any((e) => e.lv >= 100),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _onSelectSupport(svt);
                  _updateState();
                },
              )
          ],
        );
      },
    );
  }

  void _onSelectServant(final Servant selectedSvt) {
    if (!selectedSvt.isUserSvt) return;

    playerSvtData.svt = selectedSvt;
    final status = db.curUser.svtStatusOf(selectedSvt.collectionNo);
    final curStatus = status.cur;
    if (curStatus.favorite) {
      playerSvtData
        ..limitCount = curStatus.ascension
        ..lv = selectedSvt.grailedLv(curStatus.grail)
        ..tdLv = curStatus.npLv
        ..skillLvs = curStatus.skills.toList()
        ..appendLvs = curStatus.appendSkills.toList()
        ..atkFou = curStatus.fouAtk > 0 ? 1000 + curStatus.fouAtk * 20 : curStatus.fouAtk3 * 50
        ..hpFou = curStatus.fouHp > 0 ? 1000 + curStatus.fouHp * 20 : curStatus.fouHp3 * 50
        ..cardStrengthens = List.generate(selectedSvt.cards.length, (index) {
          if (status.cmdCardStrengthen == null || status.cmdCardStrengthen!.length <= index) {
            return 0;
          }
          return status.cmdCardStrengthen![index] * 20;
        })
        ..commandCodes = List.generate(selectedSvt.cards.length, (index) {
          return db.gameData.commandCodes[status.getCmdCode(index)];
        });
    } else {
      playerSvtData
        ..limitCount = 4
        ..lv = selectedSvt.lvMax
        ..tdLv = 5
        ..skillLvs = [10, 10, 10]
        ..appendLvs = [0, 0, 0]
        ..atkFou = 1000
        ..hpFou = 1000
        ..cardStrengthens = [0, 0, 0, 0, 0]
        ..commandCodes = [null, null, null, null, null];
    }

    playerSvtData.td = ServantSelector.getShownTds(selectedSvt, playerSvtData.limitCount).last;
    for (final skillNum in kActiveSkillNums) {
      playerSvtData.skills[skillNum - 1] =
          ServantSelector.getShownSkills(selectedSvt, playerSvtData.limitCount, skillNum).lastOrNull;
    }
  }

  Future<void> _onSelectSupport(final SupportServant support) async {
    final svt = await AtlasApi.svt(support.svt.id);
    if (svt == null) return;
    // if collected battle data didn't choose support svt,
    // no trait info and passive skills
    if (support.traits.isNotEmpty) {
      svt.traits = support.traits.toList();
    }
    svt
      ..classId = support.svt.classId
      ..className = support.svt.className
      ..rarity = support.svt.rarity
      ..attribute = support.svt.attribute;
    playerSvtData
      ..limitCount = support.limit.limitCount
      ..hpFou = 0
      ..atkFou = 0;
    // skill & td
    svt.skills = support.skills.skills.whereType<NiceSkill>().toList();
    playerSvtData.skills = support.skills.skills;
    playerSvtData.skillLvs = support.skills.skillLvs.map((e) => e ?? 0).toList();
    svt.noblePhantasms = [if (support.noblePhantasm.noblePhantasm != null) support.noblePhantasm.noblePhantasm!];
    playerSvtData.td = support.noblePhantasm.noblePhantasm;
    playerSvtData.tdLv = support.noblePhantasm.noblePhantasmLv;
    // ce
    final ce = support.equips.getOrNull(0);
    playerSvtData
      ..ce = ce?.equip
      ..ceLimitBreak = ce?.limitCount == 4
      ..ceLv = ce?.lv ?? 1;

    svt.preprocess();
    playerSvtData.svt = svt;
  }
}

class CraftEssenceOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final VoidCallback onChange;

  CraftEssenceOptionEditPage({super.key, required this.playerSvtData, required this.onChange});

  @override
  State<CraftEssenceOptionEditPage> createState() => _CraftEssenceOptionEditPageState();
}

class _CraftEssenceOptionEditPageState extends State<CraftEssenceOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;

  CraftEssence get ce => playerSvtData.ce!;

  VoidCallback get onChange => widget.onChange;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> topListChildren = [];
    topListChildren.add(_header(context));
    topListChildren.add(ServantOptionEditPage.buildSlider(
      leadingText: 'Lv',
      min: 1,
      max: ce.lvMax,
      value: playerSvtData.ceLv,
      label: playerSvtData.ceLv.toString(),
      onChange: (v) {
        playerSvtData.ceLv = v.round();
        _updateState();
      },
    ));
    topListChildren.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ToggleButtons(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onPressed: (final int index) {
          playerSvtData.ceLimitBreak = index == 1;
          _updateState();
        },
        isSelected: [!playerSvtData.ceLimitBreak, playerSvtData.ceLimitBreak],
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(S.current.battle_not_limit_break),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(S.current.battle_limit_break),
          )
        ],
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(S.current.battle_edit_ce_option, maxLines: 1),
        centerTitle: false,
      ),
      body: ListView(
        children: divideTiles(
          topListChildren,
          divider: const Divider(height: 10, thickness: 4),
        ),
      ),
    );
  }

  Widget _header(final BuildContext context) {
    return CustomTile(
      leading: playerSvtData.ce!.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: ce.borderedIcon,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ce.lName.l),
          Text(
            'No.${ce.collectionNo > 0 ? ce.collectionNo : ce.id}'
            '  ${Transl.ceObtain(ce.obtain).l}',
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
      onChange();
    }
  }
}
