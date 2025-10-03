import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/voice_cond.dart';
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

  const SvtVoiceTab({super.key, required this.svt});

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
    for (final r in Region.values) {
      if (r == Region.jp || isReleased(r)) {
        releasedRegions.add(r);
      }
    }
    _region = releasedRegions.contains(Transl.current) ? Transl.current : Region.jp;
    fetchSvt(_region);
  }

  bool isReleased(Region r) {
    return db.gameData.mappingData.entityRelease.ofRegion(r)?.contains(widget.svt.id) == true;
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
          trailing: Text('${Region.jp.localName}/${Region.cn.localName}', style: Theme.of(context).textTheme.bodySmall),
          onTap: () {
            launch('https://fgo.wiki/w/${widget.svt.extra.mcLink}/语音');
          },
          dense: true,
        ),
      if (widget.svt.extra.fandomLink != null)
        ListTile(
          title: const Text('Fandom'),
          trailing: Text('${Region.jp.localName}/${Region.na.localName}', style: Theme.of(context).textTheme.bodySmall),
          onTap: () {
            launch('https://fategrandorder.fandom.com/wiki/Sub:${widget.svt.extra.fandomLink}/Dialogue');
          },
          dense: true,
        ),
    ];

    List<VoiceGroup> groups = List.of(_svt?.profile.voices ?? []);
    for (final group in groups) {
      if (group.voiceLines.isEmpty) continue;
      children.add(VoiceGroupAccordion(group: group, svt: _svt ?? widget.svt, player: audioPlayer));
    }
    Widget view;
    if (groups.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator()
                : _svt == null
                ? RefreshButton(
                    text: '???',
                    onPressed: () {
                      fetchSvt(_region);
                    },
                  )
                : Text(S.current.empty_hint),
          ),
        ),
      );
    }
    view = ListView.builder(itemCount: children.length, itemBuilder: (context, index) => children[index]);

    return Column(
      children: [
        Expanded(child: InheritSelectionArea(child: view)),
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup<Region>(
                combined: true,
                options: releasedRegions.toList(),
                optionBuilder: (v) => Text(v.name.toUpperCase()),
                values: FilterRadioData.nonnull(_region),
                onFilterChanged: (v, _) {
                  if (v.radioValue != null) {
                    _region = v.radioValue!;
                    fetchSvt(_region);
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  final audioPlayer = MyAudioPlayer<VoiceLine>();

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
  }
}

class VoiceGroupAccordion extends StatelessWidget {
  final VoiceGroup group;
  final MyAudioPlayer<VoiceLine> player;
  final Servant? _svt;
  final Event? event;

  const VoiceGroupAccordion({super.key, required this.group, required this.player, Servant? svt, this.event})
    : _svt = svt;

  @override
  Widget build(BuildContext context) {
    final voiceLines = group.voiceLines.toList()..sort2((e) => e.priority ?? 0, reversed: true);
    final svt = _svt?.id == group.svtId ? _svt : db.gameData.servantsById[group.svtId];
    return SimpleAccordion(
      headerBuilder: (context, _) {
        List<InlineSpan> suffixes = [];
        if (group.voicePrefix != 0) {
          final ascensions =
              svt?.ascensionAdd.voicePrefix.ascension.entries
                  .where((e) => e.value == group.voicePrefix)
                  .map((e) => e.key)
                  .toList() ??
              [];
          final costumes =
              svt?.ascensionAdd.voicePrefix.costume.entries
                  .where((e) => e.value == group.voicePrefix)
                  .map((e) => e.key)
                  .toList() ??
              [];
          if (ascensions.isNotEmpty) {
            suffixes.add(TextSpan(text: '${S.current.ascension_short} ${ascensions.join("&")}'));
          }
          for (final costumeId in costumes) {
            final costume = svt?.profile.costume.values.firstWhereOrNull((e) => e.battleCharaId == costumeId);
            suffixes.add(
              SharedBuilder.textButtonSpan(
                context: context,
                text: costume == null ? '${S.current.costume} $costumeId' : costume.lName.l,
                onTap: costume == null ? null : () => costume.routeTo(),
              ),
            );
          }
        }
        Event? event = _getEvent(voiceLines);
        if (event != null) {
          suffixes.add(
            SharedBuilder.textButtonSpan(
              context: context,
              text: event.lName.l.replaceAll('\n', ' '),
              onTap: () => event.routeTo(),
            ),
          );
        }
        InlineSpan? svtSpan;
        if (group.svtId != _svt?.id) {
          final svtId = db.gameData.storyCharaFigures[group.svtId] ?? group.svtId;
          var curSvt = db.gameData.servantsById[svtId] ?? db.gameData.entities[svtId];
          if (_svt?.id != curSvt?.id || curSvt == null) {
            svtSpan = curSvt == null
                ? TextSpan(text: '${group.svtId} ')
                : SharedBuilder.textButtonSpan(context: context, text: '${curSvt.lName.l} ', onTap: curSvt.routeTo);
          }
        }
        return ListTile(
          dense: true,
          title: Text.rich(
            TextSpan(
              children: [
                ?svtSpan,
                TextSpan(text: Transl.enums(group.type, (enums) => enums.svtVoiceType).l),
              ],
            ),
          ),
          subtitle: suffixes.isEmpty
              ? null
              : Text.rich(
                  TextSpan(
                    children: [
                      ...divideList(suffixes, const TextSpan(text: ', ')),
                      // avoid clickable space extends to entire width
                      const TextSpan(text: ' '),
                    ],
                  ),
                  textScaler: const TextScaler.linear(0.9),
                ),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [];
        if (group.svtId != svt?.id) {
          children.add(
            ListTile(
              title: Text(S.current.card_asset_chara_figure),
              trailing: Text(group.svtId.toString()),
              dense: true,
              onTap: () {
                const limitCount = 0;
                FullscreenImageViewer.show(
                  context: context,
                  urls: [
                    '${HostsX.atlasAssetHost}/JP/CharaFigure/${group.svtId}$limitCount/${group.svtId}${limitCount}_merged.png',
                  ],
                );
              },
            ),
          );
        }
        Map<String, int> _nameCount = {};
        children.addAll(
          voiceLines.map(
            (e) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: _buildVoiceLine(context, e, _nameCount),
            ),
          ),
        );
        return Column(children: children);
      },
    );
  }

  Event? _getEvent(List<VoiceLine> lines) {
    for (final line in lines) {
      for (final cond in line.conds) {
        final e = db.gameData.events[cond.value];
        if (e != null && e.id != event?.id) return e;
      }
    }
    return null;
  }

  Future<List<AudioSource>> getSources(VoiceLine line) async {
    if (!kIsWeb) {
      await Future.wait(line.audioAssets.map((e) => AtlasIconLoader.i.get(e)));
    }
    List<AudioSource> sources = [];
    for (int index = 0; index < line.audioAssets.length; index++) {
      int delay = ((line.delay.getOrNull(index) ?? 0) * 1000).toInt();
      if (delay > 0) {
        sources.add(SilenceAudioSource(duration: Duration(milliseconds: delay)));
      }
      if (kIsWeb) {
        sources.add(AudioSource.uri(Uri.parse(AtlasIconLoader.i.proxyAssetUrl(line.audioAssets[index]))));
      } else {
        final fp = AtlasIconLoader.i.getCached(line.audioAssets[index]);
        if (fp == null) continue;
        sources.add(AudioSource.uri(Uri.file(fp)));
      }
    }
    return sources;
  }

  Widget _buildVoiceLine(BuildContext context, VoiceLine line, Map<String, int> _nameCount) {
    String _transl(String text) {
      for (final s in ['\u3000（ひとつの施策でふたつあるとき）', '（57は欠番）']) {
        text = text.replaceFirst(s, '');
      }
      text = text.trim();
      text = text.replaceFirstMapped(RegExp(r'^(.+?)(\d*)([(（)]|$)'), (match) {
        final _name = Transl.string(db.gameData.mappingData.voiceLineNames, match.group(1)!.trim());
        final _num = match.group(2);
        if (_num != null && _num.isNotEmpty) {
          return '${_name.l} $_num';
        } else {
          return _name.l;
        }
      });
      final event = _getEvent([line]);
      if (event != null) {
        text = text.replaceAll('\n', '');
        text = text.replaceFirst(event.name.replaceAll('\n', ''), event.lName.l.replaceAll('\n', ' '));
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
        int index = _nameCount[overwriteName] = (_nameCount[overwriteName] ?? 0) + 1;
        overwriteName = overwriteName.replaceAllMapped('{0}', (match) => index.toString());
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '· $name',
                    maxLines: 2,
                    maxFontSize: 12,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  for (final cond in line.conds)
                    if (![VoiceCondType.levelUp, VoiceCondType.event, VoiceCondType.birthDay].contains(cond.condType) &&
                        !(cond.condType == VoiceCondType.eventEnd && cond.value == 0))
                      VoiceCondDescriptor(
                        condType: cond.condType,
                        value: cond.value,
                        valueList: cond.valueList,
                        textScaleFactor: 0.85,
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              child: Builder(
                builder: (context) {
                  bool valid = line.audioAssets.isNotEmpty;
                  if (!valid) {
                    return const IconButton(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      onPressed: null,
                      icon: Icon(Icons.play_circle_outline),
                      tooltip: 'Not Found',
                    );
                  } else {
                    return _PlayButton(
                      player: player,
                      getSources: () {
                        return getSources(line);
                      },
                      tag: line,
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 24,
              child: Builder(
                builder: (context) {
                  bool valid = line.audioAssets.isNotEmpty;
                  if (!valid) {
                    return const IconButton(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      onPressed: null,
                      icon: Icon(Icons.file_download),
                      tooltip: 'Not Found',
                    );
                  }
                  return IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () async {
                      if (kIsWeb) {
                        toMergeVoiceLine(line);
                        return;
                      }
                      List<String?> localFiles = [];
                      EasyLoading.show(status: S.current.downloading);
                      for (final url in line.audioAssets) {
                        localFiles.add(await AtlasIconLoader.i.get(url));
                      }
                      EasyLoading.dismiss();
                      String? _dir = localFiles.firstWhereOrNull((e) => e != null);
                      if (_dir != null) _dir = pathlib.dirname(_dir);
                      String hint = '';
                      if (_dir == null) {
                        hint = S.current.failed;
                      } else {
                        hint = '${db.paths.convertIosPath(_dir)}:';
                        for (final fp in localFiles) {
                          hint += '\n - ${pathlib.basename(fp ?? S.current.failed)}';
                        }
                      }
                      SimpleConfirmDialog(
                        title: Text(S.current.save),
                        content: Text(hint),
                        confirmText: S.current.open,
                        onTapOk: () async {
                          if (_dir == null) return;
                          if (PlatformU.isDesktop) {
                            openFile(_dir);
                          } else {
                            EasyLoading.showInfo(S.current.open_in_file_manager);
                          }
                        },
                        actions: [
                          TextButton(
                            onPressed: () {
                              toMergeVoiceLine(line);
                            },
                            child: Text(S.current.merge),
                          ),
                        ],
                      ).showDialog(null);
                    },
                    icon: const Icon(Icons.file_download),
                    tooltip: S.current.download,
                  );
                },
              ),
            ),
          ],
        ),
        // _voicePlayCond(),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Text(text, textScaler: const TextScaler.linear(0.9)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void toMergeVoiceLine(VoiceLine line) {
    List<String> rows = [];
    for (final (index, url) in line.audioAssets.indexed) {
      rows.add(url);
      rows.add((line.delay.getOrNull(index) ?? 0).toString());
    }
    launch(
      ChaldeaUrl.doc('tools', queryParams: {'audioData': base64Encode(utf8.encode(rows.join('\n')))}),
      external: true,
    );
  }
}

class _PlayButton<T> extends StatefulWidget {
  final MyAudioPlayer<T> player;
  final T? tag;
  final FutureOr<List<AudioSource>> Function() getSources;
  const _PlayButton({super.key, required this.player, required this.getSources, this.tag});

  @override
  State<_PlayButton> createState() => __PlayButtonState();
}

class __PlayButtonState<T> extends State<_PlayButton<T>> {
  bool _downloading = false;
  set downloading(bool v) {
    _downloading = v;
    refresh();
  }

  late StreamSubscription<bool> subscription;
  @override
  void initState() {
    super.initState();
    subscription = widget.player.player.playingStream.listen((event) {
      refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  static bool _linuxValid = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onPressed: () async {
        if (!await checkCompatibility()) {
          return;
        }
        if (_downloading) {
          return;
        }
        if (widget.player.isPlaying(widget.tag)) {
          return widget.player.stop();
        }
        downloading = true;
        final sources = await widget.getSources();
        downloading = false;
        if (sources.isEmpty) return;

        await widget.player
            .play(sources, widget.tag)
            .catchError((e, s) {
              widget.player.resetTag();
              EasyLoading.showError('Error playing audio (May not support)\n$e');
              logger.e('Error playing audio', e, s);
            })
            .whenComplete(() {
              if (mounted) setState(() {});
            });
      },
      icon: Icon(
        widget.player.isPlaying(widget.tag)
            ? Icons.pause_circle_outline
            : _downloading
            ? Icons.downloading
            : Icons.play_circle_outline,
      ),
      tooltip: 'Play',
    );
  }

  Future<bool> checkCompatibility() async {
    if (PlatformU.isLinux) {
      EasyLoading.showInfo('Linux not supported yet');
      return false;
    }
    if (PlatformU.isLinux && !_linuxValid) {
      // if linux mpv is support in the future
      if (Process.runSync("which", ["mpv"], runInShell: true).exitCode == 0) {
        _linuxValid = true;
        return true;
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleConfirmDialog(
                title: const Text('Linux MPV'),
                showCancel: false,
                content: Text.rich(
                  TextSpan(
                    text: 'MPV is required to play audio, see\n',
                    children: [
                      TextSpan(
                        text: 'https://github.com/bleonard252/just_audio_mpv',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://github.com/bleonard252/just_audio_mpv');
                          },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return false;
      }
    }
    return SynchronousFuture(true);
  }
}

// ignore: unused_element
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
