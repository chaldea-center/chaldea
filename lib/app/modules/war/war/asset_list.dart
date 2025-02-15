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
      final confirm = await SimpleCancelOkDialog(
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

    final futures =
        scripts.map<Future<String?>>((script) async {
          if (force) await AtlasIconLoader.i.deleteFromDisk(script);
          final fp = await AtlasIconLoader.i.get(script, allowWeb: true);
          if (fp == null) return null;
          try {
            return FilePlus(fp).readAsString();
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
        } catch (e, s) {
          logger.d('parse cmd failed', e, s);
        }
      }
    }

    // post war assets
    if (war != null) {
      bgImages = {
        ...<String?>[
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

  void _parseCmd(String cmd, List<String> args, bool fullscreen) {
    switch (cmd) {
      case "bgm":
        audios[assetUrl.audio(args[0], args[0])] ??= args[0];
        break;
      case "se":
      case "seLoop":
        audios[assetUrl.audio('SE', args[0])] ??= args[0];
        break;
      case "cueSe":
        audios[assetUrl.audio(args[0], args[1])] ??= args[1];
        break;
      case "tVoice":
      case "tVoiceUser":
        for (int i = 0; i < args.length ~/ 2; i++) {
          audios[assetUrl.audio(args[i * 2], args[i * 2 + 1])] ??= '${args[i * 2]}_${args[i * 2 + 1]}';
        }
        break;
      case "voice":
        final segs = args[0].split('_');
        audios[assetUrl.audio('ChrVoice_${segs[0]}', segs.skip(1).join('_'))] ??= 'ChrVoice_${args[0]}';
        break;
      case "criMovie":
      case "movie":
        movies.add(assetUrl.movie(args[0]));
        break;
      case "charaChange":
      case "charaCrossFade":
      case "charaSet":
        figures.add(assetUrl.charaFigureId(args[1]));
        break;
      case "communicationChara":
      case "communicationCharaLoop":
        figures.add(assetUrl.charaFigureId(args[0]));
        break;
      case "equipSet":
        figures.add(assetUrl.charaGraphDefault(args[1]));
        break;
      case "horizontalImageSet":
      case "verticalImageSet":
      case "imageChange":
      case "imageSet":
        figures.add(assetUrl.image(args[1]));
        break;
      case "pictureFrame":
      case "pictureFrameTop":
        figures.add(assetUrl.image(args[0]));
        break;
      case "scene":
        bgImages.add(assetUrl.back(args[0], fullscreen));
        break;
      case "sceneSet":
        bgImages.add(assetUrl.back(args[1], fullscreen));
        break;
      case "i":
      case "image":
        figures.add(assetUrl.marks(args[0]));
        break;
      case "masterSet":
        for (final id in args.skip(1).take(2)) {
          figures.add(assetUrl.charaFigureId(id));
        }
        break;
      case "masterImageSet":
        for (final id in args.skip(1).take(2)) {
          figures.add(assetUrl.image(id));
        }
        break;
      case "masterScene":
        for (final id in args.take(2)) {
          bgImages.add(assetUrl.back(id, fullscreen));
        }
        break;
      default:
    }
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
              itemBuilder:
                  (context) => [PopupMenuItem(child: Text(S.current.refresh), onTap: () => fetchData(force: true))],
            ),
          ],
          bottom:
              _loading
                  ? null
                  : FixedHeight.tabBar(
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      tabs: tabs.map((e) => e.item1).toList(),
                    ),
                  ),
        ),
        body:
            _loading
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
            placeholder: (_, __) => AspectRatio(aspectRatio: url.endsWith('_1344_626.png') ? 1344 / 626 : 1024 / 626),
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
          placeholder: (_, __) => const SizedBox(),
          showSaveOnLongPress: true,
          viewFullOnTap: true,
          cachedOption: CachedImageOption(
            alignment: charaFigure ? Alignment.topCenter : Alignment.center,
            fit: charaFigure ? BoxFit.fitWidth : null,
            errorWidget:
                (context, url, error) => Center(child: Text((kReleaseMode ? url.split('/').last : url).breakWord)),
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
