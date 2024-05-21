import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
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
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'select_skill_page.dart';

class ServantOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final Region? playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback? onChange;
  final SvtFilterData? svtFilterData;

  ServantOptionEditPage({
    super.key,
    required this.playerSvtData,
    this.playerRegion,
    required this.questPhase,
    required this.onChange,
    required this.svtFilterData,
  });

  @override
  State<ServantOptionEditPage> createState() => _ServantOptionEditPageState();
}

class _ServantOptionEditPageState extends State<ServantOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;
  Servant get svt => playerSvtData.svt!;
  QuestPhase? get questPhase => widget.questPhase;
  SvtFilterData? get svtFilterData => widget.svtFilterData;
  bool get enableEdit => widget.onChange != null;
  static EnemyFilterData? _enemyFilterData;

  @override
  void initState() {
    super.initState();
    if (playerSvtData.svt == null && enableEdit) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await selectSvt();
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (playerSvtData.svt == null && mounted) {
            Navigator.of(context).pop();
          }
        });
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.battle_edit_servant_option),
        actions: [popupMenu],
      ),
      body: Column(
        children: [
          Expanded(child: body),
          if (enableEdit) ...[
            kDefaultDivider,
            SafeArea(child: buttonBar),
          ]
        ],
      ),
    );
  }

  Widget _buildSliderGroup() {
    playerSvtData.lv = playerSvtData.lv.clamp(1, min(120, svt.atkGrowth.length));
    final commonSliders = <Widget>[
      SliderWithPrefix(
        label: S.current.np_short,
        min: 1,
        max: 5,
        value: playerSvtData.tdLv,
        valueFormatter: (v) => 'Lv.$v',
        onChange: (v) {
          _updateState(() {
            playerSvtData.tdLv = v.round();
          });
        },
      ),
      SliderWithPrefix(
        label: 'Lv',
        min: 1,
        max: min(120, svt.atkGrowth.length),
        value: playerSvtData.lv,
        onChange: (v) {
          _updateState(() {
            playerSvtData.lv = v.round();
          });
        },
      ),
      SliderWithPrefix(
        label: 'ATK ${S.current.foukun}',
        min: 0,
        max: 2000,
        value: playerSvtData.atkFou,
        // division: 200,
        valueFormatter: (v) => '+$v',
        onChange: (v) {
          _updateState(() {
            int v2 = (v / 10).round();
            if (v2 > 100) {
              v2 = v2 ~/ 2 * 2;
            }
            playerSvtData.atkFou = v2 * 10;
          });
        },
      ),
      SliderWithPrefix(
        label: 'HP ${S.current.foukun}',
        min: 0,
        max: 2000,
        value: playerSvtData.hpFou,
        // division: 200,
        valueFormatter: (v) => '+$v',
        onChange: (v) {
          _updateState(() {
            int v2 = (v / 10).round();
            if (v2 > 100) {
              v2 = v2 ~/ 2 * 2;
            }
            playerSvtData.hpFou = v2 * 10;
          });
        },
      ),
    ];
    final activeSkills = [
      for (int skillNum in kActiveSkillNums)
        SliderWithPrefix(
          label: '${S.current.active_skill_short} $skillNum',
          min: 1,
          max: 10,
          value: playerSvtData.skillLvs[skillNum - 1],
          valueFormatter: (v) => 'Lv.$v',
          onChange: (v) {
            _updateState(() {
              playerSvtData.skillLvs[skillNum - 1] = v.round();
            });
          },
        ),
    ];
    final appendSkills = [
      for (int skillNum in kAppendSkillNums)
        SliderWithPrefix(
          label: '${S.current.append_skill_short} $skillNum',
          min: 0,
          max: 10,
          value: playerSvtData.appendLvs[skillNum - 1],
          valueFormatter: (v) => 'Lv.$v',
          onChange: (v) {
            _updateState(() {
              playerSvtData.appendLvs[skillNum - 1] = v.round();
            });
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

  Widget get body {
    if (playerSvtData.svt == null) {
      return const Center(child: Text('None'));
    }
    const divider = Divider(height: 8, thickness: 1);
    final extraPassives = playerSvtData.extraPassives
        .where((passive) => passive.shouldActiveSvtEventSkill(
            eventId: questPhase?.war?.eventId ?? 0, svtId: playerSvtData.svt?.id, includeZero: true))
        .toList();
    final List<Widget> children = [
      _header(context),
      divider,
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        child: _buildSliderGroup(),
      ),
      tipsCard,
      divider,
      ListTile(
        dense: true,
        leading: Text(S.current.support_servant_short),
        trailing: FilterGroup<SupportSvtType>(
          combined: true,
          padding: EdgeInsets.zero,
          options: SupportSvtType.values,
          values: FilterRadioData.nonnull(playerSvtData.supportType),
          enabled: playerSvtData.supportType != SupportSvtType.npc && enableEdit,
          optionBuilder: (v) => Text(v.shownName, textScaler: const TextScaler.linear(0.9)),
          onFilterChanged: (v, _) {
            setState(() {
              playerSvtData.supportType = v.radioValue!;
            });
          },
        ),
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
        header: '${S.current.custom_skill}/Buff ',
        headerWidget: SHeader.rich(TextSpan(text: '${S.current.custom_skill}/Buff', children: [
          CenterWidgetSpan(
            child: db.getIconImage(AssetURL.i.buffIcon(302), width: 18, aspectRatio: 1),
          )
        ])),
        children: [
          for (int index = 0; index < playerSvtData.customPassives.length; index++) _buildAdditionalPassive(index),
          ..._buildHiddenAddPassive(),
          Center(
            child: TextButton(
              onPressed: enableEdit
                  ? () async {
                      await router.pushPage(SkillSelectPage(
                        skillType: SkillType.passive,
                        onSelected: (skill) {
                          playerSvtData.addCustomPassive(skill, skill.maxLv);
                        },
                      ));
                      if (mounted) setState(() {});
                    }
                  : null,
              child: Text(S.current.select_skill),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: enableEdit ? onAddClassBoard : null,
              child: Text('${S.current.custom_skill}-${S.current.class_board}'),
            ),
          )
        ],
      ),
      _buildCmdCodePlanner(),
      TileGroup(
        header: S.current.extra_passive,
        children: [
          if (extraPassives.isEmpty) const ListTile(dense: true, title: Text('NONE')),
          for (final passive in extraPassives) _buildExtraPassive(passive),
        ],
      ),
      TileGroup(
        header: S.current.append_skill,
        children: [
          for (final skillNum in kAppendSkillNums) _buildAppendSkill(context, skillNum),
        ],
      ),
    ];
    return ListView(children: children);
  }

  Widget get tipsCard {
    return Card(
      child: ValueStatefulBuilder<bool>(
        initValue: false,
        builder: (context, value) {
          Widget child = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 30),
                  Expanded(
                    child: Text(
                      S.current.tips,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    value.value ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Text(
                S.current.svt_option_edit_tips,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: value.value ? null : 1,
                overflow: value.value ? null : TextOverflow.ellipsis,
              ),
            ],
          );
          return InkWell(
            onTap: () {
              value.value = !value.value;
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton<dynamic>(
      enabled: enableEdit,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            height: 24,
            child: Text(S.current.select, style: Theme.of(context).textTheme.bodySmall),
          ),
          const PopupMenuItem(
            enabled: false,
            height: 8,
            padding: EdgeInsets.zero,
            child: Divider(),
          ),
          PopupMenuItem(
            onTap: () {
              selectSvt();
            },
            child: Text(S.current.servant),
          ),
          PopupMenuItem(
            onTap: () {
              selectSvtEntity();
            },
            child: Text(S.current.enemy),
          ),
          if (questPhase?.supportServants.isNotEmpty == true)
            PopupMenuItem(
              onTap: () {
                selectSupport();
              },
              child: Text(S.current.support_servant),
            ),
          const PopupMenuDivider(),
          for (final source in PreferPlayerSvtDataSource.values)
            PopupMenuItem(
              enabled: playerSvtData.svt != null &&
                  !playerSvtData.supportType.isSupport &&
                  (source.isNone ||
                      (playerSvtData.svt?.isUserSvt == true && playerSvtData.svt?.status.favorite == true)),
              onTap: () {
                resyncServantData(source);
              },
              child: Text('${S.current.svt_option_resync}(${source.detailName})'),
            ),
        ];
      },
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(
              onPressed: playerSvtData.svt == null
                  ? null
                  : () {
                      _updateState(() {
                        playerSvtData.svt = null;
                      });
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(S.current.clear),
            ),
            FilledButton(
              onPressed: selectSvt,
              child: Text(S.current.select_servant),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.current.confirm),
            )
          ],
        )
      ],
    );
  }

  Widget _header(final BuildContext context) {
    final ascensionText = svt.getCostume(playerSvtData.limitCount)?.lName.l ??
        '${S.current.ascension_stage_short} ${playerSvtData.limitCount}';
    final atk = (svt.atkGrowth.getOrNull(playerSvtData.lv - 1) ?? 0) + playerSvtData.atkFou,
        hp = (svt.hpGrowth.getOrNull(playerSvtData.lv - 1) ?? 0) + playerSvtData.hpFou;
    return CustomTile(
      leading: svt.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: svt.ascendIcon(playerSvtData.limitCount),
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
            '  ${Transl.svtClassId(svt.classId).l}'
            '  ${Transl.svtSubAttribute(svt.attribute).l}',
          ),
          Text('ATK $atk  HP $hp'),
        ],
      ),
      trailing: TextButton(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(ascensionText, textScaler: const TextScaler.linear(0.9)),
        ),
        onPressed: () async {
          if (!enableEdit) return;
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              final List<Widget> children = [];
              void _addOne(final int limitCount, final String name, final String? icon) {
                if (icon == null) return;
                final borderedIcon = svt.bordered(icon);
                children.add(ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: db.getIconImage(
                    borderedIcon,
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
                  ),
                  title: Text(name, textScaler: const TextScaler.linear(0.9)),
                  onTap: () {
                    for (final skillNum in kActiveSkillNums) {
                      final List<NiceSkill> previousShownSkills =
                          BattleUtils.getShownSkills(svt, playerSvtData.limitCount, skillNum);
                      final List<NiceSkill> shownSkills = BattleUtils.getShownSkills(svt, limitCount, skillNum);
                      if (!listEquals(previousShownSkills, shownSkills)) {
                        playerSvtData.skills[skillNum - 1] = shownSkills.lastOrNull;
                        logger.d('Changing skill ID: ${playerSvtData.skills[skillNum - 1]?.id}');
                      }
                    }

                    final List<NiceTd> previousShownTds = BattleUtils.getShownTds(svt, playerSvtData.limitCount);
                    final List<NiceTd> shownTds = BattleUtils.getShownTds(svt, limitCount);
                    playerSvtData.limitCount = limitCount;
                    if (!listEquals(previousShownTds, shownTds)) {
                      playerSvtData.td = shownTds.last;
                      logger.d('Capping npId: ${playerSvtData.td?.id}');
                    }
                    Navigator.pop(context);
                    _updateState(() {});
                  },
                ));
              }

              final List<int> limitCounts = {0, ...?svt.extraAssets.faces.ascension?.keys}.toList();
              for (final limitCount in limitCounts) {
                _addOne(limitCount, '${S.current.ascension_stage} $limitCount', svt.ascendIcon(limitCount));
              }

              final costumeCharaIds = svt.extraAssets.faces.costume?.keys.toList() ?? [];
              for (final charaId in costumeCharaIds) {
                _addOne(charaId, svt.profile.costume[charaId]?.lName.l ?? '${S.current.costume} $charaId',
                    svt.ascendIcon(charaId));
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
          minLeadingWidth: 24,
          leading: td == null ? db.getIconImage(null, width: 24) : CommandCardWidget(card: td.svt.card, width: 28),
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
                    enabled: enableEdit,
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
                      _updateState(() {
                        playerSvtData.td = v.radioValue;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: enableEdit
                      ? () {
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
                              _updateState(() {});
                            },
                          ).showDialog(context);
                        }
                      : null,
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
          minLeadingWidth: 28,
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
                    enabled: enableEdit,
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
                      _updateState(() {
                        playerSvtData.skills[index] = v.radioValue;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: enableEdit
                      ? () {
                          router.pushPage(SkillSelectPage(
                            skillType: SkillType.active,
                            onSelected: (skill) {
                              _updateState(() {
                                playerSvtData.skills[index] = skill.toNice();
                              });
                            },
                          ));
                        }
                      : null,
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
          minLeadingWidth: 28,
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

  List<Widget> _buildHiddenAddPassive() {
    List<Widget> children = [];
    int eventId = questPhase?.event?.id ?? 0;
    if (eventId == 0) return children;
    for (final skillId
        in db.gameData.constData.getSvtLimitHides(svt.id, playerSvtData.limitCount).expand((e) => e.addPassives)) {
      // 終局特異点
      if (skillId >= 960502 && skillId <= 960507) continue;
      final skill = playerSvtData.extraPassives.firstWhereOrNull((skill) => skill.id == skillId);
      if (skill == null) continue;
      if (!skill.shouldActiveSvtEventSkill(eventId: eventId, svtId: svt.id, includeZero: false, includeHidden: true)) {
        continue;
      }

      if (playerSvtData.customPassives.any((e) => e.id == skillId)) continue;
      children.add(ListTile(
        dense: true,
        enabled: false,
        minLeadingWidth: 28,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        leading: db.getIconImage(skill.icon, width: 28, onTap: skill.routeTo),
        title: Text('[${S.current.disabled}] ${skill.lName.l}'),
        subtitle: Text(
          skill.lDetail ?? "???",
          textScaler: const TextScaler.linear(0.85),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          onPressed: () {
            playerSvtData.addCustomPassive(skill, skill.maxLv);
            setState(() {});
          },
          icon: const Icon(Icons.add_circle),
          tooltip: S.current.enable,
          color: Theme.of(context).buttonTheme.colorScheme?.primary,
        ),
      ));
    }
    return children;
  }

  Widget _buildExtraPassive(NiceSkill skill) {
    final disabled = playerSvtData.disabledExtraSkills.contains(skill.id);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        String title = skill.lName.l;
        String subtitle = skill.lDetail ?? '???';
        return ListTile(
          dense: true,
          minLeadingWidth: 28,
          leading: db.getIconImage(skill.icon ?? Atlas.common.emptySkillIcon, width: 28),
          title: Text(title, style: disabled ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
          subtitle: Text(
            subtitle,
            textScaler: const TextScaler.linear(0.85),
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
                  onPressed: enableEdit
                      ? () {
                          _updateState(() {
                            playerSvtData.disabledExtraSkills.toggle(skill.id);
                          });
                        }
                      : null,
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
    final skill = playerSvtData.customPassives[index];
    final lv = playerSvtData.customPassiveLvs.getOrNull(index);
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
          minLeadingWidth: 28,
          leading: db.getIconImage(skill.icon ?? Atlas.common.emptySkillIcon, width: 28),
          title: Text(title),
          subtitle:
              Text(subtitle, textScaler: const TextScaler.linear(0.85), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  onPressed: enableEdit
                      ? () {
                          setState(() {
                            playerSvtData.customPassives.removeAt(index);
                            playerSvtData.customPassiveLvs.removeAt(index);
                          });
                        }
                      : null,
                  child: Text(
                    S.current.remove,
                    // style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                if (maxLv > 1)
                  DropdownButton<int>(
                    isDense: true,
                    value: playerSvtData.customPassiveLvs[index],
                    items: [
                      for (int lv2 = 1; lv2 <= maxLv; lv2++) DropdownMenuItem(value: lv2, child: Text('Lv.$lv2')),
                    ],
                    onChanged: enableEdit
                        ? (v) {
                            setState(() {
                              if (v != null) {
                                playerSvtData.customPassiveLvs[index] = v;
                              }
                            });
                          }
                        : null,
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

  Future<void> onAddClassBoard() async {
    final board =
        db.gameData.classBoards.values.firstWhereOrNull((e) => e.classes.any((cls) => cls.classId == svt.classId));
    if (board == null) {
      EasyLoading.showInfo('${S.current.not_found}: ${Transl.svtClassId(svt.classId).l}');
      return;
    }
    if (!mounted) return;
    final source = await showDialog<PreferClassBoardDataSource>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SimpleDialog(
          title: Text('${S.current.plan} (${S.current.class_board})'),
          children: [
            for (final source in [
              PreferClassBoardDataSource.current,
              PreferClassBoardDataSource.target,
              PreferClassBoardDataSource.full
            ])
              SimpleDialogOption(
                child: Text(source.shownName),
                onPressed: () {
                  Navigator.pop(context, source);
                },
              )
          ],
        );
      },
    );
    if (source == null) return;

    ClassBoardPlan? plan = switch (source) {
      PreferClassBoardDataSource.none => null,
      PreferClassBoardDataSource.current => db.curUser.classBoardStatusOf(board.id),
      PreferClassBoardDataSource.target => db.curPlan_.classBoardPlan(board.id),
      PreferClassBoardDataSource.full => ClassBoardPlan.full(board),
    };
    if (plan == null) return;
    final skill = board.toSkill(plan);
    if (skill == null || skill.functions.isEmpty) {
      EasyLoading.showInfo(S.current.empty_hint);
      return;
    }
    skill.unmodifiedDetail = source.shownName;
    playerSvtData.addCustomPassive(skill, skill.maxLv);
    if (mounted) setState(() {});
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
                    if (!enableEdit) return;
                    router.pushBuilder(
                      builder: (context) => CmdCodeListPage(
                        onSelected: (selectedCode) {
                          playerSvtData.commandCodes[index] = db.gameData.commandCodes[selectedCode.collectionNo];
                          _updateState(() {});
                        },
                        filterData: db.settings.filters.cmdCodeFilterData,
                      ),
                      detail: false,
                    );
                  },
                  onLongPress: code?.routeTo,
                  child: db.getIconImage(code?.icon ?? Atlas.asset('SkillIcons/skill_999999.png'),
                      height: 60, aspectRatio: 132 / 144, padding: const EdgeInsets.all(4)),
                ),
                IconButton(
                  onPressed: enableEdit
                      ? () {
                          setState(() {
                            playerSvtData.commandCodes[index] = null;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  tooltip: S.current.remove,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: SliderWithPrefix(
                    titled: true,
                    label: S.current.card_strengthen,
                    min: 0,
                    max: 500,
                    value: playerSvtData.cardStrengthens[index],
                    // valueFormatter: (v) => v.toString(),
                    onChange: (v) {
                      _updateState(() {
                        playerSvtData.cardStrengthens[index] = v.round() ~/ 20 * 20;
                      });
                    },
                  ),
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

  void _updateState(VoidCallback fn) {
    if (enableEdit) fn();
    if (widget.onChange != null) widget.onChange!();
    if (mounted) {
      setState(() {});
    }
  }

  Future selectSvt() async {
    await router.pushPage(
      ServantListPage(
        planMode: false,
        onSelected: (selectedSvt) {
          playerSvtData.onSelectServant(
            selectedSvt,
            region: widget.playerRegion,
            jpTime: questPhase?.jpOpenAt,
          );
          _updateState(() {});
        },
        filterData: svtFilterData,
        pinged: db.curUser.battleSim.pingedSvts.toList(),
        showSecondaryFilter: true,
        eventId: questPhase?.event?.id,
      ),
      detail: true,
    );
  }

  void selectSvtEntity() {
    _enemyFilterData ??= EnemyFilterData();
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
          playerSvtData.onSelectServant(
            svt,
            region: widget.playerRegion,
            jpTime: questPhase?.jpOpenAt,
          );
          _updateState(() {});
        },
        filterData: _enemyFilterData,
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
                  _updateState(() {});
                },
              )
          ],
        );
      },
    );
  }

  void resyncServantData(PreferPlayerSvtDataSource source) {
    final selectedSvt = playerSvtData.svt;
    if (selectedSvt == null || playerSvtData.supportType.isSupport) {
      return;
    }
    final resultSource = playerSvtData.onSelectServant(
      selectedSvt,
      source: source,
      region: widget.playerRegion,
      jpTime: questPhase?.jpOpenAt,
    );

    if (mounted) setState(() {});
    EasyLoading.showSuccess('${S.current.updated}(${resultSource.detailName})');
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
    if (support.traits2.isNotEmpty) {
      svt.traits = support.traits2.toList();
    }
    final basicSvt = support.detail?.svt ?? support.svt;
    svt
      ..classId = basicSvt.classId
      ..rarity = basicSvt.rarity
      ..attribute = basicSvt.attribute;
    playerSvtData
      ..supportType = SupportSvtType.npc
      ..limitCount = support.detail?.limit.useLimitCount ?? support.limit.limitCount
      ..hpFou = (support.detail?.adjustHp ?? 0) * 10
      ..atkFou = (support.detail?.adjustAtk ?? 0) * 10
      ..lv = support.detail?.lv ?? support.lv
      ..fixedHp = support.detail?.hp ?? support.hp
      ..fixedAtk = support.detail?.atk ?? support.atk;
    // skill & td
    // svt.skills = support.skills2.skills.whereType<NiceSkill>().toList();
    playerSvtData.skills = support.skills2.skills.toList();
    playerSvtData.skillLvs = support.skills2.skillLvs.map((e) => e ?? 0).toList();
    // svt.noblePhantasms = [if (support.td2 != null) support.td2!];
    playerSvtData.td = support.td2;
    playerSvtData.tdLv = (support.td2Lv ?? 1).clamp2(1, support.td2?.maxLv ?? 1);
    // playerSvtData.appendLvs = support.classPassive.appendPassiveSkillLvs;
    playerSvtData.appendLvs.fillRange(0, playerSvtData.appendLvs.length, 0);
    playerSvtData.customPassives = List<BaseSkill>.of(support.detail?.classPassive.addPassive ?? []);
    playerSvtData.customPassiveLvs = playerSvtData.customPassives.map((e) => e.maxLv).toList();
    // ce
    final ce = support.equips.getOrNull(0);
    playerSvtData
      ..ce = ce?.equip
      ..ceLimitBreak = ce?.limitCount == 4
      ..ceLv = ce?.lv ?? 1;

    svt.preprocess();
    playerSvtData.svt = svt;
    playerSvtData
      ..commandCodes.fillRange(0, playerSvtData.commandCodes.length, null)
      ..cardStrengthens.fillRange(0, playerSvtData.cardStrengthens.length, 0);
  }
}

class CraftEssenceOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final QuestPhase? questPhase;
  final VoidCallback? onChange;
  final CraftFilterData? craftFilterData;

  CraftEssenceOptionEditPage({
    super.key,
    required this.playerSvtData,
    required this.questPhase,
    required this.onChange,
    required this.craftFilterData,
  });

  @override
  State<CraftEssenceOptionEditPage> createState() => _CraftEssenceOptionEditPageState();
}

class _CraftEssenceOptionEditPageState extends State<CraftEssenceOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;

  CraftEssence get ce => playerSvtData.ce!;

  CraftFilterData? get craftFilterData => widget.craftFilterData;

  bool get enableEdit => widget.onChange != null;

  @override
  void initState() {
    super.initState();
    if (playerSvtData.ce == null && enableEdit) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await selectCE();
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (playerSvtData.ce == null && mounted) {
            Navigator.of(context).pop();
          }
        });
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[${S.current.edit}] ${playerSvtData.svt?.lName.l ?? ""}'),
        actions: [popupMenu],
      ),
      body: Column(children: [
        Expanded(child: body),
        if (enableEdit) ...[
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ]
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
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: SliderWithPrefix(
        leadingWidth: 36,
        label: 'Lv',
        min: 1,
        max: ce.lvMax,
        value: playerSvtData.ceLv,
        onChange: (v) {
          _updateState(() {
            playerSvtData.ceLv = v.round();
            final mlbLv = ce.ascensionAdd.lvMax.ascension[3];
            if (mlbLv != null && mlbLv > 0 && playerSvtData.ceLv > mlbLv) {
              playerSvtData.ceLimitBreak = true;
            }
          });
        },
        // endOffset: -16,
      ),
    ));
    children.add(SwitchListTile.adaptive(
      value: playerSvtData.ceLimitBreak,
      title: Text(S.current.max_limit_break),
      onChanged: enableEdit
          ? (v) {
              final ce = playerSvtData.ce;
              if (v &&
                  ce != null &&
                  const [SvtFlag.svtEquipChocolate, SvtFlag.svtEquipExp, SvtFlag.svtEquipFriendShip]
                      .every((e) => !ce.flags.contains(e))) {
                int? lvMin = {1: 6, 2: 9, 3: 11, 4: 13, 5: 15}[ce.rarity];
                if (lvMin != null && lvMin <= ce.lvMax && playerSvtData.ceLv < lvMin) {
                  playerSvtData.ceLv = lvMin;
                }
              }
              playerSvtData.ceLimitBreak = v;
              _updateState(() {});
            }
          : null,
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
    children.addAll([
      DividerWithTitle(title: '${S.current.custom_skill}?'),
      Text(
        S.current.ce_custom_skill_hint,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
    ]);

    return ListView(children: children);
  }

  Widget get popupMenu {
    return PopupMenuButton(
      enabled: enableEdit,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          height: 24,
          child: Text(S.current.select, style: Theme.of(context).textTheme.bodySmall),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 8,
          padding: EdgeInsets.zero,
          child: Divider(),
        ),
        PopupMenuItem(
          onTap: () {
            selectCE();
          },
          child: Text(S.current.craft_essence),
        ),
        PopupMenuItem(
          onTap: () {
            selectStoryCE();
          },
          child: Text(S.current.story_ce),
        ),
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(
              onPressed: playerSvtData.ce == null
                  ? null
                  : () {
                      playerSvtData.ce = null;
                      _updateState(() {});
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(S.current.clear),
            ),
            FilledButton(
              onPressed: selectCE,
              child: Text(S.current.select_ce),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.current.confirm),
            ),
          ],
        )
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

  void _updateState(VoidCallback fn) {
    if (enableEdit) fn();
    if (widget.onChange != null) widget.onChange!();
    if (mounted) {
      setState(() {});
    }
  }

  Future selectCE() async {
    await router.pushPage(
      CraftListPage(
        onSelected: (ce) {
          playerSvtData.onSelectCE(ce);
          _updateState(() {});
        },
        filterData: craftFilterData,
        pinged: db.curUser.battleSim.pingedCEsWithEventAndBond(widget.questPhase, playerSvtData.svt).toList(),
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
          playerSvtData.onSelectCE(ce);
          _updateState(() {});
        },
        filterData: EnemyFilterData()..svtType.options.add(SvtType.servantEquip),
      ),
      detail: true,
    );
  }
}
