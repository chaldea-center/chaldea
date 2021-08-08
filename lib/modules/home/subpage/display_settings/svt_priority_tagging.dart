import 'package:chaldea/components/components.dart';

class SvtPriorityTagging extends StatefulWidget {
  const SvtPriorityTagging({Key? key}) : super(key: key);

  @override
  _SvtPriorityTaggingState createState() => _SvtPriorityTaggingState();
}

class _SvtPriorityTaggingState extends State<SvtPriorityTagging> {
  Map<String, TextEditingController> _controllers = {};

  TextEditingController controllerOf(String key) => _controllers[key] ??=
      TextEditingController(text: db.appSetting.priorityTags[key]);

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
            chs: '优先级备注', jpn: '優先順位ノート', eng: 'Priority Tagging')),
      ),
      body: ListView(
        children: [
          for (final priority in SvtFilterData.priorityData)
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
                    width: 60,
                    child: TextField(
                      controller: controllerOf(priority),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(),
                      maxLength: 4,
                      onChanged: (s) {
                        db.appSetting.priorityTags[priority] = s;
                      },
                    ),
                  ),
                  const SizedBox(width: 16)
                ],
              ),
            ),
          SFooter(LocalizedText.of(
              chs: '建议最多4个英文字母或2个汉字',
              jpn: '最大4つの英字または2つの漢字を提案します',
              eng:
                  'Recommended: max 4 English letters or 2 Chinese/Japanese characters')),
        ],
      ),
    );
  }
}
