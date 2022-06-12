import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestDetailPage extends StatefulWidget {
  final int? id;
  final Quest? quest;
  final Region? region;
  const QuestDetailPage({Key? key, this.id, this.quest, this.region})
      : super(key: key);

  @override
  State<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends State<QuestDetailPage> {
  Quest get quest => _quest!;
  Quest? _quest;
  int? questId;
  bool _loading = false;
  late Region region;

  @override
  void initState() {
    super.initState();
    region = _resolveDefaultRegion();
    _quest = widget.quest ??
        (region == Region.jp ? db.gameData.quests[widget.id] : null);
    questId = _quest?.id ?? widget.id;
    _resolveQuest();
  }

  Region _resolveDefaultRegion() {
    final fixedRegion = db.settings.preferredQuestRegion;
    if (widget.region != null) return widget.region!;
    if (fixedRegion == null || fixedRegion == Region.jp) {
      return Region.jp;
    }
    final jpQuest = db.gameData.quests[widget.quest?.id ?? widget.id];
    if (jpQuest == null) return Region.jp;
    final eventId = db.gameData.wars[jpQuest.warId]?.eventId;
    if (eventId == null) return Region.jp;
    final event = db.gameData.events[eventId];
    if (event == null) return Region.jp;
    print([event.extra.startTime.values]);
    if (event.extra.startTime.ofRegion(fixedRegion) != null) {
      print(event.extra.startTime.ofRegion(fixedRegion));
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
        title: AutoSizeText(_quest?.lName.l ?? 'Quest $questId',
            maxLines: 1, minFontSize: 12),
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
                    style: TextStyle(
                        color: SharedBuilder.appBarForeground(context)),
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
          PopupMenuButton(
            itemBuilder: (context) => [
              ...SharedBuilder.websitesPopupMenuItems(
                atlas: _quest == null
                    ? null
                    : Atlas.dbQuest(_quest!.id, null, region),
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
                ),
                SFooter(S.current.quest_region_has_enemy_hint),
              ],
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
}
