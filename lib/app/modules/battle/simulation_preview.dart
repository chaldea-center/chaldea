import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/battle/teams/teams_query_page.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/breakdown/quest_phase.dart';
import '../quest/quest.dart';
import 'formation/default_lvs.dart';
import 'formation/formation_storage.dart';
import 'formation/quest_selector.dart';
import 'formation/team.dart';
import 'quest/quest_edit.dart';
import 'utils.dart';

class SimulationPreview extends StatefulWidget {
  final Region? region;
  final QuestPhase? questPhase;
  final Uri? shareUri;

  const SimulationPreview({
    super.key,
    this.region,
    this.questPhase,
    this.shareUri,
  });

  @override
  State<SimulationPreview> createState() => _SimulationPreviewState();
}

class _SimulationPreviewState extends State<SimulationPreview> {
  static const _validQuestRegions = [Region.jp, Region.na];

  Region? questRegion; // region for quest selector
  QuestPhase? _questPhase;
  QuestPhase? get questPhase => _questPhase;
  set questPhase(QuestPhase? v) {
    if (v == null) {
      _questPhase = v;
    } else {
      _questPhase = QuestPhase.fromJson(v.toJson());
    }
  }

  String? questErrorMsg;
  String? errorMsg;

  TextEditingController questIdTextController = TextEditingController();

  final BattleOptions options = BattleOptions();
  BattleSimSetting get settings => db.settings.battleSim;

  List<PlayerSvtData> get onFieldSvts => options.team.onFieldSvtDataList;
  List<PlayerSvtData> get backupSvts => options.team.backupSvtDataList;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    questRegion = widget.region;
    questPhase = widget.questPhase;
    String? initText;
    if (widget.shareUri != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        importShareData(widget.shareUri!);
      });
    } else if (questPhase != null) {
      initText = '${questPhase!.id}/${questPhase!.phase}';
      if (questPhase!.enemyHash != null && questPhase!.enemyHashes.length > 1) {
        initText += '?hash=${questPhase!.enemyHash}';
      }
      if (widget.region != null) {
        initText = '/${widget.region!.upper}/quest/$initText';
      }
      questIdTextController.text = initText;
      initFormation();
    } else if (settings.previousQuestPhase != null) {
      questIdTextController.text = settings.previousQuestPhase!;
      _parseQuestPhase();
      initFormation();
    }

    if (db.settings.autoResetFilter) {
      db.settings.svtFilterData.reset();
      db.settings.craftFilterData
        ..reset()
        ..obtain.options = CEObtain.values.toSet().difference({CEObtain.valentine, CEObtain.exp, CEObtain.campaign});
    }
  }

  @override
  void dispose() {
    super.dispose();
    saveFormation();
    questIdTextController.dispose();
    QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
  }

  @override
  Widget build(final BuildContext context) {
    checkPreviewReady();
    final List<Widget> children = [];

    children.add(questSelector());
    children.add(header(S.current.quest));
    children.add(questDetail());

    children.add(header(S.current.battle_simulation_setup));
    children.add(partyOption());
    children.add(DividerWithTitle(indent: 16, title: S.current.team));
    children.add(Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            options.team.clear();
            saveFormation();
            if (mounted) setState(() {});
          },
          child: Text(
            S.current.clear,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () async {
            saveFormation();
            await router.pushPage(const FormationEditor(isSaving: true));
            if (mounted) setState(() {});
          },
          child: Text(S.current.save),
        ),
        TextButton(
          onPressed: () async {
            await router.pushPage(FormationEditor(isSaving: false, onSelected: restoreFormation));
            if (mounted) setState(() {});
          },
          child: Text(S.current.team_local),
        ),
        TextButton(
          onPressed: questPhase == null
              ? null
              : () async {
                  if (!questPhase!.isLaplaceSharable) {
                    EasyLoading.showInfo(S.current.quest_disallow_laplace_share_hint);
                    return;
                  }
                  final BattleTeamFormation? selected = await router.pushPage<BattleTeamFormation?>(
                    TeamsQueryPage(
                      mode: TeamQueryMode.quest,
                      questPhase: questPhase,
                    ),
                  );
                  if (selected != null) {
                    restoreFormation(selected);
                  }
                  if (mounted) setState(() {});
                },
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
          child: Text(S.current.team_shared),
        ),
      ],
    ));
    children.add(TeamSetupCard(
      onFieldSvts: onFieldSvts,
      backupSvts: backupSvts,
      team: options.team,
      quest: questPhase,
      playerRegion: settings.playerRegion,
      onChanged: () {
        if (mounted) setState(() {});
      },
    ));
    children.add(header(S.current.mystic_code));
    children.add(buildMysticCode());
    children.add(header(S.current.battle_misc_config));
    children.add(buildMisc());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(S.current.battle_simulation_setup, maxLines: 1),
        centerTitle: false,
        actions: [PopupMenuButton(itemBuilder: _buildPopupMenuItems)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ListView(children: children)),
          kDefaultDivider,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: buttonBar(),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem> _buildPopupMenuItems(BuildContext context) {
    List<PopupMenuItem> children = [
      PopupMenuItem(
        onTap: () {
          saveFormation();
          if (!settings.curFormation.allSvts.any((e) => e?.svtId != null)) {
            EasyLoading.showError("No servant in team");
            return;
          }
          BattleQuestInfo? questInfo;
          if (_questPhase != null && _questPhase!.id > 0) {
            questInfo = BattleQuestInfo.quest(
              _questPhase!,
              region: questRegion,
            );
          }
          final shareUri = BattleShareData(
            appBuild: AppInfo.buildNumber,
            quest: questInfo,
            option: options.toShareData(),
            team: settings.curFormation,
          ).toUriV2();
          String shareString = shareUri.toString();
          Clipboard.setData(ClipboardData(text: shareString));
          if (shareString.length > 200) {
            shareString = '${shareString.substring(0, 200)}...';
          }
          EasyLoading.showSuccess("${S.current.copied}\n$shareString");
        },
        child: Text(S.current.share),
      ),
      PopupMenuItem(
        onTap: () async {
          final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
          if (text == null || text.isEmpty) {
            EasyLoading.showError("Please copy share url to clipboard first");
            return;
          }
          final uri = Uri.tryParse(text);
          if (uri == null) {
            EasyLoading.showError('Invalid url format');
            return;
          }
          importShareData(uri);
        },
        child: Text('${S.current.import_data}(${S.current.import_from_clipboard})'),
      ),
      PopupMenuItem(
        onTap: () async {
          await null;
          if (!mounted) return;
          InputCancelOkDialog(
            title: 'Laplace Team ID',
            keyboardType: TextInputType.number,
            validate: (s) => (int.tryParse(s) ?? -1) > 0,
            onSubmit: (s) async {
              final id = int.tryParse(s);
              if (id == null || id <= 0) {
                EasyLoading.showError("Invalid ID");
                return;
              }
              importShareData(Uri.parse('https://chaldea.center/laplace/share?id=$id'));
            },
          ).showDialog(context);
        },
        child: const Text('Laplace Team ID'),
      )
    ];

    return children;
  }

  Widget header(String title) {
    return DividerWithTitle(
      title: S.current.quest,
      titleWidget: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      thickness: 2,
      padding: const EdgeInsets.only(top: 8),
    );
  }

  Widget questSelector() {
    if (questRegion != null && !_validQuestRegions.contains(questRegion)) {
      questRegion = Region.jp;
    }
    return ValueStatefulBuilder<bool>(
      initValue: false,
      builder: (context, expanded) {
        return Column(
          children: [
            FQSelectDropdown(
              key: Key('FQSelectDropdown_${questPhase?.id}'),
              initQuestId: questPhase?.id,
              onChanged: (Quest quest) async {
                EasyLoading.show();
                if (quest.phases.isEmpty) return;
                final phase = await AtlasApi.questPhase(quest.id, quest.phases.last);
                EasyLoading.dismiss();
                if (mounted) {
                  if (phase != null) {
                    questPhase = phase;
                    questIdTextController.text = '${phase.id}/${phase.phase}';
                  }
                  setState(() {});
                }
              },
            ),
            kIndentDivider,
            ListTile(
              dense: true,
              title: Text('② ${S.current.battle_quest_from} ${S.current.event}/${S.current.main_story}'),
              subtitle: Text.rich(TextSpan(
                text: '${S.current.event}→${S.current.war}→${S.current.quest}→',
                children: [
                  CenterWidgetSpan(
                    child: Icon(
                      Icons.calculate,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              )),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
                router.push(url: Routes.events, detail: true);
              },
            ),
            kIndentDivider,
            TextButton(
              onPressed: () {
                expanded.value = !expanded.value;
              },
              style: kTextButtonDenseStyle,
              child: Text(expanded.value ? S.current.show_less : S.current.show_more),
            ),
            if (expanded.value) ...[
              kIndentDivider,
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextFormField(
                  controller: questIdTextController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    hintText: '93031014/3 ${S.current.logic_type_or} **/JP/quest/93031014/3'.breakWord,
                    labelText: '③ questId/phase ${S.current.logic_type_or} chaldea/AADB quest url',
                    hintStyle: const TextStyle(overflow: TextOverflow.visible),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  DropdownButton<Region>(
                    isDense: true,
                    value: questRegion,
                    items: [
                      for (final r in _validQuestRegions)
                        DropdownMenuItem(value: r, child: Text(r.localName, textScaleFactor: 0.9)),
                    ],
                    hint: Text(Region.jp.localName),
                    onChanged: (v) {
                      setState(() {
                        if (v != null) questRegion = v;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      EasyLoading.show();
                      try {
                        await _parseQuestPhase();
                      } catch (e, s) {
                        logger.e('fetch quest phase failed', e, s);
                        questErrorMsg = escapeDioException(e);
                      } finally {
                        EasyLoading.dismiss();
                        if (mounted) setState(() {});
                      }
                    },
                    child: Text(S.current.atlas_load),
                  ),
                  ChaldeaUrl.laplaceHelpBtn('faq#what-is-atlas-db-url', zhPath: 'faq.html#什么是-atlas-db-url')
                ],
              ),
              kIndentDivider,
              ListTile(
                dense: true,
                title: Text('④ ${S.current.general_import} JSON'),
                trailing: const Icon(Icons.file_open),
                onTap: () async {
                  try {
                    final result = await FilePickerU.pickFiles(
                        type: FileType.custom, allowedExtensions: ['json'], clearCache: true);
                    final bytes = result?.files.firstOrNull?.bytes;
                    if (bytes == null) return;
                    final phaseData = QuestPhase.fromJson(Map.from(jsonDecode(utf8.decode(bytes))));
                    if (phaseData.id > 0) phaseData.id = -phaseData.id;
                    if (phaseData.allEnemies.isEmpty) {
                      EasyLoading.showError('No enemy found!');
                      return;
                    }
                    if (mounted) {
                      questPhase = phaseData;
                      questIdTextController.text = '';
                      setState(() {});
                    }
                  } catch (e, s) {
                    logger.i('load custom json quest failed', e, s);
                    EasyLoading.showError(e.toString());
                    return;
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget questDetail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (questErrorMsg != null)
          SFooter.rich(TextSpan(text: questErrorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        // kDefaultDivider,
        Wrap(
          children: [
            TextButton(
              onPressed: () {
                router.pushPage(QuestEditPage(
                  quest: questPhase,
                  onComplete: (q) {
                    q.id = -q.id.abs();
                    questPhase = q;
                    if (mounted) setState(() {});
                  },
                ));
              },
              style: kTextButtonDenseStyle,
              child: Text(S.current.general_custom),
            ),
            TextButton(
              onPressed: questPhase == null
                  ? null
                  : () {
                      QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
                      router.push(
                        url: Routes.questI(questPhase!.id),
                        child: QuestDetailPage.phase(questPhase: questPhase!),
                        detail: true,
                      );
                    },
              style: kTextButtonDenseStyle,
              child: Text(S.current.quest_detail_btn),
            ),
            TextButton(
              onPressed: questPhase == null
                  ? null
                  : () async {
                      try {
                        final text = const JsonEncoder.withIndent('  ').convert(questPhase);
                        await FilePickerU.saveFile(
                          dialogContext: context,
                          data: utf8.encode(text),
                          filename:
                              "quest-${questPhase!.id}-${questPhase!.phase}-${DateTime.now().toSafeFileName()}.json",
                        );
                      } catch (e, s) {
                        EasyLoading.showError(e.toString());
                        logger.e('dump quest phase json failed', e, s);
                        return;
                      }
                    },
              style: kTextButtonDenseStyle,
              child: Text('${S.current.general_export} JSON'),
            ),
          ],
        ),
        if (questPhase == null)
          Text(
            S.current.battle_no_quest_phase,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: QuestCard(
              key: Key('quest_phase_${questPhase.hashCode}'),
              region: questRegion,
              offline: false,
              quest: questPhase,
              displayPhases: [questPhase!.phase],
              battleOnly: true,
              preferredPhases: [questPhase!],
            ),
          )
      ],
    );
  }

  Widget partyOption() {
    final jpTime = DateTime.fromMillisecondsSinceEpoch((questPhase?.jpOpenAt ?? DateTime.now().timestamp) * 1000);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        DropdownButton<Region>(
          isDense: true,
          value: settings.playerRegion,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "${Region.jp.localName}${jpTime.toDateString('')}"),
                ]),
                textScaleFactor: 0.8,
              ),
            ),
            for (final r in Region.values)
              DropdownMenuItem(
                value: r,
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '${S.current.strength_status}:',
                      style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    TextSpan(text: r.localName),
                  ]),
                  textScaleFactor: 0.9,
                ),
              ),
          ],
          onChanged: (v) {
            SimpleCancelOkDialog(
              title: Text(S.current.update),
              content: Text('${S.current.skill_rankup}/${S.current.td_rankup}?'),
              cancelText: "NO",
              confirmText: "YES",
              onTapCancel: () {
                settings.playerRegion = v;
                if (mounted) setState(() {});
              },
              onTapOk: () {
                settings.playerRegion = v;
                for (final svt in options.team.allSvts) {
                  svt.updateRankUps(region: v, jpTime: questPhase?.jpOpenAt);
                }
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
        ),
        TextButton(
          onPressed: () {
            router.pushPage(const PlayerSvtDefaultLvEditPage());
          },
          child: Text(S.current.default_lvs),
        ),
        DropdownButton<PreferPlayerSvtDataSource>(
          isDense: true,
          value: settings.playerDataSource,
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
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '${S.current.player_data}:',
                    style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  TextSpan(text: text),
                ]),
                textScaleFactor: 0.9,
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              if (v != null) settings.playerDataSource = v;
            });
          },
        ),
      ],
    );
  }

  Widget buildMysticCode() {
    final mcData = options.team.mysticCodeData;
    Widget mcIcon = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mcData.mysticCode?.iconBuilder(context: context, width: 48, jumpToDetail: false) ??
            db.getIconImage(null, width: 48),
        if (mcData.mysticCode != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final skill in mcData.mysticCode!.skills)
                db.getIconImage(
                  mcData.enabled ? skill.icon : Atlas.common.emptySkillIcon,
                  width: 24,
                  aspectRatio: 1,
                  padding: const EdgeInsets.all(1),
                ),
            ],
          ),
      ],
    );
    if (mcData.level == 0) {
      mcIcon = Opacity(opacity: 0.7, child: mcIcon);
    }
    mcIcon = InkWell(
      onTap: () {
        router.pushPage(
          MysticCodeListPage(
            onSelected: (selectedMC) {
              mcData.mysticCode = selectedMC;
              mcData.level = settings.playerDataSource.isNone ? 10 : db.curUser.mysticCodes[selectedMC.id] ?? 10;
              if (mounted) setState(() {});
            },
          ),
          detail: true,
        );
      },
      child: SizedBox(width: 88, child: mcIcon),
    );
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        mcIcon,
        Flexible(
          child: SliderWithTitle(
            leadingText: mcData.mysticCode?.lName.l ?? S.current.mystic_code,
            min: 0,
            max: 10,
            value: options.team.mysticCodeData.level,
            label: mcData.level == 0 ? S.current.disabled : 'Lv.${mcData.level}',
            onChange: (v) {
              mcData.level = v.round();
              if (mounted) setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget buildMisc() {
    List<Widget> children = [
      SliderWithTitle(
        leadingText: S.current.battle_probability_threshold,
        min: 0,
        max: 10,
        value: options.probabilityThreshold ~/ 100,
        label: '${options.probabilityThreshold ~/ 10} %',
        onChange: (v) {
          options.probabilityThreshold = v.round() * 100;
          if (mounted) setState(() {});
        },
        padding: const EdgeInsetsDirectional.only(top: 8, start: 8),
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.disableEvent,
        title: Text(S.current.disable_event_effects),
        onChanged: (v) {
          setState(() {
            options.disableEvent = v ?? options.disableEvent;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.simulateAi,
        title: Text(S.current.simulate_simple_ai),
        onChanged: (v) {
          setState(() {
            options.simulateAi = v ?? options.simulateAi;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.simulateEnemy,
        title: Text(S.current.simulate_enemy_actions),
        onChanged: (v) {
          setState(() {
            options.simulateEnemy = v ?? options.simulateEnemy;
          });
        },
      ),
      kIndentDivider,
      ...buildPointBuffs(),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  List<Widget> buildPointBuffs() {
    List<Widget> rows = [];
    final event = questPhase?.war?.event;
    if (event == null) return rows;
    final pointGroups = {for (final group in event.pointGroups) group.groupId: group};
    Map<int, List<EventPointBuff>> grouped = {};
    for (final buff in event.pointBuffs) {
      grouped.putIfAbsent(buff.groupId, () => []).add(buff);
    }
    for (final buffs in grouped.values) {
      buffs.sort2((e) => e.eventPoint);
    }
    final groupIds = grouped.keys.toList();
    final skillNumMap = ConstData.eventPointBuffGroupSkillNumMap[event.id];
    if (skillNumMap != null) {
      groupIds.sort2((groupId) => skillNumMap[groupId] ?? groupId);
    } else {
      groupIds.sort();
    }
    for (final groupId in groupIds) {
      final groupDetail = pointGroups[groupId];
      final buffs = grouped[groupId]!;
      final cur = options.pointBuffs[groupId];
      if (!buffs.contains(cur)) {
        options.pointBuffs.remove(groupId);
      }
      String? icon = groupDetail?.icon;
      icon ??= buffs.firstOrNull?.icon;

      rows.add(ListTile(
        dense: true,
        leading: icon == null ? null : db.getIconImage(icon, width: 24, aspectRatio: 1),
        horizontalTitleGap: 0,
        title: Text(Transl.itemNames(groupDetail?.name ?? S.current.event_point).l),
        trailing: DropdownButton<EventPointBuff?>(
          isDense: true,
          value: options.pointBuffs[groupId],
          hint: Text(S.current.event_bonus, textScaleFactor: 0.8),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                S.current.disable,
                textScaleFactor: 0.8,
              ),
            ),
            ...buffs.map((buff) {
              String bonus;
              if (buff.value == 0 && buff.lv != 0) {
                bonus = 'Lv.${buff.lv}';
              } else {
                bonus = '+${buff.value.format(base: 10, percent: true)}';
              }
              return DropdownMenuItem(
                value: buff,
                child: Text.rich(
                  TextSpan(children: [
                    if (buff.skillIcon != null)
                      CenterWidgetSpan(
                        child: db.getIconImage(buff.skillIcon,
                            width: 18, height: 18, padding: const EdgeInsetsDirectional.only(end: 4)),
                      ),
                    TextSpan(text: '$bonus(${buff.eventPoint})'),
                  ]),
                  textScaleFactor: 0.8,
                ),
              );
            })
          ],
          onChanged: options.disableEvent
              ? null
              : (v) {
                  setState(() {
                    if (v == null) {
                      options.pointBuffs.remove(groupId);
                    } else {
                      options.pointBuffs[groupId] = v;
                    }
                  });
                },
        ),
      ));
    }
    if (rows.isNotEmpty) {
      rows.add(kIndentDivider);
    }
    return rows;
  }

  Widget buttonBar() {
    Widget child = Wrap(
      spacing: 4,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 90),
          child: Text(' COST: ${options.team.totalCost} ', textAlign: TextAlign.center),
        ),
        FilledButton.icon(
          onPressed: errorMsg != null
              ? null
              : () {
                  QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
                  _startSimulation();
                },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(S.current.start),
        ),
      ],
    );
    if (errorMsg?.isNotEmpty == true) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMsg ?? "",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
          child,
        ],
      );
    }
    return child;
  }

  ///

  void importShareData(Uri uri) async {
    if (!uri.path.startsWith('/laplace/share')) {
      EasyLoading.showError("Invalid url, should be https://chaldea.center/laplace/share?xxxxx");
      print(uri.path);
      return;
    }
    BattleShareData? data;
    BattleQuestInfo? questInfo;
    if (uri.queryParameters.containsKey('data')) {
      data = BattleShareData.parseUri(uri);
    } else {
      final recordId = int.tryParse(uri.queryParameters['id'] ?? "");
      if (recordId != null && recordId > 0) {
        final encoded = await showEasyLoading(() => ChaldeaWorkerApi.laplaceQueryById(recordId));
        if (encoded != null) {
          data = encoded.parse();
          questInfo = encoded.questInfo;
        }
      }
    }
    questInfo ??= BattleQuestInfo.fromQuery(uri.queryParameters);
    if (data == null) {
      EasyLoading.showError('Invalid data or id');
      return;
    }

    final minBuild = data.minBuild;
    if (minBuild != null && minBuild > AppInfo.buildNumber) {
      EasyLoading.showError(S.current.error_required_app_version('Build $minBuild'));
      return;
    }
    restoreFormation(data.team);
    questInfo = data.quest ?? questInfo;
    if (questInfo != null) {
      questIdTextController.text = questInfo.toUrl();
      await _fetchQuestPhase(
        questId: questInfo.id,
        phase: questInfo.phase,
        enemyHash: questInfo.hash,
        region: questInfo.region ?? Region.jp,
      );
    }
    options.fromShareData(data.option);

    if (questInfo != null && data.actions != null && mounted) {
      EasyLoading.dismiss();
      SimpleCancelOkDialog(
        title: Text(S.current.success),
        content: const Text("Replay Simulation/重现操作?"),
        onTapOk: () {
          replaySimulation(detail: data!, questInfo: questInfo);
        },
      ).showDialog(context);
    } else {
      EasyLoading.showSuccess(S.current.import_data_success);
    }
    if (mounted) setState(() {});
  }

  Future<void> _parseQuestPhase() async {
    questErrorMsg = null;
    final text = questIdTextController.text.trim();
    // quest id and phase
    final match = RegExp(r'(\d+)(?:/(\d+))?').firstMatch(text);
    if (match == null) {
      questErrorMsg = S.current.invalid_input;
      return;
    }
    final questId = int.parse(match.group(1)!);
    int? phase = int.tryParse(match.group(2) ?? "");
    // region
    final regionText = RegExp(r'(JP|NA|CN|TW|KR)/').firstMatch(text)?.group(1);
    Region region = questRegion ??= const RegionConverter().fromJson(regionText ?? "");
    if (region != Region.jp && region != Region.na) {
      region = Region.jp;
    }
    // hash
    final enemyHash = RegExp(r'\?hash=([0-9a-zA-Z_\-]{14})$').firstMatch(text)?.group(1);

    return _fetchQuestPhase(questId: questId, phase: phase, enemyHash: enemyHash, region: region);
  }

  Future<void> _fetchQuestPhase({
    required int questId,
    required int? phase,
    required String? enemyHash,
    required Region region,
  }) async {
    Quest? quest;
    if (region == Region.jp) quest = db.gameData.quests[questId];
    quest ??= await AtlasApi.quest(questId, region: region);
    if (quest == null) {
      questErrorMsg = '${S.current.not_found}: $questId';
      return;
    }
    if (phase == null || !quest.phases.contains(phase)) {
      // event quests released in the next day usually have no valid phase data
      phase = (quest.isAnyFree ? quest.phases.lastOrNull : quest.phases.firstOrNull) ?? 1;
    }
    questPhase = await AtlasApi.questPhase(questId, phase, hash: enemyHash, region: region);
    if (questPhase == null) {
      questErrorMsg = '${S.current.not_found}: /${region.upper}/quest/$questId/$phase';
      if (enemyHash != null) questErrorMsg = '${questErrorMsg!}?hash=$enemyHash';
    }
    if (mounted) setState(() {});
  }

  void _questSelectCallback(final QuestPhase selected) {
    questPhase = selected;
    if (!mounted) return;
    final curRoute = ModalRoute.of(context);
    if (curRoute != null) {
      Navigator.popUntil(context, (route) => route == curRoute);
    }
    questErrorMsg = null;
    settings.previousQuestPhase = '${selected.id}/${selected.phase}';
    if (mounted) {
      questIdTextController.text = settings.previousQuestPhase!;
      setState(() {});
    }
  }

  bool checkPreviewReady() {
    if (questPhase == null || questPhase!.allEnemies.isEmpty) {
      errorMsg = S.current.battle_no_quest_phase;
      return false;
    }
    if (onFieldSvts.every((setting) => setting.svt == null) && backupSvts.every((setting) => setting.svt == null)) {
      errorMsg = S.current.battle_no_servant;
      return false;
    }

    errorMsg = null;
    return true;
  }

  void _startSimulation() {
    // pre-check
    final war = questPhase?.war;
    final event = war?.event;

    if (war != null && !war.isMainStory && event != null && event.startedAt < DateTime(2022, 7, 31).timestamp) {
      options.isAfter7thAnni = false;
    } else {
      options.isAfter7thAnni = true;
    }

    final questCopy = QuestPhase.fromJson(questPhase!.toJson());
    if (options.disableEvent) {
      questCopy.warId = 0;
      questCopy.individuality.removeWhere((e) => e.isEventField);
    }

    options.pointBuffs.removeWhere((key, pointBuff) {
      return options.disableEvent || event?.pointBuffs.contains(pointBuff) != true;
    });

    //
    settings.previousQuestPhase = '${questCopy.id}/${questCopy.phase}';
    saveFormation();
    router.push(
      url: Routes.laplaceBattle,
      child: BattleSimulationPage(
        questPhase: questCopy,
        region: questRegion,
        options: options,
      ),
    );
  }

  /// Formation part

  Future<void> initFormation() async {
    EasyLoading.show();
    try {
      await restoreFormation(settings.curFormation);
    } finally {
      EasyLoading.dismiss();
      if (mounted) setState(() {});
    }
  }

  Future<void> restoreFormation(BattleTeamFormation formation) async {
    for (int index = 0; index < 3; index++) {
      onFieldSvts[index] = await PlayerSvtData.fromStoredData(formation.onFieldSvts.getOrNull(index));
      backupSvts[index] = await PlayerSvtData.fromStoredData(formation.backupSvts.getOrNull(index));
    }

    options.team.mysticCodeData.loadStoredData(formation.mysticCode);
  }

  void saveFormation() {
    final curFormation = settings.curFormation;
    curFormation.onFieldSvts = onFieldSvts.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.backupSvts = backupSvts.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.mysticCode = options.team.mysticCodeData.toStoredData();
  }
}

bool isEnemy7Knights(QuestEnemy enemy) {
  if (!enemy.traits.any((e) => e.signedId == Trait.servant.id)) return false;
  return enemy.traits.any((e) => _k7KnigntsTraits.contains(e.name));
}

const _k7KnigntsTraits = [
  Trait.classSaber,
  Trait.classArcher,
  Trait.classLancer,
  Trait.classRider,
  Trait.classCaster,
  Trait.classAssassin,
  Trait.classBerserker
];
