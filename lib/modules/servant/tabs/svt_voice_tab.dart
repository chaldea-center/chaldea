import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio1;
import 'package:chaldea/components/components.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart' as audio2;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  bool useLangCn = false;
  GeneralAudioPlayer? audioPlayer;

  @override
  void initState() {
    super.initState();
    useLangCn = Language.isCN;
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final table = svt.voices[index];
              return SimpleAccordion(
                headerBuilder: (context, expanded) =>
                    ListTile(title: Text(table.section)),
                contentBuilder: (context) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Table(
                    border: TableBorder(
                        horizontalInside:
                            Divider.createBorderSide(context, width: 1)),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: _buildVoiceRows(table),
                    columnWidths: {
                      0: FixedColumnWidth(80.0),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(33.0)
                    },
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => kDefaultDivider,
            itemCount: svt.voices.length,
          ),
        ),
        _buildButtonBar()
      ],
    );
  }

  List<TableRow> _buildVoiceRows(VoiceTable table) {
    return table.table.map((record) {
      return TableRow(children: [
        Text(record.title, style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Text((useLangCn ? record.text : record.textJp) ??
              record.textJp ??
              record.text ??
              '???'),
        ),
        IconButton(
          onPressed:
              record.voiceFile.isNotEmpty ? () => onPlayVoice(record) : null,
          icon: Icon(Icons.play_circle_outline),
          color: Colors.blue,
        ),
      ]);
    }).toList();
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          constraints: BoxConstraints(),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          onPressed: (i) {
            setState(() {
              useLangCn = i == 0;
            });
          },
          children: List.generate(
            2,
            (i) => Padding(
              padding: EdgeInsets.all(6),
              child: Text(['中', '日'][i]),
            ),
          ),
          isSelected: List.generate(2, (i) => useLangCn == (i == 0)),
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
    if (!mounted) return;
    if (url == null) {
      EasyLoading.showToast('File not found: ${record.voiceFile}');
      return;
    }
    final file = await DefaultCacheManager().getSingleFile(url);
    if (!mounted) return;
    audioPlayer?.play(file.path);
  }
}

class GeneralAudioPlayer {
  audio1.AudioPlayer? player1;
  audio2.AudioPlayer? player2;

  GeneralAudioPlayer() {
    if (usePlayer1) {
      player1 = audio1.AudioPlayer();
    } else {
      player2 = audio2.AudioPlayer();
    }
  }

  bool get usePlayer1 => !Platform.isWindows;

  /// [path] must be local path
  Future<void> play(String path) async {
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

  Future<void> stop() async {
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
    if (usePlayer1) player1?.dispose();
  }
}
