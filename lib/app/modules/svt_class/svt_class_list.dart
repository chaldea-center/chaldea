import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtClassListPage extends StatelessWidget {
  const SvtClassListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clsIds = {
      ...db.gameData.constData.classInfo.keys,
      ...SvtClass.values.map((e) => e.id)
    }.where((e) => e != 0).toList();
    clsIds.sort();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.filter_sort_class),
        actions: [
          IconButton(
            onPressed: () {
              FullscreenImageViewer.show(context: context, urls: [
                for (final region in Region.values)
                  Atlas.asset('ClassIcons/img_classchart.png', region),
              ]);
            },
            icon: const Icon(Icons.sync_alt_rounded),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final clsId = clsIds[index];
          final clsInfo = db.gameData.constData.classInfo[clsId];
          return ListTile(
            leading: db.getIconImage(SvtClassX.clsIcon(5, clsInfo?.iconImageId),
                width: 36),
            title: Text(Transl.svtClassId(clsId).l),
            subtitle: Text('No.$clsId'),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              SvtClassX.routeTo(clsId);
            },
          );
        },
        itemCount: clsIds.length,
      ),
    );
  }
}
