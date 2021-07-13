import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/elements/gallery_item.dart';

class EditGalleryPage extends StatefulWidget {
  final Map<String, GalleryItem> galleries;

  EditGalleryPage({Key? key, this.galleries = const {}}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditGalleryPageState();
}

class _EditGalleryPageState extends State<EditGalleryPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    widget.galleries.forEach((name, item) {
      if (!GalleryItem.persistentPages.contains(name)) {
        tiles.add(SwitchListTile.adaptive(
          value: db.userData.galleries[name] ?? true,
          onChanged: (bool _selected) {
            db.userData.galleries[name] = _selected;
            db.notifyAppUpdate();
          },
          title: Text(item.title),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedText.of(
            chs: '编辑主页', jpn: 'ホームページの編集', eng: 'Edit Homepage')),
        leading: BackButton(),
      ),
      body: ListView(children: divideTiles(tiles, bottom: true)),
    );
  }
}
