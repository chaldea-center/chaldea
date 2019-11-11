import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtProfileTab extends SvtTabBaseWidget {
  SvtProfileTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  _SvtLoreTabState createState() =>
      _SvtLoreTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtLoreTabState extends SvtTabBaseState<SvtProfileTab>
    with AutomaticKeepAliveClientMixin {
  _SvtLoreTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);
  bool useLangCN = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ToggleButtons(
          constraints: BoxConstraints(),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          onPressed: (i) {
            setState(() {
              useLangCN = i == 0;
            });
          },
          children: List.generate(
              2,
              (i) => Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(['中文', '日本語'][i]),
                  )),
          isSelected: List.generate(2, (i) => useLangCN == (i == 0)),
        ),
        ListView(
          children: List.generate(svt.profiles.length, (i) {
            final lore = svt.profiles[i];
            String label = Servant.unavailable.contains(svt.no)
                ? '个人资料${i + 1}'
                : i == 0 ? '角色详情' : '个人资料$i';
            String text = useLangCN ? lore.loreText : lore.loreTextJp;
            if (text.isEmpty) {
              text = '???';
            }
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTile(title: Text(label)),
                  Text(text),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
