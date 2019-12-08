import 'package:chaldea/components/components.dart';

import 'servant_list_page.dart';

class SvtFilterPage extends StatefulWidget {
  final ServantListPageState parent;
  final SvtFilterData filterData;

  const SvtFilterPage({Key key, this.parent, this.filterData})
      : super(key: key);

  @override
  _SvtFilterPageState createState() => _SvtFilterPageState();
}

class _SvtFilterPageState extends State<SvtFilterPage> {
  SvtFilterData filterData;

  @override
  void initState() {
    super.initState();
    filterData = widget.filterData ?? SvtFilterData();
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
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
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
              FilterOption(
                selected: filterData.hasDress,
                value: '灵衣',
                onChanged: (v) {
                  setState(() {
                    filterData.hasDress = v;
                    updateParentFilterResult();
                  });
                },
              )
            ],
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
                        items: SvtFilterData.sortKeyData.map((key) {
                          return DropdownMenuItem(
                              child: Text(['序号', '职阶', '星级','ATK','HP'][key.index]),
                              value: key);
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

  Widget _buildClassFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('职阶', style: TextStyle(fontSize: 16)),
          Row(
            children: <Widget>[
              Expanded(
                  flex: 3,
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 1.3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(2, (index) {
                      final name = ['金卡', '铜卡'][index] + 'All';
                      return GestureDetector(
                        child: Image(image: db.getIconFile(name)),
                        onTap: () {
                          if (index == 0) {
                            SvtFilterData.classesData.forEach(
                                (e) => filterData.className.options[e] = true);
                          } else {
                            filterData.className.options.clear();
                          }
                          updateParentFilterResult();
                        },
                      );
                    }),
                  )),
              Expanded(
                  flex: 21,
                  child: GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    childAspectRatio: 1.3,
                    physics: NeverScrollableScrollPhysics(),
                    children: SvtFilterData.classesData.map((className) {
                      final selected =
                          filterData.className.options[className] ?? false;
                      final color = selected ? '金卡' : '铜卡';
                      return GestureDetector(
                        child: Image(image: db.getIconFile('$color$className')),
                        onTap: () {
                          filterData.className.options[className] = !selected;
                          updateParentFilterResult();
                        },
                      );
                    }).toList(),
                  ))
            ],
          ),
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
        children: <Widget>[
          _buildDisplay(),
          _buildClassFilter(),
          FilterGroup(
            title: Text('稀有度'),
            options: SvtFilterData.rarityData,
            values: filterData.rarity,
            optionBuilder: (v) => Text('$v星'),
            onFilterChanged: (value) {
              // object should be the same, need not to update manually
              filterData.rarity = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('获取方式'),
            options: SvtFilterData.obtainData,
            values: filterData.obtain,
            onFilterChanged: (value) {
              filterData.obtain = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('宝具'),
            options: SvtFilterData.npColorData,
            values: filterData.npColor,
            onFilterChanged: (value) {
              filterData.npColor = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            values: filterData.npType,
            options: SvtFilterData.npTypeData,
            onFilterChanged: (value) {
              filterData.npType = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('阵营'),
            options: SvtFilterData.attributeData,
            values: filterData.attribute,
            onFilterChanged: (value) {
              filterData.attribute = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('属性'),
            options: SvtFilterData.alignment1Data,
            values: filterData.alignment1,
            onFilterChanged: (value) {
              filterData.alignment1 = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            values: filterData.alignment2,
            options: SvtFilterData.alignment2Data,
            onFilterChanged: (value) {
              filterData.alignment2 = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('性别'),
            options: SvtFilterData.genderData,
            values: filterData.gender,
            onFilterChanged: (value) {
              filterData.gender = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('特性'),
            options: SvtFilterData.traitData,
            values: filterData.trait,
            showMatchAll: true,
            showInvert: true,
            onFilterChanged: (value) {
              filterData.trait = value;
              updateParentFilterResult();
            },
          ),
          FilterGroup(
            title: Text('特殊特性'),
            options: SvtFilterData.traitSpecialData,
            values: filterData.traitSpecial,
            onFilterChanged: (value) {
              filterData.traitSpecial = value;
              updateParentFilterResult();
            },
          ),
        ],
      ),
    );
  }
}
