import 'dart:async';

import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
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

  const QuestListPage({
    super.key,
    this.quests = const [],
    this.title,
    this.needSort = true,
    this.groupWar = false,
  }) : ids = const [];
  const QuestListPage.ids({
    super.key,
    this.ids = const [],
    this.title,
    this.needSort = true,
    this.groupWar = false,
  }) : quests = const [];

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  @override
  Widget build(BuildContext context) {
    final allQuestsMap = Map.of(db.gameData.quests);
    for (final q in widget.quests) {
      // override
      allQuestsMap[q.id] = q;
    }
    final questIds = widget.quests.isEmpty ? widget.ids.toList() : widget.quests.map((e) => e.id).toList();
    if (widget.needSort) {
      questIds.sort(Quest.compareId);
    }

    final hasSpot = questIds.any((q) => allQuestsMap[q]?.spot?.shownImage != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '${questIds.length} ${S.current.quest}'),
        actions: [
          if (Language.isZH) buildPopupMenu(questIds, allQuestsMap),
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16, height: 4),
        itemBuilder: (context, index) {
          final questId = questIds[index];
          final quest = allQuestsMap[questId];

          final spot = db.gameData.spots[quest?.spotId];
          final leading = spot == null || spot.shownImage == null
              ? (hasSpot ? const SizedBox(width: 56) : null)
              : db.getIconImage(spot.shownImage, width: 56);

          if (quest == null) {
            return ListTile(
              leading: leading,
              // minLeadingWidth: 16,
              title: Text('Quest $questId', textScaler: const TextScaler.linear(0.85)),
              contentPadding: leading == null ? null : const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
              horizontalTitleGap: 8,
              onTap: () {
                router.push(url: Routes.questI(questId), detail: true);
              },
            );
          }
          bool isMainFree = quest.isMainStoryFree;
          List<InlineSpan> trailings = [];
          if (quest.consumeType.useApOrBp && quest.phases.length == 1) {
            trailings.add(TextSpan(text: '${quest.consumeType.unit}${quest.consume} '));
          }
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
          QuestPhase? phase = db.gameData.questPhases[quest.getPhaseKey(3)];
          if (phase != null) {
            trailings.add(const TextSpan(text: '\n'));
            for (final cls in phase.className) {
              trailings.add(WidgetSpan(child: db.getIconImage(cls.icon(3), height: 18)));
            }
          }
          Widget trailing = trailings.isEmpty
              ? Text(
                  'Lv.${quest.recommendLv}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Text.rich(
                  TextSpan(
                    text: 'Lv.${quest.recommendLv}\n',
                    children: trailings,
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
                )
              ],
            );
          }
          String chapter = quest.chapter;
          final title = chapter.isEmpty ? quest.lDispName : '$chapter ${quest.lDispName}';
          final interludeOwner = quest.type == QuestType.friendship
              ? db.gameData.servantsById.values.firstWhereOrNull((svt) => svt.relateQuestIds.contains(quest.id))
              : null;

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

          return ListTile(
            leading: leading,
            // minLeadingWidth: 16,
            title: Text(title, textScaler: const TextScaler.linear(0.85)),
            subtitle: subtitle.isEmpty && interludeOwner == null
                ? null
                : Text.rich(
                    TextSpan(children: [
                      if (interludeOwner != null)
                        CenterWidgetSpan(child: interludeOwner.iconBuilder(context: context, height: 32)),
                      TextSpan(text: subtitle),
                    ]),
                    textScaler: const TextScaler.linear(0.85),
                  ),
            trailing: trailing,
            contentPadding: leading == null ? null : const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
            horizontalTitleGap: 8,
            selected: quest.is90PlusFree && quest.warId > 2000,
            onTap: () {
              router.push(
                url: Routes.questI(quest.id),
                child: QuestDetailPage(quest: quest),
                detail: true,
              );
            },
          );
        },
        itemCount: questIds.length,
      ),
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
                router.pushPage(MCQuestListConvertPage(title: widget.title, quests: quests));
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
