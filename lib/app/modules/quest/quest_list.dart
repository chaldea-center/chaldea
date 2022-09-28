import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app.dart';

class QuestListPage extends StatefulWidget {
  final List<Quest> quests;
  final String? title;
  const QuestListPage({super.key, this.quests = const [], this.title});

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  @override
  Widget build(BuildContext context) {
    final quests = List.of(widget.quests);
    quests.sort((a, b) =>
        a.priority == b.priority ? a.id - b.id : b.priority - a.priority);
    final hasSpot =
        quests.any((q) => db.gameData.spots[q.spotId]?.image != null);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '${quests.length} ${S.current.quest}'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) =>
            const Divider(indent: 16, endIndent: 16, height: 4),
        itemBuilder: (context, index) {
          final quest = quests[index];
          bool isMainFree = quest.isMainStoryFree;
          List<InlineSpan> trailings = [];
          if (quest.consumeType == ConsumeType.ap ||
              quest.consumeType == ConsumeType.apAndItem) {
            trailings.add(TextSpan(text: 'AP${quest.consume} '));
          }
          if (quest.consumeType == ConsumeType.apAndItem) {
            for (final itemAmount in quest.consumeItem) {
              trailings.add(WidgetSpan(
                child: Item.iconBuilder(
                  context: context,
                  item: itemAmount.item,
                  text: itemAmount.amount.format(),
                  height: 18,
                  jumpToDetail: false,
                ),
              ));
            }
          }
          QuestPhase? phase = db.gameData.questPhases[quest.getPhaseKey(3)];
          if (phase != null) {
            trailings.add(const TextSpan(text: '\n'));
            for (final cls in phase.className) {
              trailings.add(
                  WidgetSpan(child: db.getIconImage(cls.icon(3), height: 18)));
            }
          }
          Widget trailing = trailings.isEmpty
              ? Text(
                  'Lv.${quest.recommendLv}',
                  style: Theme.of(context).textTheme.caption,
                )
              : Text.rich(
                  TextSpan(
                    text: 'Lv.${quest.recommendLv}\n',
                    children: trailings,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  textAlign: TextAlign.end,
                );
          if (quest.gifts.isNotEmpty) {
            trailing = Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                trailing,
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: LoopGift(gifts: quest.gifts),
                )
              ],
            );
          }
          String chapter = quest.type == QuestType.main
              ? quest.chapterSubStr.isEmpty && quest.chapterSubId != 0
                  ? S.current.quest_chapter_n(quest.chapterSubId)
                  : quest.chapterSubStr
              : '';
          chapter = chapter.trim();
          if (chapter.isNotEmpty) chapter += ' ';

          final spot = db.gameData.spots[quest.spotId];
          final leading = spot == null || spot.image == null
              ? (hasSpot ? const SizedBox(width: 56) : null)
              : db.getIconImage(spot.image, width: 56);
          final subtitle = isMainFree ? quest.lName.l : quest.lSpot.l;

          return ListTile(
            leading: leading,
            // minLeadingWidth: 16,
            title: Text(chapter + quest.lDispName, textScaleFactor: 0.85),
            subtitle:
                subtitle.isEmpty ? null : Text(subtitle, textScaleFactor: 0.85),
            trailing: trailing,
            contentPadding: leading == null
                ? null
                : const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
            horizontalTitleGap: 8,
            onTap: () {
              router.push(
                url: Routes.questI(quest.id),
                child: QuestDetailPage(quest: quest),
                detail: true,
              );
            },
          );
        },
        itemCount: quests.length,
      ),
    );
  }
}

class LoopGift extends StatefulWidget {
  final List<Gift> gifts;
  final double size;
  final int giftIconId;
  const LoopGift(
      {super.key, required this.gifts, this.size = 32, this.giftIconId = 0});

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
    final total = widget.gifts.length + (widget.giftIconId > 0 ? 1 : 0);
    if (total <= 0) {
      child = const SizedBox();
    } else if (total == 1) {
      child = _buildGift(0);
    } else {
      child = AnimatedCrossFade(
        firstChild: _buildGift(first),
        secondChild: _buildGift(second),
        crossFadeState:
            showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 600),
      );
    }
    return child;
  }

  Widget _buildGift(int index) {
    if (widget.giftIconId > 0) {
      if (index == 0) {
        return db.getIconImage(Atlas.assetItem(widget.giftIconId),
            width: widget.size);
      }
      index -= 1;
    }
    return widget.gifts[index % widget.gifts.length]
        .iconBuilder(context: context, width: widget.size, showOne: false);
  }
}
