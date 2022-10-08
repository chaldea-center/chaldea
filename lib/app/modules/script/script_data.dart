import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:csv/csv.dart';
import 'package:ruby_text/ruby_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../servant/tabs/voice_tab.dart';
import 'script_reader.dart';

class ScriptParsedData {
  Uri? _uri;
  ScriptState state = ScriptState();
  List<ScriptComponent> components = [];
  ScriptParsedData();

  Uri? get uri => _uri;

  void init(String scritUrl, [Region? overrideRegion]) {
    _uri = Uri.parse(scritUrl);
    state.region = overrideRegion ??
        RegionX.tryParse(_uri!.pathSegments.first) ??
        Region.jp;
    _uri = _uri!.replace(pathSegments: [
      state.region.toUpper(),
      ..._uri!.pathSegments.sublist(1)
    ]);
    state.fullscreen = false;
  }

  void reset() {
    components.clear();
    state
      ..fullscreen = false
      ..fulltext = null
      ..player.stop();
  }

  Future<void> load({bool force = false}) async {
    if (_uri == null) return;
    if (force) {
      await AtlasIconLoader.i.deleteFromDisk(_uri!.toString());
    }
    final fp = await AtlasIconLoader.i.get(_uri!.toString());
    if (fp != null) {
      state.fulltext = await FilePlus(fp).readAsString();
      _parseScript(state.fulltext ?? "");
    }
  }

  void _parseScript(String fulltext) {
    reset();
    final lines = const LineSplitter().convert(fulltext.trim());
    List<ScriptComponent> children = [];
    ScriptDialog? lastDialog;
    for (int lineNo = 0; lineNo < lines.length; lineNo++) {
      String line = lines[lineNo].trim();
      if (line.isEmpty) continue;
      if (lineNo == 0 && line.startsWith('＄')) continue;
      if (line.startsWith('＠')) {
        String speaker = line.substring(1);
        speaker =
            RegExp(r'^[A-Z]+：(.+)$').firstMatch(speaker)?.group(1) ?? speaker;
        lastDialog = ScriptDialog(speaker, _parseDialog(speaker), '', []);
        continue;
      }
      if (line == '[k]') {
        if (lastDialog != null) {
          children.add(lastDialog);
          lastDialog = null;
        } else {
          print('line $lineNo: got [k] but lastDialog is empty');
        }
        continue;
      }
      if (line == '？！' || line == '?!') {
        children.add(ScriptSelect(line, null, []));
        continue;
      }
      final selectMatch = RegExp(r'^[？?](\d+)[：:](.*)$').firstMatch(line);
      if (selectMatch != null) {
        children.add(ScriptSelect(
            selectMatch.group(0)!,
            int.parse(selectMatch.group(1)!),
            _parseDialog(selectMatch.group(2)!)));
        continue;
      }
      if (lastDialog != null) {
        if (line.endsWith('[k]')) {
          lastDialog.contents
              .addAll(_parseDialog(line.substring(0, line.length - 3)));
          children.add(lastDialog);
          lastDialog = null;
        } else {
          lastDialog.contents.addAll(_parseDialog(line));
        }
        continue;
      }
      if (RegExp(r'\[[^\[\]]+\]').hasMatch(line)) {
        final cmd = ScriptCommand.parse(line);
        if (cmd.command == 'enableFullScreen') {
          state.fullscreen = true;
        }
        children.add(cmd);
        continue;
      }
      children.add(UnknownScript(line));
    }
    components = children;
  }

  List<ScriptComponent> _parseDialog(String dialog) {
    final _childReg = RegExp(r'\[[^\[\]]+\]');
    List<ScriptComponent> out = [];
    final p1 = dialog.split(_childReg);
    dialog.splitMapJoin(_childReg, onMatch: (match) {
      out.add(ScriptText(p1.removeAt(0)));
      out.add(ScriptCommand.parse(match.group(0)!));
      return '';
    });
    out.addAll(p1.map((e) => ScriptText(e)));
    return out;
  }
}

enum _CompType {
  none,
  color,
  fontSize,
  // align, cannot assign align to TextSpan
}

class _TextStyleState {
  TextStyle style;
  ScriptComponent component;
  _CompType type;
  _TextStyleState({
    required this.style,
    required this.component,
    required this.type,
  });
}

class ScriptState {
  String? fulltext;
  Region region = Region.jp;
  bool fullscreen = false;
  final player = MyAudioPlayer<String>();
  List<_TextStyleState> dialogStyleStack = [];

  void push(TextStyle style, ScriptComponent component, _CompType type) {
    dialogStyleStack
        .add(_TextStyleState(style: style, component: component, type: type));
  }

  void pop(bool Function(_TextStyleState c) test) {
    final index = dialogStyleStack.lastIndexWhere((e) => test(e));
    if (index != dialogStyleStack.length - 1) {
      print(
          'Warning: popping non-last style: No.${index + 1}/${dialogStyleStack.length} styles');
    }
    dialogStyleStack.removeAt(index);
  }

  void clear() {
    dialogStyleStack.clear();
  }

  TextStyle mergeStyles() {
    TextStyle style = const TextStyle();
    for (final s in dialogStyleStack) {
      style = style.merge(s.style);
    }
    return style;
  }

  TextSpan textSpan({
    String? text,
    List<InlineSpan>? children,
    TextStyle? style,
    GestureRecognizer? recognizer,
    MouseCursor? mouseCursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    String? semanticsLabel,
    Locale? locale,
    bool? spellOut,
  }) {
    TextStyle? mergedStyle;
    if (style != null || dialogStyleStack.isNotEmpty) {
      mergedStyle = mergeStyles();
      if (style != null) mergedStyle = mergedStyle.merge(style);
    }
    return TextSpan(
      text: text,
      children: children,
      style: mergedStyle,
      recognizer: recognizer,
      mouseCursor: mouseCursor,
      onEnter: onEnter,
      onExit: onExit,
      semanticsLabel: semanticsLabel,
      locale: locale,
      spellOut: spellOut,
    );
  }
}

class ScriptDialog extends ScriptTexts {
  String speakerSrc;
  List<ScriptComponent> speaker;

  ScriptDialog(this.speakerSrc, this.speaker, super.contents, super.src);

  @override
  String toString() {
    return 'Dialog $speakerSrc\n${contents.join('\n')}';
  }

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state,
      {bool hideSpeaker = false}) {
    state.clear();
    List<InlineSpan> spans = [];
    if (!hideSpeaker) {
      state.push(
        headerStyle.copyWith(
            color: Theme.of(context).colorScheme.secondaryContainer),
        this,
        _CompType.none,
      );
      spans.add(state.textSpan(text: kHeaderLeading));
      for (final c in speaker) {
        spans.addAll(c.build(context, state));
      }
      spans.add(state.textSpan(text: '\n'));
    }
    state.clear();
    state.push(bodyStyle, this, _CompType.none);
    for (final p in contents) {
      spans.addAll(p.build(context, state));
    }
    state.clear();
    return spans;
  }
}

class ScriptText extends ScriptComponent {
  ScriptText(super.src);

  @override
  String toString() {
    return 'Text: $src';
  }

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state) {
    return [state.textSpan(text: src)];
  }
}

class ScriptTexts extends ScriptComponent {
  List<ScriptComponent> contents;

  ScriptTexts(super.src, this.contents);

  @override
  String toString() {
    return 'Texts: $contents';
  }

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state) {
    return [for (final c in contents) ...c.build(context, state)];
  }
}

class ScriptSelect extends ScriptTexts {
  int? index; // null = select end
  ScriptSelect(super.src, this.index, super.contents);

  static const _choiceStyle = TextStyle(color: Colors.blue);

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state) {
    if (index == null) {
      return [
        state.textSpan(text: S.current.script_choice_end, style: _choiceStyle),
        const WidgetSpan(child: Divider(thickness: 2)),
      ];
    }
    return [
      if (index == 1) const WidgetSpan(child: Divider(thickness: 2)),
      state.textSpan(
          text: '${S.current.script_choice} $index: ', style: _choiceStyle),
      for (final p in contents) ...p.build(context, state),
      // const TextSpan(text: '\n'),
    ];
  }
}

class UnknownScript extends ScriptComponent {
  UnknownScript(super.src);
  @override
  String toString() {
    return 'Unknown: $src';
  }

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state) {
    return [
      state.textSpan(
          text: '${kHeaderLeading}Unknown Script\n', style: headerStyle),
      state.textSpan(text: src)
    ];
  }
}

class ScriptCommand extends ScriptComponent {
  String command;
  List<String> args;
  ScriptCommand(super.src, this.command, [this.args = const []]);
  static const _csv =
      CsvToListConverter(fieldDelimiter: " ", shouldParseNumbers: false);

  factory ScriptCommand.parse(String code) {
    if (code.startsWith('[') && code.endsWith(']')) {
      code = code.substring(1, code.length - 1);
    }
    final cells =
        _csv.convert(code).first.map((e) => e.toString().trim()).toList();
    return ScriptCommand(code, cells.first, cells.sublist(1));
  }

  @override
  String toString() {
    return 'Command: $command(${args.join(', ')})';
  }

  String get arg1 => args[0];
  String get arg2 => args[1];
  ScriptReaderFilterData get filterData => db.settings.scriptReaderFilterData;

  @override
  List<InlineSpan> build(BuildContext context, ScriptState state,
      {bool showMore = false}) {
    // [#text:ruby], :ruby may not exist
    if (src.startsWith('#')) {
      final aa = src.substring(1).split(':');
      if (aa.length == 1) return [TextSpan(text: aa.first)];
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.ideographic,
          child: RubyText(
            [RubyTextData(aa.first, ruby: aa.sublist(1).join(':'))],
            style: state.mergeStyles(),
          ),
        )
      ];
    }
    // [&male:female]
    if (src.startsWith('&') && src.contains(':')) {
      final match = RegExp(r'^&(.*):(.*)$').firstMatch(src);
      if (match != null) {
        return [
          state.textSpan(
            text: match.group(1),
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
          state.textSpan(text: '('),
          state.textSpan(
            text: match.group(2),
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
          state.textSpan(text: ')'),
        ];
      }
    }
    // color [ffffff]
    if (command.length == 6) {
      final hex = int.tryParse('0xff$command');
      if (hex != null) {
        state.push(TextStyle(color: Color(hex)), this, _CompType.color);
        return [];
      }
    }

    const codeStyle = TextStyle(color: Colors.redAccent);
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);
    switch (command) {
      case '-': // color end closure
        state.pop((c) => c.type == _CompType.color);
        return [];
      case 'f': // [f large] font
        final tag = args.getOrNull(0)?.trim();
        if (tag == '-') {
          state.pop((c) => c.type == _CompType.fontSize);
          return [];
        } else {
          final bodySize =
              state.dialogStyleStack.getOrNull(0)?.style.fontSize ?? 16.0;
          final sizes = <String, double>{
            // "-", //30
            'x-small': 18, //18?
            'small': 24,
            'medium': 30,
            'large': 48,
            'x-large': 64,
          };
          final size = sizes[tag];
          print([command, args, size]);
          if (size == null) break;
          state.push(TextStyle(fontSize: size / 30 * bodySize), this,
              _CompType.fontSize);
          return [];
        }
      case "r":
      case "sr":
      case "csr":
        return [state.textSpan(text: '\n')];
      case 'line':
        int length = double.tryParse(args.getOrNull(0) ?? '1')?.toInt() ?? 1;
        if (length < 1) length = 1;
        return [
          state.textSpan(
            text: '\u3000' * length,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          )
        ];
      case '%1':
        return [
          state.textSpan(
            text: Transl.misc('Fujimaru').m?.ofRegion(state.region) ??
                Transl.misc('Fujimaru').l,
            style: TextStyle(color: Colors.amber[800]),
          )
        ];
      case 'image':
        // npc languages etc, mostly inline
        final imgName = args.getOrNull(0)?.split(':').first;
        if (imgName != null) {
          final url = Atlas.asset('/Marks/$imgName.png', state.region);
          return [
            WidgetSpan(
              child: CachedImage(
                imageUrl: url,
                showSaveOnLongPress: true,
                placeholder: (context, url) =>
                    Text.rich(state.textSpan(text: src)),
              ),
            ),
          ];
        }
        break;
      case 'scene':
        if (!filterData.scene) return [];
        final imgName = args.getOrNull(0)?.split(':').first.trim();
        if (imgName != null) {
          // black, white
          if (['10000', '10001'].contains(imgName)) return [];
          final url = Atlas.asset(
              state.fullscreen
                  ? 'Back/back${imgName}_1344_626.png'
                  : 'Back/back$imgName.png',
              state.region);
          return [
            WidgetSpan(
              child: CachedImage(
                imageUrl: url,
                showSaveOnLongPress: true,
              ),
            ),
          ];
        }
        break;
      case 'pictureFrame':
      case 'pictureFrameTop':
        if (!filterData.scene) return [];
        // closure: [pictureFrame img] ... [pictureFrame]
        if (args.isEmpty) return [];
        return [
          WidgetSpan(
            child: CachedImage(
              imageUrl: Atlas.asset('Image/$arg1/$arg1.png', state.region),
              showSaveOnLongPress: true,
            ),
          ),
        ];
      case 'se':
      case 'seLoop':
        if (!filterData.soundEffect) return [];
        if (args.isEmpty) break;
        final filename = args[0];
        String folder = "SE";
        if (filename.startsWith('ba')) {
          folder = 'Battle';
        } else if (filename.startsWith('ad')) {
          folder = 'SE';
        } else if (filename.startsWith('ar')) {
          folder = 'ResidentSE';
        } else if (filename.startsWith('21')) {
          folder = 'SE_21';
        }
        return [
          WidgetSpan(
            child: SoundPlayButton(
              name: filename,
              url: Atlas.asset('Audio/$folder/$filename.mp3', state.region),
              player: state.player,
            ),
          )
        ];
      case 'bgm':
        if (!filterData.bgm) return [];
        if (args.isEmpty) break;
        final filename = args[0];
        return [
          WidgetSpan(
            child: SoundPlayButton(
              name: filename,
              url: Atlas.asset('Audio/$filename/$filename.mp3', state.region),
              player: state.player,
            ),
          )
        ];
      case 'tVoice': // valentine voice
        if (!filterData.voice) return [];
        if (args.length < 2) break;
        final folder = args[0], filename = args[1];
        return [
          WidgetSpan(
            child: SoundPlayButton(
              name: null,
              url: Atlas.asset('Audio/$folder/$filename.mp3', state.region),
              player: state.player,
            ),
          )
        ];
      case 'tVoiceUser': // female/male voices
        if (!filterData.voice) return [];
        return [
          for (int index = 0; index < args.length / 2; index++)
            WidgetSpan(
              child: SoundPlayButton(
                name: null,
                url: Atlas.asset(
                    'Audio/${args[index * 2]}/${args[index * 2 + 1]}.mp3',
                    state.region),
                player: state.player,
              ),
            )
        ];
      case 'criMovie':
        if (args.isEmpty) break;
        return [
          state.textSpan(text: 'Movie  ', style: boldStyle),
          SharedBuilder.textButtonSpan(
            context: context,
            text: args[0],
            style: state.mergeStyles().copyWith(
                color: Theme.of(context).colorScheme.secondaryContainer),
            onTap: () {
              launch(Atlas.asset('Movie/${args[0]}.mp4', state.region));
            },
          )
        ];
      case 'selectionUse':
        return [
          state.textSpan(text: 'Selection Use: ', style: boldStyle),
          for (final arg in args)
            state.textSpan(text: '$arg ', style: codeStyle),
        ];
      case 'flag':
        return [
          state.textSpan(text: 'Flag: ', style: boldStyle),
          state.textSpan(text: 'Set '),
          if (args.isNotEmpty) state.textSpan(text: arg1, style: codeStyle),
          if (args.length > 1) ...[
            state.textSpan(text: ' to '),
            state.textSpan(text: arg2, style: codeStyle),
          ],
        ];
      case 'label':
        return [
          state.textSpan(text: 'Label  ', style: boldStyle),
          for (final arg in args)
            state.textSpan(text: '$arg  ', style: codeStyle)
        ];
      case 'branch':
        return [
          state.textSpan(text: 'Branch: ', style: boldStyle),
          state.textSpan(text: 'Go to label '),
          for (final arg in args)
            state.textSpan(text: '$arg  ', style: codeStyle)
        ];
      case 'masterBranch':
        return [
          state.textSpan(text: 'Master Branch: ', style: boldStyle),
          for (final arg in args)
            state.textSpan(text: '$arg  ', style: codeStyle)
        ];
      case 'revivalBranch':
        return [
          state.textSpan(text: 'Revival Branch: ', style: boldStyle),
          for (final arg in args)
            state.textSpan(text: '$arg  ', style: codeStyle)
        ];
      case 'branchQuestClear':
      case 'branchQuestNotClear':
        final label = args.getOrNull(0);
        final questId = int.tryParse(args.getOrNull(1) ?? "");
        final phase = args.getOrNull(2);
        final quest = db.gameData.quests[questId];
        bool notClear = command == 'branchQuestNotClear';
        return [
          state.textSpan(text: 'Branch: ', style: boldStyle),
          state.textSpan(text: 'Go to label '),
          state.textSpan(text: '$label', style: codeStyle),
          state.textSpan(text: ' if'),
          if (notClear) state.textSpan(text: ' NOT'),
          state.textSpan(text: ' cleared quest '),
          SharedBuilder.textButtonSpan(
            context: context,
            text: quest == null || quest.lDispName.isEmpty
                ? 'Quest $questId'
                : quest.lDispName,
            onTap: questId == null
                ? null
                : () {
                    router.push(url: Routes.questI(questId));
                  },
          ),
          if (phase != null) state.textSpan(text: ' phase $phase'),
        ];
      // case 'tVoiceUser': // valentine voice
      case 'align': // valentine voice
        if (showMore) break;
        return [];
      // ALWAYS ignore
      case 'backEffect':
      case 'backEffectDestroy':
      case 'backEffectStop':
      case 'bgmStop':
      case 'blur':
      case 'blurOff':
      case 'cameraFilter':
      case 'cameraHome':
      case 'cameraMove':
      case 'charaChange':
      case 'charaCrossFade':
      case 'charaDepth':
      case 'charaBackEffect':
      case 'charaBackEffectDestroy':
      case 'charaBackEffectStop':
      case 'charaEffect':
      case 'charaEffectDestroy':
      case 'charaEffectStop':
      case 'charaFace':
      case 'charaFaceFade':
      case 'charaFadeTime':
      case 'charaFadein':
      case 'charaFadeinFSL':
      case 'charaFadeinFSR':
      case 'charaFadeinFSSideL':
      case 'charaFadeinFSSideR':
      case 'charaFadeout':
      case 'charaFilter':
      case 'charaLayer':
      case 'charaMove':
      case 'charaMoveFSL':
      case 'charaMoveFSR':
      case 'charaMoveReturn':
      case 'charaMoveReturnFSL':
      case 'charaMoveReturnFSR':
      case 'charaMoveScale':
      case 'charaPut':
      case 'charaPutFSL':
      case 'charaPutFSR':
      case 'charaRoll':
      case 'charaRollMove':
      case 'charaScale':
      case 'charaSet':
      case 'charaShake':
      case 'charaShakeStop':
      case 'charaSpecialEffect':
      case 'charaSpecialEffectStop':
      case 'charaTalk':
      case 'communicationChara':
      case 'communicationCharaClear':
      case 'communicationCharaFace':
      case 'communicationCharaLoop':
      case 'cueSe':
      case 'cueSeStop':
      case 'cueSeVolume':
      case 'distortionstart':
      case 'distortionstop':
      case 'end':
      case 'effect':
      case 'effectDestroy':
      case 'effectStop':
      case 'enableFullScreen':
      case 'equipSet':
      case 'fadein':
      case 'fadeMove':
      case 'fadeout':
      case 'flashin':
      case 'flashout':
      case 'flashOff':
      case 'fowardEffect':
      case 'fowardEffectStop':
      case 'fowardEffectDestroy':
      case 'imageSet':
      case 'input':
      case 'maskin':
      case 'maskout':
      case 'messageOff':
      case 'messageShake':
      case 'masterSet':
      case 'overlayFadein':
      case 's': // dialog speed
      case 'sceneSet':
      case 'seStop':
      case 'seVolume':
      case 'shake':
      case 'shakeStop':
      case 'skip':
      case 'soundStopAll':
      case 'soundStopAllFade':
      case 'speed':
      case 'subCameraFilter':
      case 'subCameraOff':
      case 'subCameraOn':
      case 'subRenderDepth':
      case 'subRenderFadein':
      case 'subRenderFadeinFSL':
      case 'subRenderFadeinFSR':
      case 'subRenderFadeout':
      case 'subRenderMove':
      case 'subRenderMoveFSL':
      case 'subRenderMoveFSR':
      case 'talkNameBack':
      case 'wait':
      case 'wipeFilter':
      case 'wipein':
      case 'wipeout':
      case 'wipeOff':
      case 'turnPageOff':
      case 'turnPageOn':
      case 'twt':
      case 'wt':
        return [];
      default:
        break;
    }
    return [state.textSpan(text: '[$src]')];
  }
}

abstract class ScriptComponent {
  final kHeaderLeading = ' ꔷ ';
  final headerStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  final bodyStyle = const TextStyle(fontSize: 15);
  String src;
  ScriptComponent(this.src);
  List<InlineSpan> build(BuildContext context, ScriptState state);
}
