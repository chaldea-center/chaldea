import 'dart:async';

import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart' show MasterDataManager;
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import '../mc/mc_quest.dart';

class QuestListPage extends StatefulWidget {
  final List<Quest> quests;
  final List<int> ids;
  final String? title;
  final bool needSort;
  final bool groupWar; // not implemented yet
  final NiceWar? war;
  final bool? groupByWar;
  final MasterDataManager? mstData;

  const QuestListPage({
    super.key,
    this.quests = const [],
    this.title,
    this.needSort = true,
    this.groupWar = false,
    this.war,
    this.groupByWar,
    this.mstData,
  }) : ids = const [];

  const QuestListPage.ids({
    super.key,
    this.ids = const [],
    this.title,
    this.needSort = true,
    this.groupWar = false,
    this.war,
    this.groupByWar,
    this.mstData,
  }) : quests = const [];

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  late MasterDataManager? mstData = widget.mstData;

  Set<int> allMapIds = {};
  int _selectedMapId = 0;

  @override
  void initState() {
    super.initState();
    for (final quest in widget.quests) {
      allMapIds.add(quest.mapId);
    }
    for (final questId in widget.ids) {
      final quest = db.gameData.quests[questId];
      if (quest != null) {
        allMapIds.add(quest.mapId);
      }
    }
    allMapIds.remove(0);
  }

  @override
  Widget build(BuildContext context) {
    final allQuestsMap = Map.of(db.gameData.quests);
    for (final q in widget.quests) {
      // override
      allQuestsMap[q.id] = q;
    }
    final questIds = widget.quests.isEmpty ? widget.ids.toList() : widget.quests.map((e) => e.id).toList();

    if (_selectedMapId != 0) {
      questIds.removeWhere((questId) {
        final quest = allQuestsMap[questId];
        return quest != null && quest.mapId != _selectedMapId;
      });
    }

    if (widget.needSort) {
      if (const [WarId.rankup, WarId.interlude].contains(widget.war?.id)) {
        questIds.sortByList((questId) {
          final quest = db.gameData.quests[questId];
          return <int>[quest?.openedAt ?? 0, questId];
        }, reversed: true);
      } else {
        questIds.sort(Quest.compareId);
      }
    }

    final hasSpot = questIds.any((q) => allQuestsMap[q]?.spot?.shownImage != null);

    Widget buildQuest(int questId) {
      final quest = allQuestsMap[questId];

      final spot = db.gameData.spots[quest?.spotId];

      Servant? owner = quest != null && (quest.type == QuestType.friendship || quest.warId == WarId.rankup)
          ? db.gameData.servantsById.values.firstWhereOrNull((svt) => svt.relateQuestIds.contains(quest.id))
          : null;

      final leading = spot == null || spot.shownImage == null
          ? (hasSpot ? const SizedBox(width: 56) : null)
          : db.getIconImage(spot.shownImage, width: 56);
      List<String> userQuestInfo = [];
      final userQuest = mstData?.userQuest[questId];
      if (mstData != null) {
        bool hasSvt = mstData!.userSvtCollection[owner?.id]?.isOwned == true;
        if (userQuest != null) {
          userQuestInfo.add(userQuest.getText());
        } else if (hasSvt) {
          userQuestInfo.add('❤');
        }
        userQuestInfo.add('$questId  ${quest?.openedAt.sec2date().toCustomString(second: false)}');
      }

      if (quest == null) {
        return ListTile(
          leading: leading,
          // minLeadingWidth: 16,
          title: Text('Quest $questId', textScaler: const TextScaler.linear(0.85)),
          subtitle: userQuestInfo.isEmpty ? null : Text(userQuestInfo.join('\n')),
          contentPadding: leading == null ? null : const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
          horizontalTitleGap: 8,
          onTap: () {
            router.push(url: Routes.questI(questId), detail: true);
          },
        );
      }
      bool isMainFree = quest.isMainStoryFree;

      List<InlineSpan> trailings = [TextSpan(text: 'Lv.${quest.recommendLv}')];

      List<InlineSpan> consumes = [];
      if (quest.phases.isNotEmpty &&
          quest.consumeType.useApOrBp &&
          (quest.afterClear.isRepeat || quest.phases.length == 1)) {
        final int consume =
            db.gameData.questPhaseDetails[quest.id * 100 + quest.phases.last]?.actConsume ?? quest.consume;
        consumes.add(TextSpan(text: '${quest.consumeType.unit}$consume'));
      }
      consumes.addAll([
        for (final itemAmount in quest.consumeItem)
          WidgetSpan(
            child: Item.iconBuilder(
              context: context,
              item: itemAmount.item,
              text: itemAmount.amount.format(),
              height: 18,
              jumpToDetail: false,
            ),
          ),
      ]);

      List<InlineSpan> clsIcons = [];

      List<int> clsIconIds = [];
      if (quest.phases.isNotEmpty &&
          (quest.afterClear.isRepeat || (quest.type == QuestType.event && quest.phases.length == 1))) {
        final key = quest.id * 100 + quest.phases.last;
        clsIconIds = db.gameData.questPhases[key]?.classIds ?? db.gameData.questPhaseDetails[key]?.classIds ?? [];
      }
      if (clsIconIds.isNotEmpty) {
        // consumes.add(TextSpan(text: '\n${S.current.bond} ${phase.bond}'));
        clsIcons.addAll([
          for (final clsId in clsIconIds) WidgetSpan(child: db.getIconImage(SvtClassX.clsIcon(clsId, 3), height: 18)),
        ]);
      }

      if (consumes.isNotEmpty) {
        trailings.add(TextSpan(children: consumes));
      }
      if (clsIcons.isNotEmpty) {
        trailings.add(TextSpan(children: clsIcons));
      }

      Widget trailing = Text.rich(
        TextSpan(
          children: divideList(trailings, const TextSpan(text: '\n')),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        textAlign: TextAlign.end,
      );
      if (quest.gifts.isNotEmpty || quest.giftIcon != null) {
        trailing = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            trailing,
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: LoopGift(gifts: quest.gifts, giftIcon: quest.giftIcon),
            ),
          ],
        );
      }
      String chapter = quest.chapter;
      final title = chapter.isEmpty ? quest.lDispName : '$chapter ${quest.lDispName}';

      String subtitle;
      if (isMainFree) {
        subtitle = quest.lName.l;
        final layer = kLB7SpotLayers[quest.spotId];
        if (layer != null) {
          subtitle = '${S.current.map_layer_n(layer)} $subtitle';
        }
      } else {
        subtitle = quest.lSpot.l;
      }
      if (userQuestInfo.isNotEmpty) {
        subtitle = [if (subtitle.isNotEmpty) subtitle, ...userQuestInfo].join('\n');
      }

      return ListTile(
        leading: leading,
        // minLeadingWidth: 16,
        title: Text(title, textScaler: const TextScaler.linear(0.85)),
        subtitle: subtitle.isEmpty && owner == null
            ? null
            : Text.rich(
                TextSpan(
                  children: [
                    if (owner != null) CenterWidgetSpan(child: owner.iconBuilder(context: context, height: 32)),
                    TextSpan(text: subtitle),
                  ],
                ),
                textScaler: const TextScaler.linear(0.85),
              ),
        trailing: trailing,
        contentPadding: leading == null ? null : const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
        horizontalTitleGap: 8,
        selected: quest.is90PlusFree && quest.warId > 2000,
        onTap: () {
          router.push(
            url: Routes.questI(quest.id),
            child: QuestDetailPage(quest: quest, questIdList: questIds),
            detail: true,
          );
        },
      );
    }

    Map<int, List<int>> warQuestIds = {};
    for (final int questId in questIds) {
      warQuestIds.putIfAbsent(db.gameData.quests[questId]?.warId ?? 0, () => []).add(questId);
    }

    Widget body;
    if (widget.groupByWar ?? warQuestIds.values.where((v) => v.length > 2).length > 1) {
      List<Widget> children = [];
      final warIds = warQuestIds.keys.toList()..sort();
      for (final warId in warIds.reversed) {
        final ids = warQuestIds[warId]!;
        final war = db.gameData.wars[warId];
        children.add(
          SimpleAccordion(
            expanded: questIds.length < 25,
            headerBuilder: (context, _) {
              return ListTile(dense: true, title: Text(war?.lLongName.l.setMaxLines(2) ?? "War $warId"));
            },
            contentBuilder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: divideList([
                  for (final questId in ids) buildQuest(questId),
                ], const Divider(indent: 16, endIndent: 16, height: 4)),
              );
            },
          ),
        );
      }
      body = ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
      );
    } else {
      body = ListView.separated(
        separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16, height: 4),
        itemBuilder: (context, index) {
          return buildQuest(questIds[index]);
        },
        itemCount: questIds.length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '${questIds.length} ${S.current.quest}'),
        actions: [if (Language.isZH) buildPopupMenu(questIds, allQuestsMap)],
      ),
      body: body,
    );
  }

  Widget buildPopupMenu(List<int> questIds, Map<int, Quest> allQuestsMap) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (widget.quests.isNotEmpty)
            PopupMenuItem(
              child: const Text('导出至Mooncell'),
              onTap: () {
                final quests = questIds.map((e) => allQuestsMap[e]).whereType<Quest>().toList();
                router.pushPage(MCQuestListConvertPage(title: widget.title, quests: quests, war: widget.war));
              },
            ),
          if (allMapIds.length > 1 && allMapIds.length < 50)
            PopupMenuItem(
              child: const Text('Map filter'),
              onTap: () {
                final mapIds = [0, ...allMapIds]..sort();
                router.showDialog(
                  builder: (context) => SimpleDialog(
                    title: Text('Map ID'),
                    children: [
                      for (final mapId in mapIds)
                        SimpleDialogOption(
                          child: Text(mapId == 0 ? S.current.reset : '$mapId'),
                          onPressed: () {
                            Navigator.pop(context);
                            _selectedMapId = mapId;
                            if (mounted) setState(() {});
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          if (db.runtimeData.clipBoard.mstData != null)
            PopupMenuItem(
              child: const Text('Read Login Data'),
              onTap: () {
                mstData = db.runtimeData.clipBoard.mstData;
                if (mounted) setState(() {});
              },
            ),
        ];
      },
    );
  }
}

class LoopGift extends StatefulWidget {
  final List<Gift> gifts;
  final double size;
  final String? giftIcon;
  const LoopGift({super.key, required this.gifts, this.size = 32, this.giftIcon});

  @override
  State<LoopGift> createState() => _LoopGiftState();
}

class _LoopGiftState extends State<LoopGift> {
  int tick = 0;
  int first = 0;
  int second = 1;
  bool showFirst = true;
  late Timer timer;

  @override
  void didUpdateWidget(covariant LoopGift oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gifts != oldWidget.gifts) {
      tick = 0;
      first = 0;
      second = 1;
      showFirst = true;
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 3000), (t) async {
      tick += 1;
      showFirst = !showFirst;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
      if (showFirst) {
        second += 2;
      } else {
        first += 2;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final total = widget.gifts.length + (widget.giftIcon != null ? 1 : 0);
    if (total <= 0) {
      child = const SizedBox();
    } else if (total == 1) {
      child = _buildGift(0);
    } else {
      child = AnimatedCrossFade(
        firstChild: _buildGift(first),
        secondChild: _buildGift(second),
        crossFadeState: showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 600),
      );
    }
    return child;
  }

  Widget _buildGift(int index) {
    if (widget.giftIcon != null) {
      if (index == 0) {
        return db.getIconImage(widget.giftIcon, width: widget.size);
      }
      index -= 1;
    }
    return widget.gifts[index % widget.gifts.length].iconBuilder(context: context, width: widget.size, showOne: false);
  }
}
