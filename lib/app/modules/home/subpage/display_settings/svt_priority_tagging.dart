import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class SvtPriorityTagging extends StatefulWidget {
  SvtPriorityTagging({Key? key}) : super(key: key);

  @override
  _SvtPriorityTaggingState createState() => _SvtPriorityTaggingState();
}

class _SvtPriorityTaggingState extends State<SvtPriorityTagging> {
  final Map<int, TextEditingController> _controllers = {};

  TextEditingController controllerOf(int key) => _controllers[key] ??=
      TextEditingController(text: db2.settings.priorityTags[key]);

  @override
  void dispose() {
    super.dispose();
    _controllers.values.forEach((e) => e.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedText.of(
            chs: '优先级备注',
            jpn: '優先順位ノート',
            eng: 'Priority Tagging',
            kor: '우선순위 매기기')),
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
                      title: Text(S.current.priority + ' $priority'),
                    ),
                  ),
                  SizedBox(
                    width: 88,
                    child: TextField(
                      controller: controllerOf(priority),
                      textAlign: TextAlign.center,
                      maxLength: 10,
                      onChanged: (s) {
                        db2.settings.priorityTags[priority] = s;
                        db2.saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(width: 16)
                ],
              ),
            ),
          SFooter(LocalizedText.of(
            chs: '建议备注不要太长，否则可能显示不全',
            jpn: 'コメントは長すぎないようにすることをお勧めします。長すぎると、表示が不完全になります。',
            eng:
                'Tags should not be too long, otherwise it cannot be shown completely',
            kor: '태그는 짧게 해주세요. 너무 길면 전부 표시되지 않습니다',
          )),
        ],
      ),
    );
  }
}
