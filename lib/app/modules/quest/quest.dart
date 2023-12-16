import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../battle/teams/teams_query_page.dart';
import '../common/filter_group.dart';
import '../mc/mc_quest.dart';

class QuestDetailPage extends StatefulWidget {
  final int? id;
  final int? phase;
  final String? enemyHash;
  final Quest? quest;
  final Region? region;
  final QuestPhase? questPhase;
  const QuestDetailPage({super.key, this.id, this.phase, this.enemyHash, this.quest, this.region}) : questPhase = null;
  QuestDetailPage.phase({super.key, required QuestPhase this.questPhase})
      : region = null,
        id = questPhase.id,
        phase = questPhase.phase,
        enemyHash = null,
        quest = questPhase;

  @override
  State<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends State<QuestDetailPage> {
  Quest get quest => _quest!;
  Quest? _quest;
  int? questId;
  bool _loading = false;
  late Region region;
  Key uniqueKey = UniqueKey();
  int phase = 0;
  (int phase, String? enemyHash)? initHash;

  @override
  void initState() {
    super.initState();
    region = _resolveDefaultRegion();
    _quest = widget.quest ?? (region == Region.jp ? db.gameData.quests[widget.id] : null);
    questId = _quest?.id ?? widget.id;
    if (_quest != null) {
      if (widget.phase != null && _quest!.phases.contains(widget.phase)) {
        phase = widget.phase!;
        if (phase > 0) initHash = (phase, widget.enemyHash);
      } else if (_quest!.isAnyFree && _quest!.phases.isNotEmpty) {
        phase = _quest!.phases.last;
      }
    }
    _resolveQuest();
  }

  Region _resolveDefaultRegion() {
    if (widget.region != null) return widget.region!;
    final fixedRegion = db.settings.preferredQuestRegion;
    if (fixedRegion == null || fixedRegion == Region.jp) {
      return Region.jp;
    }
    final jpQuest = db.gameData.quests[widget.quest?.id ?? widget.id];
    final released = db.gameData.mappingData.warRelease.ofRegion(fixedRegion)?.contains(jpQuest?.warId);
    if (released == true) {
      return fixedRegion;
    }
    return Region.jp;
  }

  Future<void> _resolveQuest() async {
    if (_quest == null && questId != null) {
      _loading = true;
      if (mounted) setState(() {});
      _quest = widget.questPhase ?? await AtlasApi.quest(questId!, region: region);
      _loading = false;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(_quest?.lNameWithChapter ?? 'Quest $questId', maxLines: 1, minFontSize: 12),
        actions: [
          if (widget.questPhase == null)
            DropdownButton<Region>(
              value: region,
              items: [
                for (final region in Region.values)
                  DropdownMenuItem(
                    value: region,
                    child: Text(region.localName),
                  ),
              ],
              icon: Icon(
                Icons.arrow_drop_down,
                color: SharedBuilder.appBarForeground(context),
              ),
              selectedItemBuilder: (context) => [
                for (final region in Region.values)
                  DropdownMenuItem(
                    child: Text(
                      region.localName,
                      style: TextStyle(color: SharedBuilder.appBarForeground(context)),
                    ),
                  )
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) {
                    region = v;
                    _quest = null;
                    _resolveQuest();
                    setState(() {});
                  }
                });
              },
              underline: const SizedBox(),
            ),
          PopupMenuButton<dynamic>(
            itemBuilder: (context) {
              String? mcLink;
              if (_quest != null && (_quest!.type == QuestType.friendship || _quest!.warId == WarId.rankup)) {
                final svt =
                    db.gameData.servantsById.values.firstWhereOrNull((e) => e.relateQuestIds.contains(_quest!.id));
                mcLink = svt?.extra.mcLink;
                if (mcLink != null) mcLink += '/从者任务';
              }
              return [
                PopupMenuItem(
                  enabled: false,
                  height: 32,
                  child: Text('No.$questId', textScaler: const TextScaler.linear(0.9)),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  enabled: widget.questPhase == null,
                  onTap: () {
                    final key = '/quest/$questId/';
                    AtlasApi.cachedQuestPhases.removeWhere((key, value) => key.contains(key));
                    AtlasApi.cacheManager.removeWhere((info) => info.url.contains(key));
                    if (questId != null) AtlasApi.cacheDisabledQuests.add(questId!);
                    uniqueKey = UniqueKey();
                    if (mounted) setState(() {});
                  },
                  child: Text(S.current.refresh),
                ),
                ...SharedBuilder.websitesPopupMenuItems(
                  atlas: _quest == null
                      ? null
                      : Atlas.dbQuest(
                          _quest!.id,
                          _quest!.phases.contains(phase) ? phase : _quest!.phases.firstOrNull,
                          region,
                        ),
                  mooncell: mcLink,
                ),
                PopupMenuItem(
                  onTap: _showFixRegionDialog,
                  child: Text(S.current.quest_prefer_region),
                ),
                if (region == Region.jp && Language.isZH) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: _quest == null
                        ? null
                        : () {
                            router.pushPage(MCQuestEditPage(quest: _quest!));
                          },
                    child: const Text("导出至Mooncell"),
                  ),
                ],
              ];
            },
          )
        ],
      ),
      body: _quest == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(S.current.quest_not_found_error(region.localName)),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (quest.phases.length > 1 && widget.questPhase == null)
                  Center(
                    child: FilterGroup<int>(
                      combined: true,
                      options: [0, ...quest.phases],
                      values: FilterRadioData.nonnull(phase),
                      padding: EdgeInsets.zero,
                      optionBuilder: (v) => Text(v == 0 ? '※' : v.toString()),
                      onFilterChanged: (v, _) {
                        setState(() {
                          phase = v.radioValue!;
                        });
                      },
                    ),
                  ),
                if (widget.questPhase != null)
                  QuestCard(
                    quest: quest,
                    region: null,
                    offline: false,
                    // key: uniqueKey,
                    displayPhases: {widget.questPhase!.phase: null},
                    preferredPhases: [widget.questPhase!],
                  )
                else
                  QuestCard(
                    quest: quest,
                    region: region,
                    offline: false,
                    key: uniqueKey,
                    displayPhases:
                        quest.phases.contains(phase) ? {phase: initHash?.$1 == phase ? widget.enemyHash : null} : null,
                  ),
                if (quest.isLaplaceSharable) sharedTeamsButton,
                if (db.gameData.dropData.domusAurea.questIds.contains(quest.id)) blacklistButton,
                SFooter(S.current.quest_region_has_enemy_hint),
                ...getCampaigns(),
                const SafeArea(child: SizedBox())
              ],
            ),
    );
  }

  Widget get sharedTeamsButton {
    return TextButton.icon(
      onPressed: () {
        router.pushPage(
          TeamsQueryPage(
            mode: TeamQueryMode.quest,
            quest: quest,
            phaseInfo: BattleQuestInfo(id: quest.id, phase: quest.phases.last, enemyHash: null),
          ),
        );
      },
      icon: const Icon(Icons.search),
      label: Text(
        S.current.team_shared,
        // style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Widget get blacklistButton {
    if (db.curUser.freeLPParams.blacklist.contains(quest.id)) {
      return TextButton.icon(
        onPressed: () {
          setState(() {
            db.curUser.freeLPParams.blacklist.remove(quest.id);
          });
        },
        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
        label: Text(
          S.current.remove_from_blacklist,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      );
    }

    return TextButton.icon(
      onPressed: () {
        setState(() {
          db.curUser.freeLPParams.blacklist.add(quest.id);
        });
      },
      icon: const Icon(Icons.add, color: Colors.redAccent),
      label: Text(
        S.current.add_to_blacklist,
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  void _showFixRegionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.quest_prefer_region),
          children: [
            ListTile(
              title: Text(S.current.general_default),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              selected: db.settings.preferredQuestRegion == null,
              onTap: () {
                Navigator.pop(context);
                db.settings.preferredQuestRegion = null;
              },
            ),
            for (final region in Region.values)
              ListTile(
                title: Text(region.localName),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                selected: db.settings.preferredQuestRegion == region,
                onTap: () {
                  Navigator.pop(context);
                  db.settings.preferredQuestRegion = region;
                },
              ),
            SFooter(S.current.quest_prefer_region_hint)
          ],
        );
      },
    );
  }

  bool _showAllCampaign = false;
  List<Widget> getCampaigns() {
    List<Widget> children = [];
    final events = db.gameData.events.values
        .where((e) =>
            e.campaignQuests.any((q) => q.questId == quest.id) ||
            e.campaigns.any((c) => c.targetIds.contains(quest.id)))
        .toList();
    if (events.isEmpty) return const [];
    if (!_showAllCampaign) {
      events.removeWhere((e) => e.isOutdated());
    }
    events.sort2((e) => -e.startedAt);
    for (final event in events) {
      if (_showAllCampaign || !event.isOutdated()) {
        List<String> times = [];
        for (final r in <Region>{Region.jp, db.curUser.region, region}) {
          final start = r == Region.jp ? event.startedAt : event.extra.startTime.ofRegion(r);
          if (start == null) continue;
          times.add('${r.upper}: ${start.sec2date().toDateString()}');
        }
        children.add(ListTile(
          dense: true,
          title: Text(event.lName.l),
          subtitle: Text(times.join(' / ')),
          onTap: event.routeTo,
        ));
      }
    }

    children.add(Center(
      child: IconButton(
        onPressed: () {
          setState(() {
            _showAllCampaign = !_showAllCampaign;
          });
        },
        icon: Icon(_showAllCampaign ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
      ),
    ));
    if (children.isEmpty) {
      children.add(const ListTile(
        title: Text('No future event'),
        dense: true,
      ));
    }
    return [
      TileGroup(
        header: S.current.event_campaign,
        children: children,
      )
    ];
  }
}
