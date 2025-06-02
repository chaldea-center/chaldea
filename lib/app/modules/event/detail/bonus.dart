import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/servant/filter.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBonusTab extends StatefulWidget {
  final Event event;
  const EventBonusTab({super.key, required this.event});

  @override
  State<EventBonusTab> createState() => _EventBonusTabState();
}

class _EventBonusTabState extends State<EventBonusTab> {
  final svtFilterData = SvtFilterData()..reset();

  @override
  Widget build(BuildContext context) {
    List<Widget> ceWidgets = [], svtWidgets = [];
    // ce
    final eventCEs = db.gameData.craftEssences.values.where((e) => e.eventSkills(widget.event.id).isNotEmpty).toList();
    eventCEs.sort2((e) => e.collectionNo);
    for (final ce in eventCEs) {
      ceWidgets.add(ceDetail(ce));
    }

    // svt
    Map<int, BaseSkill> eventSkills = {};
    Map<int, List<Servant>> svts = {};
    for (final svt in db.gameData.servantsNoDup.values) {
      for (final skill in svt.eventSkills(eventId: widget.event.id, includeZero: false)) {
        svts.putIfAbsent(skill.id, () => []).add(svt);
        eventSkills[skill.id] ??= skill;
      }
    }
    svts = sortDict(svts);

    for (final skillId in svts.keys) {
      svtWidgets.add(svtDetail(eventSkills[skillId]!, svts[skillId]!));
    }

    List<Widget> tabs = [
      if (svtWidgets.isNotEmpty) Tab(child: Text(S.current.servant, style: Theme.of(context).textTheme.bodyMedium)),
      if (ceWidgets.isNotEmpty)
        Tab(child: Text(S.current.craft_essence, style: Theme.of(context).textTheme.bodyMedium)),
    ];
    List<Widget> views = [
      if (svtWidgets.isNotEmpty)
        Column(
          children: [
            Expanded(
              child: ListView.builder(itemBuilder: (context, index) => svtWidgets[index], itemCount: svtWidgets.length),
            ),
            SafeArea(child: buttonBar),
          ],
        ),
      if (ceWidgets.isNotEmpty)
        ListView.builder(itemBuilder: (context, index) => ceWidgets[index], itemCount: ceWidgets.length),
    ];
    if (tabs.isEmpty) return const SizedBox();
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          if (tabs.length > 1) FixedHeight.tabBar(TabBar(tabs: tabs)),
          Expanded(child: TabBarView(children: views)),
        ],
      ),
    );
  }

  Widget svtDetail(BaseSkill skill, List<Servant> servants) {
    servants.retainWhere((e) => ServantFilterPage.filter(svtFilterData, e));
    servants.sort(
      (a, b) => SvtFilterData.compare(
        a,
        b,
        keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
        reversed: [false, true, true],
      ),
    );
    return TileGroup(
      children: [
        SkillDescriptor(
          skill: skill,
          hideDetail: true,
          // showBuffDetail: true,
          showEvent: false,
        ),
        GridView.extent(
          maxCrossAxisExtent: 48,
          childAspectRatio: 132 / 144,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 10),
          children: [
            for (final svt in servants)
              svt.iconBuilder(
                context: context,
                text: svt.status.favorite ? 'NP${svt.status.cur.npLv}' : null,
                option: ImageWithTextOption(
                  alignment: Alignment.bottomLeft,
                  fontSize: 12,
                  padding: const EdgeInsets.only(bottom: 4),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget ceDetail(CraftEssence ce) {
    StringBuffer subtitle = StringBuffer(Transl.ceObtain(ce.extra.obtain).l);
    subtitle.write(' HP ${ce.hpBase == ce.hpMax ? ce.hpBase.toString() : '${ce.hpBase}/${ce.hpMax}'}');
    subtitle.write(' ATK ${ce.atkBase == ce.atkMax ? ce.atkBase.toString() : '${ce.atkBase}/${ce.atkMax}'}');
    List<Widget> children = [
      ListTile(
        leading: ce.iconBuilder(context: context),
        title: Text(ce.lName.l, maxLines: 1),
        subtitle: Text(subtitle.toString()),
        onTap: ce.routeTo,
      ),
    ];

    int? _lastTag;
    for (final skill in ce.eventSkills(widget.event.id)) {
      final tag = Object.hash(skill.icon, skill.lName.l);
      if (_lastTag != tag) {
        children.add(
          ListTile(
            leading: db.getIconImage(skill.icon, height: 28),
            title: Text(skill.lName.l, textScaler: const TextScaler.linear(0.8)),
            // horizontalTitleGap: 4,
          ),
        );
      } else {
        children.add(kIndentDivider);
      }
      _lastTag = tag;
      children.addAll(
        FuncsDescriptor.describe(
          funcs: skill.functions,
          script: skill.script,
          showPlayer: true,
          showEnemy: false,
          showEvent: false,
        ),
      );
    }

    return TileGroup(children: children);
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.filter_alt),
          label: Text(S.current.filter),
          onPressed: () => FilterPage.show(
            context: context,
            builder: (context) => ServantFilterPage(
              filterData: svtFilterData,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
              planMode: false,
            ),
          ),
        ),
      ],
    );
  }
}
