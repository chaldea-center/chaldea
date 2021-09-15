import 'package:chaldea/components/extensions.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:libwinmedia/libwinmedia.dart' as audio_win;
import 'package:path/path.dart' as p;

import 'audio_player.dart';

/// [audio_win.LWM.initialize] before start app
class AudioPlayerWin with AudioPlayer {
  @override
  int id;
  audio_win.Player player;

  AudioPlayerWin([this.id = 0]) : player = audio_win.Player(id: id);

  @override
  bool checkSupport(String path, [String? originPath]) {
    List<String> unsupported = ['ogg', 'ogx', 'oga', 'ogv'];

    String extension = p.extension(originPath ?? path).trimCharLeft('.');
    if (unsupported.contains(extension)) {
      EasyLoading.showInfo('Unsupported audio type: $extension');
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    player.dispose();
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> play(String path, [String? originPath]) async {
    player.open([audio_win.Media(uri: path)]);
    player.play();
  }

  @override
  Future<void> stop() async {
    player.pause();
  }
}
