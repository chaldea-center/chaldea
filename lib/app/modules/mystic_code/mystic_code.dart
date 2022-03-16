import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MysticCodePage extends StatefulWidget {
  final int? id;

  MysticCodePage({Key? key, this.id}) : super(key: key);

  @override
  _MysticCodePageState createState() => _MysticCodePageState();
}

class _MysticCodePageState extends State<MysticCodePage> {
  Map<int, MysticCode> get codes => db2.gameData.mysticCodes;

  int? _selected;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  int _level = 10;

  @override
  Widget build(BuildContext context) {
    if (_selected == null) {
      _selected = widget.id ?? (codes.isEmpty ? null : codes.keys.first);
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        _scrollTo(0);
      });
    }
    final MysticCode? mysticCode = codes[_selected];
    if (codes.isEmpty) {
      return NotFoundPage(
        title: S.current.mystic_code,
        url: Routes.mysticCodeI(_selected ?? 0),
      );
    }
    _level = db2.curUser.mysticCodes[_selected]?.clamp(1, 10) ?? 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.mystic_code),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => db2.curUser.isGirl = !db2.curUser.isGirl),
            icon: FaIcon(
              db2.curUser.isGirl
                  ? FontAwesomeIcons.venus
                  : FontAwesomeIcons.mars,
            ),
          )
        ],
      ),
      body: mysticCode == null
          ? Container()
          : Column(
              children: [
                buildScrollHeader(),
                Expanded(
                    child:
                        SingleChildScrollView(child: buildDetails(mysticCode))),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 16, right: 2),
                        child: Text(S.current.level)),
                    SizedBox(
                        width: 20,
                        child: Center(child: Text(_level.toString()))),
                    Expanded(
                      child: Slider(
                        value: _level.toDouble(),
                        onChanged: (v) => setState(() =>
                            db2.curUser.mysticCodes[_selected!] = v.toInt()),
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        label: _level.toString(),
                      ),
                    )
                  ],
                ),
              ],
            ),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: _selected == e.key
                                ? Colors.blue
                                : Colors.transparent)),
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = e.key),
                      child: db2.getIconImage(code.icon, width: 50, height: 50),
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
    print('_selected=$_selected, dx=$dx');
    if (!mounted) return;
    List<int> keys = codes.keys.toList();
    int _curIndex = codes.keys.toList().indexOf(_selected ?? 0);
    _curIndex = (_curIndex + dx).clamp(0, codes.length - 1);
    setState(() {
      _selected = keys[_curIndex];
    });
    if (codes.length > 1) {
      final length = _scrollController.position.maxScrollExtent -
          _scrollController.position.minScrollExtent;
      final offset = length / (codes.length - 1) * _curIndex +
          _scrollController.position.minScrollExtent;
      _scrollController.animateTo(offset,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Widget buildDetails(MysticCode mysticCode) {
    List<int> expRequired = [0, ...mysticCode.expRequired];
    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(mysticCode.lName.l,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            isHeader: true,
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(mysticCode.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              )
            ],
          ),
        if (!Transl.isEN)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(mysticCode.lName.na,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              )
            ],
            // color: TableCellData.headerColor.withAlpha(120),
          ),
        CustomTableRow(children: [
          TableCellData(
            text: mysticCode.detail,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ]),
        CustomTableRow(
            children: [TableCellData(text: S.current.skill, isHeader: true)]),
        CustomTableRow(children: [
          TableCellData(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: mysticCode.skills.map((e) => buildSkill(e)).toList(),
            ),
          )
        ]),
        CustomTableRow(children: [
          TableCellData(text: S.current.game_experience, isHeader: true)
        ]),
        for (int row = 0; row < expRequired.length / 5; row++) ...[
          CustomTableRow.fromTexts(
            texts: [
              'Lv.',
              for (int i = row * 5; i < row * 5 + 5; i++)
                i == 9 ? '-' : '${i + 1}->${i + 2}'
            ],
            defaults: TableCellData(
                color:
                    TableCellData.resolveHeaderColor(context).withOpacity(0.5)),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_single,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i + 1 >= expRequired.length
                    ? '-'
                    : ((expRequired.getOrNull(i + 1) ?? 0) -
                            (expRequired.getOrNull(i) ?? 0))
                        .format(compact: false),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_sum,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i + 1 >= expRequired.length
                    ? '-'
                    : expRequired[i + 1].format(compact: false),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
        ],
        CustomTableRow(children: [
          TableCellData(text: S.current.illustration, isHeader: true)
        ]),
        ...buildCodeImages(mysticCode)
      ],
    );
  }

  List<Widget> buildCodeImages(MysticCode mysticCode) {
    List<Widget> children = [];
    List<String> items = [], masterFaces = [], masterFigures = [];
    for (final assets in [
      mysticCode.extraAssets,
      ...mysticCode.costumes.map((e) => e.extraAssets)
    ]) {
      items.addAll([assets.item.female, assets.item.male]);
      masterFaces.addAll([assets.masterFace.female, assets.masterFace.male]);
      masterFigures
          .addAll([assets.masterFigure.female, assets.masterFigure.male]);
    }
    children.addAll([
      _oneGroup('item', items, 80),
      _oneGroup('masterFace', masterFaces, 120),
      _oneGroup('masterFigure', masterFigures, 300),
    ].whereType<Widget>());

    return children;
  }

  Widget? _oneGroup(String title, List<String> urls, double height,
      [bool expanded = true]) {
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
                FullscreenImageViewer.show(
                    context: context, urls: urls, initialPage: index);
              },
              showSaveOnLongPress: true,
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
          ),
        ),
      ),
    );
  }

  Widget buildSkill(NiceSkill skill) {
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }
    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 22, 6),
      leading: db2.getIconImage(skill.icon, width: 33),
      title: Text(skill.lName.l),
      subtitle: Transl.isJP ? null : Text(skill.name),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
    );
    return TileGroup(
      children: [
        header,
        SFooter(
          skill.lDetail ?? '???',
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
