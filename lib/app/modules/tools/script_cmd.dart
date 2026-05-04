import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/local_settings.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/widgets/widgets.dart';

enum CommandMarker {
  unknown,
  skip,
  keep,
  charaFigure,
  back,
  image,
  effect,
  audio,
  bgm,
  mov,
  special;

  String get displayName => name;
}

class CommandData {
  final String commandName;
  final Set<String> examples;
  CommandMarker marker;

  CommandData({required this.commandName, required this.examples, this.marker = CommandMarker.unknown});

  Map<String, dynamic> toJson() => {'commandName': commandName, 'marker': marker.name, 'examples': examples.toList()};

  factory CommandData.fromJson(Map<String, dynamic> json) {
    return CommandData(
      commandName: json['commandName'] as String,
      marker: CommandMarker.values.firstWhere((e) => e.name == json['marker'], orElse: () => CommandMarker.unknown),
      examples: Set.from(json['examples'] as List),
    );
  }
}

class ScriptCmdPage extends StatefulWidget {
  const ScriptCmdPage({super.key});

  @override
  State<ScriptCmdPage> createState() => _ScriptCmdPageState();
}

class _ScriptCmdPageState extends State<ScriptCmdPage> {
  final TextEditingController _dirController = TextEditingController();
  final Map<String, CommandData> _commands = {};
  bool _loading = false;
  CommandMarker? _shownMarker;

  late final saveFilepath = joinPaths(db.paths.downloadDir, 'script_commands.json');

  @override
  void dispose() {
    _dirController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    String? selectedDirectory;
    if (_dirController.text.isNotEmpty) {
      selectedDirectory = _dirController.text;
    } else {
      final result = await FilePicker.getDirectoryPath();
      if (result != null) {
        selectedDirectory = result;
        _dirController.text = result;
      }
    }

    if (selectedDirectory != null) {
      await _loadFiles(selectedDirectory);
    }
  }

  Future<void> _loadFiles(String directory) async {
    setState(() {
      _loading = true;
    });

    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        EasyLoading.showError('Directory does not exist');
        return;
      }

      for (final cmd in _commands.values) {
        cmd.examples.clear();
      }
      // _commands.clear();
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.txt')) {
          await _parseFile(entity);
        }
      }
      EasyLoading.showSuccess('Loaded ${_commands.length} commands');
    } catch (e, s) {
      EasyLoading.showError('Error loading files: $e');
      logger.e('load files failed', e, s);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _parseFile(File file) async {
    final lines = await file.readAsLines();
    final commandRegex = RegExp(r'\[([^\]]+)\]');
    final colorRegexp = RegExp(r'^[0-9a-fA-F]{6}$');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final matches = commandRegex.allMatches(line);

      for (final match in matches) {
        final commandStr = match.group(1)!;
        final parts = commandStr.split(RegExp(r'\s+'));
        if (parts.isEmpty) continue;

        String commandName = parts[0];
        // if (commandName.endsWith('～')) commandName = commandName.substring(0, commandName.length - 1);
        final params = parts.skip(1).toList().join(' ');
        //
        if (commandStr.length == 6 && params.isEmpty && colorRegexp.hasMatch(commandStr)) {
          continue;
        }
        if (commandName.contains(',')) continue;
        if (commandName.startsWith('#')) continue;
        if (commandName.startsWith('%')) continue;
        if (commandName.startsWith('&')) continue;
        if (commandName.length == 1 && RegExp('[A-Z]').hasMatch(commandName)) continue;

        final cmdData = _commands[commandName] ??= CommandData(commandName: commandName, examples: {});

        if (cmdData.examples.length < 10) {
          cmdData.examples.add(params);
        }
      }
    }
  }

  Future<void> _saveResult() async {
    if (_commands.isEmpty) {
      EasyLoading.showError('No commands to save');
      return;
    }

    try {
      final file = File(saveFilepath);
      final data = {
        'commands': _commands.values.map((e) => e.toJson()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
        'sourceDirectory': _dirController.text,
      };
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      EasyLoading.showSuccess('Saved to $saveFilepath');
    } catch (e, s) {
      EasyLoading.showError('Error saving: $e');
      logger.e('save result failed', e, s);
    }
  }

  Future<void> _loadPreviousResult() async {
    try {
      final file = File(saveFilepath);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      _commands.clear();
      final commands = data['commands'] as List;
      for (final cmd in commands) {
        final cmdData = CommandData.fromJson(cmd as Map<String, dynamic>);
        _commands[cmdData.commandName] = cmdData;
      }

      if (data['sourceDirectory'] != null) {
        _dirController.text = data['sourceDirectory'] as String;
      }

      EasyLoading.showSuccess('Loaded ${_commands.length} commands');
      setState(() {});
    } catch (e, s) {
      EasyLoading.showError('Error loading: $e');
      logger.e('load previous data failed', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCommands = _commands.values.toList();
    if (_shownMarker != null) {
      sortedCommands.retainWhere((e) => e.marker == _shownMarker);
    }
    sortedCommands.sort((a, b) => a.commandName.compareTo(b.commandName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Script Command Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _commands.isEmpty ? null : _saveResult,
            tooltip: S.current.save,
          ),
          IconButton(icon: const Icon(Icons.folder_open), onPressed: _loadPreviousResult, tooltip: 'Load Previous'),
        ],
      ),
      body: Column(
        children: [
          _buildDirectoryInput(),
          Expanded(child: _loading ? const LinearProgressIndicator() : _buildCommandsList(sortedCommands)),
          _buildButtonBar(sortedCommands),
        ],
      ),
    );
  }

  Widget _buildDirectoryInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _dirController,
              decoration: InputDecoration(
                labelText: 'Root Directory',
                hintText: 'Select or input directory path',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.folder), onPressed: _pickDirectory),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _loadFiles(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _pickDirectory,
            icon: const Icon(Icons.search),
            label: const Text('Load'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandsList(List<CommandData> sortedCommands) {
    return ListView.builder(
      itemCount: sortedCommands.length,
      itemBuilder: (context, index) {
        final cmdData = sortedCommands[index];
        return _buildCommandTile(cmdData, index);
      },
    );
  }

  final paramColors = [Colors.red, Colors.green, Colors.yellow];

  Widget _buildCommandTile(CommandData cmdData, int index) {
    return ExpansionTile(
      dense: true,
      leading: Text('${index + 1}'),
      title: Text(cmdData.commandName),
      subtitle: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        spacing: 2,
        children: [
          Text.rich(
            TextSpan(
              children: divideList(
                [
                  for (final v in cmdData.examples.take(4))
                    TextSpan(
                      children: [
                        for (final (i, s) in v.split(RegExp(r'\s+')).indexed)
                          TextSpan(
                            text: '$s ',
                            style: TextStyle(color: paramColors[i % paramColors.length]),
                          ),
                      ],
                    ),
                ],
                const TextSpan(
                  text: ' / ',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ),
            maxLines: 2,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          FilterGroup<CommandMarker>(
            options: CommandMarker.values,
            values: FilterRadioData.nonnull(cmdData.marker),
            combined: true,
            shrinkWrap: true,
            padding: .zero,
            optionBuilder: (value) => Padding(padding: .symmetric(horizontal: 4, vertical: 2), child: Text(value.name)),
            onFilterChanged: (optionData, lastChanged) {
              setState(() {
                cmdData.marker = optionData.radioValue!;
              });
            },
          ),
        ],
      ),
      // trailing: DropdownButton<CommandMarker>(
      //   value: cmdData.marker,
      //   items: CommandMarker.values.map((marker) {
      //     return DropdownMenuItem(value: marker, child: Text(marker.displayName));
      //   }).toList(),
      //   onChanged: (value) {
      //     if (value != null) {
      //       setState(() {
      //         cmdData.marker = value;
      //       });
      //     }
      //   },
      // ),
      children: cmdData.examples.map((example) {
        return ListTile(dense: true, leading: const SizedBox.shrink(), title: Text('"$example"'));
      }).toList(),
    );
  }

  Widget _buildButtonBar(List<CommandData> sortedCommands) {
    return SafeArea(
      child: Wrap(
        crossAxisAlignment: .center,
        children: [
          DropdownButton<CommandMarker?>(
            // isDense: true,
            isExpanded: false,
            value: _shownMarker,
            items: [
              DropdownMenuItem(child: Text(S.current.general_all)),
              for (final v in CommandMarker.values) DropdownMenuItem(value: v, child: Text(v.name)),
            ],
            onChanged: (v) {
              setState(() {
                _shownMarker = v;
              });
            },
          ),
          TextButton(
            onPressed: () {
              // copyToClipboard(jsonEncode(sortedCommands.map((e) => e.commandName).toList()), toast: true);
              copyToClipboard(sortedCommands.map((e) => 'case "${e.commandName}":').toList().join('\n'), toast: true);
            },
            child: Text('CopyCommands'),
          ),
        ],
      ),
    );
  }
}
