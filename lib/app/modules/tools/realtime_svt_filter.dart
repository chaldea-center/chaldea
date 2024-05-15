import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class RealtimeSvtFilterPage extends StatefulWidget {
  const RealtimeSvtFilterPage({super.key});

  @override
  State<RealtimeSvtFilterPage> createState() => _RealtimeSvtFilterPageState();
}

class _RealtimeSvtFilterPageState extends State<RealtimeSvtFilterPage>
    with RegionBasedState<List<MstSvtFilter>, RealtimeSvtFilterPage> {
  List<MstSvtFilter> get filters => data!;

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  Future<List<MstSvtFilter>?> fetchData(Region? r, {Duration? expireAfter}) async {
    return AtlasApi.mstData('mstSvtFilter', (json) => (json as List).map((e) => MstSvtFilter.fromJson(e)).toList(),
        region: r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("In-game Servant Filter"),
        actions: [
          dropdownRegion(),
          // popupMenu,
        ],
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstSvtFilter> filters) {
    filters.sort2((e) => -e.priority);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final filter = filters[index];
        final svtIds = filter.svtIds.toList();
        svtIds.sort((a, b) => SvtFilterData.compare(
              db.gameData.servantsById[a],
              db.gameData.servantsById[b],
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
              reversed: [true, false, true],
            ));
        return TileGroup(
          header: 'No.${filter.id}',
          children: [
            ListTile(
              title: Text(filter.name),
              subtitle: Text([filter.startedAt, filter.endedAt].map((e) => e.sec2date().toStringShort()).join(' ~ ')),
            ),
            GridView.extent(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent: 48,
              children: [
                for (final svtId in svtIds)
                  db.gameData.servantsById[svtId]?.iconBuilder(context: context) ??
                      db.gameData.entities[svtId]?.iconBuilder(context: context) ??
                      Text(svtId.toString()),
              ],
            )
          ],
        );
      },
    );
  }
}
