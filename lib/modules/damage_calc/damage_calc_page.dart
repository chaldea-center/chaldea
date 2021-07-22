import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';

class DamageCalcPage extends StatefulWidget {
  @override
  _DamageCalcPageState createState() => _DamageCalcPageState();
}

class _DamageCalcPageState extends State<DamageCalcPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).calculator),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                SplitRoute.push(context, ServantListPage(), detail: false);
              }),
          IconButton(icon: Icon(Icons.replay), onPressed: () {}),
          IconButton(icon: Icon(Icons.save), onPressed: () {})
        ],
      ),
      body: ListView(
        children: <Widget>[
          SHeader('Enemies'),
          CustomTable(
            children: <Widget>[
              CustomTableRow(
                children: [
                  TableCellData(
                      child: Text(
                    'Enemy 1\nCaster，天，HP 20200',
                    textAlign: TextAlign.center,
                  )),
                  TableCellData(child: Text('Enemy 2')),
                  TableCellData(child: Text('Enemy 3')),
                ],
              )
            ],
          ),
          SHeader('Servant'),
          ListTile(
            title: Text('阿尔托莉雅Alter'),
            onTap: () {},
          ),
          SHeader('Partner Buff'),
          ListTile(
            title: Text('Buffs'),
          ),
          SHeader('魔术礼装'),
          ListTile(
            title: Text('战斗服 10/0/10'),
          ),
        ],
      ),
    );
  }
}
