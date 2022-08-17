import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/builders.dart';

// quest.openAt is not correct...

class SvtQuestTimeline extends StatefulWidget {
  const SvtQuestTimeline({Key? key}) : super(key: key);

  @override
  State<SvtQuestTimeline> createState() => _SvtQuestTimelineState();
}

class _SvtQuestTimelineState extends State<SvtQuestTimeline> {
  List<Quest> relatedQuests = [];
  Map<int, Servant> relatedServants = {};
  Region region = Region.jp;
  bool reversed = false;
  bool showOutdated = false;

  @override
  void initState() {
    super.initState();
    for (final svt in db.gameData.servantsNoDup.values) {
      for (final questId in svt.relateQuestIds) {
        final quest = db.gameData.quests[questId];
        if (quest != null) {
          relatedQuests.add(quest);
          relatedServants[questId] = svt;
        }
      }
    }
    region = db.curUser.region;
    reversed = region == Region.jp;
  }

  int? getOpenAt(int questId, Region r) {
    int? t = db.gameData.mappingData.questRelease[questId]?.ofRegion(r);
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, List<Quest>> grouped = {};
    for (final quest in relatedQuests) {
      final t = getOpenAt(quest.id, region) ?? quest.openedAt * -1;
      grouped.putIfAbsent(t, () => []).add(quest);
    }
    for (final qs in grouped.values) {
      qs.sort2((e) => e.priority);
    }
    final ts = grouped.keys.toList();
    ts.sort((a, b) {
      int r;
      if (a > 0 && b > 0) {
        r = a - b;
      } else if (a < 0 && b < 0) {
        r = a.abs() - b.abs();
      } else {
        r = a > 0 ? -1 : 1;
      }
      return reversed ? -r : r;
    });
    for (final q in relatedQuests) {
      if (q.openedAt == 946652400 && getOpenAt(q.id, region) == null) {
        print(q.id);
      }
    }

    List<Widget> children = [SHeader(S.current.rankup_timeline_hint)];

    final now = DateTime.now().timestamp;
    for (final t in ts) {
      if (!showOutdated) {
        if (region == Region.jp && t < now - 3600 * 24 * 400) {
          continue;
        }
        if (region != Region.jp && t > 0 && t < now - 3600 * 24 * 31) {
          continue;
        }
      }
      final timeStr =
          DateTime.fromMillisecondsSinceEpoch(t.abs() * 1000).toDateString();
      children.add(SHeader(t < 0 ? '$timeStr (JP)' : timeStr));
      children.add(GridView.extent(
        maxCrossAxisExtent: 64,
        childAspectRatio: 132 / 144,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: grouped[t]!.map((quest) {
          final svt = relatedServants[quest.id]!;
          Set<int> iconIds = {};
          // 8-NP, 9-skill, 40-bond
          if (quest.type == QuestType.friendship) {
            iconIds.add(40);
            if (quest.gifts.isEmpty) {
              for (final skill in svt.skills) {
                if (skill.condQuestId == quest.id) {
                  iconIds.add(9);
                  break;
                }
              }
              for (final td in svt.noblePhantasms) {
                if (td.condQuestId == quest.id) {
                  iconIds.add(8);
                  break;
                }
              }
            }
          }
          for (final gift in quest.gifts) {
            if (gift.type == GiftType.questRewardIcon &&
                (gift.objectId == 8 || gift.objectId == 9)) {
              iconIds.add(gift.objectId);
            }
          }

          return InkWell(
            onTap: () {
              quest.routeTo(popDetails: true);
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                svt.iconBuilder(context: context, jumpToDetail: false),
                Padding(
                  padding: const EdgeInsets.only(right: 2, bottom: 6),
                  child: Wrap(
                    spacing: 1,
                    children: [
                      for (final iconId in iconIds)
                        db.getIconImage(Atlas.assetItem(iconId), width: 20),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.interlude_and_rankup),
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
                  setState(() {
                    region = v;
                  });
                }
              });
            },
            underline: const SizedBox(),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                showOutdated = !showOutdated;
              });
            },
            tooltip: S.current.outdated,
            icon: Icon(
                showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
          ),
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () {
              setState(() => reversed = !reversed);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
      ),
    );
  }
}
