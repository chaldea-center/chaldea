import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestDetailPage extends StatefulWidget {
  final int? id;
  final Quest? quest;
  final Region? region;
  const QuestDetailPage({super.key, this.id, this.quest, this.region});

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

  @override
  void initState() {
    super.initState();
    region = _resolveDefaultRegion();
    _quest = widget.quest ?? (region == Region.jp ? db.gameData.quests[widget.id] : null);
    questId = _quest?.id ?? widget.id;
    _resolveQuest();
  }

  Region _resolveDefaultRegion() {
    if (widget.region != null) return widget.region!;
    final fixedRegion = db.settings.preferredQuestRegion;
    if (fixedRegion == null || fixedRegion == Region.jp) {
      return Region.jp;
    }
    // TODO: deal with chaldea gate wars
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
      _quest = await AtlasApi.quest(questId!, region: region);
      _loading = false;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(_quest?.lName.l ?? 'Quest $questId', maxLines: 1, minFontSize: 12),
        actions: [
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
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                height: 32,
                child: Text('No.$questId', textScaleFactor: 0.9),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () {
                  final key = '/quest/$questId/';
                  AtlasApi.cachedQuestPhases.removeWhere((key, value) => key.contains(key));
                  AtlasApi.cacheManager.removeWhere((info) => info.url.contains(key));
                  uniqueKey = UniqueKey();
                  if (mounted) setState(() {});
                },
                child: Text(S.current.refresh),
              ),
              ...SharedBuilder.websitesPopupMenuItems(
                atlas: _quest == null ? null : Atlas.dbQuest(_quest!.id, _quest!.phases.getOrNull(0), region),
              ),
              PopupMenuItem(
                onTap: _showFixRegionDialog,
                child: Text(S.current.quest_prefer_region),
              ),
            ],
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
              children: [
                QuestCard(
                  quest: quest,
                  region: region,
                  offline: false,
                  key: uniqueKey,
                ),
                if (db.gameData.dropRate.newData.questIds.contains(quest.id)) blacklistButton,
                SFooter(S.current.quest_region_has_enemy_hint),
                ...getCampaigns(),
                const SafeArea(child: SizedBox())
              ],
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

  void _showFixRegionDialog() async {
    await null;
    if (!mounted) return;
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
        });
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
