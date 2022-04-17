import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/craft_essence/craft.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../command_code/cmd_code.dart';

class SvtRelatedCardTab extends StatelessWidget {
  final Servant svt;

  const SvtRelatedCardTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [];
    List<Widget> pages = [];

    final bondCE = db.gameData.craftEssencesById[svt.bondEquip];
    if (bondCE != null) {
      tabs.add(S.current.bond_craft);
      pages.add(SingleChildScrollView(
        child: SafeArea(child: CraftDetailBasePage(ce: bondCE)),
      ));
    }

    final valentineCEs = svt.valentineEquip
        .map((e) => db.gameData.craftEssencesById[e])
        .whereType<CraftEssence>()
        .toList();
    if (valentineCEs.isNotEmpty) {
      tabs.add(S.current.valentine_craft);
      pages.add(ListView.separated(
        itemCount: valentineCEs.length,
        itemBuilder: (context, index) =>
            SafeArea(child: CraftDetailBasePage(ce: valentineCEs[index])),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      ));
    }

    final charaCEs = db.gameData.craftEssences.values
        .where((ce) => ce.extra.characters.contains(svt.collectionNo))
        .toList();
    final charaCCs = db.gameData.commandCodes.values
        .where((cc) => cc.extra.characters.contains(svt.collectionNo))
        .toList();
    if (charaCEs.isNotEmpty || charaCCs.isNotEmpty) {
      tabs.add(S.current.svt_related_ce);
      pages.add(ListView(
        children: [
          if (charaCEs.isNotEmpty)
            TileGroup(
              header: S.current.craft_essence,
              children: [
                for (final ce in charaCEs)
                  ListTile(
                    leading: ImageWithText(
                        image: db.getIconImage(ce.borderedIcon,
                            height: 45, width: 45 / 144 * 132)),
                    title: Text(ce.lName.l),
                    onTap: () {
                      router.push(
                        url: ce.route,
                        child: CraftDetailPage(
                          ce: ce,
                          onSwitch: (cur, next) =>
                              Utility.findNextOrPrevious<CraftEssence>(
                                  list: charaCEs, cur: cur, reversed: next),
                        ),
                        detail: true,
                      );
                    },
                  )
              ],
            ),
          if (charaCCs.isNotEmpty)
            TileGroup(
              header: S.current.command_code,
              children: [
                for (final cc in charaCCs)
                  ListTile(
                    leading: ImageWithText(
                        image: db.getIconImage(cc.icon,
                            height: 45, width: 45 / 144 * 132)),
                    title: Text(cc.lName.l),
                    onTap: () {
                      router.push(
                        url: cc.route,
                        child: CmdCodeDetailPage(
                          cc: cc,
                          onSwitch: (cur, next) =>
                              Utility.findNextOrPrevious<CommandCode>(
                                  list: charaCCs, cur: cur, reversed: next),
                        ),
                        detail: true,
                      );
                    },
                  ),
              ],
            ),
        ],
      ));
    }
    final tabbar = TabBar(
      isScrollable: true,
      tabs: tabs
          .map((e) =>
              Tab(child: Text(e, style: Theme.of(context).textTheme.bodyText2)))
          .toList(),
    );

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: SizedBox(height: 36, child: tabbar)),
            ],
          ),
          Expanded(child: TabBarView(children: pages)),
        ],
      ),
    );
  }
}
