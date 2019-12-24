import 'package:chaldea/components/components.dart';

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

class GalleryItem {
  static const String servant = 'servant';
  static const String craft_essential = 'craft';
  static const String cmd_code = 'cmd_code';
  static const String item = 'item';
  static const String event = 'event';
  static const String drop_calculator = 'drop_calculator';
  static const String plan = 'plan';
  static const String gacha = 'gacha';
  static const String calculator = 'calculator';
  static const String master_equip = 'master_equip';
  static const String backup = 'backup';
  static const String more = 'more';

//  static Map<String, GalleryItem> allItems;

  // instant part
  final String name;
  final String Function(BuildContext context) titleBuilder;
  final IconData icon;
  final WidgetBuilder builder;
  final bool isDetail;

  const GalleryItem(
      {@required this.name,
      @required this.titleBuilder,
      @required this.icon,
      @required this.builder,
      this.isDetail = false})
      : assert(name != null),
        assert(titleBuilder != null),
        assert(icon != null),
        assert(builder != null);

  @override
  String toString() {
    return '$runtimeType($name)';
  }
}
