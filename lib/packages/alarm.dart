import 'package:alarm/alarm.dart';
import 'package:path/path.dart' as p;

import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/packages/packages.dart';
import 'app_info.dart';

abstract class AlarmX {
  static bool _initiated = false;
  static bool _hasInitError = false;
  static bool get isSupported => 1 > 2 && (PlatformU.isIOS) && AppInfo.isDebugOn && !_hasInitError;

  static const _audioUrl = "https://static.atlasacademy.io/JP/Audio/Bgm/BGM_MIZUGIKENGOU/BGM_MIZUGIKENGOU.mp3";

  static Future<bool> ensureInit() async {
    if (!isSupported) return false;
    if (_initiated) return _initiated;
    try {
      await Alarm.init();
      _initiated = true;
    } catch (e, s) {
      _hasInitError = true;
      logger.e('alarm init failed', e, s);
    }
    return _initiated;
  }

  static Future<bool> schedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return false;
    if (!await ensureInit()) return false;
    Alarm.ringing.listen((alarmSet) {});
    String? audioFp = await AtlasIconLoader.i.get(_audioUrl);
    if (audioFp == null) return false;
    audioFp = 'temp/${p.basename(audioFp)}';
    return Alarm.set(
      alarmSettings: AlarmSettings(
        id: id,
        dateTime: dateTime,
        assetAudioPath: audioFp,
        volumeSettings: VolumeSettings.fade(fadeDuration: const Duration(seconds: 5)),
        notificationSettings: NotificationSettings(title: title, body: body, stopButton: 'STOP'),
        loopAudio: true,
        vibrate: true,
      ),
    );
  }

  static Future<bool> stop(int id) async {
    if (!isSupported) return false;
    return Alarm.stop(id);
  }

  static Future<void> stopAll() async {
    if (!isSupported) return;
    return Alarm.stopAll();
  }

  static Future<List<AlarmSettings>> getAlarms() async {
    if (!isSupported) return [];
    return Alarm.getAlarms();
  }
}
