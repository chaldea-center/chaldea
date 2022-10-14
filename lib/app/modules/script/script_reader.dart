import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'filter.dart';
import 'script_data.dart';

class ScriptReaderPage extends StatefulWidget {
  final ScriptLink script;
  final Region? region;
  const ScriptReaderPage({super.key, required this.script, this.region});

  @override
  State<ScriptReaderPage> createState() => _ScriptReaderPageState();
}

class _ScriptReaderPageState extends State<ScriptReaderPage> {
  bool _loading = true;
  final data = ScriptParsedData();
  final filterData = db.settings.scriptReaderFilterData;

  @override
  void initState() {
    super.initState();
    data.init(widget.script.script, widget.region);
    fetch();
  }

  @override
  void dispose() {
    super.dispose();
    data.state.bgmPlayer.stop();
    data.state.sePlayer.stop();
    data.state.voicePlayer.stop();
  }

  Future<void> fetch({bool force = false}) async {
    data.reset();
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
    await data.load(force: force);
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.script is ValentineScript) {
      title = Transl.ceNames((widget.script as ValentineScript).scriptName).l;
    } else {
      title = widget.script.scriptId;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Script $title',
          overflow: TextOverflow.fade,
        ),
        actions: [
          SharedBuilder.appBarRegionDropdown(
            context: context,
            region: data.state.region,
            onChanged: (v) {
              setState(() {
                if (v != null) data.init(widget.script.script, v);
              });
              fetch();
            },
          ),
          popupMenu,
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : reader(),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text(S.current.refresh),
            onTap: () {
              fetch(force: true);
            },
          ),
          PopupMenuItem(
            child: Text(S.current.jump_to('Atlas')),
            onTap: () {
              launch(
                '${Atlas.appHost}${data.state.region.upper}/script/${widget.script.scriptId}',
                external: true,
              );
            },
          ),
          if (db.runtimeData.enableDebugTools)
            PopupMenuItem(
              child: const Text('Source Script'),
              onTap: () {
                launch(
                  data.uri?.toString() ?? widget.script.script,
                  external: true,
                );
              },
            ),
          PopupMenuItem(
            child: Text(S.current.settings_tab_name),
            onTap: () async {
              await null;
              if (!mounted) return;
              FilterPage.show(
                context: context,
                builder: (context) => ScriptReaderFilterPage(
                  filterData: db.settings.scriptReaderFilterData,
                  onChanged: (v) {
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
          ),
        ];
      },
    );
  }

  Widget reader() {
    if (data.components.isEmpty) return const Center(child: Text('Empty'));
    List<Widget> children = [];
    for (int index = 0; index < data.components.length; index++) {
      final part = data.components[index];
      List<InlineSpan> spans = [];
      if (part is ScriptCommand) {
        // show some
        spans.addAll(part.build(context, data.state, showMore: true));
      } else if (part is ScriptDialog) {
        final prevPart = index == 0 ? null : data.components[index - 1];
        spans.addAll(part.build(
          context,
          data.state,
          hideSpeaker: prevPart is ScriptDialog &&
              prevPart.speakerSrc == part.speakerSrc,
        ));
      } else {
        spans.addAll(part.build(context, data.state));
      }
      if (spans.isEmpty) continue;
      children.add(SelectableText.rich(TextSpan(children: spans)));
      children.add(const SizedBox(height: 8));
    }
    children.add(
        const SafeArea(child: Text('- End -', textAlign: TextAlign.center)));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: children,
    );
  }
}
