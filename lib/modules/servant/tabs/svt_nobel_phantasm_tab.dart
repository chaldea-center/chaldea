//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtNobelPhantasmTab extends SvtTabBaseWidget {
  SvtNobelPhantasmTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtNobelPhantasmTabState createState() =>
      _SvtNobelPhantasmTabState(parent: parent, svt: svt, plan: status);
}

class _SvtNobelPhantasmTabState extends SvtTabBaseState<SvtNobelPhantasmTab> {
  _SvtNobelPhantasmTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.nobelPhantasm == null || svt.nobelPhantasm.length == 0) {
      return Container(child: Center(child: Text('No NobelPhantasm Data')));
    }
    status.npIndex =
        fixValidRange(status.npIndex ?? 0, 0, svt.nobelPhantasm.length - 1);

    final td = svt.nobelPhantasm[status.npIndex];
    return ListView(
      children: <Widget>[
        TileGroup(
          children: <Widget>[
            buildToggle(status.npIndex),
            buildHeader(td),
            for (Effect e in td.effects) ...buildEffect(e)
          ],
        )
      ],
    );
  }

  Widget buildToggle(int selected) {
    if (svt.nobelPhantasm.length <= 1) {
      return Container();
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 4),
        child: FittedBox(
          child: ToggleButtons(
            constraints: BoxConstraints(),
            selectedColor: Colors.white,
            fillColor: Theme.of(context).primaryColor,
            children: svt.nobelPhantasm.map((td) {
              Widget button;
              if (td.state.contains('强化前') || td.state.contains('强化后')) {
                final iconKey = td.state.contains('强化前') ? '宝具未强化' : '宝具强化';
                button = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    db.getIconImage(iconKey, height: 22),
                    Text(td.state)
                  ],
                );
              } else {
                button = Text(td.state);
              }
              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: button);
            }).toList(),
            isSelected:
                List.generate(svt.nobelPhantasm.length, (i) => selected == i),
            onPressed: (no) {
              setState(() {
                status.npIndex = no;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildHeader(NobelPhantasm td) {
    return CustomTile(
      leading: Column(
        children: <Widget>[
          db.getIconImage(td.color, width: 99),
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
    assert([1, 5].contains(effect.lvData.length));
    int crossCount =
        effect.lvData.length == 1 ? (effect.lvData[0].length < 10 ? 0 : 1) : 5;
    return <Widget>[
      CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, crossCount == 0 ? 0 : 16, 6),
        subtitle: crossCount == 0
            ? Row(children: [
                Expanded(child: Text(effect.description), flex: 4),
                Expanded(child: Center(child: Text(effect.lvData[0])), flex: 1),
              ])
            : Text(effect.description),
      ),
      if (crossCount > 0)
        Table(
          children: [
            for (int row = 0; row < effect.lvData.length / crossCount; row++)
              TableRow(
                children: List.generate(crossCount, (col) {
                  int index = row * crossCount + col;
                  if (index >= effect.lvData.length) return Container();
                  return Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        effect.lvData[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: index == 5 || index == 9
                              ? Colors.redAccent
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              )
          ],
        ),
    ];
  }
}
