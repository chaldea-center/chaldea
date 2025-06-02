import 'package:flutter/scheduler.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class MysticCodePage extends StatefulWidget {
  final int? id;

  MysticCodePage({super.key, this.id});

  @override
  _MysticCodePageState createState() => _MysticCodePageState();
}

class _MysticCodePageState extends State<MysticCodePage> {
  Map<int, MysticCode> get codes => db.gameData.mysticCodes;

  int? _selected;
  late final _scrollController = ScrollController();

  int _level = 10;

  @override
  Widget build(BuildContext context) {
    if (_selected == null) {
      _selected = widget.id ?? (codes.isEmpty ? null : codes.keys.first);
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollTo(0);
      });
    }
    final MysticCode? mysticCode = codes[_selected];
    if (codes.isEmpty) {
      return NotFoundPage(title: S.current.mystic_code, url: Routes.mysticCodeI(_selected ?? 0));
    }
    _level = db.curUser.mysticCodes[_selected]?.clamp(1, 10) ?? 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(mysticCode?.lName.l ?? S.current.mystic_code),
        actions: [
          IconButton(
            onPressed: () => setState(() => db.curUser.isGirl = !db.curUser.isGirl),
            icon: FaIcon(db.curUser.isGirl ? FontAwesomeIcons.venus : FontAwesomeIcons.mars),
          ),
        ],
      ),
      body: mysticCode == null
          ? Container()
          : Column(
              children: [
                buildScrollHeader(),
                Expanded(child: SingleChildScrollView(child: buildDetails(mysticCode))),
                SafeArea(child: levelSlider),
              ],
            ),
    );
  }

  Widget get levelSlider {
    return Row(
      children: [
        Padding(padding: const EdgeInsetsDirectional.only(start: 16, end: 2), child: Text(S.current.level)),
        SizedBox(width: 20, child: Center(child: Text(_level.toString()))),
        Expanded(
          child: Slider(
            value: _level.toDouble(),
            onChanged: (v) => setState(() => db.curUser.mysticCodes[_selected!] = v.toInt()),
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: _level.toString(),
          ),
        ),
      ],
    );
  }

  Widget buildScrollHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _scrollTo(-1),
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.grey),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 50,
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: codes.entries.map((e) {
                final code = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _selected == e.key ? Colors.blue : Colors.transparent),
                    ),
                    child: db.getIconImage(
                      code.icon,
                      width: 50,
                      height: 50,
                      onTap: () => setState(() => _selected = e.key),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _scrollTo(1),
          icon: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
        ),
      ],
    );
  }

  void _scrollTo(int dx) {
    if (!mounted) return;
    List<int> keys = codes.keys.toList();
    int _curIndex = codes.keys.toList().indexOf(_selected ?? 0);
    if (_curIndex < 0) return;
    _curIndex = (_curIndex + dx).clamp(0, codes.length - 1);
    setState(() {
      _selected = keys[_curIndex];
    });
    if (codes.length > 1 && _scrollController.hasClients && _scrollController.position.hasContentDimensions) {
      final length = _scrollController.position.maxScrollExtent - _scrollController.position.minScrollExtent;
      final offset = length / (codes.length - 1) * _curIndex + _scrollController.position.minScrollExtent;
      _scrollController.animateTo(offset, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Widget buildDetails(MysticCode mysticCode) {
    List<int> expRequired = [0, ...mysticCode.expRequired];
    return CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow.fromTexts(texts: ['No.${mysticCode.id}']),
        CustomTableRow(
          children: [
            TableCellData(
              child: Text(mysticCode.lName.l, style: const TextStyle(fontWeight: FontWeight.bold)),
              isHeader: true,
            ),
          ],
        ),
        if (!Transl.isJP)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(mysticCode.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        if (!Transl.isEN)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(mysticCode.lName.na, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ],
            // color: TableCellData.headerColor.withAlpha(120),
          ),
        for (final detail in {Transl.mcDetail(mysticCode.id).l, mysticCode.detail})
          CustomTableRow(
            children: [
              TableCellData(
                text: detail,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ],
          ),
        CustomTableRow(children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in mysticCode.skills) SkillDescriptor(skill: skill, level: _level),
        CustomTableRow(children: [TableCellData(text: S.current.game_experience, isHeader: true)]),
        for (int row = 0; row < expRequired.length / 5; row++) ...[
          CustomTableRow.fromTexts(
            texts: ['Lv.', for (int i = row * 5; i < row * 5 + 5; i++) i == 9 ? '-' : '${i + 1}→${i + 2}'],
            defaults: TableCellData(color: TableCellData.resolveHeaderColor(context).withAlpha(128)),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_single,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i + 1 >= expRequired.length
                    ? '-'
                    : ((expRequired.getOrNull(i + 1) ?? 0) - (expRequired.getOrNull(i) ?? 0)).format(compact: false),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_sum,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i + 1 >= expRequired.length ? '-' : expRequired[i + 1].format(compact: false),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
        ],
        ...buildObtains(mysticCode),
        CustomTableRow(children: [TableCellData(text: S.current.illustration, isHeader: true)]),
        ...buildCodeImages(mysticCode),
      ],
    );
  }

  List<Widget> buildCodeImages(MysticCode mysticCode) {
    List<Widget> children = [];
    List<String> items = [], masterFaces = [], masterFigures = [];
    for (final assets in [mysticCode.extraAssets, ...mysticCode.costumes.map((e) => e.extraAssets)]) {
      items.addAll([assets.item.female, assets.item.male]);
      masterFaces.addAll([assets.masterFace.female, assets.masterFace.male]);
      masterFigures.addAll([assets.masterFigure.female, assets.masterFigure.male]);
    }
    children.addAll(
      [
        _oneGroup(S.current.icons, items, 80),
        _oneGroup(S.current.card_asset_face, masterFaces, 120),
        _oneGroup(S.current.illustration, masterFigures, 300),
      ].whereType<Widget>(),
    );

    return children;
  }

  Widget? _oneGroup(String title, List<String> urls, double height, [bool expanded = true]) {
    urls = urls.toSet().toList();
    if (urls.isEmpty) return null;
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) => ListTile(title: Text(title)),
      expandElevation: 0,
      contentBuilder: (context) => SizedBox(
        height: height,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: urls.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => CachedImage(
              imageUrl: urls[index],
              onTap: () {
                FullscreenImageViewer.show(context: context, urls: urls, initialPage: index);
              },
              showSaveOnLongPress: true,
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
          ),
        ),
      ),
    );
  }

  List<Widget> buildObtains(MysticCode mysticCode) {
    List<Widget> children = [
      CustomTableRow.fromTexts(texts: [S.current.filter_obtain], isHeader: true),
    ];
    for (final quest in db.gameData.quests.values) {
      if (quest.giftsWithPhasePresents.any((gift) => gift.type == GiftType.equip && gift.objectId == mysticCode.id)) {
        children.add(
          CustomTableRow.fromChildren(
            children: [CondTargetValueDescriptor(condType: CondType.questClear, target: quest.id, value: 1)],
          ),
        );
      }
    }
    if (children.length == 1) {
      children.add(CustomTableRow.fromTexts(texts: const ['-']));
    }
    return children;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
