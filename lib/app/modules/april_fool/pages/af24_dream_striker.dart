import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../base/april_fool_page.dart';

class FateDreamStriker extends StatefulWidget {
  const FateDreamStriker({super.key});

  @override
  State<FateDreamStriker> createState() => _FateDreamStrikerState();
}

class _FateDreamStrikerState extends State<FateDreamStriker> with AprilFoolPageMixin {
  @override
  final manifestUrl = 'https://static.atlasacademy.io/JP/External/FDS/manifest.json';

  @override
  Future<void> parseManifest(List<AAFileManifest> files, AprilFoolPageData data) async {
    data
      ..maxUserSvtCollectionNo = 408
      ..iconAspectRatio = data.size.aspectRatio
      ..getFilename = (data) {
        return 'fds-${data.curSvt?.id}'
            '-${data.curSvt?.graphs.indexOf(data.curSvt?.curGraph ?? "")}'
            '-${data.backgrounds.indexOf(data.curBg ?? "") + 1}.png';
      };
    data.servants.clear();
    Map<int, AprilFoolSvtData> servants = {};
    final baseUri = Uri.parse(manifestUrl);
    for (final file in files) {
      final m = RegExp(r'Card/card_sg_(\d+)').firstMatch(file.fileName)?.group(1);
      if (m == null || !file.fileName.endsWith('.png')) continue;
      final id = int.parse(m);
      final fileUrl = baseUri.resolve(file.fileName).toString();
      final svt = servants.putIfAbsent(id, () => AprilFoolSvtData(id, fileUrl));
      svt.assets.add(fileUrl);
      svt.graphs.add(fileUrl);
    }

    for (final file in files) {
      final m = RegExp(r'Figure/figure_(\d+)').firstMatch(file.fileName)?.group(1);
      if (m == null || !file.fileName.endsWith('.png')) continue;
      final id = int.parse(m);
      final fileUrl = baseUri.resolve(file.fileName).toString();
      final svt = servants.putIfAbsent(id, () => AprilFoolSvtData(id, fileUrl));
      svt.assets.add(fileUrl);
      svt.graphs.add(fileUrl); // ?
    }
    data.servants = servants.values.toList();
    data.servants.sort2((e) => -e.id);
    for (final svt in data.servants) {
      svt.svt = svt.id <= data.maxUserSvtCollectionNo ? db.gameData.servantsNoDup[svt.id] : null;
      svt.curGraph = svt.graphs.firstOrNull;
    }

    data.backgrounds = [
      for (int rarity = 1; rarity <= 6; rarity++) baseUri.resolve('UI/bg_saintgraph_bg_$rarity.png').toString(),
    ];

    data.curSvt = data.servants.firstOrNull;
    data.curBg = data.backgrounds.lastOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Fate/Dream Striker'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildSvtSelector(),
                const Divider(height: 8),
                buildSvtGraphSelector(),
                buildBgSelector(),
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AprilFoolGraph(chara: data.curSvt?.curGraph, bg: data.curBg, size: data.size),
                ),
                const SafeArea(child: SizedBox(height: 16)),
              ],
            ),
          ),
          kDefaultDivider,
          buildButtonBar(),
        ],
      ),
    );
  }
}
