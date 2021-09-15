import 'package:chaldea/platform_interface/platform/platform.dart';

import 'audio_player_main.dart';
import 'audio_player_win.dart';

abstract class AudioPlayer {
  int get id;

  factory AudioPlayer([int id = 0]) =>
      PlatformU.isWindows ? AudioPlayerWin(id) : AudioPlayerMain(id);

  /// [path] must be local path
  /// [DefaultCacheManager] download from [originPath] and save cache as [path]
  Future<void> play(String path, [String? originPath]);

  bool checkSupport(String path, [String? originPath]);

  Future<void> stop();

  Future<void> pause();

  void dispose();
}
