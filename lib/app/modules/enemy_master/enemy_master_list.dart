import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'enemy_master.dart';

class EnemyMasterListPage extends StatefulWidget {
  const EnemyMasterListPage({super.key});

  @override
  State<EnemyMasterListPage> createState() => _EnemyMasterListPageState();
}

class _EnemyMasterListPageState extends State<EnemyMasterListPage>
    with RegionBasedState<List<EnemyMaster>, EnemyMasterListPage> {
  List<EnemyMaster> get masters => data!;

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  Future<List<EnemyMaster>?> fetchData(Region? r) async {
    return AtlasApi.enemyMasters(region: r ?? Region.jp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.enemy_master),
        actions: [
          dropdownRegion(),
          // popupMenu,
        ],
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<EnemyMaster> masters) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: masters.length,
      itemBuilder: (context, index) {
        final master = masters[index];
        // master.battles.sort2((e) => e.id);
        final battle = master.battles.getOrNull(0);
        // https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/BattleUIAtlas/frame_enemymaster_bg.png
        return ListTile(
          leading: battle == null
              ? const SizedBox.shrink()
              : Transform.rotate(
                  angle: -pi / 4,
                  child: db.getIconImage(battle.face, width: 36),
                ),
          title: Text(master.lName.l),
          subtitle: Text('No.${master.id}'),
          trailing: battle == null
              ? null
              : SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 2.0,
                      alignment: Alignment.topLeft,
                      child: db.getIconImage(battle.commandSpellIcon, width: 36, aspectRatio: 1),
                    ),
                  ),
                ),
          onTap: () {
            router.pushPage(EnemyMasterDetailPage(master: master));
          },
        );
      },
    );
  }
}
