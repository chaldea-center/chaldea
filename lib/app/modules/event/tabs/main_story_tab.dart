import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

class MainStoryTab extends StatelessWidget {
  final bool reversed;
  final bool showOutdated;
  final bool showSpecialRewards;
  final ScrollController scrollController;

  const MainStoryTab({
    Key? key,
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<NiceWar> mainStories = db2.gameData.mainStories.values.toList();
    if (!showOutdated) {
      mainStories.removeWhere((e) {
        final plan = db2.curUser.mainStoryOf(e.id);
        return e.isOutdated() && !plan.enabled;
      });
    }
    // first three chapters has the same startTimeJp
    mainStories.sort2((e) => e.id, reversed: reversed);
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    return Column(
      children: <Widget>[
        Material(
          child: CustomTile(
            title: Text(S.of(context).main_record_chapter),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(S.of(context).main_record_fixed_drop),
                const SizedBox(width: 6),
                Text(S.of(context).main_record_bonus)
              ],
            ),
          ),
          elevation: 1,
        ),
        Expanded(
          child: db2.onUserData(
            (context, _) => ListView(
              controller: scrollController,
              children: mainStories.map((record) {
                final plan = db2.curUser.mainStoryOf(record.id);
                bool outdated = record.isOutdated();
                Widget? title, subtitle;
                title = AutoSizeText(
                  record.lLongName.l,
                  maxLines: 2,
                  maxFontSize: 16,
                  style: outdated ? TextStyle(color: _outdatedColor) : null,
                );
                Widget tile = ListTile(
                  title: title,
                  subtitle: subtitle,
                  trailing: Wrap(
                    children: [
                      Switch.adaptive(
                        value: plan.fixedDrop,
                        onChanged: (v) {
                          plan.fixedDrop = v;
                          db2.itemCenter.updateMainStory();
                        },
                      ),
                      Switch.adaptive(
                        value: plan.questReward,
                        onChanged: (v) {
                          plan.questReward = v;
                          db2.itemCenter.updateMainStory();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // SplitRoute.push(
                    //   context,
                    //   MainRecordDetailPage(record: record),
                    //   popDetail: true,
                    // );
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
