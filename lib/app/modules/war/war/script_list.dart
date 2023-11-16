import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/material.dart';
import 'package:chaldea/widgets/tile_items.dart';

class ScriptListPage extends StatefulWidget {
  final NiceWar war;
  const ScriptListPage({super.key, required this.war});

  @override
  State<ScriptListPage> createState() => _ScriptListPageState();
}

class _ScriptListPageState extends State<ScriptListPage> {
  NiceWar get war => widget.war;
  @override
  Widget build(BuildContext context) {
    List<Widget> mainPart = [], eventPart = [];
    if (war.startScript != null) {
      mainPart.add(ListTile(
        dense: true,
        title: Text('Start Script ${war.startScript?.scriptId}', textScaler: const TextScaler.linear(1.1)),
        contentPadding: EdgeInsets.zero,
        onTap: () => onTap(war.startScript!),
      ));
    }
    final quests = war.quests.toList();
    quests.sort2((e) => -e.priority);
    for (final quest in quests) {
      List<TextSpan> spans = [];
      for (final phase in quest.phaseScripts) {
        final validScripts = phase.scripts.where((e) => e.scriptId.isNotEmpty && e.script != 'NONE').toList();
        if (validScripts.isEmpty) continue;
        if (spans.isNotEmpty) spans.add(const TextSpan(text: ' \n'));
        spans.addAll([
          TextSpan(text: '${phase.phase}: '),
          ...divideList(
            validScripts.map((script) => SharedBuilder.textButtonSpan(
                  context: context,
                  text: script.scriptId,
                  onTap: () => onTap(script),
                )),
            const TextSpan(text: ' / '),
          )
        ]);
      }
      if (spans.isEmpty) continue;
      spans.add(const TextSpan(text: ' '));
      final target = quest.type == QuestType.main ? mainPart : eventPart;
      String chapter = quest.chapter;
      final title = chapter.isEmpty ? quest.lDispName : '$chapter ${quest.lDispName}';
      target.addAll([
        ListTile(
          dense: true,
          title: Text(title, textScaler: const TextScaler.linear(1.1)),
          contentPadding: EdgeInsets.zero,
          trailing: IconButton(
            onPressed: () {
              router.push(url: quest.route, child: QuestDetailPage(quest: quest));
            },
            icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 8),
          child: Text.rich(
            TextSpan(children: spans),
            textScaler: const TextScaler.linear(0.9),
          ),
        )
      ]);
    }
    List<Tab> tabs = [];
    List<Widget> views = [];
    if (mainPart.isNotEmpty) {
      tabs.add(Tab(text: S.current.main_story));
      views.add(ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: mainPart..add(const SafeArea(child: SizedBox())),
      ));
    }
    if (eventPart.isNotEmpty) {
      tabs.add(Tab(text: S.current.event_quest));
      views.add(ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: eventPart..add(const SafeArea(child: SizedBox())),
      ));
    }
    if (tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(war.lLongName.l.setMaxLines(1))),
        body: Center(child: Text(S.current.empty_hint)),
      );
    }

    return DefaultTabController(
      length: views.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(war.lLongName.l.setMaxLines(1)),
          bottom: tabs.length > 1 ? FixedHeight.tabBar(TabBar(tabs: tabs)) : null,
        ),
        body: TabBarView(children: views),
      ),
    );
  }

  void onTap(ScriptLink script) {
    Region? region;
    if (script.script.contains('/JP/')) {
      region = db.settings.resolvedPreferredRegions.first;
      bool? released = db.gameData.mappingData.warRelease.ofRegion(region)?.contains(war.id);
      released = region == Region.jp || released == true;
      if (!released) region = Region.jp;
    }
    script.routeTo(region: region);
  }
}
