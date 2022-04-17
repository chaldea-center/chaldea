import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class MainStoryTab extends StatelessWidget {
  final bool reversed;
  final bool showOutdated;
  final bool showSpecialRewards;
  final ScrollController scrollController;
  final bool titleOnly;

  const MainStoryTab({
    Key? key,
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    required this.scrollController,
    this.titleOnly = false,
  }) : super(key: key);

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
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    return Column(
      children: <Widget>[
        if (!titleOnly)
          Material(
            child: CustomTile(
              title: Text(S.of(context).main_record_chapter),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.of(context).quest_fixed_drop_short),
                  const SizedBox(width: 6),
                  Text(S.of(context).quest_reward_short)
                ],
              ),
            ),
            elevation: 1,
          ),
        Expanded(
          child: db.onUserData(
            (context, _) => ListView(
              controller: scrollController,
              children: mainStories.map((record) {
                final plan = db.curUser.mainStoryOf(record.id);
                bool outdated = record.isOutdated();
                String originTitle = record.lLongName.l.trim();
                String titleText;
                String? subtitleText;
                if (originTitle.contains('\n')) {
                  titleText = originTitle.split('\n').first;
                  subtitleText = originTitle.substring(titleText.length + 1);
                } else {
                  titleText = originTitle;
                }
                Widget? title, subtitle;
                title = AutoSizeText(
                  titleText,
                  maxLines: subtitleText == null ? 2 : 1,
                  // maxFontSize: 16,
                  style: outdated ? TextStyle(color: _outdatedColor) : null,
                );
                if (subtitleText != null) {
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
                    router.push(url: Routes.warI(record.id), detail: true);
                  },
                );
                if (showSpecialRewards) {
                  if (showSpecialRewards) {
                    // tile = EventBasePage.buildSpecialRewards(
                    //     context, record, tile);
                  }
                }
                return tile;
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
