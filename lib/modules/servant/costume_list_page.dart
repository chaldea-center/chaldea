import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/costume_detail_page.dart';

class CostumeListPage extends StatefulWidget {
  const CostumeListPage({Key? key}) : super(key: key);

  @override
  _CostumeListPageState createState() => _CostumeListPageState();
}

class _CostumeListPageState extends State<CostumeListPage> {
  @override
  Widget build(BuildContext context) {
    final costumes = db.gameData.costumes.values.toList();
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text(S.current.costume)),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final costume = costumes[index];
          return ListTile(
            leading: db.getIconImage(
              costume.icon,
              aspectRatio: 132 / 144,
              // padding: EdgeInsets.symmetric(vertical: 0),
            ),
            title: Text(costume.lName),
            subtitle: Text(
                'No.${costume.no} / ${db.gameData.servants[costume.svtNo]?.info.localizedName}'),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => CostumeDetailPage(costume: costume),
              );
            },
          );
        },
        separatorBuilder: (_, __) => kDefaultDivider,
        itemCount: db.gameData.costumes.length,
      ),
    );
  }
}
