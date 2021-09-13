import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';

class DamageCalcPage extends StatefulWidget {
  DamageCalcPage({Key? key}) : super(key: key);

  @override
  _DamageCalcPageState createState() => _DamageCalcPageState();
}

class _DamageCalcPageState extends State<DamageCalcPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).calculator),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                SplitRoute.push(context, ServantListPage(), detail: false);
              }),
          IconButton(icon: const Icon(Icons.replay), onPressed: () {}),
          IconButton(icon: const Icon(Icons.save), onPressed: () {})
        ],
      ),
      body: ListView(
        children: <Widget>[
          const SHeader('Enemies'),
          CustomTable(
            children: <Widget>[
              CustomTableRow(
                children: [
                  TableCellData(
                      child: const Text(
                    'Enemy 1\nCaster，天，HP 20200',
                    textAlign: TextAlign.center,
                  )),
                  TableCellData(child: const Text('Enemy 2')),
                  TableCellData(child: const Text('Enemy 3')),
                ],
              )
            ],
          ),
          const SHeader('Servant'),
          ListTile(
            title: const Text('阿尔托莉雅Alter'),
            onTap: () {},
          ),
          const SHeader('Partner Buff'),
          const ListTile(
            title: Text('Buffs'),
          ),
          const SHeader('魔术礼装'),
          const ListTile(
            title: Text('战斗服 10/0/10'),
          ),
        ],
      ),
    );
  }
}
