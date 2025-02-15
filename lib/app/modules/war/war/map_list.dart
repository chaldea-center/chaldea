import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'war_map.dart';

class WarMapListPage extends StatelessWidget {
  final NiceWar war;
  const WarMapListPage({super.key, required this.war});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.war_map)),
      body: ListView(
        children:
            war.maps.map((map) {
              return ListTile(
                title: Text('${S.current.war_map} ${map.id}'),
                onTap: () {
                  router.push(child: WarMapPage(war: war, map: map));
                },
              );
            }).toList(),
      ),
    );
  }
}
