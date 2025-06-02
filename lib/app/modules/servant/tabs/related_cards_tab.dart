import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/craft_essence/craft.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../command_code/cmd_code.dart';

class SvtRelatedCardTab extends StatelessWidget {
  final Servant svt;

  const SvtRelatedCardTab({super.key, required this.svt});

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [];
    List<Widget> pages = [];

    final bondCE = db.gameData.craftEssencesById[svt.bondEquip];
    if (bondCE != null) {
      tabs.add(S.current.bond_craft);
      pages.add(SingleChildScrollView(child: SafeArea(child: CraftDetailBasePage(ce: bondCE, enableLink: true))));
    }

    final valentineCEs =
        svt.valentineEquip.map((e) => db.gameData.craftEssencesById[e]).whereType<CraftEssence>().toList();
    if (valentineCEs.isNotEmpty) {
      tabs.add(S.current.valentine_craft);
      pages.add(
        ListView.separated(
          itemCount: valentineCEs.length,
          itemBuilder:
              (context, index) => SafeArea(child: CraftDetailBasePage(ce: valentineCEs[index], enableLink: true)),
          separatorBuilder: (_, _) => const SizedBox(height: 16),
        ),
      );
    }

    if (svt.isServantType && svt.collectionNo > 0) {
      final charaCEs =
          db.gameData.allCraftEssences.where((ce) => ce.extra.characters.contains(svt.collectionNo)).toList()
            ..sort2((e) => -e.collectionNo);
      final charaCCs =
          db.gameData.commandCodes.values.where((cc) => cc.extra.characters.contains(svt.collectionNo)).toList()
            ..sort2((e) => -e.collectionNo);
      if (charaCEs.isNotEmpty || charaCCs.isNotEmpty) {
        tabs.add(S.current.svt_related_ce);
        pages.add(
          ListView(
            children: [
              if (charaCEs.isNotEmpty)
                TileGroup(
                  header: S.current.craft_essence,
                  children: [
                    for (final ce in charaCEs)
                      ListTile(
                        leading: db.getIconImage(ce.borderedIcon, height: 45, width: 45 / 144 * 132),
                        title: Text(ce.lName.l),
                        onTap: () {
                          router.push(
                            url: ce.route,
                            child: CraftDetailPage(
                              ce: ce,
                              onSwitch:
                                  (cur, next) => Utility.findNextOrPrevious<CraftEssence>(
                                    list: charaCEs,
                                    cur: cur,
                                    reversed: next,
                                  ),
                            ),
                            detail: true,
                          );
                        },
                      ),
                  ],
                ),
              if (charaCCs.isNotEmpty)
                TileGroup(
                  header: S.current.command_code,
                  children: [
                    for (final cc in charaCCs)
                      ListTile(
                        leading: db.getIconImage(cc.icon, height: 45, width: 45 / 144 * 132),
                        title: Text(cc.lName.l),
                        onTap: () {
                          router.push(
                            url: cc.route,
                            child: CmdCodeDetailPage(
                              cc: cc,
                              onSwitch:
                                  (cur, next) =>
                                      Utility.findNextOrPrevious<CommandCode>(list: charaCCs, cur: cur, reversed: next),
                            ),
                            detail: true,
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        );
      }
    }
    final tabbar = TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      tabs: tabs.map((e) => Tab(child: Text(e, style: Theme.of(context).textTheme.bodyMedium))).toList(),
    );

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(children: <Widget>[Expanded(child: SizedBox(height: 36, child: tabbar))]),
          Expanded(child: TabBarView(children: pages)),
        ],
      ),
    );
  }
}
