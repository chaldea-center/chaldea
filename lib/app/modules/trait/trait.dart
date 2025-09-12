import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'tabs/buff_tab.dart';
import 'tabs/enemy_tab.dart';
import 'tabs/event.dart';
import 'tabs/field_tab.dart';
import 'tabs/func_tab.dart';
import 'tabs/skill.dart';
import 'tabs/sp_dmg.dart';
import 'tabs/svt_tab.dart';

class TraitDetailPage extends StatefulWidget {
  final List<int> ids;
  TraitDetailPage({super.key, required int id}) : ids = [id];
  TraitDetailPage.ids({super.key, required List<int> ids}) : ids = ids.isEmpty ? [0] : ids;

  @override
  State<TraitDetailPage> createState() => _TraitDetailPageState();
}

class _TraitDetailPageState extends State<TraitDetailPage> {
  late List<int> ids = widget.ids;
  late final _id = ids.firstOrNull ?? 0;

  @override
  Widget build(BuildContext context) {
    String title;
    if (ids.length == 1) {
      final id = ids.first;
      String name = Transl.traitName(id);
      title = '${S.current.trait} $id';
      if (name != id.toString()) {
        title += ' - $name';
      }
    } else {
      title = '${S.current.trait} ${ids.map((e) => Transl.traitName(e)).join(" & ")}';
    }
    bool isEventTrait =
        ids.length == 1 && (Transl.md.eventTrait.containsKey(_id) || Transl.md.fieldTrait.containsKey(_id));
    return DefaultTabController(
      length: isEventTrait ? 8 : 7,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(title, overflow: TextOverflow.fade, maxLines: 1, minFontSize: 14),
          bottom: FixedHeight.tabBar(
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                if (isEventTrait) Tab(text: S.current.event),
                Tab(text: S.current.servant),
                Tab(text: S.current.enemy),
                Tab(text: S.current.super_effective_damage),
                Tab(text: S.current.quest),
                const Tab(text: "Func"),
                const Tab(text: "Buff"),
                Tab(text: S.current.skill),
              ],
            ),
          ),
        ),
        body: ListTileTheme(
          data: const ListTileThemeData(horizontalTitleGap: 8),
          child: TabBarView(
            children: [
              if (isEventTrait) TraitEventTab(_id),
              TraitServantTab(ids),
              TraitEnemyTab(ids),
              TraitSPDMGTab(ids),
              TraitFieldTab(ids),
              TraitFuncTab(ids),
              TraitBuffTab(ids),
              TraitSkillTab(ids),
            ],
          ),
        ),
      ),
    );
  }
}
