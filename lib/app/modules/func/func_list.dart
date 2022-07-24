import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';

class FuncListPage extends StatefulWidget {
  final FuncType? type;
  const FuncListPage({Key? key, this.type}) : super(key: key);

  @override
  _FuncListPageState createState() => _FuncListPageState();
}

class _FuncListPageState extends State<FuncListPage>
    with SearchableListState<BaseFunction?, FuncListPage> {
  final filterData = FuncFilterData();

  int? get _searchFuncId {
    final _id = int.tryParse(searchEditingController.text);
    if (_id != null &&
        _id >= 0 &&
        !db.gameData.baseFunctions.containsKey(_id)) {
      return _id;
    }
    return null;
  }

  @override
  Iterable<BaseFunction?> get wholeData {
    int? _id = _searchFuncId;
    return [
      if (_id != null) null,
      ...db.gameData.baseFunctions.values,
    ];
  }

  @override
  bool get prototypeExtent => true;

  @override
  void initState() {
    super.initState();
    if (widget.type != null) {
      filterData.funcType.options = {widget.type!};
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => (a?.funcId ?? -1) - (b?.funcId ?? 0));
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: const Text("Funcs"),
        bottom: searchBar,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => FuncFilter(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool filter(BaseFunction? func) {
    if (func == null) return true;
    if (!filterData.funcTargetTeam.matchOne(func.funcTargetTeam)) {
      return false;
    }
    if (!filterData.funcTargetType.matchOne(func.funcTargetType)) {
      return false;
    }
    if (!filterData.funcType.matchOne(func.funcType)) {
      return false;
    }
    if (!filterData.buffType.matchAny(func.buffs.map((e) => e.type))) {
      return false;
    }
    if (!filterData.trait.matchAny([
      ...func.functvals,
      ...func.funcquestTvals,
      ...func.traitVals
    ].map((e) => e.id))) {
      return false;
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(BaseFunction? func) sync* {
    if (func == null) {
      yield _searchFuncId?.toString();
      return;
    }
    yield func.funcId.toString();
    yield func.funcType.toString();
    yield* SearchUtil.getAllKeys(func.lPopupText);
    yield* SearchUtil.getAllKeys(Transl.funcType(func.funcType));
    yield* SearchUtil.getAllKeys(Transl.funcPopuptextBase(func.funcType.name));
  }

  @override
  Widget listItemBuilder(BaseFunction? func) {
    return ListTile(
      dense: true,
      leading: func?.funcPopupIcon == null
          ? const SizedBox(height: 24, width: 24)
          : db.getIconImage(func?.funcPopupIcon, height: 24),
      horizontalTitleGap: 8,
      title: Text(func?.lPopupText.l ?? "Func $_searchFuncId"),
      subtitle: func == null
          ? null
          : Text(
              '${func.funcId} ${func.funcType.name} ${Transl.funcType(func.funcType).l}',
              maxLines: 1,
            ),
      onTap: () {
        final id = func?.funcId ?? _searchFuncId;
        if (id != null) router.push(url: Routes.funcI(id));
      },
    );
  }

  @override
  Widget gridItemBuilder(BaseFunction? func) =>
      throw UnimplementedError('GridView not designed');
}
