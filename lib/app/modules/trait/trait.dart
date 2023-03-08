import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'tabs/buff_tab.dart';
import 'tabs/enemy_tab.dart';
import 'tabs/event.dart';
import 'tabs/func_tab.dart';
import 'tabs/skill.dart';
import 'tabs/sp_dmg.dart';
import 'tabs/svt_tab.dart';

class TraitDetailPage extends StatefulWidget {
  final int id;
  const TraitDetailPage({super.key, required this.id});

  @override
  State<TraitDetailPage> createState() => _TraitDetailPageState();
}

class _TraitDetailPageState extends State<TraitDetailPage> {
  int get id => widget.id;

  @override
  Widget build(BuildContext context) {
    String name = Transl.trait(id).l;
    String title = '${S.current.trait} $id';
    if (name != id.toString()) {
      title += ' - $name';
    }
    bool isEventTrait = Transl.md.eventTrait.containsKey(id) || Transl.md.fieldTrait.containsKey(id);
    return DefaultTabController(
      length: isEventTrait ? 7 : 6,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            title,
            overflow: TextOverflow.fade,
            maxLines: 1,
            minFontSize: 14,
          ),
          bottom: FixedHeight.tabBar(TabBar(isScrollable: true, tabs: [
            if (isEventTrait) Tab(text: S.current.event),
            Tab(text: S.current.servant),
            Tab(text: S.current.enemy),
            Tab(text: S.current.super_effective_damage),
            const Tab(text: "Func"),
            const Tab(text: "Buff"),
            Tab(text: S.current.skill),
          ])),
        ),
        body: ListTileTheme(
          data: const ListTileThemeData(horizontalTitleGap: 8),
          child: TabBarView(
            children: [
              if (isEventTrait) TraitEventTab(id),
              TraitServantTab(id),
              TraitEnemyTab(id),
              TraitSPDMGTab(id),
              TraitFuncTab(id),
              TraitBuffTab(id),
              TraitSkillTab(id),
            ],
          ),
        ),
      ),
    );
  }
}
