import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtVoiceTab extends StatefulWidget {
  final Servant svt;

  const SvtVoiceTab({Key? key, required this.svt}) : super(key: key);

  @override
  State<SvtVoiceTab> createState() => _SvtVoiceTabState();
}

class _SvtVoiceTabState extends State<SvtVoiceTab> {
  late Region _region;
  Set<Region> releasedRegions = {};

  Servant? _svt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    releasedRegions.add(Region.jp);
    for (final r in Region.values) {
      if (isReleased(r)) {
        releasedRegions.add(r);
      }
    }
    if (releasedRegions.isEmpty) releasedRegions.add(Region.jp);
    _region =
        releasedRegions.contains(Transl.current) ? Transl.current : Region.jp;
    fetchSvt(_region);
  }

  bool isReleased(Region r) {
    return db.gameData.mappingData.svtRelease
            .ofRegion(r)
            ?.contains(widget.svt.collectionNo) ==
        true;
  }

  void fetchSvt(Region r) async {
    _loading = true;
    _svt = null;
    if (mounted) setState(() {});
    final result = await AtlasApi.svt(widget.svt.id, region: r);
    if (r == _region) {
      _svt = result;
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      if (widget.svt.extra.mcLink != null)
        ListTile(
          title: const Text('Mooncell'),
          trailing: Text(
            '${Region.jp.localName}/${Region.cn.localName}',
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: () {
            launch('https://fgo.wiki/w/${widget.svt.extra.mcLink}/语音');
          },
          dense: true,
        ),
      if (widget.svt.extra.fandomLink != null)
        ListTile(
          title: const Text('Fandom'),
          trailing: Text(
            '${Region.jp.localName}/${Region.na.localName}',
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: () {
            launch(
                'https://fategrandorder.fandom.com/wiki/Sub:${widget.svt.extra.fandomLink}/Dialogue');
          },
          dense: true,
        ),
    ];

    List<VoiceGroup> groups = List.of(_svt?.profile.voices ?? []);
    for (final group in groups) {
      if (group.voiceLines.isEmpty) continue;
      children.add(_buildGroup(context, group));
    }
    Widget view;
    if (groups.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child:
              _loading ? const CircularProgressIndicator() : const Text('???'),
        ),
      ));
    }
    view = ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );

    return Column(
      children: [
        Expanded(child: view),
        SafeArea(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup<Region>(
                combined: true,
                options: releasedRegions.toList(),
                optionBuilder: (v) => Text(v.name.toUpperCase()),
                values: FilterRadioData(_region),
                onFilterChanged: (v, _) {
                  if (v.radioValue != null) {
                    _region = v.radioValue!;
                    fetchSvt(_region);
                  }
                  setState(() {});
                },
              )
            ],
          ),
        )
      ],
    );
  }

  Event? _getEvent(List<VoiceLine> lines) {
    for (final line in lines) {
      for (final cond in line.conds) {
        final event = db.gameData.events[cond.value];
        if (event != null) return event;
      }
    }
    return null;
  }

  Widget _buildGroup(BuildContext context, VoiceGroup group) {
    final svt = _svt ?? widget.svt;
    final voiceLines = group.voiceLines.toList()
      ..sort2((e) => e.priority ?? 0, reversed: true);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        List<InlineSpan> suffixes = [];
        if (group.voicePrefix != 0) {
          final ascensions = svt.ascensionAdd.voicePrefix.ascension.entries
              .where((e) => e.value == group.voicePrefix)
              .map((e) => e.key)
              .toList();
          final costumes = svt.ascensionAdd.voicePrefix.costume.entries
              .where((e) => e.value == group.voicePrefix)
              .map((e) => e.key)
              .toList();
          if (ascensions.isNotEmpty) {
            suffixes.add(TextSpan(
                text: '${S.current.ascension_short} ${ascensions.join("&")}'));
          }
          for (final costumeId in costumes) {
            final costume = svt.profile.costume.values
                .firstWhereOrNull((e) => e.battleCharaId == costumeId);
            suffixes.add(SharedBuilder.textButtonSpan(
              context: context,
              text: costume == null
                  ? '${S.current.costume} $costumeId'
                  : costume.lName.l,
              onTap: costume == null ? null : () => costume.routeTo(),
            ));
          }
        }
        Event? event = _getEvent(voiceLines);
        if (event != null) {
          suffixes.add(SharedBuilder.textButtonSpan(
            context: context,
            text: event.lName.l.replaceAll('\n', ' '),
            onTap: () => event.routeTo(),
          ));
        }
        String name = Transl.enums(group.type, (enums) => enums.svtVoiceType).l;
        return ListTile(
          title: Text(name),
          subtitle: suffixes.isEmpty
              ? null
              : Text.rich(
                  TextSpan(
                      children:
                          divideList(suffixes, const TextSpan(text: ', '))),
                  textScaleFactor: 0.9,
                ),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [];
        if (group.svtId != svt.id) {
          children.add(ListTile(
            title: Text(S.current.card_asset_chara_figure),
            trailing: Text(group.svtId.toString()),
            dense: true,
            onTap: () {
              FullscreenImageViewer.show(context: context, urls: [
                '${Hosts.atlasAssetHost}/JP/CharaFigure/${group.svtId}0/${group.svtId}0_merged.png'
              ]);
            },
          ));
        }
        Map<String, int> _nameCount = {};
        children.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Table(
            border: TableBorder(
                horizontalInside: Divider.createBorderSide(context, width: 1)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: voiceLines
                .map((e) => _buildVoiceLine(context, e, _nameCount))
                .toList(),
            columnWidths: const [
              FlexColumnWidth(),
              FixedColumnWidth(36.0),
              FixedColumnWidth(36.0)
            ].asMap(),
          ),
        ));
        return Column(children: children);
      },
    );
  }

  TableRow _buildVoiceLine(
      BuildContext context, VoiceLine line, Map<String, int> _nameCount) {
    String _transl(String text) {
      for (final s in ['\u3000（ひとつの施策でふたつあるとき）', '（57は欠番）']) {
        text = text.replaceFirst(s, '');
      }
      text = text.trim();
      text = text.replaceFirstMapped(RegExp(r'^(.+?)(\d*)([(（)]|$)'), (match) {
        final _name = Transl.string(
            db.gameData.mappingData.voiceLineNames, match.group(1)!.trim());
        final _num = match.group(2);
        if (_num != null && _num.isNotEmpty) {
          return '${_name.l} $_num';
        } else {
          return _name.l;
        }
      });
      final event = _getEvent([line]);
      if (event != null) {
        text = text.replaceFirst(event.name, event.lName.l);
      }
      return text;
    }

    String name = '', overwriteName = '';

    if (line.name != null && line.name!.isNotEmpty) {
      name = _transl(line.name!);
    }

    if (line.overwriteName.isNotEmpty) {
      overwriteName = line.overwriteName;
      if (overwriteName.contains('{0}')) {
        int index =
            _nameCount[overwriteName] = (_nameCount[overwriteName] ?? 0) + 1;
        overwriteName =
            overwriteName.replaceAllMapped('{0}', (match) => index.toString());
      }
      overwriteName = _transl(overwriteName);
    }
    if (overwriteName.contains(name)) {
      name = overwriteName;
    } else if (overwriteName.isNotEmpty) {
      name = '$name($overwriteName)';
    }
    String text;
    if (line.subtitle.isNotEmpty) {
      text = line.subtitle;
    } else if (line.text.any((e) => e.isNotEmpty)) {
      text = line.text.join('');
    } else {
      text = '-';
    }
    text = text.replaceAll(RegExp(r'\[([0-9a-zA-Z _,\.]+)\]'), '');
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              '· $name',
              maxLines: 2,
              maxFontSize: 12,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
            ),
            Text(text),
          ],
        ),
      ),
      Builder(
        builder: (context) {
          bool valid = line.audioAssets.isNotEmpty;
          if (!valid) {
            return const IconButton(
              onPressed: null,
              icon: Icon(Icons.play_circle_outline),
              tooltip: 'Not Found',
            );
          } else {
            return IconButton(
              onPressed: () {
                onPlayVoice(line).catchError((e, s) async {
                  EasyLoading.showError(
                      'Error playing audio (May not support)\n$e');
                  logger.e('Error playing audio:\n${line.audioAssets}', e, s);
                  _playing = null;
                });
              },
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'Play',
            );
          }
        },
      ),
      Builder(
        builder: (context) {
          bool valid = line.audioAssets.isNotEmpty;
          if (!valid) {
            return const IconButton(
              onPressed: null,
              icon: Icon(Icons.file_download),
              tooltip: 'Not Found',
            );
          }
          return IconButton(
            onPressed: () async {
              if (kIsWeb) {
                for (var url in line.audioAssets) {
                  launch(url);
                }
                return;
              }
              List<String?> localFiles = [];
              EasyLoading.show(status: S.current.downloading);
              for (final url in line.audioAssets) {
                localFiles.add(await AtlasIconLoader.i.get(url));
              }
              EasyLoading.dismiss();
              if (!mounted) return;
              String? _dir = localFiles.firstWhereOrNull((e) => e != null);
              if (_dir != null) _dir = dirname(_dir);
              String hint = '';
              if (_dir == null) {
                hint = S.current.failed;
              } else {
                hint = '${db.paths.convertIosPath(_dir)}:';
                for (final fp in localFiles) {
                  hint += '\n - ${basename(fp ?? S.current.failed)}';
                }
              }
              SimpleCancelOkDialog(
                title: Text(S.current.save),
                content: Text(hint),
                confirmText: S.current.open,
                onTapOk: () async {
                  if (_dir == null) return;
                  if (PlatformU.isDesktop) {
                    OpenFile.open(_dir);
                  } else {
                    EasyLoading.showInfo(S.current.open_in_file_manager);
                  }
                },
              ).showDialog(context);
            },
            icon: const Icon(Icons.file_download),
            tooltip: S.current.download,
          );
        },
      ),
    ]);
  }

  static final audioPlayer = AudioPlayer();

  int? _playing;

  Future<void> onPlayVoice(VoiceLine line) async {
    if (line.audioAssets.isEmpty) {
      // check before call and set button disabled
      return;
    }
    if (PlatformU.isLinux) {
      EasyLoading.showInfo('Linux not supported yet');
      return;
    }
    if (line.hashCode == _playing) return;
    _playing = line.hashCode;
    await audioPlayer.stop();
    List<AudioSource> sources = [];
    for (int index = 0; index < line.audioAssets.length; index++) {
      final asset = Uri.tryParse(line.audioAssets[index]);
      double delay = line.delay.getOrNull(index) ?? 0;
      if (delay > 0 && PlatformU.isAndroid) {
        // Android only
        sources.add(SilenceAudioSource(
            duration: Duration(milliseconds: (delay * 1000).toInt())));
      }
      if (asset != null) {
        sources.add(AudioSource.uri(asset));
      }
    }
    await audioPlayer.setAudioSource(ConcatenatingAudioSource(
      useLazyPreparation: false,
      shuffleOrder: _DoNotShuffleOrder(),
      children: sources,
    ));
    // final url = await WikiUtil.resolveFileUrl(record.voiceFile!);

    /// [DefaultCacheManager] will change the extension when saving cache
    ///   * .ogg/.ogx -> .oga
    ///   * .wav -> .bin
    if (mounted) {
      await audioPlayer.play();
    }
    _playing = null;
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
  }
}

class _DoNotShuffleOrder extends ShuffleOrder {
  int _count;
  @override
  List<int> get indices => List.generate(_count, (index) => index);

  _DoNotShuffleOrder() : _count = 0;

  @override
  void shuffle({int? initialIndex}) {}

  @override
  void insert(int index, int count) {
    _count += count;
  }

  @override
  void removeRange(int start, int end) {
    _count -= end - start;
    if (_count < 0) _count = 0;
  }

  @override
  void clear() {
    _count = 0;
  }
}
