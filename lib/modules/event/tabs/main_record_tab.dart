import 'package:chaldea/components/components.dart';

class MainRecordTab extends StatefulWidget {
  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text('Main Records Tab'),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
