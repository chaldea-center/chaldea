import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ServantListPage extends StatefulWidget {
  ServantListPage({Key? key}) : super(key: key);

  @override
  _ServantListPageState createState() => _ServantListPageState();
}

class _ServantListPageState extends State<ServantListPage>
    with SearchableListState<Servant, ServantListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servant List')),
    );
  }

  @override
  bool filter(Servant svt) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  String getSummary(Servant svt) {
    // TODO: implement getSummary
    throw UnimplementedError();
  }

  @override
  Widget gridItemBuilder(Servant svt) {
    // TODO: implement gridItemBuilder
    throw UnimplementedError();
  }

  @override
  Widget listItemBuilder(Servant svt) {
    // TODO: implement listItemBuilder
    throw UnimplementedError();
  }

  @override
  Iterable<Servant> get wholeData => db2.gameData.servants.values;
}
