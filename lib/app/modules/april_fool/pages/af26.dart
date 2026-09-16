import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../base/april_fool_page.dart';

class AprilFool2026 extends StatefulWidget {
  const AprilFool2026({super.key});

  @override
  State<AprilFool2026> createState() => _AprilFool2026State();
}

class _AprilFool2026State extends State<AprilFool2026> with AprilFoolPageMixin {
  @override
  final manifestUrl = 'https://static.atlasacademy.io/JP/External/JP_AF_2026/manifest.json';

  List<AAFileManifest> staffPhotos = [];
  List<AAFileManifest> masterFaces = [];
  List<AAFileManifest> masterFigures = [];

  @override
  Future<void> parseManifest(List<AAFileManifest> files, AprilFoolPageData data) async {
    data.maxUserSvtCollectionNo = 466;
    data.servants.clear();
    Map<int, AprilFoolSvtData> servants = {};
    final baseUri = Uri.parse(manifestUrl);
    final svtPatterns = [
      RegExp(r'CharaGraph/(\d+)\D'),
      RegExp(r'CharaFigure/(\d+)4_merged'),
      RegExp(r'Faces/f_(\d+)4\.png'),
      RegExp(r'Faces/f_(\d+)4_bordered\.png'),
      RegExp(r'NarrowFigure/(\d+)\D'),
      RegExp(r'Status/(\d+)\D'),
    ];
    const _kSvtIdRemap = <int, int>{
      1002100: 1002000,
      2501500: 2501400,
      800140: 800100,
      800190: 800100,
      //
    };
    files = files.toList();
    files.sort2((e) => e.size);
    for (final file in files) {
      int? svtId;
      for (final regexp in svtPatterns) {
        final svtIdStr = regexp.firstMatch(file.fileName)?.group(1);
        if (svtIdStr == null || !file.fileName.endsWith('.png')) continue;
        svtId = int.parse(svtIdStr);
        break;
      }
      if (svtId != null && _kSvtIdRemap.containsKey(svtId)) svtId = _kSvtIdRemap[svtId]!;
      if (svtId == null) {
        print('skip ${file.fileName}');
        continue;
      }

      final fileUrl = baseUri.resolve(file.fileName).toString();
      final svt = servants[svtId] ??= AprilFoolSvtData(svtId, fileUrl);
      svt.assets.add(fileUrl);
      svt.svt ??= db.gameData.servantsById[svtId];
    }

    staffPhotos.clear();
    masterFaces.clear();
    masterFigures.clear();
    for (final file in data.files) {
      if (file.fileName.startsWith('StaffPhoto')) {
        staffPhotos.add(file);
      } else if (file.fileName.startsWith('MasterFace')) {
        masterFaces.add(file);
      } else if (file.fileName.startsWith('MasterFigure')) {
        masterFigures.add(file);
      }
    }
    masterFaces.sort((a, b) => b.fileName.compareTo(a.fileName));
    masterFigures.sort((a, b) => b.fileName.compareTo(a.fileName));

    data.servants = servants.values.toList();
    data.servants.sortByList((e) => [e.svt == null ? 0 : 1, -(e.svt?.collectionNo ?? 999), -e.id]);
    for (final svt in data.servants) {
      final faces = svt.assets.where((e) => e.contains('Faces/')).toList();
      if (faces.isNotEmpty) {
        svt.icon = faces.firstWhereOrNull((e) => e.contains('_bordered')) ?? faces.first;
      }
      // svt.assets.sort();
    }
    data.curSvt = data.servants.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final svt = data.curSvt;
    return Scaffold(
      appBar: buildAppBar('April Fool 2026'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DividerWithTitle(title: S.current.servant),
                buildSvtSelector(),
                const Divider(height: 8),
                if (svt != null) ...[
                  ListTile(
                    dense: true,
                    leading: db.getIconImage(svt.icon),
                    title: Text(svt.svt?.lName.l ?? 'Servant ${svt.id}'),
                    subtitle: Text('No.${svt.svt?.collectionNo ?? svt.id}'),
                    trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                    onTap: svt.svt?.routeTo,
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: .horizontal,
                      children: [
                        for (final asset in svt.assets) CachedImage(imageUrl: asset, showSaveOnLongPress: true),
                      ],
                    ),
                  ),
                  DividerWithTitle(title: 'Staff'),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: .horizontal,
                      itemCount: staffPhotos.length,
                      itemBuilder: (context, index) =>
                          CachedImage(imageUrl: staffPhotos[index].resolveUrl(manifestUrl), showSaveOnLongPress: true),
                    ),
                  ),
                  DividerWithTitle(title: S.current.mystic_code),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: .horizontal,
                      itemCount: masterFaces.length,
                      itemBuilder: (context, index) =>
                          CachedImage(imageUrl: masterFaces[index].resolveUrl(manifestUrl), showSaveOnLongPress: true),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: .horizontal,
                      itemCount: masterFigures.length,
                      itemBuilder: (context, index) => CachedImage(
                        imageUrl: masterFigures[index].resolveUrl(manifestUrl),
                        showSaveOnLongPress: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          kDefaultDivider,
        ],
      ),
    );
  }
}
