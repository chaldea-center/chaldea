import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/builders.dart';
import '../common/filter_page_base.dart';
import 'timeline_filter.dart';

// quest.openAt is not correct...

class _GroupData {
  List<Quest> quests = [];
  List<Event> events = [];
}

class SvtQuestTimeline extends StatefulWidget {
  const SvtQuestTimeline({super.key});

  @override
  State<SvtQuestTimeline> createState() => _SvtQuestTimelineState();
}

class _SvtQuestTimelineState extends State<SvtQuestTimeline> {
  List<Quest> relatedQuests = [];
  Map<int, Quest> questMap = {};
  Map<int, Servant> relatedServants = {};

  final filterData = SvtQuestTimelineFilterData();

  @override
  void initState() {
    super.initState();
    // also defined in parser to add quest release time
    final storyQuestMap = {
      1: [1000624, 3000124, 3000607, 3001301, 1000631],
      38: [3000915],
    };
    for (final svt in db.gameData.servantsNoDup.values) {
      for (final questId in svt.relateQuestIds) {
        final quest = db.gameData.quests[questId];
        if (quest != null) {
          relatedQuests.add(quest);
          relatedServants[questId] = svt;
        }
      }
    }
    for (final svtNo in storyQuestMap.keys) {
      final svt = db.gameData.servantsNoDup[svtNo];
      for (final questId in storyQuestMap[svtNo]!) {
        final quest = db.gameData.quests[questId];
        if (svt != null && quest != null) {
          relatedQuests.add(quest);
          relatedServants[questId] = svt;
        }
      }
    }

    questMap = {for (final q in relatedQuests) q.id: q};
    filterData.region = db.curUser.region;
    filterData.reversed = filterData.region == Region.jp;
  }

  int getOpenAt(Quest quest, Region r) {
    if (r == Region.jp) return quest.openedAt;
    final releaseTime = db.gameData.mappingData.questRelease[quest.id]?.ofRegion(r);
    if (releaseTime != null) return releaseTime;
    return quest.openedAt * -1;
  }

  @override
  Widget build(BuildContext context) {
    final shownQuests = relatedQuests.where((quest) {
      final svt = relatedServants[quest.id];
      if (!filterData.favorite.check(svt?.status.favorite ?? false)) {
        return false;
      }
      if (filterData.questType.options.isNotEmpty && !filterData.questType.matchAny(getQuestTypes(quest))) {
        return false;
      }
      if (filterData.upgradeType.isNotEmpty && !filterData.upgradeType.matchAny(getUpgradeTypes(quest))) {
        return false;
      }
      return true;
    }).toList();
    // <openAt, list>
    final Map<int, _GroupData> grouped = {};
    switch (filterData.sortType.radioValue!) {
      case TimelineSortType.questOpenTime:
        for (final quest in shownQuests) {
          grouped.putIfAbsent(getOpenAt(quest, filterData.region), () => _GroupData()).quests.add(quest);
        }
        break;
      case TimelineSortType.apCampaignTime:
        final rqs = shownQuests.map((e) => e.id).toSet();
        for (final event in db.gameData.events.values) {
          Set<int> qs = {};
          for (final campaign in event.campaigns) {
            if ([CombineAdjustTarget.questAp, CombineAdjustTarget.questApFirstTime].contains(campaign.target)) {
              qs.addAll(campaign.targetIds);
              qs.addAll(event.campaignQuests.map((e) => e.questId));
            }
          }
          qs = qs.intersection(rqs);
          if (qs.isNotEmpty) {
            final d = grouped.putIfAbsent(event.startedAt, () => _GroupData());
            d.quests.addAll(qs.map((e) => questMap[e]!));
            d.events.add(event);
          }
        }
        break;
    }

    for (final data in grouped.values) {
      data.quests.sortByList((e) => [e.warId, e.priority]);
      data.events.sort2((e) => e.startedAt);
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
      return filterData.reversed ? -r : r;
    });

    List<Widget> children = [SHeader(S.current.rankup_timeline_hint)];

    final now = DateTime.now().timestamp;
    for (final t in ts) {
      if (!filterData.showOutdated) {
        if (filterData.useApCampaign) {
          if (t < now - 3600 * 24 * 31 * (filterData.region.eventDelayMonth + 1)) {
            continue;
          }
        } else {
          if (filterData.region == Region.jp && t < now - 3600 * 24 * 400) {
            continue;
          }
          if (filterData.region != Region.jp && t > 0 && t < now - 3600 * 24 * 31) {
            continue;
          }
        }
      }
      children.add(timeAndSvtGrid(t, grouped[t]!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.interlude_and_rankup),
        actions: [
          DropdownButton<Region>(
            value: filterData.region,
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
                        color: filterData.useApCampaign
                            ? Theme.of(context).disabledColor
                            : SharedBuilder.appBarForeground(context)),
                  ),
                )
            ],
            onChanged: filterData.useApCampaign
                ? null
                : (v) {
                    setState(() {
                      if (v != null) {
                        setState(() {
                          filterData.region = v;
                        });
                      }
                    });
                  },
            underline: const SizedBox(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => SvtQuestTimelineFilter(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          IconButton(
            icon: FaIcon(
              filterData.reversed ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () {
              setState(() => filterData.reversed = !filterData.reversed);
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const Divider(height: 6),
        itemCount: children.length,
      ),
    );
  }

  Iterable<TimelineQuestType> getQuestTypes(Quest quest) sync* {
    if (quest.type == QuestType.friendship) yield TimelineQuestType.interlude;
    if (quest.warId == WarId.rankup) yield TimelineQuestType.rankup;
    if (quest.type == QuestType.main) yield TimelineQuestType.main;
  }

  Iterable<TimelineUpgradeType> getUpgradeTypes(Quest quest) sync* {
    final svt = relatedServants[quest.id];
    if (svt != null) {
      if (svt.skills.any((e) => e.svt.condQuestId == quest.id)) {
        yield TimelineUpgradeType.skill;
      }
      if (svt.noblePhantasms.any((e) => e.svt.condQuestId == quest.id)) {
        yield TimelineUpgradeType.np;
      }
    }
  }

  Widget timeAndSvtGrid(int timestamp, _GroupData data, [int maxShown = 50]) {
    final timeStr = DateTime.fromMillisecondsSinceEpoch(timestamp.abs() * 1000).toDateString();
    List<Widget> children = [
      SHeader(timestamp < 0 || filterData.useApCampaign ? '$timeStr (JP)' : '$timeStr (${filterData.region.upper})'),
      if (data.events.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              for (final event in data.events)
                InkWell(
                  onTap: event.routeTo,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: SizedBox(
                      child: Text(
                        event.lName.l.setMaxLines(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
    ];
    if (data.quests.length > maxShown) {
      Map<dynamic, int> types = {};
      for (final quest in data.quests) {
        for (final type in getQuestTypes(quest)) {
          types.addNum(type, 1);
        }
        for (final type in getUpgradeTypes(quest)) {
          types.addNum(type, 1);
        }
      }
      String countText = '${data.quests.length} ${S.current.quest}: ';
      countText +=
          [...TimelineQuestType.values, ...TimelineUpgradeType.values].where((e) => types.containsKey(e)).map((e) {
        final name = e is TimelineQuestType
            ? e.shownName
            : e is TimelineUpgradeType
                ? e.shownName
                : e.name;
        return '${types[e]} $name';
      }).join(', ');
      children.add(ListTile(
        title: Text(
          countText,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          textScaleFactor: 0.8,
        ),
        onTap: () {
          router.pushPage(Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('${data.quests.length} ${S.current.quest}(s)')),
              body: GridView.extent(
                maxCrossAxisExtent: 64,
                childAspectRatio: 132 / 144,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: data.quests.map((q) => _buildIcon(context, q)).toList(),
              ),
            ),
          ));
        },
      ));
    } else {
      children.add(GridView.extent(
        maxCrossAxisExtent: 64,
        childAspectRatio: 132 / 144,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: data.quests.map((q) => _buildIcon(context, q)).toList(),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildIcon(BuildContext context, Quest quest) {
    final svt = relatedServants[quest.id]!;
    Set<int> iconIds = {};
    Map<int, NiceSkill> targetSkills = {};
    NiceTd? targetTd;
    if (quest.type == QuestType.friendship) {
      iconIds.add(ItemIconId.interlude);
    }
    for (final skill in svt.skills) {
      if (skill.svt.condQuestId == quest.id) {
        iconIds.add(ItemIconId.skillUpgrade);
        targetSkills[skill.id] = skill; // Mash has multiple skills with same id
      }
    }
    for (final td in svt.noblePhantasms) {
      if (td.svt.condQuestId == quest.id) {
        iconIds.add(ItemIconId.tdUpgrade);
        targetTd = td;
        break;
      }
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            final spotImage = quest.spot?.shownImage;
            return SimpleDialog(
              children: [
                ListTile(
                  leading: svt.iconBuilder(context: context),
                  title: Text('No.${svt.collectionNo} ${svt.lName.l}'),
                  onTap: () {
                    Navigator.pop(context);
                    svt.routeTo(popDetails: true);
                  },
                ),
                ListTile(
                  leading: spotImage == null ? null : db.getIconImage(quest.spot?.shownImage),
                  title: Text(quest.lName.l),
                  subtitle: Text(quest.lSpot.l),
                  onTap: () {
                    Navigator.pop(context);
                    quest.routeTo(popDetails: true);
                  },
                ),
                for (final skill in targetSkills.values) DisableLayoutBuilder(child: SkillDescriptor(skill: skill)),
                if (targetTd != null) DisableLayoutBuilder(child: TdDescriptor(td: targetTd)),
              ],
            );
          },
        );
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
                  GameCardMixin.cardIconBuilder(
                    context: context,
                    icon: Atlas.assetItem(iconId),
                    width: 20,
                    text: iconId == ItemIconId.skillUpgrade
                        ? targetSkills.values.map((e) => e.svt.num).toSet().toList().sortReturn().join()
                        : null,
                    option: ImageWithTextOption(fontSize: 12),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
