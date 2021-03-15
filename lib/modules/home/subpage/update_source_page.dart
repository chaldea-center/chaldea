import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UpdateSourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpdateSourcePageState();
}

class _UpdateSourcePageState extends State<UpdateSourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).download_source),
        leading: BackButton(),
      ),
      body: TileGroup(
        scrollable: true,
        children: [
          ListTile(
            leading: FaIcon(FontAwesomeIcons.github),
            title: Text('Chaldea APP @Github'),
            subtitle: Text('$kProjectHomepage/releases'),
            horizontalTitleGap: 0,
            onTap: () {
              jumpToExternalLinkAlert(url: '$kProjectHomepage/releases');
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.github),
            title: Text('Dataset @Github'),
            subtitle: Text('$kDatasetHomepage/releases'),
            horizontalTitleGap: 0,
            onTap: () {
              jumpToExternalLinkAlert(url: '$kDatasetHomepage/releases');
            },
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
