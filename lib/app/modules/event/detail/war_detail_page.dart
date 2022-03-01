import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';
import '../../common/not_found.dart';

class WarDetailPage extends StatefulWidget {
  final int? warId;
  final NiceWar? war;
  WarDetailPage({Key? key, this.warId, this.war}) : super(key: key);

  @override
  _WarDetailPageState createState() => _WarDetailPageState();
}

class _WarDetailPageState extends State<WarDetailPage> {
  NiceWar? _war;
  NiceWar get war => _war!;
  @override
  void initState() {
    super.initState();
    _war = widget.war ?? db2.gameData.wars[widget.warId];
  }

  @override
  void didUpdateWidget(covariant WarDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _war = widget.war ?? db2.gameData.wars[widget.warId];
  }

  @override
  Widget build(BuildContext context) {
    if (_war == null) {
      return NotFoundPage(
        title: 'War ${widget.warId}',
        url: Routes.warI(widget.warId ?? 0),
      );
    }
    final plan =
        war.isMainStory ? db2.curUser.mainStoryOf(war.id) : MainStoryPlan();
    List<Widget> children = [
      if (war.banner != null)
        Center(child: CachedImage(imageUrl: war.banner, height: 80)),
    ];
    children.add(CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          text: war.lLongName.l.replaceAll('\n', ' '),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Transl.isJP)
        CustomTableRow(children: [
          TableCellData(
            text: war.longName.replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      CustomTableRow(children: [
        TableCellData(text: 'Age', isHeader: true),
        TableCellData(text: war.age, flex: 3),
      ]),
      if (war.eventId > 0)
        CustomTableRow(children: [
          TableCellData(isHeader: true, text: S.current.event_title),
          TableCellData(
            flex: 3,
            child: TextButton(
              onPressed: () {
                router.push(url: Routes.eventI(war.eventId), detail: true);
              },
              child: Text(Transl.eventNames(war.eventName).l),
            ),
          )
        ]),
    ]));
    List<Quest> freeQuests = [],
        mainQuests = [],
        bondQuests = [],
        eventQuests = [];
    for (final quest in war.quests) {
      if (quest.type == QuestType.main) {
        mainQuests.add(quest);
      } else if (quest.type == QuestType.friendship) {
        bondQuests.add(quest);
      } else if (quest.type == QuestType.free ||
          (quest.type == QuestType.event &&
              quest.afterClear == QuestAfterClearType.repeatLast)) {
        freeQuests.add(quest);
      } else {
        eventQuests.add(quest);
      }
    }
    if (war.spots.isNotEmpty) {
      children.add(TileGroup(
        header: S.current.quest,
        children: [
          if (mainQuests.isNotEmpty)
            ListTile(
              title: const Text('Main Quest'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {},
            ),
          if (freeQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.free_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {},
            ),
          if (bondQuests.isNotEmpty)
            ListTile(
              title: const Text('Interlude'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {},
            ),
          if (eventQuests.isNotEmpty)
            ListTile(
              title: const Text('Event Quest'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {},
            ),
        ],
      ));
    }

    if (war.itemReward.isNotEmpty) {
      children.add(
        ListTile(
          title: Text(S.current.game_rewards),
          trailing: war.isMainStory
              ? db2.onUserData((context, snapshot) => Switch.adaptive(
                    value: plan.questReward,
                    onChanged: (v) {
                      plan.questReward = v;
                      db2.itemCenter.updateMainStory();
                    },
                  ))
              : null,
          onTap: () {
            plan.questReward = !plan.questReward;
            db2.itemCenter.updateMainStory();
          },
        ),
      );
      children.add(SharedBuilder.groupItems(
        context: context,
        items: war.itemReward,
        width: 48,
      ));
    }
    if (war.itemDrop.isNotEmpty) {
      children.add(
        ListTile(
          title: Text(S.current.main_record_fixed_drop),
          trailing: war.isMainStory
              ? db2.onUserData((context, snapshot) => Switch.adaptive(
                    value: plan.fixedDrop,
                    onChanged: (v) {
                      plan.fixedDrop = v;
                      db2.itemCenter.updateMainStory();
                    },
                  ))
              : null,
          onTap: () {
            plan.fixedDrop = !plan.fixedDrop;
            db2.itemCenter.updateMainStory();
          },
        ),
      );
      children.add(SharedBuilder.groupItems(
        context: context,
        items: war.itemDrop,
        width: 48,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          war.lLongName.l.replaceAll('\n', ' '),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
              atlas: Atlas.dbWar(war.id),
            ),
          )
        ],
      ),
      body: ListView(children: children),
    );
  }
}
