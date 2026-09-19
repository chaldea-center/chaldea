import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/atlas.dart';

class CharaFigureSource {
  final Region region;
  final int id;
  int form;

  int face = 0;
  int figureWidth = 1024;
  int faceCount = 0;
  int baseFigureHeight = 768;
  bool? isBaseFigureHeightDetected;
  int assetRevision = 0;
  SvtScript? script;
  List<SvtScript> scripts = const [];

  CharaFigureSource({required this.region, required this.id, this.form = 0});

  static CharaFigureSource? tryParse(String input) {
    final text = input.trim();
    final id = int.tryParse(text);
    if (id != null) {
      return CharaFigureSource(region: Region.jp, id: id);
    }

    final match = RegExp(r'(?:^|/)CharaFigure/(?:Form/(\d+)/)?(\d+)(?:/(\d+)(?:_merged)?\.png)?/?(?:[?#].*)?$')
        .firstMatch(text);
    if (match == null) return null;
    final pathId = match.group(2)!;
    final filenameId = match.group(3);
    if (filenameId != null && filenameId != pathId) return null;
    return CharaFigureSource(
      region: Region.fromUrl(text) ?? Region.jp,
      id: int.parse(pathId),
      form: int.tryParse(match.group(1) ?? '') ?? 0,
    );
  }

  void reset() {
    face = 0;
    figureWidth = 1024;
    faceCount = 0;
    baseFigureHeight = 768;
    isBaseFigureHeightDetected = null;
    script = null;
    assetRevision++;
  }

  /// Loads all forms for [id] and selects [form].
  ///
  /// Returns the unavailable requested form when it has to fall back to the
  /// first returned form. Network, parsing, and empty-result failures throw.
  Future<int?> loadScripts({bool refresh = false}) async {
    final requestedForm = form;
    final result = await AtlasApi.svtScript(id, region: region, expireAfter: refresh ? Duration.zero : null);
    if (result == null || result.isEmpty) {
      throw StateError('No scripts found for $id');
    }

    final scriptsByForm = <int, SvtScript>{};
    for (final item in result) {
      scriptsByForm.putIfAbsent(item.form, () => item);
    }
    scripts = scriptsByForm.values.toList();

    final requestedScript = scriptsByForm[requestedForm];
    final nextScript = requestedScript ?? scripts.first;
    if (nextScript.form != form) {
      form = nextScript.form;
      reset();
    }
    script = nextScript;
    return requestedScript == null ? requestedForm : null;
  }

  String get mergedUrl {
    final asset = AssetURL(region);
    return form == 0 ? asset.charaFigureId(id) : asset.charaFigureForm(form, id);
  }

  String get nonMergedUrl => mergedUrl.replaceFirst('_merged.png', '.png');

  String get explorerFolderUrl {
    Uri uri = Uri.parse(mergedUrl);
    uri = uri.replace(
      host: 'explorer.atlasacademy.io',
      pathSegments: ['aa-fgo-public', ...uri.pathSegments.sublist(0, uri.pathSegments.length - 1)],
    );
    return uri.toString();
  }

  List<String> get imageCandidates => [mergedUrl, nonMergedUrl];
}
