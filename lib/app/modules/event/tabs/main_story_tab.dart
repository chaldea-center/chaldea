import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class MainStoryTab extends StatelessWidget {
  final bool reversed;
  final bool showOutdated;
  final bool showSpecialRewards;
  final bool titleOnly;

  const MainStoryTab({
    super.key,
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    this.titleOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    List<NiceWar> mainStories = db.gameData.mainStories.values.toList();
    if (!showOutdated) {
      mainStories.removeWhere((e) {
        final plan = db.curUser.mainStoryOf(e.id);
        return e.isOutdated() && !plan.enabled;
      });
    }
    // first three chapters has the same startTimeJp
    mainStories.sort2((e) => e.id, reversed: reversed);
    return Column(
      children: <Widget>[
        if (!titleOnly)
          Material(
            elevation: 1,
            child: CustomTile(
              title: Text(S.current.main_story_chapter),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 56),
                    child: Text(
                      S.current.quest_fixed_drop_short,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 56),
                    child: Text(
                      S.current.quest_reward_short,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        Expanded(
          child: db.onUserData(
            (context, _) => ListView.builder(
              itemCount: mainStories.length,
              itemBuilder: (context, index) =>
                  buildOne(context, mainStories[index]),
            ),
          ),
        )
      ],
    );
  }

  Widget buildOne(BuildContext context, NiceWar record) {
    final plan = db.curUser.mainStoryOf(record.id);
    bool outdated = record.isOutdated();
    String shortName = record.lName.l;
    String longName = record.lLongName.l;
    String titleText = shortName;
    String subtitleText = longName.startsWith(shortName)
        ? longName.substring(shortName.length).trimChar(' -\n')
        : longName.replaceAll('\n', ' ');
    Widget? title, subtitle;
    title = AutoSizeText(
      titleText,
      maxLines: 2,
      // maxFontSize: 16,
      style: outdated
          ? TextStyle(color: Theme.of(context).textTheme.caption?.color)
          : null,
    );
    if (subtitleText.isNotEmpty) {
      subtitle = AutoSizeText(
        subtitleText,
        maxLines: 1,
      );
    }

    Widget tile = ListTile(
      title: title,
      subtitle: subtitle,
      trailing: titleOnly
          ? null
          : Wrap(
              children: [
                Switch.adaptive(
                  value: plan.fixedDrop,
                  onChanged: (v) {
                    plan.fixedDrop = v;
                    db.itemCenter.updateMainStory();
                  },
                ),
                Switch.adaptive(
                  value: plan.questReward,
                  onChanged: (v) {
                    plan.questReward = v;
                    db.itemCenter.updateMainStory();
                  },
                ),
              ],
            ),
      onTap: () {
        router.popDetailAndPush(
          url: Routes.warI(record.id),
          detail: true,
          popDetail: SplitRoute.of(context)?.detail != true,
        );
      },
    );
    if (showSpecialRewards) {
      List<Widget> rewards = [];
      final entries = record.itemReward.entries.toList();
      entries.sort((a, b) => Item.compare(a.key, b.key));
      for (final entry in entries) {
        if (entry.value <= 0) continue;
        final objectId = entry.key;
        if ([
          Items.grailId,
          Items.crystalId,
          // Items.rarePrismId,
          // Items.hpFou4,
          // Items.atkFou4,
        ].contains(objectId)) {
          rewards.add(Item.iconBuilder(
            context: context,
            item: null,
            itemId: objectId,
            width: 32,
            text: entry.value.format(),
          ));
        }
      }

      if (rewards.isNotEmpty) {
        tile = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile,
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 4),
              child: Wrap(
                spacing: 1,
                children: rewards,
              ),
            )
          ],
        );
      }
    }
    return tile;
  }
}
