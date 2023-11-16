import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class WarBgmListPage extends StatelessWidget {
  final List<int> bgmIds;
  const WarBgmListPage({super.key, required this.bgmIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.bgm)),
      body: ListView(
        children: bgmIds.map((id) {
          final bgm = db.gameData.bgms[id];
          if (bgm == null) return ListTile(title: Text('${S.current.bgm} $id'));
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
            leading: db.getIconImage(
              bgm.logo,
              aspectRatio: 124 / 60,
              width: 56,
            ),
            horizontalTitleGap: 8,
            title: Text(bgm.lName.l.setMaxLines(1), textScaler: const TextScaler.linear(1)),
            subtitle: Text('No.${bgm.id} ${bgm.fileName}', textScaler: const TextScaler.linear(1)),
            onTap: () {
              bgm.routeTo();
            },
          );
        }).toList(),
      ),
    );
  }
}
