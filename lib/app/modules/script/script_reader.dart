import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tuple/tuple.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../war/war/asset_list.dart';
import 'filter.dart';
import 'reader_entry.dart';
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
  final filterData = db.settings.filters.scriptReaderFilterData;
  List<Tuple2<NiceWar, Quest?>> relatedQuests = [];
  String? prevScript;
  String? nextScript;

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
    try {
      await data.load(force: force);
    } catch (e, s) {
      logger.e('load script data failed', e, s);
      EasyLoading.showError(e.toString());
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void findSurroundingScripts() {
    relatedQuests = ScriptLink.findQuests(widget.script.scriptId);
    List<String> surroundingScripts = [];
    if (relatedQuests.isNotEmpty) {
      final war = relatedQuests.first.item1;
      final quest1 = relatedQuests.first.item2;
      if ([WarId.chaldeaGate, WarId.rankup, WarId.daily, WarId.interlude].contains(war.id) ||
          quest1?.type == QuestType.friendship) {
        if (quest1 != null) {
          for (final phase in quest1.phaseScripts) {
            surroundingScripts.addAll(phase.scripts.map((e) => e.scriptId));
          }
        }
      } else {
        if (war.startScript != null) {
          surroundingScripts.add(war.startScript!.scriptId);
        }
        final quests = war.quests.toList();
        quests.sort2((e) => -e.priority);
        for (final quest in quests) {
          for (final phase in quest.phaseScripts) {
            surroundingScripts.addAll(phase.scripts.map((e) => e.scriptId));
          }
        }
      }
    }
    int curIndex = surroundingScripts.indexOf(widget.script.scriptId);
    if (curIndex >= 0) {
      prevScript = surroundingScripts.getOrNull(curIndex - 1);
      nextScript = surroundingScripts.getOrNull(curIndex + 1);
    }
  }

  String get scriptName {
    if (widget.script is ValentineScript) {
      return Transl.ceNames((widget.script as ValentineScript).scriptName).l;
    } else {
      return widget.script.scriptId;
    }
  }

  @override
  Widget build(BuildContext context) {
    findSurroundingScripts();
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Script $scriptName', overflow: TextOverflow.fade),
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
        body: reader(),
      ),
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
            enabled: data.uri != null,
            child: Text(S.current.media_assets),
            onTap: () {
              router.pushPage(WarAssetListPage(title: scriptName, scripts: [data.uri!.toString()]));
            },
          ),
          PopupMenuItem(
            child: Text(S.current.jump_to('Atlas')),
            onTap: () {
              launch('${Atlas.appHost}${data.state.region.upper}/script/${widget.script.scriptId}', external: true);
            },
          ),
          if (db.runtimeData.enableDebugTools)
            PopupMenuItem(
              child: const Text('Source Script'),
              onTap: () {
                launch(data.uri?.toString() ?? widget.script.script, external: true);
              },
            ),
          PopupMenuItem(
            child: Text(S.current.settings_tab_name),
            onTap: () {
              FilterPage.show(
                context: context,
                builder: (context) => ScriptReaderFilterPage(
                  filterData: db.settings.filters.scriptReaderFilterData,
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

  Widget get info {
    List<InlineSpan> questSpans = [];
    if (relatedQuests.length == 1) {
      final war = relatedQuests.first.item1;
      final quest = relatedQuests.first.item2;
      questSpans.add(
        TextSpan(
          children: [
            SharedBuilder.textButtonSpan(context: context, text: war.lShortName, onTap: war.routeTo),
            const TextSpan(text: ' - '),
            quest == null
                ? const TextSpan(text: ' Opening Script')
                : SharedBuilder.textButtonSpan(context: context, text: quest.lName.l, onTap: quest.routeTo),
          ],
        ),
      );
    } else {
      NiceWar? lastWar;
      for (final entry in relatedQuests) {
        if (lastWar != entry.item1) {
          lastWar = entry.item1;
          questSpans.add(
            SharedBuilder.textButtonSpan(context: context, text: lastWar.lShortName, onTap: lastWar.routeTo),
          );
        }
        final quest = entry.item2;
        if (quest == null) {
          questSpans.add(const TextSpan(text: '$kULLeading Open Script'));
        } else {
          questSpans.add(
            TextSpan(
              children: [
                const TextSpan(text: kULLeading),
                SharedBuilder.textButtonSpan(context: context, text: quest.lName.l, onTap: quest.routeTo),
              ],
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
      }
    }

    questSpans = questSpans.divided((index) => const TextSpan(text: '\n'));

    return CustomTable(
      children: [
        CustomTableRow(
          children: [
            TableCellData(text: 'ID', isHeader: true),
            TableCellData(text: widget.script.scriptId, flex: 3),
          ],
        ),
        CustomTableRow.fromTexts(texts: [S.current.quest], isHeader: true),
        if (questSpans.isEmpty) CustomTableRow.fromTexts(texts: const ['-']),
        if (questSpans.isNotEmpty)
          CustomTableRow(
            children: [TableCellData(child: Text.rich(TextSpan(children: questSpans)))],
          ),
        CustomTableRow.fromChildren(children: [navButtons]),
      ],
    );
  }

  Widget get navButtons {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: prevButton)),
        homeButton,
        Expanded(child: Center(child: nextButton)),
      ],
    );
  }

  Widget get homeButton {
    return IconButton(
      onPressed: () {
        bool found = false;
        Navigator.of(context).popUntil((route) {
          final page = route.settings;
          if (page is! SplitPage) return true;
          final args = page.arguments;
          if (args is! RouteConfiguration) return true;
          if (args.url?.startsWith('${Routes.script}/') == true) {
            found = true;
            return false;
          }
          return true;
        });
        if (!found) {
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.home),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: const EdgeInsets.all(2),
    );
  }

  Widget get prevButton {
    return Text.rich(
      TextSpan(
        children: [
          CenterWidgetSpan(child: Icon(DirectionalIcons.keyboard_arrow_back(context), size: 20)),
          prevScript == null
              ? const TextSpan(text: '     -     ', style: kMonoStyle)
              : SharedBuilder.textButtonSpan(
                  context: context,
                  text: prevScript!,
                  onTap: () {
                    router.push(
                      url: Routes.scriptI(prevScript!),
                      child: ScriptIdLoadingPage(scriptId: prevScript!, region: data.state.region),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget get nextButton {
    return Text.rich(
      TextSpan(
        children: [
          nextScript == null
              ? const TextSpan(text: '     -     ', style: kMonoStyle)
              : SharedBuilder.textButtonSpan(
                  context: context,
                  text: nextScript!,
                  onTap: () {
                    router.push(
                      url: Routes.scriptI(nextScript!),
                      child: ScriptIdLoadingPage(scriptId: nextScript!, region: data.state.region),
                    );
                  },
                ),
          CenterWidgetSpan(child: Icon(DirectionalIcons.keyboard_arrow_forward(context), size: 20)),
        ],
      ),
    );
  }

  Widget reader() {
    List<Widget> children = [];
    if (_loading) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else if (data.components.isEmpty) {
      children.add(Center(child: Text(S.current.empty_hint)));
    }

    for (int index = 0; index < data.components.length; index++) {
      final part = data.components[index];
      List<InlineSpan> spans = [];
      if (part is ScriptCommand) {
        // show some
        spans.addAll(part.build(context, data.state, showMore: true));
      } else if (part is ScriptDialog) {
        final prevPart = index == 0 ? null : data.components[index - 1];
        spans.addAll(
          part.build(
            context,
            data.state,
            hideSpeaker: prevPart is ScriptDialog && prevPart.speakerSrc == part.speakerSrc,
          ),
        );
      } else {
        spans.addAll(part.build(context, data.state));
      }
      if (spans.isEmpty) continue;
      children.add(Text.rich(TextSpan(children: spans)));
      children.add(const SizedBox(height: 8));
    }
    children.add(const SafeArea(child: Text('- End -', textAlign: TextAlign.center)));

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        info,
        const SizedBox(height: 8),
        for (final child in children) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
        const Divider(height: 16),
        if (!_loading) navButtons,
        const SafeArea(child: SizedBox(height: 8)),
      ],
    );
  }
}
