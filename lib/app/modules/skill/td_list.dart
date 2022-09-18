import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import 'td_filter.dart';

class TdListPage extends StatefulWidget {
  const TdListPage({Key? key}) : super(key: key);

  @override
  _TdListPageState createState() => _TdListPageState();
}

class _TdListPageState extends State<TdListPage>
    with SearchableListState<BaseTd?, TdListPage> {
  final filterData = TdFilterData();

  int? get _searchTdId {
    final _id = int.tryParse(searchEditingController.text);
    if (_id != null && _id >= 0 && !db.gameData.baseTds.containsKey(_id)) {
      return _id;
    }
    return null;
  }

  @override
  Iterable<BaseTd?> get wholeData {
    int? _id = _searchTdId;
    return [
      if (_id != null) null,
      ...db.gameData.baseTds.values,
    ];
  }

  @override
  bool get prototypeExtent => true;

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => (a?.id ?? 0) - (b?.id ?? 0));
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.noble_phantasm),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => TdFilter(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  bool filter(BaseTd? td) {
    if (td == null) return true;
    if (!filterData.card.matchOne(td.card)) {
      return false;
    }
    if (!filterData.type.matchOne(td.damageType)) {
      return false;
    }
    if (!filterData.funcTargetType
        .matchAny(td.functions.map((e) => e.funcTargetType))) {
      return false;
    }
    if (!filterData.funcType.matchAny(td.functions.map((e) => e.funcType))) {
      return false;
    }
    if (!filterData.buffType.matchAny(td.functions
        .where((e) => e.buffs.isNotEmpty)
        .map((e) => e.buffs.first.type))) {
      return false;
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(BaseTd? td) sync* {
    if (td == null) {
      yield _searchTdId?.toString();
      return;
    }
    yield td.id.toString();
    yield* SearchUtil.getSkillKeys(td);
  }

  @override
  Widget listItemBuilder(BaseTd? td) {
    return ListTile(
      dense: true,
      leading: td == null
          ? const SizedBox(width: 36, height: 36)
          : CommandCardWidget(card: td.card, width: 36),
      horizontalTitleGap: 6,
      contentPadding: const EdgeInsetsDirectional.only(start: 10, end: 16),
      title: Text.rich(
        TextSpan(
          text: td?.nameWithRank ?? "${S.current.noble_phantasm} $_searchTdId",
          children: [
            if (td != null)
              TextSpan(
                  text:
                      '\n${td.id} ${Transl.enums(td.damageType, (enums) => enums.tdEffectFlag).l}',
                  style: Theme.of(context).textTheme.caption)
          ],
        ),
      ),
      onTap: () {
        final id = td?.id ?? _searchTdId;
        if (id != null) router.popDetailAndPush(url: Routes.tdI(id));
      },
    );
  }

  @override
  Widget gridItemBuilder(BaseTd? td) =>
      throw UnimplementedError('GridView not designed');
}
