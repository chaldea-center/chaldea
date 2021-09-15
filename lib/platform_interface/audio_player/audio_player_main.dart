import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:chaldea/components/extensions.dart';
import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as p;

import 'audio_player.dart';

class AudioPlayerMain with AudioPlayer {
  @override
  int id;
  audio_players.AudioPlayer player;

  AudioPlayerMain([this.id = 0])
      : player = audio_players.AudioPlayer(playerId: id.toString()) {
    player.onPlayerError.listen((event) {
      EasyLoading.showError(LocalizedText.of(
          chs: '$event\n可能是不受支持的格式',
          jpn: '$event\nサポートされていない形式かもしれ',
          eng: '$event\nMay be an unsupported format'));
    });
  }

  @override
  bool checkSupport(String path, [String? originPath]) {
    // for web, decided by browser
    List<String> unsupported = [];
    if (PlatformU.isMacOS || PlatformU.isIOS) {
      unsupported = ['ogg', 'ogx', 'oga', 'ogv', 'wav'];
    }
    String extension = p.extension(originPath ?? path).trimCharLeft('.');
    if (unsupported.contains(extension)) {
      EasyLoading.showInfo('Unsupported audio type: $extension');
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    stop().then((value) => player.dispose());
  }

  @override
  Future<void> pause() {
    return player.pause();
  }

  @override
  Future<void> play(String path, [String? originPath]) async {
    if (!checkSupport(path, originPath)) {
      return;
    }
    await player.stop();
    await player.play(path, isLocal: true);
  }

  @override
  Future<void> stop() {
    return player.stop();
  }
}
