import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_audio/just_audio.dart';

import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../app/tools/icon_cache_manager.dart';
import '../utils/basic.dart';

class MyAudioPlayer<T> {
  final AudioPlayer player;
  final void Function(dynamic e)? onError;
  final bool showError;
  MyAudioPlayer({AudioPlayer? player, this.onError, this.showError = true}) : player = player ?? AudioPlayer();

  dynamic _tag;
  bool get playing => _tag != null;
  bool isPlaying(T? tag) => tag != null && _tag == tag;
  void resetTag() => _tag = null;

  Future<void> play(List<AudioSource> sources, [T? tag]) async {
    dynamic curTag = tag ?? DateTime.now().microsecondsSinceEpoch;
    _tag = curTag;
    bool invalid() => curTag != _tag;
    if (player.playing) {
      await player.pause();
    }
    for (final source in sources) {
      if (source is SilenceAudioSource) {
        await Future.delayed(source.duration);
      } else if (source is UriAudioSource) {
        if (invalid()) return;
        try {
          await player.setAudioSource(source);
          if (invalid()) return;
          await player.play();
          await Future.delayed(const Duration(milliseconds: 10));
        } catch (e, s) {
          logger.e('failed play audio: ${source.uri}', e, s);
          if (onError != null) {
            onError!(e);
          } else if (showError) {
            EasyLoading.showError(escapeDioException(e));
          }
        }
        // may not be `completed`
        while (player.playerState.processingState != ProcessingState.completed) {
          if (invalid()) return;
          await Future.delayed(const Duration(milliseconds: 20));
        }
      }
    }
    _tag = null;
  }

  Future<void> playOrPause(List<AudioSource> sources, T tag) async {
    if (tag == _tag) {
      return stop();
    } else {
      play(sources, tag);
    }
  }

  Future<void> stop() async {
    _tag = null;
    if (PlatformU.isWindows || PlatformU.isLinux) {
      return player.pause();
    } else {
      return player.stop();
    }
  }
}

extension MyAudioPlayerString on MyAudioPlayer<String> {
  Future<void> playUri(String url) async {
    AudioSource source;
    String? fp;
    if (!kIsWeb) {
      fp = await AtlasIconLoader.i.get(url);
    }
    source = fp != null ? AudioSource.uri(Uri.file(fp), tag: url) : AudioSource.uri(Uri.parse(url), tag: url);
    playOrPause([source], url);
  }
}

class SoundPlayButton extends StatelessWidget {
  final String? name;
  final String? url;
  final MyAudioPlayer<String> player;

  const SoundPlayButton({super.key, this.name, required this.url, required this.player});

  @override
  Widget build(BuildContext context) {
    final playButton = StreamBuilder(
      stream: player.player.processingStateStream,
      builder: (context, processState) => StreamBuilder(
        stream: player.player.playingStream,
        builder: (context, isPlaying) {
          bool playing =
              (isPlaying.data ?? false) && player.isPlaying(url) && processState.data != ProcessingState.completed;
          return Icon(playing ? Icons.pause : Icons.play_arrow, size: 18);
        },
      ),
    );
    if (name == null || name!.isEmpty) {
      return ElevatedButton(
        onPressed: url == null ? null : () => onPressed(url!),
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          minimumSize: const Size(18, 18),
        ),
        child: playButton,
      );
    }
    return ElevatedButton.icon(
      onPressed: url == null ? null : () => onPressed(url!),
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 14, 2),
      ),
      icon: playButton,
      label: Text(name!),
    );
  }

  Future onPressed(String _url) async {
    player.playUri(_url);
  }
}
