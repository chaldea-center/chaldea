import 'package:chaldea/components/components.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssential ce;

  const CraftDetailPage({Key key, this.ce}) : super(key: key);

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.ce.name),
      ),
      body: Center(
        child: Text(widget.ce.name),
      ),
    );
  }
}
