import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/event/war/script_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/not_found.dart';
import '../../quest/quest_list.dart';
import 'asset_list.dart';
import 'free_overview.dart';
import 'map_list.dart';
import 'war_bgm_list.dart';
import 'war_map.dart';

class WarDetailPage extends StatefulWidget {
  final int? warId;
  final NiceWar? war;

  WarDetailPage({super.key, this.warId, this.war});

  @override
  _WarDetailPageState createState() => _WarDetailPageState();
}

class _WarDetailPageState extends State<WarDetailPage> {
  NiceWar? _war;
  bool _loading = false;
  int get id => widget.war?.id ?? widget.warId ?? _war?.id ?? 0;

  NiceWar get war => _war!;

  @override
  void initState() {
    super.initState();
    _war = widget.war ?? db.gameData.wars[widget.warId];
  }

  Future<void> fetchWar() async {
    _war = null;
    _loading = true;
    if (mounted) setState(() {});
    _war =
        widget.war ?? db.gameData.wars[widget.warId] ?? await AtlasApi.war(id);
    _loading = false;
    if (mounted) setState(() {});
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
    if (_war == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${S.current.war_title} $id'),
        ),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : RefreshButton(onPressed: fetchWar),
        ),
      );
    }
    final banners = war.extra.allBanners;
    final warAdds = war.warAdds.toList();
    warAdds.sort2((e) => e.startedAt);
    List<String> warBanners = {
      for (final warAdd in warAdds) warAdd.overwriteBanner,
    }.whereType<String>().toList();
    warBanners = {
      if (war.banner != null) war.banner!,
      ...warBanners.reversed.take(6).toList().reversed
    }.toList();

    List<Widget> children = [
      if (banners.isNotEmpty)
        CarouselUtil.limitHeightWidget(context: context, imageUrls: banners),
    ];

    List<String> shortNames = [war.lName.jp];
    List<String> longNames = [war.lLongName.jp];
    for (final warAdd in war.warAdds) {
      if (warAdd.type == WarOverwriteType.name &&
          !shortNames.contains(warAdd.overwriteStr)) {
        shortNames.add(warAdd.overwriteStr);
      }
      if (warAdd.type == WarOverwriteType.longName &&
          !longNames.contains(warAdd.overwriteStr)) {
        longNames.add(warAdd.overwriteStr);
      }
    }
    String lLongName = longNames.map((e) => Transl.warNames(e).l).join('\n');
    String longNameJp = longNames.join('\n');
    String lShortName = shortNames.map((e) => Transl.warNames(e).l).join('\n');
    String shortNameJp = shortNames.join('\n');

    Quest? firstMainQuest;
    NiceWar? condWar;
    if (war.startType == WarStartType.quest) {
      firstMainQuest = war.quests.firstWhereOrNull((q) => q.id == war.targetId);
    }
    if (firstMainQuest == null) {
      final mainQuests =
          war.quests.where((e) => e.type == QuestType.main).toList();
      mainQuests.sort2((e) => -e.priority);
      firstMainQuest = mainQuests.getOrNull(0);
    }
    if (firstMainQuest != null) {
      final targetId = firstMainQuest.releaseConditions
          .firstWhereOrNull((cond) => cond.type == CondType.questClear)
          ?.targetId;
      final condQuest = db.gameData.quests[targetId];
      if (targetId == condQuest?.war?.lastQuestId) {
        // usually only main story use the lastQuestId
        condWar = condQuest?.war;
      }
    }

    children.add(CustomTable(
      selectable: true,
      children: [
        CustomTableRow(children: [
          TableCellData(
            text: lLongName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            color: TableCellData.resolveHeaderColor(context),
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(children: [
            TableCellData(
              text: longNameJp,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
            )
          ]),
        if (lShortName != lLongName)
          CustomTableRow.fromTexts(texts: [lShortName]),
        if (shortNameJp != longNameJp && !Transl.isJP)
          CustomTableRow.fromTexts(texts: [shortNameJp]),
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
                    .map((e) => CachedImage(
                        imageUrl: e, height: 48, showSaveOnLongPress: true))
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
                  war.event?.lShortName.l ?? Transl.eventNames(war.eventName).l,
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                ),
              ),
            )
          ]),
        if (condWar != null)
          CustomTableRow(children: [
            TableCellData(isHeader: true, text: S.current.open_condition),
            TableCellData(
              flex: 3,
              child: TextButton(
                onPressed: () {
                  condWar?.routeTo();
                },
                style: kTextButtonDenseStyle,
                child: Text(
                  condWar.lShortName,
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                ),
              ),
            )
          ]),
        if (war.bgm.id != 0)
          CustomTableRow(children: [
            TableCellData(isHeader: true, text: S.current.bgm),
            TableCellData(
              flex: 3,
              child: TextButton(
                onPressed: () {
                  war.bgm.routeTo();
                },
                style: kTextButtonDenseStyle,
                child: Text(
                  war.bgm.tooltip.setMaxLines(1),
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                ),
              ),
            )
          ]),
      ],
    ));
    List<Quest> mainQuests = [],
        freeQuests = [],
        raidQuests = [],
        difficultQuests = [],
        oneOffQuests = [],
        bondQuests = [],
        eventQuests = [],
        selectionQuests = [];
    for (final quest in war.quests) {
      if (quest.type == QuestType.main) {
        mainQuests.add(quest);
      } else if (quest.type == QuestType.friendship) {
        bondQuests.add(quest);
      } else if (quest.type == QuestType.free ||
          (quest.type == QuestType.event &&
              quest.afterClear == QuestAfterClearType.repeatLast)) {
        if (quest.afterClear != QuestAfterClearType.repeatLast) {
          oneOffQuests.add(quest);
        } else if (quest.flags.contains(QuestFlag.raid)) {
          raidQuests.add(quest);
        } else if (quest.flags.contains(QuestFlag.dropFirstTimeOnly)) {
          difficultQuests.add(quest);
        } else if (quest.flags.contains(QuestFlag.noBattle)) {
          eventQuests.add(quest);
        } else {
          freeQuests.add(quest);
        }
      } else {
        eventQuests.add(quest);
      }
    }

    final selections = List.of(war.questSelections);
    selections.sort2((e) => -e.priority);
    selectionQuests = selections.map((e) => e.quest).toList();

    if (war.spots.isNotEmpty || selectionQuests.isNotEmpty) {
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
          if (freeQuests.isNotEmpty && war.id != 1002 && war.id != 9999)
            ListTile(
              title: Text("${S.current.item} (${S.current.free_quest})"),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.pushPage(FreeQuestOverview(quests: freeQuests));
              },
            ),
          if (raidQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.raid_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.raid_quest, quests: raidQuests),
                );
              },
            ),
          if (difficultQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.high_difficulty_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.high_difficulty_quest,
                      quests: difficultQuests),
                );
              },
            ),
          if (oneOffQuests.isNotEmpty)
            ListTile(
              title: Text(S.current.one_off_quest),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                      title: S.current.one_off_quest, quests: oneOffQuests),
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
          if (selectionQuests.isNotEmpty)
            ListTile(
              title: const Text('Selections'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  child: QuestListPage(
                    title: 'Selections',
                    quests: selectionQuests,
                    needSort: false,
                  ),
                );
              },
            ),
        ],
      ));
    }

    List<Widget> extraTiles = [];
    if (war.quests.any((q) => q.phaseScripts.isNotEmpty)) {
      extraTiles.add(ListTile(
        title: Text(S.current.script_story),
        onTap: () {
          router.pushPage(ScriptListPage(war: war));
        },
      ));
      extraTiles.add(ListTile(
        title: Text(S.current.media_assets),
        onTap: () {
          router.pushPage(WarAssetListPage(war: war));
        },
      ));
    }
    Set<int> bgms = {
      war.bgm.id,
      ...war.warAdds
          .where((e) => e.type == WarOverwriteType.bgm)
          .map((e) => e.overwriteId),
      ...war.maps.map((e) => e.bgm.id),
    }.where((e) => e != 0).toSet();
    if (bgms.isNotEmpty) {
      if (bgms.length == 1) {
        final bgm = db.gameData.bgms[bgms.first];
        final name = bgm?.tooltip.setMaxLines(1);
        extraTiles.add(ListTile(
          title: Text(S.current.bgm),
          subtitle: name?.toText(),
          onTap: bgm?.routeTo,
        ));
      } else {
        extraTiles.add(ListTile(
          title: Text(S.current.bgm),
          onTap: () {
            router.pushPage(WarBgmListPage(bgmIds: bgms.toList()));
          },
        ));
      }
    }
    final maps =
        war.maps.where((e) => e.mapImageW > 0 && e.mapImageH > 0).toList();
    if (maps.isNotEmpty) {
      if (maps.length == 1) {
        final map = maps.first;
        extraTiles.add(ListTile(
          title: Text('${S.current.war_map} ${map.id}'),
          onTap: () {
            router.push(child: WarMapPage(war: war, map: map));
          },
        ));
      } else {
        extraTiles.add(ListTile(
          title: Text(S.current.war_map),
          onTap: () {
            router.push(child: WarMapListPage(war: war));
          },
        ));
      }
    }
    if (extraTiles.isNotEmpty) {
      children.add(TileGroup(children: extraTiles));
    }

    final subWars = db.gameData.wars.values.where((w) {
      if (w.parentWarId == war.id) return true;
      for (final warAdd in w.warAdds) {
        if (warAdd.type == WarOverwriteType.parentWar &&
            warAdd.overwriteId == war.id) {
          return true;
        }
      }
      return false;
    }).toList();
    if (subWars.isNotEmpty) {
      subWars.sort2((e) => -e.priority);
      List<Widget> warTiles = [];
      for (final _w in subWars) {
        warTiles.add(LayoutBuilder(builder: (context, constraints) {
          String title = _w.lLongName.l;
          final height = min(constraints.maxWidth / 2, 164.0) / 142 * 354;
          return ListTile(
            leading: _w.banner == null
                ? null
                : db.getIconImage(_w.banner, height: height),
            horizontalTitleGap: 8,
            title: Text(
              title,
              maxLines: 1,
              textScaleFactor: 0.8,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _w.routeTo();
            },
          );
        }));
      }
      children.add(TileGroup(
        header: 'Sub Wars',
        children: warTiles,
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
