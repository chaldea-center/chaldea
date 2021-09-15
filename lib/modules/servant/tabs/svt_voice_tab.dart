import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/lang_switch.dart';
import 'package:chaldea/platform_interface/audio_player/audio_player.dart';
import 'package:path/path.dart' as p;

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtVoiceTab extends SvtTabBaseWidget {
  const SvtVoiceTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtVoiceTabState createState() => _SvtVoiceTabState();
}

class _SvtVoiceTabState extends SvtTabBaseState<SvtVoiceTab> {
  Language? lang;
  AudioPlayer? audioPlayer;

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
          padding: const EdgeInsets.only(left: 16),
          child: Table(
            border: TableBorder(
                horizontalInside: Divider.createBorderSide(context, width: 1)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: _buildVoiceRows(table),
            columnWidths: const [
              FlexColumnWidth(),
              FixedColumnWidth(36.0),
              FixedColumnWidth(36.0)
            ].asMap(),
          ),
        ),
      ));
    }
    if (lang == Language.eng) {
      children.add(Center(
        child: Text(
          'Voices maybe mismatched',
          style: Theme.of(context).textTheme.caption,
        ),
      ));
    }
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
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                '· ' + _getLocalizedText(record.title),
                maxLines: 1,
                maxFontSize: 12,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
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
            bool downloading = state.value;
            bool valid = record.voiceFile?.isNotEmpty == true;
            if (!valid) {
              return const IconButton(
                onPressed: null,
                icon: Icon(Icons.play_circle_outline),
                tooltip: 'Not Found',
              );
            }
            if (downloading) {
              return IconButton(
                onPressed: null,
                icon: const Icon(Icons.download_rounded),
                tooltip: S.current.downloading,
              );
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
                    if (state.mounted) {
                      state.setState(() {
                        state.value = !state.value;
                      });
                    }
                  });
                },
                icon: const Icon(Icons.play_circle_outline),
                tooltip: 'Play',
              );
            }
          },
        ),
        ValueStatefulBuilder<bool>(
          initValue: false,
          builder: (context, state) {
            bool downloading = state.value;
            bool valid = record.voiceFile?.isNotEmpty == true;
            if (!valid || downloading) {
              return const IconButton(
                onPressed: null,
                icon: Icon(Icons.file_download),
                tooltip: 'Not Found',
              );
            }
            return IconButton(
              onPressed: () async {
                state.setState(() {
                  state.value = !state.value;
                });
                final file = await WikiUtil.getWikiFile(record.voiceFile!);
                if (file == null) return;
                final fp = p.join(db.paths.downloadDir, record.voiceFile);
                await SimpleCancelOkDialog.showSave(
                    context: context, srcFile: file, savePath: fp);
                if (state.mounted) {
                  state.setState(() {
                    state.value = !state.value;
                  });
                }
              },
              icon: const Icon(Icons.file_download),
              tooltip: S.current.download,
            );
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
      if (db.gameData.events.limitEvents.containsKey(text)) {
        return db.gameData.events.limitEvents[text]!.localizedName;
      }
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
    if (record.voiceFile?.isNotEmpty != true) {
      // check before call and set button disabled
      return;
    }
    audioPlayer ??= AudioPlayer();
    final url = await WikiUtil.resolveFileUrl(record.voiceFile!);
    final file = await WikiUtil.getWikiFile(record.voiceFile!);
    if (file == null) {
      EasyLoading.showToast('File not found: ${record.voiceFile}');
      return;
    }

    /// [DefaultCacheManager] will change the extension when saving cache
    ///   * .ogg/.ogx -> .oga
    ///   * .wav -> .bin

    if (!mounted) return;
    await audioPlayer?.play(file.path, url);
  }
}

LocalizedGroup get _localizedVoices => const LocalizedGroup([
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
