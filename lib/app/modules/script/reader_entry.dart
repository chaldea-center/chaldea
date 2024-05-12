import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/material.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'script_reader.dart';

class ScriptReaderEntryPage extends StatefulWidget {
  const ScriptReaderEntryPage({super.key});

  @override
  State<ScriptReaderEntryPage> createState() => _ScriptReaderEntryPageState();
}

class _ScriptReaderEntryPageState extends State<ScriptReaderEntryPage> {
  final _textEditController = TextEditingController();
  late Region region = db.curUser.region;
  @override
  void dispose() {
    super.dispose();
    _textEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.script_story),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: [
              [S.current.event, S.current.war, S.current.script_story],
              [S.current.quest, S.current.script_story]
            ].map((e) => e.join('→')).join(', '),
            children: [
              ListTile(
                title: Text('${S.current.script_story}: ${S.current.main_story}/${S.current.limited_event}'),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.push(url: Routes.events);
                },
              ),
            ],
          ),
          TileGroup(
            header: 'Script ID',
            children: [
              ListTile(
                title: Text(S.current.game_server),
                trailing: DropdownButton<Region>(
                  value: region,
                  items: [
                    for (final r in Region.values)
                      DropdownMenuItem(
                        value: r,
                        child: Text(r.localName),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (v != null) region = v;
                    });
                  },
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    // const Text('ID    '),
                    Expanded(
                      child: TextFormField(
                        controller: _textEditController,
                        textAlign: TextAlign.center,
                        onChanged: (s) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Script ID',
                          border: const OutlineInputBorder(),
                          counterText: '${_textEditController.text.trim().length}/10',
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Center(
            child: IconButton(
              onPressed: () {
                String id = _textEditController.text.trim();
                if (id.isEmpty) return;
                final match = RegExp(r'/script/([^\?]+)').firstMatch(id);
                if (match != null) {
                  id = match.group(1)!;
                }
                router.push(
                  url: Routes.scriptI(id),
                  child: ScriptIdLoadingPage(scriptId: id, region: region),
                );
              },
              icon: const Icon(Icons.menu_book_rounded),
              color: _textEditController.text.trim().isEmpty ? null : AppTheme(context).tertiary,
            ),
          )
        ],
      ),
    );
  }
}

class ScriptIdLoadingPage extends StatefulWidget {
  final String scriptId;
  final ScriptLink? script;
  final Region? region;
  const ScriptIdLoadingPage({super.key, required this.scriptId, this.script, this.region});

  @override
  State<ScriptIdLoadingPage> createState() => _ScriptIdLoadingPageState();
}

class _ScriptIdLoadingPageState extends State<ScriptIdLoadingPage> {
  ScriptLink? script;
  late Region region = widget.region ?? Region.jp;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.script != null && widget.scriptId == widget.script?.scriptId) {
      if (widget.region == null || widget.script!.script.contains('/${widget.region!.upper}/')) {
        script = widget.script;
      }
    }
    if (script == null) fetch();
  }

  Future<void> fetch({bool force = false}) async {
    script = null;
    _loading = true;
    if (mounted) setState(() {});
    script = await AtlasApi.script(widget.scriptId, region: region, expireAfter: force ? Duration.zero : null);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (script != null) {
      return ScriptReaderPage(
        script: script!,
        region: widget.region,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Script ${widget.scriptId}')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.current.not_found),
                  const SizedBox(height: 16),
                  FilterGroup<Region>(
                    options: Region.values,
                    values: FilterRadioData.nonnull(region),
                    onFilterChanged: (v, _) {
                      setState(() {
                        region = v.radioValue!;
                      });
                    },
                    optionBuilder: (v) => Text(v.localName),
                    combined: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      fetch(force: true);
                    },
                    child: Text(S.current.refresh),
                  )
                ],
              ),
      ),
    );
  }
}
