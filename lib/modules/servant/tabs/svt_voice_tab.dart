import 'dart:convert';

import 'package:audioplayers/audioplayers.dart' as audio1;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/lang_switch.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart' as audio2;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtVoiceTab extends SvtTabBaseWidget {
  SvtVoiceTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtVoiceTabState createState() =>
      _SvtVoiceTabState(parent: parent, svt: svt, plan: status);
}

class _SvtVoiceTabState extends SvtTabBaseState<SvtVoiceTab> {
  _SvtVoiceTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);
  Language? lang;
  GeneralAudioPlayer? audioPlayer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var table in svt.voices) {
      children.add(SimpleAccordion(
        headerBuilder: (context, expanded) =>
            ListTile(title: Text(_getLocalizedText(table.section, true))),
        contentBuilder: (context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            border: TableBorder(
                horizontalInside: Divider.createBorderSide(context, width: 1)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: _buildVoiceRows(table),
            columnWidths: {0: FlexColumnWidth(), 1: FixedColumnWidth(33.0)},
          ),
        ),
      ));
    }
    if (lang == Language.eng)
      children.add(Center(
        child: Text(
          'Voices maybe mismatched',
          style: Theme.of(context).textTheme.caption,
        ),
      ));
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => kDefaultDivider,
            itemCount: children.length,
          ),
        ),
        _buildButtonBar()
      ],
    );
  }

  List<TableRow> _buildVoiceRows(VoiceTable table) {
    return table.table.map((record) {
      return TableRow(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                _getLocalizedText(record.title),
                maxLines: 1,
                maxFontSize: 12,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(LocalizedText(
                chs: record.text,
                jpn: record.textJp,
                eng: record.textEn,
              ).ofPrimary(lang ?? Language.current))
            ],
          ),
        ),
        ValueStatefulBuilder<bool>(
          initValue: false,
          builder: (context, state) {
            bool playing = state.value;
            bool valid = record.voiceFile.isNotEmpty;
            if (!valid) {
              return IconButton(
                onPressed: null,
                icon: Icon(Icons.play_circle_outline),
              );
            }
            if (playing) {
              return IconButton(
                  onPressed: null, icon: Icon(Icons.download_rounded));
            } else {
              return IconButton(
                onPressed: () {
                  if (!state.mounted) return;
                  state.setState(() {
                    state.value = !state.value;
                  });
                  onPlayVoice(record).onError((e, s) {
                    EasyLoading.showError('Error playing audio\n$e');
                    logger.e(
                        'Error playing audio\n${jsonEncode(record)}\n', e, s);
                  }).whenComplete(() {
                    if (state.mounted)
                      state.setState(() {
                        state.value = !state.value;
                      });
                  });
                },
                icon: Icon(Icons.play_circle_outline),
              );
            }
          },
        ),
      ]);
    }).toList();
  }

  String _getLocalizedText(String text, [bool isTitle = false]) {
    String _getPart(String _text) {
      final match = RegExp(r'^(.+?)([\s\d]+)$').firstMatch(_text);
      if (match == null) return _localizedVoices.of(_text);
      String prefix = (match.group(1) ?? '').trim(),
          digit = match.group(2)!.trim();
      return _localizedVoices.of(prefix) + ' ' + digit;
    }

    if (isTitle) {
      return text.replaceFirstMapped(RegExp(r'^(.*?)(?:\(([^()]+)\))?$'),
          (match) {
        if (match.group(2) != null) {
          return _getPart(match.group(1)!) +
              '(' +
              _getPart(match.group(2)!) +
              ')';
        } else {
          return _getPart(match.group(1)!);
        }
      });
    } else {
      return _getPart(text);
    }
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ProfileLangSwitch(
          primary: lang,
          onChanged: (v) {
            setState(() {
              lang = v;
            });
          },
        ),
      ],
    );
  }

  Future<void> onPlayVoice(VoiceRecord record) async {
    if (record.voiceFile.isEmpty) {
      // check before call and set button disabled
      return;
    }
    audioPlayer ??= GeneralAudioPlayer();
    final String? url = await MooncellUtil.resolveFileUrl(record.voiceFile);
    // print('${record.voiceFile}  -> $url');
    if (url == null) {
      EasyLoading.showToast('File not found: ${record.voiceFile}');
      return;
    }

    /// [DefaultCacheManager] will change the extension when saving cache
    ///   * .ogg/.ogx -> .oga
    ///   * .wav -> .bin

    final file = await DefaultCacheManager().getSingleFile(url);
    if (!mounted) return;
    await audioPlayer?.play(file.path, url);
  }
}

class GeneralAudioPlayer {
  /// audioplayers:
  ///   * Android: mp3/wav/ogg/ogx √
  ///   * iOS/macOS: only mp3
  audio1.AudioPlayer? player1;

  /// flutter_audio_desktop: miniaudio
  /// * support mp3/wav
  /// * not support ogg/ogx
  audio2.AudioPlayer? player2;

  bool _valid;

  bool get valid => _valid;

  GeneralAudioPlayer() : _valid = true {
    if (usePlayer1) {
      player1 = audio1.AudioPlayer();
      player1!.onPlayerError.listen((event) {
        EasyLoading.showError(LocalizedText.of(
            chs: '$event\n可能是不受支持的格式',
            jpn: '$event\nサポートされていない形式かもしれ',
            eng: '$event\nMay be an unsupported format'));
      });
    } else {
      player2 = audio2.AudioPlayer();
    }
  }

  bool get usePlayer1 => !Platform.isWindows;

  /// [path] must be local path
  /// [DefaultCacheManager] download from [originPath] and save cache as [path]
  Future<void> play(String path, [String? originPath]) async {
    assert(() {
      if (!_valid) {
        throw Exception('Call player after disposed.');
      }
      return true;
    }());
    if (!checkSupport(path, originPath)) {
      return;
    }
    if (usePlayer1) {
      await player1!.stop();
      await player1!.play(path, isLocal: true);
    } else {
      if (player2!.isPlaying) {
        await player2!.stop();
      }
      await player2!.load(path);
      await player2!.play();
    }
  }

  bool checkSupport(String path, [String? originPath]) {
    print('$originPath\n  -> $path');
    List<String> unsupported = [];
    if (usePlayer1) {
      if (Platform.isMacOS || Platform.isIOS) {
        unsupported = ['ogg', 'ogx', 'oga', 'ogv', 'wav'];
      }
    } else {
      unsupported = ['ogg', 'ogx', 'oga', 'ogv'];
    }
    String extension = p.extension(originPath ?? path).trimCharLeft('.');
    if (unsupported.contains(extension)) {
      EasyLoading.showInfo('Unsupported audio type: $extension');
      return false;
    }
    return true;
  }

  Future<void> stop() async {
    _valid = false;
    if (usePlayer1) {
      await player1!.stop();
    } else {
      await player2!.stop();
    }
  }

  Future<void> pause() async {
    if (usePlayer1) {
      await player1!.pause();
    } else {
      await player2!.pause();
    }
  }

  void dispose() {
    stop().then((value) => player1?.dispose());
  }
}

LocalizedGroup get _localizedVoices => LocalizedGroup([
      LocalizedText(chs: '战斗形象', jpn: '', eng: 'Battle Sprite'),
      LocalizedText(chs: '期间限定加入', jpn: '', eng: ''),
      LocalizedText(chs: '战斗', jpn: '', eng: 'Battle'),
      LocalizedText(chs: '开始', jpn: '', eng: 'Battle Start'),
      LocalizedText(chs: '技能', jpn: '', eng: 'Skill'),
      LocalizedText(chs: '指令卡', jpn: '', eng: 'Attack Selected'),
      LocalizedText(chs: '宝具卡', jpn: '', eng: 'NP Selected'),
      LocalizedText(chs: '攻击', jpn: '', eng: 'Attack'),
      LocalizedText(chs: '宝具', jpn: '', eng: 'Noble Phantasm'),
      LocalizedText(chs: '受击', jpn: '', eng: 'Damage'),
      LocalizedText(chs: '无法战斗', jpn: '', eng: 'Defeated'),
      LocalizedText(chs: '胜利', jpn: '', eng: 'Battle Finish'),
      LocalizedText(chs: '召唤和强化', jpn: '', eng: 'Summon and Leveling'),
      LocalizedText(chs: '召唤', jpn: '', eng: 'Summoned'),
      LocalizedText(chs: '升级', jpn: '', eng: 'Level Up'),
      LocalizedText(chs: '灵基再临', jpn: '', eng: 'Ascension'),
      LocalizedText(chs: '个人空间', jpn: '', eng: 'My Room'),
      LocalizedText(chs: '羁绊', jpn: '', eng: 'Bond'),
      LocalizedText(chs: '羁绊Lv.', jpn: '', eng: 'Bond Lv.'),
      LocalizedText(chs: '羁绊 Lv.', jpn: '', eng: 'Bond Lv.'),
      LocalizedText(chs: '对话', jpn: '', eng: 'Dialogue'),
      LocalizedText(chs: '喜欢的东西', jpn: '', eng: 'Something you Like'),
      LocalizedText(chs: '讨厌的东西', jpn: '', eng: 'Something you Hate'),
      LocalizedText(chs: '关于圣杯', jpn: '', eng: 'About the Holy Grail'),
      LocalizedText(chs: '活动举行中', jpn: '', eng: 'During an Event'),
      LocalizedText(chs: '生日', jpn: '', eng: 'Birthday'),
      LocalizedText(chs: '灵衣', jpn: '', eng: 'Costume'),
      LocalizedText(chs: '灵衣开放', jpn: '', eng: 'Costume Unlock'),
      LocalizedText(chs: '灵衣相关', jpn: '', eng: 'Costume Related'),
    ]);
