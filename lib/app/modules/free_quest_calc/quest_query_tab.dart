import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/event/tabs/main_story_tab.dart';

class FreeQuestQueryTab extends StatefulWidget {
  FreeQuestQueryTab({super.key});

  @override
  _FreeQuestQueryTabState createState() => _FreeQuestQueryTabState();
}

class _FreeQuestQueryTabState extends State<FreeQuestQueryTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainStoryTab(
      scrollController: _scrollController,
      showOutdated: true,
      showSpecialRewards: false,
      reversed: true,
      titleOnly: true,
    );
  }
}
