import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBonusTab extends StatelessWidget with PrimaryScrollMixin {
  final Event event;
  const EventBonusTab({super.key, required this.event});

  Widget ceDetail(BuildContext context, CraftEssence ce) {
    StringBuffer subtitle = StringBuffer(Transl.ceObtain(ce.extra.obtain).l);
    subtitle.write(
        ' HP ${ce.hpBase == ce.hpMax ? ce.hpBase.toString() : '${ce.hpBase}/${ce.hpMax}'}');
    subtitle.write(
        ' ATK ${ce.atkBase == ce.atkMax ? ce.atkBase.toString() : '${ce.atkBase}/${ce.atkMax}'}');
    List<Widget> children = [
      ListTile(
        leading: ce.iconBuilder(context: context),
        title: Text(ce.lName.l, maxLines: 1),
        subtitle: Text(subtitle.toString()),
      )
    ];

    int? _lastTag;
    for (final skill in ce.eventSkills(event)) {
      final tag = Object.hash(skill.icon, skill.lName.l);
      if (_lastTag != tag) {
        children.add(ListTile(
          leading: db.getIconImage(skill.icon, height: 28),
          title: Text(skill.lName.l, textScaleFactor: 0.8),
          horizontalTitleGap: 4,
        ));
      } else {
        children.add(kIndentDivider);
      }
      _lastTag = tag;
      children.addAll(FuncsDescriptor.describe(
        funcs: skill.functions,
        script: skill.script,
        showPlayer: true,
        showEnemy: false,
        showEvent: false,
      ));
    }

    return TileGroup(children: children);
  }

  @override
  Widget buildContent(BuildContext context) {
    List<Widget> ceWidgets = [], svtWidgets = [];
    final eventCEs = db.gameData.craftEssences.values
        .where((e) => e.eventSkills(event).isNotEmpty)
        .toList();
    eventCEs.sort2((e) => e.collectionNo);

    for (final ce in eventCEs) {
      ceWidgets.add(ceDetail(context, ce));
    }

    Map<int, BaseSkill> eventSkills = {};
    Map<int, List<Servant>> svts = {};

    for (final svt in db.gameData.servantsNoDup.values) {
      for (final skill in svt.extraPassive) {
        if (skill.isEventSkill(event.id)) {
          svts.putIfAbsent(skill.id, () => []).add(svt);
          eventSkills[skill.id] ??= skill;
        }
      }
    }
    svts = sortDict(svts);

    for (final skillId in svts.keys) {
      final group = svts[skillId]!
        ..sort((a, b) => SvtFilterData.compare(a, b,
            keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
            reversed: [false, true, true]));
      svtWidgets.add(TileGroup(
        children: [
          SkillDescriptor(
            skill: eventSkills[skillId]!,
            hideDetail: true,
            showBuffDetail: true,
            showEvent: false,
          ),
          GridView.extent(
            maxCrossAxisExtent: 48,
            childAspectRatio: 132 / 144,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.only(start: 16, end: 10),
            children:
                group.map((e) => e.iconBuilder(context: context)).toList(),
          ),
        ],
      ));
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          FixedHeight.tabBar(
            TabBar(
              tabs: [
                for (var text in [S.current.craft_essence, S.current.servant])
                  Tab(
                    child: Text(text,
                        style: Theme.of(context).textTheme.bodyText2),
                  )
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (var children in [ceWidgets, svtWidgets])
                  ListView.builder(
                    itemBuilder: (context, index) => children[index],
                    itemCount: children.length,
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
