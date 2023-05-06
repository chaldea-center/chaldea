import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/command_code/cmd_code_list.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/enemy/enemy_list.dart';
import 'package:chaldea/app/modules/enemy/support_servant.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/models/userdata/userdata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'select_skill_page.dart';

class ServantOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final Region playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback onChange;

  ServantOptionEditPage({
    super.key,
    required this.playerSvtData,
    required this.playerRegion,
    required this.questPhase,
    required this.onChange,
  });

  @override
  State<ServantOptionEditPage> createState() => _ServantOptionEditPageState();

  static Widget buildSlider2({
    required final String leadingText,
    required final int min,
    required final int max,
    required final int value,
    required final String label,
    required final ValueChanged<double> onChange,
    EdgeInsetsGeometry padding = const EdgeInsets.only(left: 0, top: 8),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text('$leadingText: $label'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 24,
            maxWidth: 360,
          ),
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max > min ? max - min : null,
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
}

class _ServantOptionEditPageState extends State<ServantOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;
  Servant get svt => playerSvtData.svt!;
  QuestPhase? get questPhase => widget.questPhase;

  @override
  void initState() {
    super.initState();
    if (playerSvtData.svt == null && questPhase?.supportServants.isNotEmpty != true) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) Navigator.pop(context);
        selectSvt();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.battle_edit_servant_option),
        actions: [
          IconButton(
            onPressed: selectSvt,
            icon: const Icon(Icons.change_circle_outlined),
            tooltip: S.current.select_servant,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: body),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget _buildSliderGroup() {
    playerSvtData.lv = playerSvtData.lv.clamp(1, min(120, svt.atkGrowth.length));
    final commonSliders = <Widget>[
      SliderWithPrefix(
        label: S.current.noble_phantasm_level,
        min: 1,
        max: 5,
        value: playerSvtData.tdLv,
        valueText: 'Lv.${playerSvtData.tdLv}',
        onChange: (v) {
          playerSvtData.tdLv = v.round();
          _updateState();
        },
        endOffset: -16,
      ),
      SliderWithPrefix(
        label: 'Lv',
        min: 1,
        max: min(120, svt.atkGrowth.length),
        value: playerSvtData.lv,
        valueText: playerSvtData.lv.toString(),
        onChange: (v) {
          playerSvtData.lv = v.round();
          _updateState();
        },
        endOffset: -16,
      ),
      SliderWithPrefix(
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
        endOffset: -16,
      ),
      SliderWithPrefix(
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
        endOffset: -16,
      ),
    ];
    final activeSkills = [
      for (int skillNum in kActiveSkillNums)
        SliderWithPrefix(
          label: '${S.current.active_skill_short} $skillNum',
          min: 1,
          max: 10,
          value: playerSvtData.skillLvs[skillNum - 1],
          valueText: 'Lv.${playerSvtData.skillLvs[skillNum - 1]}',
          onChange: (v) {
            playerSvtData.skillLvs[skillNum - 1] = v.round();
            _updateState();
          },
          endOffset: -16,
        ),
    ];
    final appendSkills = [
      for (int skillNum in kAppendSkillNums)
        SliderWithPrefix(
          label: '${S.current.append_skill_short} $skillNum',
          min: 0,
          max: 10,
          value: playerSvtData.appendLvs[skillNum - 1],
          valueText: 'Lv.${playerSvtData.appendLvs[skillNum - 1]}',
          onChange: (v) {
            playerSvtData.appendLvs[skillNum - 1] = v.round();
            _updateState();
          },
          endOffset: -16,
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

  Widget get body {
    if (playerSvtData.svt == null) {
      return const Center(child: Text('None'));
    }
    const divider = Divider(height: 8, thickness: 1);
    final extraPassives = playerSvtData.extraPassives
        .where((passive) => passive.isExtraPassiveEnabledForEvent(questPhase?.war?.eventId ?? 0))
        .toList();
    final List<Widget> children = [
      _header(context),
      divider,
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        child: _buildSliderGroup(),
      ),
      divider,
      TileGroup(
        header: S.current.noble_phantasm,
        children: [
          _buildTdDescriptor(context),
        ],
      ),
      TileGroup(
        header: S.current.active_skill,
        children: [
          for (final skillNum in kActiveSkillNums) _buildActiveSkill(context, skillNum),
        ],
      ),
      TileGroup(
        header: S.current.append_skill,
        children: [
          for (final skillNum in kAppendSkillNums) _buildAppendSkill(context, skillNum),
        ],
      ),
      TileGroup(
        header: S.current.extra_passive,
        children: [
          if (extraPassives.isEmpty) const ListTile(dense: true, title: Text('NONE')),
          for (final passive in extraPassives) _buildExtraPassive(passive),
        ],
      ),
      TileGroup(
        header: '${S.current.extra_passive} (${S.current.general_custom})',
        children: [
          for (int index = 0; index < playerSvtData.additionalPassives.length; index++) _buildAdditionalPassive(index),
          Center(
            child: TextButton(
              onPressed: () async {
                await router.pushPage(SkillSelectPage(
                  skillType: SkillType.passive,
                  onSelected: (skill) {
                    playerSvtData.addCustomPassive(skill, skill.maxLv);
                  },
                ));
                if (mounted) setState(() {});
              },
              child: Text(S.current.select_skill),
            ),
          )
        ],
      ),
      _buildCmdCodePlanner()
    ];
    return ListView(children: children);
  }

  Widget get buttonBar {
    return ButtonBar(
      children: [
        Wrap(
          // spacing: 4,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
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
              child: Text(S.current.select_servant),
            ),
            TextButton(
              onPressed: selectSvtEntity,
              child: Text(S.current.enemy),
            ),
            if (questPhase?.supportServants.isNotEmpty == true)
              TextButton(
                onPressed: selectSupport,
                child: Text(S.current.support_servant_short),
              ),
          ],
        )
      ],
    );
  }

  Widget _header(final BuildContext context) {
    final faces = svt.extraAssets.faces;
    final ascensionText = svt.getCostume(playerSvtData.limitCount)?.lName.l ??
        '${S.current.ascension} ${playerSvtData.limitCount == 0 ? 1 : playerSvtData.limitCount}';
    final atk = (svt.atkGrowth.getOrNull(playerSvtData.lv - 1) ?? 0) + playerSvtData.atkFou,
        hp = (svt.hpGrowth.getOrNull(playerSvtData.lv - 1) ?? 0) + playerSvtData.hpFou;
    return CustomTile(
      leading: svt.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: svt.ascendIcon(playerSvtData.limitCount, true),
        option: ImageWithTextOption(
          errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
        ),
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
                          BattleUtils.getShownSkills(svt, playerSvtData.limitCount, skillNum);
                      final List<NiceSkill> shownSkills = BattleUtils.getShownSkills(svt, ascensionPhase, skillNum);
                      if (!listEquals(previousShownSkills, shownSkills)) {
                        playerSvtData.skills[skillNum - 1] = shownSkills.lastOrNull;
                        logger.d('Changing skill ID: ${playerSvtData.skills[skillNum - 1]?.id}');
                      }
                    }

                    final List<NiceTd> previousShownTds = BattleUtils.getShownTds(svt, playerSvtData.limitCount);
                    final List<NiceTd> shownTds = BattleUtils.getShownTds(svt, ascensionPhase);
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
    final List<NiceTd> shownTds = BattleUtils.getShownTds(svt, ascension);
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
                    options: [...shownTds, null],
                    values: FilterRadioData(playerSvtData.td),
                    combined: true,
                    optionBuilder: (td) {
                      if (td == null) {
                        return Text(S.current.disable);
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
    final List<NiceSkill> shownSkills = BattleUtils.getShownSkills(svt, ascension, skillNum);

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
          leading: db.getIconImage(skill?.icon ?? Atlas.common.emptySkillIcon, width: 28),
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
                    options: [...shownSkills, null],
                    values: FilterRadioData(playerSvtData.skills[index]),
                    combined: true,
                    optionBuilder: (skill) {
                      if (skill == null) {
                        return Text(S.current.disable);
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
                    router.pushPage(SkillSelectPage(
                      skillType: SkillType.active,
                      onSelected: (skill) {
                        playerSvtData.skills[index] = skill.toNice()..num = skillNum;
                        _updateState();
                      },
                    ));
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
          leading: db.getIconImage(skill?.icon ?? Atlas.common.emptySkillIcon, width: 28),
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

  Widget _buildExtraPassive(NiceSkill skill) {
    final disabled = playerSvtData.disabledExtraSkills.contains(skill.id);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        String title = skill.lName.l;
        String subtitle = skill.lDetail ?? '???';
        return ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: db.getIconImage(skill.icon ?? Atlas.common.emptySkillIcon, width: 28),
          title: Text(title, style: disabled ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
          subtitle: Text(
            subtitle,
            textScaleFactor: 0.85,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: disabled ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
          ),
        );
      },
      contentBuilder: (context) {
        return Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      playerSvtData.disabledExtraSkills.toggle(skill.id);
                    });
                  },
                  child: disabled
                      ? Text(S.current.enable)
                      : Text(S.current.disable, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SkillDescriptor(
                  skill: skill,
                  showEnemy: !svt.isUserSvt,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildAdditionalPassive(int index) {
    final skill = playerSvtData.additionalPassives[index];
    final lv = playerSvtData.additionalPassiveLvs[index];
    final maxLv = skill.maxLv;
    return SimpleAccordion(
      headerBuilder: (context, _) {
        String title = skill.lName.l;
        if (maxLv > 1) {
          title += ' Lv.$lv';
        }
        String subtitle = skill.lDetail ?? '???';
        return ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: db.getIconImage(skill.icon ?? Atlas.common.emptySkillIcon, width: 28),
          title: Text(title),
          subtitle: Text(subtitle, textScaleFactor: 0.85, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
      contentBuilder: (context) {
        return Column(
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      playerSvtData.additionalPassives.removeAt(index);
                      playerSvtData.additionalPassiveLvs.removeAt(index);
                    });
                  },
                  child: Text(
                    S.current.remove,
                    // style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                if (maxLv > 1)
                  DropdownButton<int>(
                    isDense: true,
                    value: playerSvtData.additionalPassiveLvs[index],
                    items: [
                      for (int lv2 = 1; lv2 <= maxLv; lv2++) DropdownMenuItem(value: lv2, child: Text('Lv.$lv2')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        if (v != null) {
                          playerSvtData.additionalPassiveLvs[index] = v;
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SkillDescriptor(
                  skill: skill,
                  showEnemy: !svt.isUserSvt,
                  level: lv,
                ),
              ),
            )
          ],
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
              final card = svt.cards[index];
              if (!svt.cardDetails.containsKey(card)) {
                return TableRow(children: [
                  Center(child: CommandCardWidget(card: svt.cards[index], width: 60)),
                  const SizedBox(),
                  const SizedBox(),
                  const SizedBox(),
                ]);
              }
              final code = playerSvtData.commandCodes[index];
              return TableRow(children: [
                Center(child: CommandCardWidget(card: svt.cards[index], width: 60)),
                InkWell(
                  onTap: () {
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
                SliderWithTitle(
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
    widget.onChange();
    if (mounted) {
      setState(() {});
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
        pinged: db.settings.battleSim.pingedSvts.toList(),
      ),
      detail: true,
    );
  }

  final filterData = EnemyFilterData();
  void selectSvtEntity() {
    router.pushPage(
      EnemyListPage(
        onSelected: (entity) async {
          switch (entity.type) {
            case SvtType.servantEquip:
            case SvtType.combineMaterial:
            case SvtType.statusUp:
            case SvtType.svtEquipMaterial:
            case SvtType.all:
            case SvtType.commandCode:
            case SvtType.svtMaterialTd:
              EasyLoading.showError(S.current.invalid_input);
              return;
            case SvtType.normal:
            case SvtType.heroine:
            case SvtType.enemy:
            case SvtType.enemyCollection:
            case SvtType.enemyCollectionDetail:
              break;
          }
          EasyLoading.show();
          final svt = db.gameData.servantsById[entity.id] ?? await AtlasApi.svt(entity.id);
          EasyLoading.dismiss();
          if (svt == null) {
            EasyLoading.showError('${S.current.not_found}: ${entity.id}-${entity.lName.l}');
            return;
          }
          _onSelectServant(svt);
          _updateState();
        },
        filterData: filterData,
      ),
      detail: true,
    );
  }

  void selectSupport() {
    final supports = questPhase?.supportServants ?? [];
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.support_servant),
          children: [
            for (final svt in supports)
              SimpleDialogOption(
                child: SupportServantTile(
                  svt: svt,
                  onTap: null,
                  hasLv100: supports.any((e) => e.lv >= 100),
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
    playerSvtData.svt = selectedSvt;
    final status = db.curUser.svtStatusOf(selectedSvt.collectionNo);
    final curStatus = status.cur;
    if (db.settings.battleSim.preferPlayerData && curStatus.favorite) {
      playerSvtData
        ..limitCount = curStatus.ascension
        ..lv = selectedSvt.grailedLv(curStatus.grail)
        ..tdLv = curStatus.npLv.clamp(1, 5)
        ..skillLvs = curStatus.skills.toList()
        ..appendLvs = curStatus.appendSkills.toList()
        ..atkFou = curStatus.fouAtk > 0 ? 1000 + curStatus.fouAtk * 20 : curStatus.fouAtk3 * 50
        ..hpFou = curStatus.fouHp > 0 ? 1000 + curStatus.fouHp * 20 : curStatus.fouHp3 * 50
        ..cardStrengthens = List.generate(selectedSvt.cards.length, (index) {
          return (status.cmdCardStrengthen?.getOrNull(index) ?? 0) * 20;
        })
        ..commandCodes = List.generate(selectedSvt.cards.length, (index) {
          return db.gameData.commandCodes[status.getCmdCode(index)];
        });
    } else {
      final defaults = db.settings.battleSim.defaultLvs;
      int lv, tdLv;
      if (defaults.useMaxLv) {
        lv = selectedSvt.lvMax;
      } else {
        lv = defaults.lv.clamp(1, min(120, selectedSvt.atkGrowth.length));
      }
      if (defaults.useDefaultTdLv) {
        if (selectedSvt.rarity <= 3 ||
            selectedSvt.extra.obtains.any((e) => const [SvtObtain.eventReward, SvtObtain.friendPoint].contains(e))) {
          tdLv = 5;
        } else if (selectedSvt.rarity == 4) {
          tdLv = 2;
        } else {
          tdLv = 1;
        }
      } else {
        tdLv = defaults.tdLv;
      }
      playerSvtData
        ..limitCount = defaults.limitCount
        ..lv = lv
        ..tdLv = tdLv
        ..skillLvs = List.generate(3, (index) => defaults.activeSkillLv)
        ..appendLvs = defaults.appendLvs.toList()
        ..atkFou = 1000
        ..hpFou = 1000
        ..cardStrengthens = [0, 0, 0, 0, 0]
        ..commandCodes = [null, null, null, null, null];
    }

    playerSvtData.extraPassives = selectedSvt.extraPassive.toList();
    final region = widget.playerRegion;

    final tds = BattleUtils.getShownTds(selectedSvt, playerSvtData.limitCount);
    if (region != Region.jp) {
      final releasedTds = tds
          .where((td) => db.gameData.mappingData.tdPriority[selectedSvt.id]?.ofRegion(region)?[td.id] != null)
          .toList();
      playerSvtData.td = releasedTds.lastOrNull ?? tds.lastOrNull;
    } else {
      playerSvtData.td = tds.lastOrNull;
    }

    for (final skillNum in kActiveSkillNums) {
      final skills = BattleUtils.getShownSkills(selectedSvt, playerSvtData.limitCount, skillNum);
      if (region != Region.jp) {
        final releaseSkills = skills
            .where(
                (skill) => db.gameData.mappingData.skillPriority[selectedSvt.id]?.ofRegion(region)?[skill.id] != null)
            .toList();
        playerSvtData.skills[skillNum - 1] = releaseSkills.lastOrNull ?? skills.lastOrNull;
      } else {
        playerSvtData.skills[skillNum - 1] = skills.lastOrNull;
      }
    }
  }

  Future<void> _onSelectSupport(final SupportServant support) async {
    EasyLoading.show();
    final svt = await AtlasApi.svt(support.svt.id);
    EasyLoading.dismiss();
    if (svt == null) {
      EasyLoading.showError('Servant ${support.svt.id} not found');
      return;
    }
    // if collected battle data didn't choose support svt,
    // no trait info and passive skills
    if (support.traits.isNotEmpty) {
      svt.traits = support.traits.toList();
    }
    svt
      ..classId = support.svt.classId
      ..rarity = support.svt.rarity
      ..attribute = support.svt.attribute;
    playerSvtData
      ..isSupportSvt = true
      ..limitCount = support.limit.limitCount
      ..hpFou = 0
      ..atkFou = 0
      ..lv = support.lv
      ..fixedHp = support.hp
      ..fixedAtk = support.atk;
    // skill & td
    svt.skills = support.skills.skills.whereType<NiceSkill>().toList();
    playerSvtData.skills = support.skills.skills;
    playerSvtData.skillLvs = support.skills.skillLvs.map((e) => e ?? 0).toList();
    svt.noblePhantasms = [if (support.noblePhantasm.noblePhantasm != null) support.noblePhantasm.noblePhantasm!];
    playerSvtData.td = support.noblePhantasm.noblePhantasm;
    playerSvtData.tdLv = support.noblePhantasm.noblePhantasmLv.clamp(1, 5);
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
  final QuestPhase? questPhase;
  final VoidCallback onChange;

  CraftEssenceOptionEditPage({
    super.key,
    required this.playerSvtData,
    required this.questPhase,
    required this.onChange,
  });

  @override
  State<CraftEssenceOptionEditPage> createState() => _CraftEssenceOptionEditPageState();
}

class _CraftEssenceOptionEditPageState extends State<CraftEssenceOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;

  CraftEssence get ce => playerSvtData.ce!;

  @override
  void initState() {
    super.initState();
    if (playerSvtData.ce == null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) Navigator.pop(context);
        selectCE();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.battle_edit_ce_option),
        actions: [
          IconButton(
            onPressed: selectCE,
            icon: const Icon(Icons.change_circle_outlined),
            tooltip: S.current.select_ce,
          )
        ],
      ),
      body: Column(children: [
        Expanded(child: body),
        kDefaultDivider,
        SafeArea(child: buttonBar),
      ]),
    );
  }

  Widget get body {
    if (playerSvtData.ce == null) {
      return const Center(child: Text("None"));
    }
    List<Widget> children = [];
    children.add(_header(context));

    children.add(Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: SliderWithTitle(
        leadingText: 'Lv',
        min: 1,
        max: ce.lvMax,
        value: playerSvtData.ceLv,
        label: playerSvtData.ceLv.toString(),
        onChange: (v) {
          playerSvtData.ceLv = v.round();
          final mlbLv = ce.ascensionAdd.lvMax.ascension[3];
          if (mlbLv != null && mlbLv > 0 && playerSvtData.ceLv > mlbLv) {
            playerSvtData.ceLimitBreak = true;
          }
          _updateState();
        },
      ),
    ));
    children.add(SwitchListTile.adaptive(
      value: playerSvtData.ceLimitBreak,
      title: Text(S.current.max_limit_break),
      onChanged: (v) {
        playerSvtData.ceLimitBreak = v;
        _updateState();
      },
    ));

    children = divideTiles(children, divider: const Divider(height: 8, thickness: 1), bottom: true);

    final skills = ce.getActivatedSkills(playerSvtData.ceLimitBreak);
    for (final skillNum in skills.keys) {
      final skillsForNum = skills[skillNum]!;
      if (skills.length > 1) {
        children.add(DividerWithTitle(title: '${S.current.skill} $skillNum'));
      }
      for (final skill in skillsForNum) {
        children.add(SkillDescriptor(skill: skill));
      }
    }

    return ListView(children: children);
  }

  Widget get buttonBar {
    return ButtonBar(
      children: [
        TextButton(
          onPressed: playerSvtData.ce == null
              ? null
              : () {
                  playerSvtData.ce = null;
                  _updateState();
                },
          child: Text(
            S.current.clear,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: selectCE,
          child: Text(S.current.select_ce),
        ),
        TextButton(
          onPressed: selectStoryCE,
          child: Text(S.current.story_ce),
        ),
      ],
    );
  }

  Widget _header(final BuildContext context) {
    final atk = ce.atkGrowth.getOrNull(playerSvtData.ceLv - 1) ?? 0,
        hp = ce.hpGrowth.getOrNull(playerSvtData.ceLv - 1) ?? 0;

    return CustomTile(
      leading: playerSvtData.ce!.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: ce.borderedIcon,
      ),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: ce.routeTo,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ce.lName.l),
          Text(
            'No.${ce.collectionNo > 0 ? ce.collectionNo : ce.id}'
            '  ${Transl.ceObtain(ce.obtain).l}',
          ),
          Text('ATK $atk  HP $hp'),
        ],
      ),
    );
  }

  void _updateState() {
    widget.onChange();
    if (mounted) {
      setState(() {});
    }
  }

  void selectCE() {
    final event = widget.questPhase?.war?.event;
    Set<int> pinged = db.settings.battleSim.pingedCEs.toSet();
    if (event != null) {
      for (final ce in db.gameData.craftEssences.values) {
        if (pinged.contains(ce.collectionNo)) continue;
        if (ce.skills.any((skill) => skill.isEventSkill(event))) {
          pinged.add(ce.collectionNo);
        }
      }
    }
    final bondCE = db.gameData.craftEssencesById[playerSvtData.svt?.bondEquip];
    if (bondCE != null && bondCE.collectionNo > 0) {
      pinged.add(bondCE.collectionNo);
    }
    router.pushPage(
      CraftListPage(
        onSelected: (selectedCe) {
          _onSelectCE(selectedCe);
        },
        filterData: db.settings.craftFilterData,
        pinged: pinged.toList(),
      ),
      detail: true,
    );
  }

  void selectStoryCE() {
    router.pushPage(
      EnemyListPage(
        onSelected: (card) async {
          if (card.type != SvtType.servantEquip) {
            EasyLoading.showError(S.current.invalid_input);
            return;
          }
          EasyLoading.show();
          CraftEssence? ce = await AtlasApi.ce(card.id);
          EasyLoading.dismiss();
          if (ce == null) {
            EasyLoading.showError(S.current.not_found);
            return;
          }
          _onSelectCE(ce);
        },
        filterData: EnemyFilterData()..svtType.options.add(SvtType.servantEquip),
      ),
      detail: true,
    );
  }

  void _onSelectCE(final CraftEssence selectedCE) {
    playerSvtData.ce = selectedCE;
    final status = db.curUser.ceStatusOf(selectedCE.collectionNo);
    if (db.settings.battleSim.preferPlayerData && selectedCE.collectionNo > 0 && status.status == CraftStatus.owned) {
      playerSvtData.ceLv = status.lv;
      playerSvtData.ceLimitBreak = status.limitCount == 4;
    } else {
      playerSvtData.ceLv = 1;
    }
    _updateState();
  }
}
