import 'package:chaldea/components/components.dart';

class MainRecordDetailPage extends StatefulWidget {
  final String name;

  const MainRecordDetailPage({Key key, this.name}) : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage> {
  @override
  Widget build(BuildContext context) {
    final record = db.gameData.events.mainRecords[widget.name];

    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text(widget.name)),
      body: ListView(
        children: <Widget>[

        ],
      ),
    );
  }
}
