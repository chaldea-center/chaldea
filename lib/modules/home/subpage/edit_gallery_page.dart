import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';

class EditGalleryPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_EditGalleryPageState();

}

class _EditGalleryPageState extends State<EditGalleryPage>{
  @override
  Widget build(BuildContext context) {
    List<Widget> tiles=[];
    GalleryItem.allItems.forEach((key,item){
      if(key!=GalleryItem.more){
        tiles.add(SwitchListTile.adaptive(
          value: db.userData.galleries[key],
          onChanged: (bool _selected){
            db.userData.galleries[key]=_selected;
            db.onAppUpdate();
          },
          title: Text(item.title),
        ));
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text('Edit galleries'),leading: BackButton(),),
      body: ListView(
        children: tiles,
      ),
    );
  }
}