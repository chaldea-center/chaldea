import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBonusTab extends HookWidget {
  final Event event;
  const EventBonusTab({super.key, required this.event});

  Widget ceDetail(BuildContext context, CraftEssence ce) {
    StringBuffer subtitle = StringBuffer(Transl.ceObtain(ce.extra.obtain).l);
    subtitle.write(' HP ${ce.hpBase == ce.hpMax ? ce.hpBase.toString() : '${ce.hpBase}/${ce.hpMax}'}');
    subtitle.write(' ATK ${ce.atkBase == ce.atkMax ? ce.atkBase.toString() : '${ce.atkBase}/${ce.atkMax}'}');
    List<Widget> children = [
      ListTile(
        leading: ce.iconBuilder(context: context),
        title: Text(ce.lName.l, maxLines: 1),
        subtitle: Text(subtitle.toString()),
        onTap: ce.routeTo,
      )
    ];

    int? _lastTag;
    for (final skill in ce.skills.where((skill) => skill.isEventSkill(event))) {
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
  Widget build(BuildContext context) {
    List<Widget> ceWidgets = [], svtWidgets = [];
    final eventCEs =
        db.gameData.craftEssences.values.where((e) => e.skills.any((skill) => skill.isEventSkill(event))).toList();
    eventCEs.sort2((e) => e.collectionNo);

    for (final ce in eventCEs) {
      ceWidgets.add(ceDetail(context, ce));
    }

    Map<int, BaseSkill> eventSkills = {};
    Map<int, List<Servant>> svts = {};

    for (final svt in db.gameData.servantsNoDup.values) {
      for (final skill in svt.extraPassive) {
        if (skill.isEventSkill(event)) {
          svts.putIfAbsent(skill.id, () => []).add(svt);
          eventSkills[skill.id] ??= skill;
        }
      }
    }
    svts = sortDict(svts);

    for (final skillId in svts.keys) {
      final group = svts[skillId]!
        ..sort((a, b) => SvtFilterData.compare(a, b,
            keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no], reversed: [false, true, true]));
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
            children: group.map((e) => e.iconBuilder(context: context)).toList(),
          ),
        ],
      ));
    }
    List<Widget> tabs = [
      if (ceWidgets.isNotEmpty)
        Tab(
          child: Text(S.current.craft_essence, style: Theme.of(context).textTheme.bodyMedium),
        ),
      if (svtWidgets.isNotEmpty)
        Tab(
          child: Text(S.current.servant, style: Theme.of(context).textTheme.bodyMedium),
        )
    ];
    if (tabs.isEmpty) return const SizedBox();
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          if (tabs.length > 1) FixedHeight.tabBar(TabBar(tabs: tabs)),
          Expanded(
            child: TabBarView(
              children: [
                for (var children in [ceWidgets, svtWidgets].where((e) => e.isNotEmpty))
                  ListView.builder(
                    controller: useScrollController(),
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
