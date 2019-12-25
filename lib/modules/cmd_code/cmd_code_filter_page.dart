import 'package:chaldea/components/components.dart';

import 'cmd_code_list_page.dart';

class CmdCodeFilterPage extends StatefulWidget {
  final CmdCodeListPageState parent;
  final CmdCodeFilterData filterData;

  const CmdCodeFilterPage({Key key, this.parent, this.filterData})
      : super(key: key);

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends State<CmdCodeFilterPage> {
  CmdCodeFilterData filterData;

  @override
  void initState() {
    super.initState();
    filterData = widget.filterData ?? CmdCodeFilterData();
  }

  @override
  void dispose() {
    super.dispose();
    db.saveUserData();
  }

  void updateParentFilterResult() {
    setState(() {
      widget.parent?.onFilterChanged(filterData);
    });
  }

  Widget _buildDisplay() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('显示&排序'),
          ToggleButtons(
            constraints: BoxConstraints(minHeight: 30),
            selectedColor: Colors.white,
            fillColor: Theme.of(context).primaryColor,
            children: List.generate(
                2,
                (i) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(['List', 'Grid'][i]),
                    )),
            isSelected: [!filterData.useGrid, filterData.useGrid],
            onPressed: (i) {
              filterData.useGrid = i == 1;
              updateParentFilterResult();
            },
          ),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < filterData.sortKeys.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('${i + 1}  '),
                    DropdownButton(
                        value: filterData.sortKeys[i],
                        items: CmdCodeFilterData.sortKeyData.map((key) {
                          return DropdownMenuItem(
                              child: Text(['序号', '星级'][key.index]), value: key);
                        }).toList(),
                        onChanged: (key) {
                          filterData.sortKeys[i] = key;
                          updateParentFilterResult();
                        }),
                    IconButton(
                        icon: Icon(filterData.sortReversed[i]
                            ? Icons.arrow_downward
                            : Icons.arrow_upward),
                        onPressed: () {
                          filterData.sortReversed[i] =
                              !filterData.sortReversed[i];
                          updateParentFilterResult();
                        })
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('筛选'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.replay),
              onPressed: () {
                filterData.reset();
                updateParentFilterResult();
              })
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _buildDisplay(),
          FilterGroup(
            title: Text('稀有度'),
            options: CmdCodeFilterData.rarityData,
            values: filterData.rarity,
            optionBuilder: (v) => Text('$v星'),
            onFilterChanged: (value) {
              filterData.rarity = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('分类'),
            options: CmdCodeFilterData.obtainData,
            values: filterData.obtain,
            onFilterChanged: (value) {
              filterData.obtain = value;
              updateParentFilterResult();
            },
          ),
        ],
      ),
    );
  }
}
