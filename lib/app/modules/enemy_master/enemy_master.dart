import 'dart:math';

import 'package:chaldea/app/modules/common/extra_assets_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class EnemyMasterDetailPage extends StatefulWidget {
  final EnemyMaster master;
  const EnemyMasterDetailPage({super.key, required this.master});

  @override
  State<EnemyMasterDetailPage> createState() => _EnemyMasterDetailPageState();
}

class _EnemyMasterDetailPageState extends State<EnemyMasterDetailPage> {
  EnemyMaster get master => widget.master;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(master.name)),
      body: ListView(
        children: [
          info,
        ],
      ),
    );
  }

  Widget get info {
    return CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow.fromTexts(texts: ['No.${master.id}'], isHeader: true),
        CustomTableRow(children: [
          TableCellData(
            child: Text(master.lName.l,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(master.lName.jp,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              )
            ],
          ),
        if (!Transl.isEN)
          CustomTableRow(
            children: [
              TableCellData(
                child: Text(master.lName.na,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              )
            ],
          ),
        CustomTableRow.fromTexts(
            texts: [S.current.illustration], isHeader: true),
        ...[
          ExtraAssetsPage.oneGroup(
            S.current.card_asset_face,
            master.battles.map((e) => e.face).toSet(),
            120,
            transform: (child) {
              return Transform.rotate(
                angle: -pi / 4,
                child: Padding(
                  padding: const EdgeInsets.all(17.5),
                  child: child,
                ),
              );
            },
          ),
          ExtraAssetsPage.oneGroup(S.current.command_spell,
              master.battles.map((e) => e.commandSpellIcon).toSet(), 160),
          ExtraAssetsPage.oneGroup(
              S.current.card_asset_chara_figure,
              {
                for (final battle in master.battles) ...[
                  battle.figure,
                  ...battle.cutin,
                ],
              }.whereType<String>().toSet(),
              300),
        ].whereType<Widget>().map((e) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 16), child: e))
      ],
    );
  }
}
