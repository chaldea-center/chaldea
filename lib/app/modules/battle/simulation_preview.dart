import 'dart:convert';
import 'dart:math';

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
import 'package:chaldea/app/modules/bond/bond_bonus.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../bond/formation_bond.dart';
import '../quest/breakdown/quest_phase.dart';
import '../quest/quest.dart';
import 'formation/default_lvs.dart';
import 'formation/formation_card.dart';
import 'formation/formation_storage.dart';
import 'formation/quest_selector.dart';
import 'formation/team.dart';
import 'quest/quest_edit.dart';
import 'utils.dart';

class SimulationPreview extends StatefulWidget {
  final Region? region;
  final QuestPhase? questPhase;
  final Uri? shareUri;

  const SimulationPreview({super.key, this.region, this.questPhase, this.shareUri});

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
      options.mightyChain = v.shouldEnableMightyChain();
    }
  }

  String? questErrorMsg;
  String? errorMsg;

  TextEditingController questIdTextController = TextEditingController();

  final BattleOptions options = BattleOptions();
  BattleSimSetting get settings => db.settings.battleSim;

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
    children.add(
      Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              options.formation.updateSvts([]);
              saveFormation();
              if (mounted) setState(() {});
            },
            child: Text(S.current.clear, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          TextButton(
            onPressed: () async {
              final team = saveFormation();
              await router.pushPage(
                FormationEditor(
                  teamToSave: team.formation.allCardIds.isEmpty ? null : team,
                  onSelected: restoreFormation,
                ),
              );
              if (mounted) setState(() {});
            },
            child: Text(S.current.team_local),
          ),
          TextButton(
            onPressed: questPhase == null ? null : () => onTapSharedTeams(questPhase!),
            style: TextButton.styleFrom(foregroundColor: AppTheme(context).tertiary),
            child: Text(S.current.team_shared),
          ),
          TextButton(
            onPressed: () {
              router.pushPage(
                BondBonusHomePage(
                  option: FormationBondOption(formation: options.formation.copy(), quest: questPhase),
                ),
              );
            },
            child: Text(S.current.bond),
          ),
        ],
      ),
    );
    children.add(
      TeamSetupCard(
        formation: options.formation,
        quest: questPhase,
        playerRegion: settings.playerRegion,
        onChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
    children.add(
      DividerWithTitle(
        titleWidget: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: S.current.mystic_code,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SharedBuilder.textButtonSpan(
                context: context,
                text: ' ${S.current.disable} ',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                onTap: () {
                  setState(() {
                    options.formation.mysticCodeData.level = 0;
                    options.formation.mysticCodeData.mysticCode = null;
                  });
                },
              ),
            ],
          ),
        ),
        thickness: 2,
        padding: const EdgeInsets.only(top: 8),
      ),
    );
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
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: max(0, constraints.maxWidth - 640) / 2),
                  children: children,
                );
              },
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), child: buttonBar()),
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
          if (settings.curTeam.formation.allCardIds.isEmpty) {
            EasyLoading.showError("No servant in team");
            return;
          }
          BattleQuestInfo? questInfo;
          if (_questPhase != null && _questPhase!.id > 0) {
            questInfo = BattleQuestInfo.quest(_questPhase!, region: questRegion);
          }
          final shareUri = BattleShareData(
            appBuild: AppInfo.buildNumber,
            quest: questInfo,
            options: options.toShareData(),
            formation: settings.curTeam.formation,
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
        onTap: () {
          InputCancelOkDialog.number(
            title: 'Laplace Team ID',
            validate: (v) => v > 0,
            onSubmit: (id) async {
              if (id <= 0) {
                EasyLoading.showError("Invalid ID");
                return;
              }
              importShareData(Uri.parse('https://chaldea.center/laplace/share?id=$id'));
            },
          ).showDialog(context);
        },
        child: const Text('Laplace Team ID'),
      ),
    ];

    return children;
  }

  Widget header(String title) {
    return DividerWithTitle(
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
              subtitle: Text.rich(
                TextSpan(
                  text: '${S.current.event}→${S.current.war}→${S.current.quest}→',
                  children: [
                    CenterWidgetSpan(
                      child: Icon(Icons.calculate, size: 14, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
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
                        DropdownMenuItem(
                          value: r,
                          child: Text(r.localName, textScaler: const TextScaler.linear(0.9)),
                        ),
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
                  ChaldeaUrl.laplaceHelpBtn('faq#atlas-db-url'),
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
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                      clearCache: true,
                    );
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
    final sameQuestIds = ConstData.getSimilarQuestIds(questPhase?.id ?? 0);
    List<TextSpan> hints = [
      if (questPhase != null && questPhase!.enemyHashes.length > 1)
        TextSpan(text: S.current.laplace_enemy_multi_ver_hint),
      if (sameQuestIds.isNotEmpty)
        TextSpan(
          text: '${S.current.quest_content_same_warning}: ',
          children: [
            for (final questId in sameQuestIds)
              SharedBuilder.textButtonSpan(
                context: context,
                text: '$questId ',
                onTap: () => router.push(url: Routes.questI(questId)),
              ),
          ],
        ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (questErrorMsg != null)
          SFooter.rich(
            TextSpan(
              text: questErrorMsg,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        // kDefaultDivider,
        Wrap(
          children: [
            TextButton(
              onPressed: () {
                router.pushPage(
                  QuestEditPage(
                    quest: questPhase,
                    onComplete: (q) {
                      q.id = -q.id.abs();
                      questPhase = q;
                      if (mounted) setState(() {});
                    },
                  ),
                );
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
              child: Text(S.current.details),
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: questPhase == null
              ? Card(
                  child: SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: Center(child: Text(S.current.battle_no_quest_phase)),
                  ),
                )
              : QuestCard(
                  key: Key('quest_phase_${questPhase.hashCode}'),
                  region: questRegion,
                  offline: false,
                  quest: questPhase,
                  displayPhases: {questPhase!.phase: questPhase?.enemyHashOrTotal},
                  battleOnly: true,
                  preferredPhases: [questPhase!],
                ),
        ),
        if (hints.isNotEmpty)
          SFooter.rich(
            TextSpan(
              children: [
                for (final (index, hint) in hints.indexed)
                  TextSpan(
                    text: '${index == 0 ? "" : "\n"}${index + 1}. ',
                    children: [
                      TextSpan(
                        children: [hint],
                        style: TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
              ],
            ),
          ),
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
                TextSpan(children: [TextSpan(text: "${Region.jp.localName}${jpTime.toDateString('')}")]),
                textScaler: const TextScaler.linear(0.8),
              ),
            ),
            for (final r in Region.values)
              DropdownMenuItem(
                value: r,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${S.current.strength_status}:',
                        style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      TextSpan(text: r.localName),
                    ],
                  ),
                  textScaler: const TextScaler.linear(0.9),
                ),
              ),
          ],
          onChanged: (v) {
            SimpleConfirmDialog(
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
                for (final svt in options.formation.svts) {
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
          items: [
            for (final source in PreferPlayerSvtDataSource.values)
              DropdownMenuItem(
                value: source,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${S.current.player_data}:',
                        style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      TextSpan(text: source.shownName),
                    ],
                  ),
                  textScaler: const TextScaler.linear(0.9),
                ),
              ),
          ],
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
    final mcData = options.formation.mysticCodeData;
    final enabled = mcData.enabled;
    final skills = mcData.mysticCode?.skills ?? [];
    final skillRow = max(1, skills.length ~/ 3);
    Widget mcIcon = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mcData.mysticCode?.iconBuilder(context: context, height: 48, jumpToDetail: false) ??
            db.getIconImage(null, height: 48),
        for (int row = 0; row < skillRow; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final skill = mcData.mysticCode?.skills.getOrNull(row * 3 + index);
              if (skill != null && enabled) {
                return db.getIconImage(skill.icon, width: 24, aspectRatio: 1, padding: const EdgeInsets.all(1));
              } else {
                return db.getIconImage(
                  Atlas.common.emptySkillIcon,
                  width: 24,
                  aspectRatio: 1,
                  padding: const EdgeInsets.all(1),
                );
              }
            }),
          ),
      ],
    );
    if (!enabled) {
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
          child: SliderWithPrefix(
            titled: true,
            label: enabled ? mcData.mysticCode?.lName.l ?? S.current.mystic_code : S.current.mystic_code,
            min: 0,
            max: 10,
            value: mcData.level,
            valueFormatter: (v) => enabled ? 'Lv.$v' : S.current.disabled,
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
      SliderWithPrefix(
        titled: true,
        label: S.current.battle_probability_threshold,
        min: 0,
        max: 1000,
        value: options.threshold,
        valueFormatter: (v) => v.format(percent: true, base: 10),
        onEdit: (v) {
          options.threshold = v.round().clamp(0, 1000);
          if (mounted) setState(() {});
        },
        onChange: (v) {
          final v2 = (v.round() ~/ 100 * 100).clamp(0, 1000);
          if (v2 != options.threshold) {
            options.threshold = v2;
            if (mounted) setState(() {});
          }
        },
        padding: const EdgeInsetsDirectional.only(start: 16),
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
        value: options.simulateEnemy,
        title: Text(S.current.simulate_enemy_actions),
        onChanged: (v) {
          setState(() {
            options.simulateEnemy = v ?? options.simulateEnemy;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.simulateAi,
        title: Text(S.current.simulate_simple_ai),
        subtitle: Text("Only for ${S.current.raid_quest}"),
        onChanged: (v) {
          setState(() {
            options.simulateAi = v ?? options.simulateAi;
          });
        },
      ),
      kIndentDivider,
      CheckboxListTile(
        dense: true,
        value: options.mightyChain,
        title: Text('${S.current.battle_after_7th} (QAB Chain)'),
        onChanged: (v) {
          setState(() {
            options.mightyChain = v ?? options.mightyChain;
          });
        },
      ),
      kIndentDivider,
      ...buildPointBuffs(),
      ...buildEnemyRateUp(),
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: children);
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

      rows.add(
        ListTile(
          dense: true,
          leading: icon == null ? null : db.getIconImage(icon, width: 24, aspectRatio: 1),
          minLeadingWidth: 24,
          title: Text(Transl.itemNames(groupDetail?.name ?? S.current.event_point).l),
          trailing: DropdownButton<EventPointBuff?>(
            isDense: true,
            value: options.pointBuffs[groupId],
            hint: Text(S.current.event_bonus, textScaler: const TextScaler.linear(0.8)),
            items: [
              DropdownMenuItem(value: null, child: Text(S.current.disable, textScaler: const TextScaler.linear(0.8))),
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
                    TextSpan(
                      children: [
                        if (buff.skillIcon != null)
                          CenterWidgetSpan(
                            child: db.getIconImage(
                              buff.skillIcon,
                              width: 18,
                              height: 18,
                              padding: const EdgeInsetsDirectional.only(end: 4),
                            ),
                          ),
                        TextSpan(text: '$bonus(${buff.eventPoint})'),
                      ],
                    ),
                    textScaler: const TextScaler.linear(0.8),
                  ),
                );
              }),
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
        ),
      );
    }
    if (rows.isNotEmpty) {
      rows.add(kIndentDivider);
    }
    return rows;
  }

  List<Widget> buildEnemyRateUp() {
    List<Widget> rows = [];
    final event = questPhase?.war?.event;
    if (event == null) {
      if (questPhase != null) options.enemyRateUp.clear();
      return rows;
    }
    Set<int> enemyIndivs = {};
    for (final ce in db.gameData.craftEssencesById.values) {
      for (final skill in ce.skills) {
        for (final func in skill.functions) {
          if (func.funcType != FuncType.enemyEncountCopyRateUp) continue;
          final vals = func.svals.firstOrNull;
          final indiv = vals?.Individuality ?? 0;
          if (vals?.EventId != event.id || indiv == 0) continue;
          enemyIndivs.add(indiv);
        }
      }
    }
    for (final indiv in enemyIndivs) {
      rows.add(
        SwitchListTile(
          dense: true,
          title: Text(Transl.traitName(indiv)),
          subtitle: Text('${Transl.funcType(FuncType.enemyEncountCopyRateUp).l}: 100%'),
          value: options.enemyRateUp.contains(indiv),
          onChanged: options.disableEvent
              ? null
              : (v) {
                  setState(() {
                    options.enemyRateUp.toggle(indiv);
                  });
                },
        ),
      );
    }
    options.enemyRateUp.removeWhere((e) => !enemyIndivs.contains(e));
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
          child: Text(' COST: ${options.formation.totalCost} ', textAlign: TextAlign.center),
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
    try {
      if (uri.queryParameters.containsKey('data')) {
        data = BattleShareData.parseUri(uri);
      } else {
        final teamId = int.tryParse(uri.queryParameters['id'] ?? "");
        if (teamId != null && teamId > 0) {
          final encoded = await showEasyLoading(() => ChaldeaWorkerApi.team(teamId));
          if (encoded != null) {
            data = encoded.parse();
            questInfo = encoded.questInfo;
          }
        }
      }
    } catch (e, s) {
      EasyLoading.showError('Parse data failed: $e');
      logger.e('parse shared team data failed', e, s);
      return;
    }
    questInfo ??= BattleQuestInfo.fromQuery(uri.queryParameters);
    if (questInfo != null) {
      questIdTextController.text = questInfo.toUrl();
      await _fetchQuestPhase(
        questId: questInfo.id,
        phase: questInfo.phase,
        enemyHash: questInfo.enemyHash,
        region: questInfo.region ?? Region.jp,
      );
    }

    if (questInfo == null) {
      EasyLoading.showError('Invalid data or id');
      return;
    }
    if (data == null) return;

    final minBuild = data.minBuild;
    if (minBuild != null && minBuild > AppInfo.buildNumber) {
      EasyLoading.showError(S.current.error_required_app_version('Build $minBuild', AppInfo.buildNumber));
      return;
    }
    restoreFormation(data);

    options.fromShareData(data.options);

    if (data.actions.isNotEmpty && mounted) {
      EasyLoading.dismiss();
      SimpleConfirmDialog(
        title: Text(S.current.success),
        content: const Text("Replay Simulation/重现操作?"),
        onTapOk: () {
          replaySimulation(detail: data!);
        },
      ).showDialog(context);
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
    quest ??= await showEasyLoading(() => AtlasApi.quest(questId, region: region));
    if (quest == null) {
      questErrorMsg = '${S.current.not_found}: $questId';
      return;
    }
    if (phase == null || !quest.phases.contains(phase)) {
      // event quests released in the next day usually have no valid phase data
      phase = (quest.isAnyFree ? quest.phases.lastOrNull : quest.phases.firstOrNull) ?? 1;
    }
    questPhase = await showEasyLoading(() => AtlasApi.questPhase(questId, phase ?? 1, hash: enemyHash, region: region));
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
    if (options.formation.svts.every((setting) => setting.svt == null)) {
      errorMsg = S.current.battle_no_servant;
      return false;
    }

    errorMsg = null;
    return true;
  }

  Future<void> _startSimulation() async {
    // pre-check
    if (!options.simulateAi && questPhase?.isLaplaceNeedAi == true) {
      final confirm = await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return SimpleConfirmDialog(
            title: Text(S.current.simulate_simple_ai),
            content: const Text("This quest is suggested to enable Simulate Simple AI.\nContinue with it disabled?"),
          );
        },
      );
      if (confirm != true) return;
    }

    final war = questPhase?.war;
    final event = war?.event;

    final questCopy = QuestPhase.fromJson(questPhase!.toJson());

    if (questCopy.extraDetail?.waveSetup == 1 && questCopy.stages.length > 1 && mounted) {
      final int? chosenWave = await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Wave Battle"),
            children: [
              SimpleDialogOption(
                child: Text('${S.current.general_all} ${S.current.quest_wave}'),
                onPressed: () {
                  Navigator.pop(context, -1);
                },
              ),
              for (int wave = 1; wave <= questCopy.stages.length; wave++)
                SimpleDialogOption(
                  child: Text('${S.current.quest_wave} $wave'),
                  onPressed: () {
                    Navigator.pop(context, wave);
                  },
                ),
            ],
          );
        },
      );
      if (chosenWave == null) return;
      if (chosenWave > 0 && chosenWave <= questCopy.stages.length) {
        final stage = questCopy.stages[chosenWave - 1];
        stage.wave = 1;
        questCopy.stages = [stage];
      }
    }

    if (options.disableEvent) {
      questCopy.warId = 0;
      questCopy.removeEventQuestIndividuality();
    }

    options.pointBuffs.removeWhere((key, pointBuff) {
      return options.disableEvent || event?.pointBuffs.contains(pointBuff) != true;
    });

    // check replay
    BattleShareData? replayActions;
    final replayTeamData = db.runtimeData.clipBoard.teamData;
    if (replayTeamData != null && replayTeamData.decoded != null && replayTeamData.questId == questCopy.id && mounted) {
      final needReplay = await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return SimpleConfirmDialog(
            title: const Text("Replay Actions?"),
            cancelText: "NO",
            confirmText: "YES",
            actions: [
              TextButton(
                onPressed: () {
                  db.runtimeData.clipBoard.teamData = null;
                  Navigator.pop(context, false);
                },
                child: Text("NO(${S.current.reset})"),
              ),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(['${S.current.team} ${replayTeamData.id} @${replayTeamData.username}'].join('\n')),
                IgnorePointer(child: FormationCard(formation: replayTeamData.decoded!.formation)),
              ],
            ),
          );
        },
      );
      if (needReplay == null) return;
      if (needReplay == true) replayActions = replayTeamData.decoded;
    }

    //
    settings.previousQuestPhase = '${questCopy.id}/${questCopy.phase}';
    saveFormation();
    router.push(
      url: Routes.laplaceBattle,
      child: BattleSimulationPage(
        questPhase: questCopy,
        region: questRegion,
        options: options,
        replayActions: replayActions,
      ),
    );
  }

  /// Formation part

  Future<void> initFormation() async {
    EasyLoading.show();
    try {
      await restoreFormation(settings.curTeam);
    } finally {
      EasyLoading.dismiss();
      if (mounted) setState(() {});
    }
  }

  Future<void> restoreFormation(BattleShareData team) async {
    final formation = team.formation;
    List<PlayerSvtData> svts = [];
    for (int index = 0; index < max(6, team.formation.svts.length); index++) {
      svts.add(await PlayerSvtData.fromStoredData(formation.svts.getOrNull(index)));
    }
    options.formation.svts
      ..clear()
      ..addAll(svts);
    options.fromShareData(team.options);
    options.formation.mysticCodeData.loadStoredData(formation.mysticCode);
  }

  BattleShareData saveFormation() {
    final team = settings.curTeam;
    final curFormation = team.formation;
    curFormation.svts = options.formation.svts.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.mysticCode = options.formation.mysticCodeData.toStoredData();
    final questInfo = questPhase == null ? null : BattleQuestInfo.quest(questPhase!);
    team.quest = questInfo;
    team.options = options.toShareData();

    return team;
  }

  void onTapSharedTeams(QuestPhase quest) async {
    if (!quest.isLaplaceSharable) {
      EasyLoading.showInfo(S.current.quest_disallow_laplace_share_hint);
      return;
    }
    bool? noEnemyHash = false;
    final versionCount = quest.enemyHashes.length;
    if (versionCount > 1) {
      final index = quest.enemyHashes.indexOf(quest.enemyHash ?? "");
      noEnemyHash = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        // barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text(S.current.version),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text('${S.current.general_all} $versionCount ${S.current.version}s'),
                onTap: () {
                  noEnemyHash = true;
                  Navigator.pop(context, true);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text('${S.current.current_} (No.${index + 1}/$versionCount)'),
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
              SFooter(S.current.laplace_enemy_multi_ver_hint),
            ],
          );
        },
      );
    }
    if (noEnemyHash == null) return;
    final phaseInfo = BattleQuestInfo.quest(quest);
    if (noEnemyHash == true) phaseInfo.enemyHash = null;
    router.pushPage(
      TeamsQueryPage(
        mode: TeamQueryMode.quest,
        quest: quest,
        phaseInfo: phaseInfo,
        onSelect: (data) {
          restoreFormation(data);
          if (mounted) setState(() {});
        },
      ),
    );
  }
}

bool isEnemy7Knights(QuestEnemy enemy) {
  if (!enemy.traits.any((e) => e == Trait.servant.value)) return false;
  return enemy.traits.any((e) => _k7KnigntsTraits.contains(e));
}

final _k7KnigntsTraits = [
  Trait.classSaber.value,
  Trait.classArcher.value,
  Trait.classLancer.value,
  Trait.classRider.value,
  Trait.classCaster.value,
  Trait.classAssassin.value,
  Trait.classBerserker.value,
];
