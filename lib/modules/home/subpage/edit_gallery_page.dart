import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';

class EditGalleryPage extends StatefulWidget {
  final Map<String, GalleryItem> galleries;

  const EditGalleryPage({Key key, this.galleries}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditGalleryPageState();
}

class _EditGalleryPageState extends State<EditGalleryPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    widget.galleries?.forEach((name, item) {
      if (name != GalleryItem.more) {
        tiles.add(SwitchListTile.adaptive(
          value: db.userData.galleries[name] ?? true,
          onChanged: (bool _selected) {
            db.userData.galleries[name] = _selected;
            db.onAppUpdate();
          },
          title: Text(item.titleBuilder(context)),
        ));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit galleries'),
        leading: BackButton(),
      ),
      body: ListView(
        children: tiles,
      ),
    );
  }
}
