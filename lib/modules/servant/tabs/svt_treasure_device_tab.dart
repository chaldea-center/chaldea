import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtTreasureDeviceTab extends SvtTabBaseWidget {
  SvtTreasureDeviceTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtTreasureDeviceTabState createState() =>
      _SvtTreasureDeviceTabState(parent: parent, svt: svt, plan: status);
}

class _SvtTreasureDeviceTabState extends SvtTabBaseState<SvtTreasureDeviceTab> {
  _SvtTreasureDeviceTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.treasureDevice == null || svt.treasureDevice.length == 0) {
      return Container(child: Center(child: Text('No NobelPhantasm Data')));
    }
    if (status.treasureDeviceEnhanced == null ||
        status.treasureDeviceEnhanced >= svt.treasureDevice.length) {}
    int tdNo = status.treasureDeviceEnhanced;
    if (tdNo == null || tdNo < 0 || tdNo >= svt.treasureDevice.length) {
      tdNo =
          svt.treasureDevice.first.enhanced ? svt.treasureDevice.length - 1 : 0;
    }
    final td = svt.treasureDevice[tdNo];
    return ListView(
      children: <Widget>[
        TileGroup(
          children: <Widget>[
            buildToggle(tdNo),
            buildHeader(td),
            for (Effect e in td.effects) ...buildEffect(e)
          ],
        )
      ],
    );
  }

  Widget buildToggle(int selected) {
    if (svt.treasureDevice.length <= 1) {
      return Container();
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 4),
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
                        Image(
                            image: db.getIconImage(iconKey), height: 110 * 0.2),
                        Text(td.state)
                      ],
                    ),
            );
          }).toList(),
          isSelected: List.generate(svt.treasureDevice.length, (i) {
            return selected == i;
          }),
          onPressed: (no) {
            setState(() {
              status.treasureDeviceEnhanced = no;
            });
          },
        ),
      ),
    );
  }

  Widget buildHeader(TreasureDevice td) {
    return CustomTile(
      leading: Column(
        children: <Widget>[
          Image(
            image: db.getIconImage(td.color),
            width: 110 * 0.9,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 110 * 0.9),
            child: Text(
              '${td.typeText} ${td.rank}',
              style: TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(
            td.upperName,
            style: TextStyle(fontSize: 16, color: Colors.black54),
            maxLines: 1,
          ),
          AutoSizeText(
            td.name,
            style: TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
          AutoSizeText(
            td.upperNameJp,
            style: TextStyle(fontSize: 16, color: Colors.black54),
            maxLines: 1,
          ),
          AutoSizeText(
            td.nameJp,
            style: TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
        ],
      ),
    );
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
}
