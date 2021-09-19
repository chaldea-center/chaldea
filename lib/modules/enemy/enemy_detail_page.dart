import 'package:chaldea/components/components.dart';

class EnemyDetailPage extends StatefulWidget {
  final EnemyDetail enemy;

  const EnemyDetailPage({Key? key, required this.enemy}) : super(key: key);

  @override
  _EnemyDetailPageState createState() => _EnemyDetailPageState();
}

class _EnemyDetailPageState extends State<EnemyDetailPage> {
  EnemyDetail get enemy => widget.enemy;

  @override
  Widget build(BuildContext context) {
    final names = enemy.lNames;
    return Scaffold(
      appBar: AppBar(
        title: Text(names.join('/')),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          CustomTable(
            children: [
              CustomTableRow(children: [
                TableCellData(
                  text: names.join('\n'),
                  isHeader: true,
                  textAlign: TextAlign.center,
                )
              ]),
              CustomTableRow(children: [
                TableCellData(
                  text: enemy.ids.map((e) => EnemyDetail.lNameOf(e)).join('\n'),
                  textAlign: TextAlign.center,
                )
              ]),
              CustomTableRow(children: [
                TableCellData(
                    child: db.getIconImage(enemy.icon, height: 64), flex: 1),
                TableCellData(
                  flex: 3,
                  padding: EdgeInsets.zero,
                  child: CustomTable(hideOutline: true, children: [
                    // CustomTableRow(children: [
                    //   TableCellData(
                    //       text: S.current.filter_sort_class, isHeader: true),
                    //   TableCellData(
                    //     flex: 3,
                    //     child: enemy.classIcons.isEmpty
                    //         ? const Text('?')
                    //         : Wrap(
                    //             spacing: 4,
                    //             runSpacing: 4,
                    //             alignment: WrapAlignment.center,
                    //             children: [
                    //               for (final icon in enemy.classIcons)
                    //                 db.getIconImage(icon, height: 24),
                    //             ],
                    //           ),
                    //   )
                    // ]),
                    CustomTableRow.fromTexts(
                      texts: [
                        S.current.filter_attribute,
                        LocalizedText.of(
                            chs: '行动数', jpn: '行動数', eng: 'Actions'),
                        LocalizedText.of(chs: '充能', jpn: 'チャージ', eng: 'Charge'),
                        S.current.info_death_rate
                      ],
                      isHeader: true,
                    ),
                    CustomTableRow.fromTexts(texts: [
                      Localized.svtFilter.of(enemy.attribute),
                      enemy.actions?.toString() ?? '?',
                      enemy.charges.isEmpty ? '?' : enemy.charges.join('/'),
                      enemy.deathRate ?? '?',
                    ]),
                    CustomTableRow.fromTexts(texts: [
                      'Hits',
                      'Hits(${S.current.critical_attack})',
                      'Hits(NP)'
                    ], isHeader: true),
                    // CustomTableRow.fromTexts(texts: [
                    //   enemy.hitsCommon.join('/'),
                    //   enemy.hitsCritical.join('/'),
                    //   enemy.hitsNp.join('/'),
                    // ])
                  ]),
                ),
              ]),
              CustomTableRow(children: [
                TableCellData(
                  child: enemy.classIcons.isEmpty
                      ? const Text('?')
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final icon in enemy.classIcons)
                              db.getIconImage(icon, height: 24),
                          ],
                        ),
                ),
                TableCellData(text: enemy.hitsCommon.join('/')),
                TableCellData(text: enemy.hitsCritical.join('/')),
                TableCellData(text: enemy.hitsNp.join('/')),
              ]),
              CustomTableRow.fromTexts(
                  texts: [S.current.info_trait], isHeader: true),
              CustomTableRow.fromTexts(texts: [
                enemy.traits.isEmpty
                    ? '-'
                    : enemy.traits
                        .map((e) => Localized.masterMission.of(e))
                        .join(', ')
              ]),
              CustomTableRow.fromTexts(
                  texts: [S.current.skill], isHeader: true),
              CustomTableRow.fromTexts(
                texts: [enemy.skill],
                defaults: TableCellData(
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              CustomTableRow.fromTexts(
                  texts: [S.current.noble_phantasm], isHeader: true),
              CustomTableRow.fromTexts(
                texts: [enemy.noblePhantasm],
                defaults: TableCellData(
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
