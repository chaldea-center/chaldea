import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/not_found.dart';
import '../../quest/quest_list.dart';

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
    _war = widget.war ?? db.gameData.wars[widget.warId];
  }

  @override
  void didUpdateWidget(covariant WarDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _war = widget.war ?? db.gameData.wars[widget.warId];
  }

  MainStoryPlan get plan => db.curUser.mainStoryOf(war.id);
  @override
  Widget build(BuildContext context) {
    if (_war == null) {
      return NotFoundPage(
        title: 'War ${widget.warId}',
        url: Routes.warI(widget.warId ?? 0),
      );
    }
    final banners = [
      ...war.extra.titleBanner.values.whereType<String>(),
    ];
    // final eventBanners = war.event?.extra.titleBanner.values
    //     .whereType<String>()
    //     .toList();
    // if (eventBanners != null && eventBanners.isNotEmpty) {
    //   banners.addAll(eventBanners);
    // }
    List<String> warBanners = {
      war.banner,
      for (final warAdd in war.warAdds) warAdd.overwriteBanner,
    }.whereType<String>().toList();

    List<Widget> children = [
      if (banners.isNotEmpty)
        CarouselUtil.limitHeightWidget(context: context, imageUrls: banners),
    ];
    String warName = war.name;
    String longName = war.longName;
    children.add(CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          text: war.lLongName.l,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Transl.isJP)
        CustomTableRow(children: [
          TableCellData(
            text: longName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      if (warName != longName) CustomTableRow.fromTexts(texts: [war.lName.l]),
      if (warName != longName && !Transl.isJP)
        CustomTableRow.fromTexts(texts: [warName]),
      CustomTableRow(children: [
        TableCellData(text: S.current.war_age, isHeader: true),
        TableCellData(text: war.age, flex: 3),
      ]),
      if (warBanners.isNotEmpty)
        CustomTableRow(children: [
          TableCellData(text: S.current.war_banner, isHeader: true),
          TableCellData(
            flex: 3,
            child: Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              children: warBanners
                  .map((e) => db.getIconImage(e, height: 48))
                  .toList(),
            ),
          ),
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
              style: kTextButtonDenseStyle,
              child: Text(
                Transl.eventNames(war.eventName).l,
                textAlign: TextAlign.center,
              ),
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
              title: Text(S.current.main_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.main_quest, quests: mainQuests),
                );
              },
            ),
          if (freeQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.free_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.free_quest, quests: freeQuests),
                );
              },
            ),
          if (bondQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.interlude),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.interlude, quests: bondQuests),
                );
              },
            ),
          if (eventQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.event_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.event_quest, quests: eventQuests),
                );
              },
            ),
        ],
      ));
    }

    if (war.itemReward.isNotEmpty) {
      children.add(
        ListTile(
          title: Text(S.current.game_rewards),
          trailing: war.isMainStory
              ? db.onUserData((context, snapshot) => Switch.adaptive(
                    value: plan.questReward,
                    onChanged: (v) {
                      plan.questReward = v;
                      db.itemCenter.updateMainStory();
                    },
                  ))
              : null,
          onTap: () {
            plan.questReward = !plan.questReward;
            db.itemCenter.updateMainStory();
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
          title: Text(S.current.quest_fixed_drop),
          trailing: war.isMainStory
              ? db.onUserData((context, snapshot) => Switch.adaptive(
                    value: plan.fixedDrop,
                    onChanged: (v) {
                      plan.fixedDrop = v;
                      db.itemCenter.updateMainStory();
                    },
                  ))
              : null,
          onTap: () {
            plan.fixedDrop = !plan.fixedDrop;
            db.itemCenter.updateMainStory();
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
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<dynamic>(
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                height: 32,
                child: Text('No.${widget.war?.id ?? widget.warId}',
                    textScaleFactor: 0.9),
              ),
              const PopupMenuDivider(),
              ...SharedBuilder.websitesPopupMenuItems(
                atlas: Atlas.dbWar(war.id),
                mooncell: war.extra.mcLink ?? war.event?.extra.mcLink,
                fandom: war.extra.fandomLink ?? war.event?.extra.fandomLink,
              ),
              ...SharedBuilder.noticeLinkPopupMenuItems(
                noticeLink: war.extra.noticeLink,
              ),
            ],
          )
        ],
      ),
      body: ListView(children: children),
    );
  }
}
