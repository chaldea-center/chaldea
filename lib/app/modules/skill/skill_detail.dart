import 'dart:async';

import 'package:ruby_text/ruby_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SkillDetailPage extends StatefulWidget {
  final int? id;
  final BaseSkill? skill;
  const SkillDetailPage({super.key, this.id, this.skill})
      : assert(id != null || skill != null);

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  bool loading = false;
  BaseSkill? _skill;
  int get id => widget.skill?.id ?? widget.id ?? _skill?.id ?? -1;
  BaseSkill get skill => _skill!;

  @override
  void initState() {
    super.initState();
    fetchSkill();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchSkill() async {
    _skill = null;
    loading = true;
    if (mounted) setState(() {});
    _skill = widget.skill ??
        db.gameData.baseSkills[widget.id] ??
        await AtlasApi.skill(id);
    loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_skill == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${S.current.skill} $id'),
          actions: [if (id >= 0) popupMenu],
        ),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : RefreshButton(onPressed: fetchSkill),
        ),
      );
    }
    final svts = ReverseGameData.skill2Svt(id).toList()
      ..sort2((e) => e.collectionNo);
    final ces = ReverseGameData.skill2CE(id).toList()
      ..sort2((e) => e.collectionNo);
    final ccs = ReverseGameData.skill2CC(id).toList()
      ..sort2((e) => e.collectionNo);
    final mcs = ReverseGameData.skill2MC(id).toList()..sort2((e) => e.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          skill.lName.l,
          overflow: TextOverflow.fade,
        ),
        actions: [popupMenu],
      ),
      body: ListView(
        children: [
          CustomTable(children: [
            CustomTableRow.fromTexts(texts: ['No.${skill.id}'], isHeader: true),
            CustomTableRow.fromChildren(children: [
              RubyText(
                [RubyTextData(skill.name, ruby: skill.ruby)],
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            ]),
            SkillDescriptor(
              skill: skill,
              showEnemy: true,
              showNone: true,
              jumpToDetail: false,
            ),
            CustomTableRow(children: [
              TableCellData(text: S.current.general_type, isHeader: true),
              TableCellData(flex: 2, text: skill.type.name)
            ]),
          ]),
          if (svts.isNotEmpty) cardList(S.current.servant, svts),
          if (ces.isNotEmpty) cardList(S.current.craft_essence, ces),
          if (ccs.isNotEmpty) cardList(S.current.command_code, ccs),
          if (mcs.isNotEmpty) cardList(S.current.mystic_code, mcs),
        ],
      ),
    );
  }

  Widget cardList(String header, List<GameCardMixin> cards) {
    return TileGroup(
      header: header,
      children: [
        for (final card in cards)
          ListTile(
            dense: true,
            leading: card.iconBuilder(context: context),
            title: Text(card.lName.l),
            onTap: card.routeTo,
          )
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) =>
          SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbSkill(id)),
    );
  }
}
