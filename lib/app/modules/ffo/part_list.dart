import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'ffo_card.dart';
import 'filter.dart';
import 'schema.dart';

class FfoPartListPage extends StatefulWidget {
  final FfoPartWhere where;
  final ValueChanged<FfoSvtPart?>? onSelected;

  FfoPartListPage({super.key, required this.where, this.onSelected});

  @override
  State<StatefulWidget> createState() => FfoPartListPageState();
}

class FfoPartListPageState extends State<FfoPartListPage>
    with SearchableListState<FfoSvtPart, FfoPartListPage> {
  @override
  Iterable<FfoSvtPart> get wholeData =>
      FfoDB.i.parts.values.where((e) => e.collectionNo > 400 || e.svt != null);

  static FfoPartFilterData filterData = FfoPartFilterData();

  @override
  final bool prototypeExtent = true;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => FfoPartFilterData.compare(a.svt, b.svt,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(widget.where.shownName, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: S.current.clear,
            onPressed: () {
              Navigator.pop(context);
              widget.onSelected?.call(null);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => FfoPartFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
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
  Widget listItemBuilder(FfoSvtPart part) {
    String? name;
    if (part.collectionNo < 400) {
      name = db.gameData.servantsNoDup[part.collectionNo]?.lName.l;
    }
    name ??= part.svt?.name ?? 'Svt ${part.collectionNo}';
    final svtClass =
        part.svt?.svtClass?.lName ?? part.svt?.classType.toString();
    return CustomTile(
      leading: SizedBox(
        width: 51.2,
        height: 72.0,
        child: FfoCard(
          params: FFOParams.only(
            where: widget.where,
            part: part,
            clipOverflow: true,
            cropNormalizedSize: true,
          ),
        ),
      ),
      title: AutoSizeText(Transl.svtNames(name).l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(name, maxLines: 1),
          Text(
              'No.${part.collectionNo} - $kStarChar${part.svt?.rarity} $svtClass'),
        ],
      ),
      trailing:
          db.getIconImage(FFOUtil.borderedSprite(part.svt?.icon), width: 42),
      selected: SplitRoute.isSplit(context) && selected == part,
      onTap: _getOnTap(part),
      enabled: part.svt != null,
    );
  }

  @override
  Widget gridItemBuilder(FfoSvtPart part) {
    return GestureDetector(
      onTap: _getOnTap(part),
      child: db.getIconImage(FFOUtil.imgUrl(part.svt?.icon), width: 72),
    );
  }

  VoidCallback? _getOnTap(FfoSvtPart part) {
    if (part.svt == null) {
      return null;
    }
    return () {
      Navigator.pop(context);
      widget.onSelected?.call(part);
    };
  }

  @override
  bool filter(FfoSvtPart part) {
    final svt = part.svt;
    if (svt == null) return true;
    if (!filterData.rarity.matchOne(svt.rarity)) {
      return false;
    }
    if (svt.svtClass == null || !filterData.classType.matchOne(svt.svtClass!)) {
      return false;
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(FfoSvtPart part) sync* {
    yield part.collectionNo.toString();
    if (part.svt != null) {
      yield* SearchUtil.getAllKeys(Transl.svtNames(part.svt!.name));
    }
    final originSvt = part.collectionNo < 400
        ? db.gameData.servantsNoDup[part.collectionNo]
        : null;
    if (originSvt != null) {
      for (final name in originSvt.allNames) {
        yield* SearchUtil.getAllKeys(Transl.svtNames(name));
      }
    }
  }
}
