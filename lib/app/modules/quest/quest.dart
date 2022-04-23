import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/quest_card.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/atlas.dart';

class QuestDetailPage extends StatefulWidget {
  final int? id;
  final Quest? quest;
  final Region region;
  const QuestDetailPage(
      {Key? key, this.id, this.quest, this.region = Region.jp})
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
    region = widget.region;
    _quest = widget.quest ??
        (region == Region.jp ? db.gameData.quests[widget.id] : null);
    questId = _quest?.id ?? widget.id;
    _resolveQuest();
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
        title: Text(_quest?.lName.l ?? 'Quest $questId'),
        actions: [
          DropdownButton<Region>(
            value: region,
            items: [
              for (final region in Region.values)
                DropdownMenuItem(
                  value: region,
                  child: Text(region.toUpper()),
                ),
            ],
            selectedItemBuilder: (context) => [
              for (final region in Region.values)
                DropdownMenuItem(
                  child: Text(
                    region.toUpper(),
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
            itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
              atlas: _quest == null
                  ? null
                  : Atlas.dbQuest(_quest!.id, null, region),
            ),
          )
        ],
      ),
      body: _quest == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Not Found'),
            )
          : ListView(
              children: [
                QuestCard(
                  quest: quest,
                  region: region,
                  offline: false,
                )
              ],
            ),
    );
  }
}
