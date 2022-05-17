import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/widgets/tile_items.dart';

class SvtPriorityTagging extends StatefulWidget {
  SvtPriorityTagging({Key? key}) : super(key: key);

  @override
  _SvtPriorityTaggingState createState() => _SvtPriorityTaggingState();
}

class _SvtPriorityTaggingState extends State<SvtPriorityTagging> {
  final Map<int, TextEditingController> _controllers = {};

  TextEditingController controllerOf(int key) => _controllers[key] ??=
      TextEditingController(text: db.settings.priorityTags[key]);

  @override
  void dispose() {
    super.dispose();
    _controllers.values.forEach((e) => e.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.setting_priority_tagging),
      ),
      body: ListView(
        children: [
          for (final priority in [1, 2, 3, 4, 5])
            DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(bottom: Divider.createBorderSide(context))),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('${S.current.priority} $priority'),
                    ),
                  ),
                  SizedBox(
                    width: 88,
                    child: TextField(
                      controller: controllerOf(priority),
                      textAlign: TextAlign.center,
                      maxLength: 10,
                      onChanged: (s) {
                        db.settings.priorityTags[priority] = s;
                        db.saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(width: 16)
                ],
              ),
            ),
          SFooter(S.current.priority_tagging_hint),
        ],
      ),
    );
  }
}
