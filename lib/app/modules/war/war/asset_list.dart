import 'package:flutter/foundation.dart';

import 'package:tuple/tuple.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class WarAssetListPage extends StatefulWidget {
  final NiceWar? war;
  final List<String>? scripts;
  final String? title;
  const WarAssetListPage({super.key, this.war, this.scripts, this.title});

  @override
  State<WarAssetListPage> createState() => _WarAssetListPageState();
}

class _WarAssetListPageState extends State<WarAssetListPage> with AfterLayoutMixin {
  Set<String> bgImages = {};
  Set<String> figures = {};
  Map<String, String> audios = {}; // <url,name>
  Set<String> movies = {};

  final assetUrl = AssetURL();
  final audioPlayer = MyAudioPlayer<String>();
  bool _loading = true;
  int progress = 0;
  int total = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    fetchData(showConfirmCount: 30);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
  }

  void fetchData({int showConfirmCount = -1, bool force = false}) async {
    bgImages.clear();
    figures.clear();
    audios.clear();
    movies.clear();
    _loading = true;
    progress = 0;
    if (mounted) setState(() {});
    final war = widget.war;

    List<String> scripts = [];
    if (widget.scripts != null) {
      scripts.addAll(widget.scripts!);
    }
    if (war != null) {
      if (war.startScript != null) {
        scripts.add(war.startScript!.script);
      }
      final quests = war.quests.toList();
      quests.sort2((e) => -e.priority);
      for (final quest in quests) {
        for (final phase in quest.phaseScripts) {
          scripts.addAll(phase.scripts.map((e) => e.script));
        }
      }
    }

    total = scripts.length;
    if (showConfirmCount > 0 && total > showConfirmCount && mounted) {
      final confirm = await SimpleConfirmDialog(
        title: Text(S.current.confirm),
        content: Text("$total ${S.current.script_story}, ${S.current.download}?"),
      ).showDialog(context);
      if (confirm != true) {
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    // war assets
    if (war != null) {
      for (final bgm in [
        war.bgm,
        ...war.maps.map((e) => e.bgm),
        for (final warAdd in war.warAdds)
          if (warAdd.type == WarOverwriteType.bgm) db.gameData.bgms[warAdd.overwriteId],
      ]) {
        if (bgm != null && bgm.id != 0 && bgm.audioAsset != null) {
          audios[bgm.audioAsset!] ??= bgm.fileName;
        }
      }
    }

    // script assets
    final reg = RegExp(r'\[([^\]]+)\]');
    bool anyFullscreen = false;

    final futures = scripts.map<Future<String?>>((script) async {
      if (force) await AtlasIconLoader.i.deleteFromDisk(script);
      final fp = await AtlasIconLoader.i.get(script, allowWeb: true);
      if (fp == null) return null;
      try {
        return await FilePlus(fp).readAsString();
      } catch (e, s) {
        logger.e('read $fp failed', e, s);
        return null;
      } finally {
        progress += 1;
        if (mounted) {
          setState(() {});
        }
      }
    }).toList();
    for (final _content in futures) {
      final content = await _content;
      if (content == null) continue;
      final fullscreen = content.contains('[enableFullScreen]');
      if (fullscreen) anyFullscreen = true;
      for (final match in reg.allMatches(content)) {
        final args = match.group(1)!.split(RegExp(r'\s+')).map((e) => e.trim()).toList();
        final cmd = args.removeAt(0);
        if (args.isEmpty) continue;
        try {
          _parseCmd(cmd, args, fullscreen);
        } on RangeError {
          //
        } catch (e, s) {
          logger.d('parse cmd failed', e, s);
        }
      }
    }

    // post war assets
    if (war != null) {
      bgImages = {
        ...<String?>[
          war.shownBanner,
          war.banner,
          war.headerImage,
          for (final map in war.maps) ...[map.mapImage, map.headerImage],
          ...war.warAdds.map((warAdd) {
            switch (warAdd.type) {
              case WarOverwriteType.banner:
                return warAdd.overwriteBanner;
              case WarOverwriteType.bgImage:
                return warAdd.overwriteId != 0 ? assetUrl.back(warAdd.overwriteId, anyFullscreen) : null;
              default:
                return null;
            }
          }),
          ...?war.event?.eventAdds.map((eventAdd) {
            switch (eventAdd.overwriteType) {
              case EventOverwriteType.banner:
                return eventAdd.overwriteBanner;
              case EventOverwriteType.bgImage:
                return eventAdd.overwriteId != 0 ? assetUrl.back(eventAdd.overwriteId, anyFullscreen) : null;
              default:
                return null;
            }
          }),
        ].whereType(),
        ...bgImages,
      };
    }

    bgImages.removeWhere(
      (url) => [
        '/Back/back10000.png',
        '/Back/back10001.png',
        '/Back/back10000_1344_626.png',
        '/Back/back10001_1344_626.png',
      ].any((e) => url.endsWith(e)),
    );
    figures.removeWhere(
      (url) => [
        '/Image/back10000/back10000.png',
        '/Image/back10001/back10001.png',
        '/Image/cut063_cinema/cut063_cinema.png',
        '/Image/cut063_cinema_fs/cut063_cinema_fs.png',
      ].any((e) => url.endsWith(e)),
    );
    _loading = false;
    if (mounted) setState(() {});
  }

  static final commaReg = RegExp(r'[,，]');

  void _parseCmd(String cmd, List<String> args, bool fullscreen) {
    if (args.isEmpty) return;
    switch (cmd) {
      // CharaFigure
      case "charaChange":
      case "charaCrossFade":
      case "charaSet":
        figures.add(assetUrl.charaFigureId(args[1]));
      case "masterSet":
        for (final id in args.skip(1).take(2)) {
          figures.add(assetUrl.charaFigureId(id));
        }
      case "communicationChara":
      case "communicationCharaLoop": //0
        figures.add(assetUrl.charaFigureId(args[0]));
      case "useSimpleMeshFigure":
        for (final id in args[0].split(commaReg)) {
          figures.add(assetUrl.charaFigureId(id.trim()));
        }
      case "equipSet":
        figures.add(assetUrl.charaGraphDefault(args[1]));
      // Marks
      case "i":
      case "image":
      case "talkNameBack":
        figures.add(assetUrl.marks(args[0].split(':').first));
      // Image
      case "horizontalImageSet":
      case "imageChange":
      case "imageSet":
      case "verticalImageSet":
        figures.add(assetUrl.image(args[1]));
      case "masterImageSet":
        for (final id in args.skip(1).take(2)) {
          figures.add(assetUrl.image(id));
        }
      case "pictureFrame":
      case "pictureFrameTop":
        figures.add(assetUrl.image(args[0]));
      // case "subCameraFilter": args[2] may be 0

      // Background
      case "bScene":
        for (final id in args[0].split(commaReg)) {
          bgImages.add(assetUrl.back(id.split(RegExp(r'[：:]'))[0], fullscreen));
        }
      case "masterScene":
        for (final x in args.take(2)) {
          bgImages.add(assetUrl.back(x, fullscreen));
        }
      case "scene":
        bgImages.add(assetUrl.back(args[0], fullscreen));
      case "sceneSet":
        bgImages.add(assetUrl.back(args[1], fullscreen));

      // Audio
      // case "advSoundSet": // voice fragments
      case "cueSe":
      case "cueSeContinue":
        audios[assetUrl.audio(args[0], args[1])] ??= args[1];
      // case "cueSeContinueStop": // unknown subfolder
      // case "cueSeContinueVolume":
      // case "cueSeStop":
      // case "cueSeVolume":
      case "se":
      case "seContinue":
      case "seContinueStop":
      case "seContinueVolume":
      case "seLoop":
      case "seStop":
      case "seVolume":
        final name = args[0];
        String folder = "SE";
        if (name.startsWith('ba')) {
          folder = 'Battle';
        } else if (name.startsWith('ad')) {
          folder = 'SE';
        } else if (name.startsWith('ar')) {
          folder = 'ResidentSE';
        } else if (name.startsWith(RegExp(r'2\d_'))) {
          folder = 'SE_${name.substring(0, 2)}';
        }
        audios[assetUrl.audio(folder, args[0])] ??= args[0];
      case "tVoice":
      case "tVoiceUser":
        for (int i = 0; i < args.length ~/ 2; i++) {
          final a1 = args[i * 2], a2 = args[i * 2 + 1];
          audios[assetUrl.audio(a1, a2)] ??= '${a1}_$a2';
        }
      case "voice":
      case "voiceStop":
        final result = _getCharaVoiceAssetUrl(args[0]);
        if (result != null) {
          audios[result.$1] = result.$2;
        }
      // BGM
      case "bgm":
      case "bgmStop":
      case "bgmStopEnd":
      case "jingle":
      case "jingleStop":
        audios[assetUrl.audio(args[0], args[0])] ??= args[0];
      // MOV
      case "criMovie":
      case "movie":
        movies.add(assetUrl.movie(args[0]));
      // Effect: skip
      default:
    }
  }

  (String url, String name)? _getCharaVoiceAssetUrl(String name) {
    final segs = name.split('_');
    segs.removeWhere((e) => e.isEmpty);
    if (name.startsWith('NP_')) {
      return (assetUrl.audio('NoblePhantasm_${segs[1]}', name), name);
    } else if (segs.length >= 3) {
      final svtId = segs[0], fn = segs[2];
      if (fn.startsWith('B')) {
        if (fn.length == 4 && const ["B05", "B06", "B07", "B80", "B81", "B82"].contains(fn.substring(0, 3))) {
          return (assetUrl.audio('NoblePhantasm_$svtId', name.substring(svtId.length + 1)), 'NoblePhantasm/$name}');
        }
        return (assetUrl.audio('Servants_$svtId', name.substring(svtId.length + 1)), 'Servants/$name}');
      }
      return (assetUrl.audio('ChrVoice_$svtId', name.substring(svtId.length + 1)), 'ChrVoice/$name');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tuple2<Tab, Widget>>[];
    if (bgImages.isNotEmpty) {
      tabs.add(Tuple2(Tab(text: S.current.background), bgImageView));
    }
    if (figures.isNotEmpty) {
      tabs.add(Tuple2(Tab(text: S.current.card_asset_chara_figure), figureView));
    }
    if (audios.isNotEmpty) {
      tabs.add(Tuple2(const Tab(text: 'BGM/SE'), audioView));
    }
    if (movies.isNotEmpty) {
      tabs.add(Tuple2(Tab(text: S.current.video), movieView));
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.war?.lName.l ?? widget.title ?? S.current.media_assets),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text(S.current.refresh), onTap: () => fetchData(force: true)),
              ],
            ),
          ],
          bottom: _loading
              ? null
              : FixedHeight.tabBar(
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: tabs.map((e) => e.item1).toList(),
                  ),
                ),
        ),
        body: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator(value: total > 0 ? progress / total : null)),
                  const SizedBox(height: 16),
                  Text('${S.current.downloading}  $progress/$total'),
                ],
              )
            : TabBarView(children: tabs.map((e) => e.item2).toList()),
      ),
    );
  }

  Widget get bgImageView {
    final bgImages = this.bgImages.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final url = bgImages[index];
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: CachedImage(
            imageUrl: bgImages[index],
            placeholder: (_, _) => AspectRatio(aspectRatio: url.endsWith('_1344_626.png') ? 1344 / 626 : 1024 / 626),
            showSaveOnLongPress: true,
            viewFullOnTap: true,
            cachedOption: CachedImageOption(errorWidget: (context, url, error) => Center(child: Text(url.breakWord))),
            onTap: () {
              FullscreenImageViewer.show(context: context, urls: bgImages, initialPage: index);
            },
          ),
        );
      },
      itemCount: bgImages.length,
    );
  }

  Widget get figureView {
    final figures = this.figures.toList();
    return GridView.extent(
      maxCrossAxisExtent: 300,
      childAspectRatio: 1024 / 768,
      children: List.generate(figures.length, (index) {
        final fig = figures[index];
        final charaFigure = fig.contains('CharaFigure');
        return CachedImage(
          imageUrl: fig,
          placeholder: (_, _) => const SizedBox(),
          showSaveOnLongPress: true,
          viewFullOnTap: true,
          cachedOption: CachedImageOption(
            alignment: charaFigure ? Alignment.topCenter : Alignment.center,
            fit: charaFigure ? BoxFit.fitWidth : null,
            errorWidget: (context, url, error) =>
                Center(child: Text((kReleaseMode ? url.split('/').last : url).breakWord)),
          ),
          onTap: () {
            FullscreenImageViewer.show(context: context, urls: figures, initialPage: index);
          },
        );
      }),
    );
  }

  Widget get audioView {
    final audios = Map.of(this.audios);
    final urls = audios.keys.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        String url = urls[index], filename = audios[url]!;
        final player = SoundPlayButton(url: url, player: audioPlayer);
        String? bgmName;
        if (filename.startsWith('BGM_')) {
          final bgm = db.gameData.bgms.values.firstWhereOrNull((e) => e.fileName == filename);
          if (bgm != null && bgm.name.isNotEmpty) {
            bgmName = bgm.lName.l.setMaxLines(1);
          }
        }
        return ListTile(
          dense: true,
          leading: player,
          title: Text(bgmName == null ? filename : '$filename\n$bgmName'),
          onTap: () {
            player.onPressed(url);
          },
          trailing: IconButton(
            onPressed: () {
              launch(url, external: true);
            },
            icon: const Icon(Icons.download),
            tooltip: S.current.download,
          ),
        );
      },
      itemCount: urls.length,
    );
  }

  Widget get movieView {
    final movies = this.movies.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final name = movies[index].split('/').last.split('.').first;
        return ListTile(
          dense: true,
          title: Text(name),
          onTap: () {
            router.pushPage(VideoPlayPage(url: movies[index], title: name));
          },
        );
      },
      itemCount: movies.length,
    );
  }
}
