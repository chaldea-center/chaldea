import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class MyRoomBGAssetsPage extends StatefulWidget {
  const MyRoomBGAssetsPage({super.key});

  @override
  State<MyRoomBGAssetsPage> createState() => _MyRoomBGAssetsPageState();
}

// public enum MyRoomAddEntity.OverwriteType
// {
// 	BG_IMAGE = 1,
// 	BGM = 2,
// 	SERVANT_OVERLAY_OBJECT = 6,
// 	BG_IMAGE_MULTIPLE = 7,
// 	BACK_OBJECT = 8,
// }

class MstMyRoomAdd {
  int type;
  int overwriteId;
  MstMyRoomAdd({
    required this.type,
    required this.overwriteId,
  });
}

class _MyRoomBGAssetsPageState extends State<MyRoomBGAssetsPage>
    with RegionBasedState<List<MstMyRoomAdd>, MyRoomBGAssetsPage> {
  List<String> assets = [];

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  Future<List<MstMyRoomAdd>?> fetchData(Region? r) {
    CachedApi.cacheManager.clearFailed();
    return CachedApi.cacheManager.getModel(
      'https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${r ?? Region.jp}/master/mstMyroomAdd.json',
      (list) {
        final data = List<Map>.from(list)
            .map((e) => MstMyRoomAdd(type: e['type'] ?? 0, overwriteId: e['overwriteId'] ?? 0))
            .toList();
        return data.where((e) => e.type == 1 && e.overwriteId > 0).toList();
      },
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstMyRoomAdd> data) {
    final asset = AssetURL(region ?? Region.jp);
    final urls = [
      for (final room in data) ...[
        asset.back(room.overwriteId, false),
        asset.back(room.overwriteId, true),
      ]
    ];
    return ListView.builder(
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final url = urls[index];
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: CachedImage(
            imageUrl: url,
            placeholder: (_, __) => AspectRatio(
              aspectRatio: url.endsWith('_1344_626.png') ? 1344 / 626 : 1024 / 626,
            ),
            showSaveOnLongPress: true,
            viewFullOnTap: true,
            cachedOption: CachedImageOption(
              errorWidget: (context, url, error) => Center(
                child: Text(url.breakWord),
              ),
            ),
            onTap: () {
              FullscreenImageViewer.show(context: context, urls: urls, initialPage: index);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Room Background'),
        actions: [
          dropdownRegion(),
          IconButton(
            onPressed: doFetchData,
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          )
        ],
      ),
      body: buildBody(context),
    );
  }
}
