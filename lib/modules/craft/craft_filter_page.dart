import 'package:chaldea/components/components.dart';

import 'craft_list_page.dart';

class CraftFilterPage extends StatefulWidget {
  final CraftListPageState parent;
  final CraftFilterData filterData;

  const CraftFilterPage({Key key, this.parent, this.filterData})
      : super(key: key);

  @override
  _CraftFilterPageState createState() => _CraftFilterPageState();
}

class _CraftFilterPageState extends State<CraftFilterPage> {
  CraftFilterData filterData;
  Map<String, FilterCallBack<Servant>> filterFunctions = {};

  @override
  void initState() {
    super.initState();
    filterData = widget.filterData ?? CraftFilterData();
  }

  @override
  void dispose() {
    super.dispose();
    db.saveData();
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
            constraints: BoxConstraints(),
            selectedColor: Colors.white,
            fillColor: Theme.of(context).primaryColor,
            children: List.generate(
                2,
                (i) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        items: CraftFilterData.sortKeyData.map((key) {
                          return DropdownMenuItem(child: Text(key), value: key);
                        }).toList(),
                        onChanged: (key) {
                          filterData.sortKeys[i] = key;
                          updateParentFilterResult();
                        }),
                    IconButton(
                        icon: Icon(filterData.sortDirections[i]
                            ? Icons.arrow_upward
                            : Icons.arrow_downward),
                        onPressed: () {
                          filterData.sortDirections[i] =
                              !filterData.sortDirections[i];
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
            title: Text('Rarity'),
            options: CraftFilterData.rarityData,
            values: filterData.rarity,
            optionBuilder: (v) => Text('$v星'),
            onFilterChanged: (value) {
              // object should be the same, need not to update manually
              filterData.rarity = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('分类'),
            options: CraftFilterData.categoryData,
            values: filterData.category,
            onFilterChanged: (value) {
              filterData.category = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('属性'),
            options: CraftFilterData.atkHpTypeData,
            values: filterData.atkHpType,
            onFilterChanged: (value) {
              filterData.atkHpType = value;
              updateParentFilterResult();
            },
          ),
        ],
      ),
    );
  }
}
