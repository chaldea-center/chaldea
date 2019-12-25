import 'package:chaldea/components/components.dart';

class ItemPlanSolverPage extends StatefulWidget {
  @override
  _ItemPlanSolverPageState createState() => _ItemPlanSolverPageState();
}

class _ItemPlanSolverPageState extends State<ItemPlanSolverPage> {
  final solver = GLPKSolver();
  GLPKParams params = GLPKParams(minCoeff: 10);
  GLPKSolution solution;

  @override
  void initState() {
    super.initState();
    solver.initial(callback: () => setState(() {}));
  }

  @override
  void dispose() {
    solver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solution'),
        leading: BackButton(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Total Num: ${solution?.totalNum}'),
                  trailing: Text('Total AP: ${solution?.totalEff}'),
                ),
                ...buildPlaceRows()
              ],
            ),
          ),
          buildButtonBar(),
        ],
      ),
    );
  }

  List<Widget> buildPlaceRows() {
    return List.generate(solution?.variables?.length ?? 0, (i) {
      final variable = solution.variables[i];
      return ListTile(
        title: Text(variable.name),
        subtitle: Text(variable.detail.entries
            .map((e) => '${e.key}*${e.value}')
            .join(', ')),
        trailing: Text('${variable.value}*${variable.coeff} AP'),
      );
    });
  }

  Widget buildButtonBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(height: 1, thickness: 1),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Text('最低AP'),
            DropdownButton(
                value: params.minCoeff,
                items: List.generate(
                    20,
                    (i) =>
                        DropdownMenuItem(value: i, child: Text(i.toString()))),
                onChanged: (v) => params.minCoeff = v),
            Text('目标'),
            DropdownButton(
                value: params.coeffPrio,
                items: [
                  DropdownMenuItem(value: true, child: Text('AP')),
                  DropdownMenuItem(value: false, child: Text('次数'))
                ],
                onChanged: (v) => params.coeffPrio = v),
            Text('版本'),
            DropdownButton(
                value: params.maxColNum > 0,
                items: [
                  DropdownMenuItem(value: true, child: Text('国服')),
                  DropdownMenuItem(value: false, child: Text('日服'))
                ],
                onChanged: (v) =>
                    params.maxColNum = v ? db.gameData.glpk.cnMaxColNum : -1),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    params.addOne(db.gameData.glpk.rowNames.first, 50);
                  });
                }),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: solver.solverReady != true ? null : solve,
              child: Text('Solve', style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  void solve() async {
    showToast('To be improved!');
    if (1 > 2) {
      db.runtimeData.itemStatistics.update();
      params..objRows.clear()..objNums.clear();
      db.runtimeData.itemStatistics.leftItems.forEach((itemKey, value) {
        if (db.gameData.glpk.rowNames.contains(itemKey) && value < 0) {
          params.objRows.add(itemKey);
          params.objNums.add(-value);
        }
      });
      if (sum(params.objNums) > 0) {
        solution =
            await solver.calculate(data: db.gameData.glpk, params: params);
      } else {
        solution = GLPKSolution(totalEff: 0, totalNum: 0, variables: []);
      }
      setState(() {});
    }
  }
}
