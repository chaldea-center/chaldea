import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CharaDetail extends StatelessWidget {
  final String name;

  const CharaDetail({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final lName = Transl.charaNames(name);
    List<Widget> children = [];
    final table = CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(
              lName.l,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            isHeader: true,
          )
        ]),
        if (!Transl.isJP) CustomTableRow(children: [TableCellData(text: lName.jp, textAlign: TextAlign.center)]),
        if (!Transl.isEN) CustomTableRow(children: [TableCellData(text: lName.na, textAlign: TextAlign.center)]),
      ],
    );
    children.add(table);

    final ces = db.gameData.craftEssences.values.where((ce) => ce.extra.unknownCharacters.contains(name)).toList();
    final ccs = db.gameData.commandCodes.values.where((cc) => cc.extra.unknownCharacters.contains(name)).toList();
    if (ces.isNotEmpty) {
      children.addAll([
        ListTile(title: Text(S.current.craft_essence)),
        SharedBuilder.grid<CraftEssence>(
          context: context,
          items: ces,
          builder: (context, ce) => ce.iconBuilder(context: context, width: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]);
    }
    if (ccs.isNotEmpty) {
      children.addAll([
        ListTile(title: Text(S.current.command_code)),
        SharedBuilder.grid<CommandCode>(
          context: context,
          items: ccs,
          builder: (context, cc) => cc.iconBuilder(context: context, width: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]);
    }
    ces.sort2((e) => e.collectionNo);
    ccs.sort2((e) => e.collectionNo);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          lName.l,
          minFontSize: 12,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(children: children),
    );
  }
}
