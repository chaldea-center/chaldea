import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtTreasureDeviceTab extends SvtTabBaseWidget {
  SvtTreasureDeviceTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  _SvtTreasureDeviceTabState createState() =>
      _SvtTreasureDeviceTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtTreasureDeviceTabState extends SvtTabBaseState<SvtTreasureDeviceTab>
    with AutomaticKeepAliveClientMixin {
  _SvtTreasureDeviceTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);

  Widget buildHeader(TreasureDevice np, int tdNo) {
    Widget tdHeader = CustomTile(
      leading: Column(
        children: <Widget>[
          Image.file(
            db.getIconFile(np.color),
            height: 110 * 0.9,
          ),
          Text(
            '${np.typeText} ${np.rank}',
            style: TextStyle(fontSize: 14, color: Colors.black),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(np.upperName,
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          Text(np.name, style: TextStyle(fontWeight: FontWeight.w600)),
          Text(np.upperNameJp,
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          Text(np.nameJp, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    if (svt.treasureDevice.length <= 1) {
      return tdHeader;
    } else {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: ToggleButtons(
              constraints: BoxConstraints(),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: svt.treasureDevice.map((td) {
                String iconKey = td.state.contains('强化前')
                    ? '宝具未强化'
                    : td.state.contains('强化后') ? '宝具强化' : null;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: iconKey == null
                      ? Text(td.state)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.file(db.getIconFile(iconKey),
                                height: 110 * 0.2),
                            Text(td.state)
                          ],
                        ),
                );
              }).toList(),
              isSelected: List.generate(svt.treasureDevice.length, (i) {
                return tdNo == i;
              }),
              onPressed: (no) {
                setState(() {
                  plan.treasureDeviceEnhanced = no;
                });
              },
            ),
          ),
          tdHeader
        ],
      );
    }
  }

  List<Widget> buildEffect(Effect effect) {
    assert([1, 5].contains(effect.lvData.length), '$effect');
    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          subtitle: Text(effect.description),
          trailing: effect.lvData.length == 1
              ? Text(formatNumToString(effect.lvData[0], effect.valueType))
              : null),
      if (effect.lvData.length > 1)
        CustomTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            title: GridView.count(
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              children: List.generate(effect.lvData.length, (index) {
                return Align(
                  alignment: Alignment.center,
                  child: Text(
                    formatNumToString(effect.lvData[index], effect.valueType),
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }),
            ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.treasureDevice == null || svt.treasureDevice.length == 0) {
      return Container(child: Center(child: Text('No NobelPhantasm Data')));
    }
    int tdNo = plan.treasureDeviceEnhanced ??
        (svt.treasureDevice.first.enhanced ? 1 : 0);
    final np = svt.treasureDevice[tdNo];
    return ListView(
      children: <Widget>[
        TileGroup(
          tiles: <Widget>[
            buildHeader(np, tdNo),
            for (Effect e in np.effects) ...buildEffect(e)
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
