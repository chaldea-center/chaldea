import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/elements/gallery_item.dart';

class EditGalleryPage extends StatefulWidget {
  EditGalleryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditGalleryPageState();
}

class _EditGalleryPageState extends State<EditGalleryPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    GalleryItem.allItems.forEach((item) {
      if (!GalleryItem.persistentPages.contains(item)) {
        tiles.add(SwitchListTile.adaptive(
          value: db.userData.galleries[item.name] ?? true,
          onChanged: (bool _selected) {
            db.userData.galleries[item.name] = _selected;
            db.notifyAppUpdate();
            setState(() {});
          },
          title: Text(item.titleBuilder()),
          secondary: item.buildIcon(context, size: 24),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedText.of(
            chs: '编辑主页', jpn: 'ホームページの編集', eng: 'Edit Homepage', kor: '홈페이지 편집')),
      ),
      body: ListView(children: divideTiles(tiles, bottom: true)),
    );
  }
}
