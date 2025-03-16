import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:csv/csv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'converter.dart';

class ImportCSVPage extends StatefulWidget {
  const ImportCSVPage({super.key});

  @override
  State<ImportCSVPage> createState() => _ImportCSVPageState();
}

class _ImportCSVPageState extends State<ImportCSVPage> {
  List<ParedSvtCsvRow> parsedRows = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.import_csv_title),
        actions: [ChaldeaUrl.docsHelpBtn('import_data.html#csv-template')],
      ),
      body: Column(
        children: [
          Expanded(child: ListView(children: [ListTile(title: Text('${parsedRows.length} records'))])),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await FilePickerU.pickFiles(clearCache: true);
            final bytes = result?.files.getOrNull(0)?.bytes;
            if (bytes == null) return;
            try {
              final rawData = const CsvToListConverter().convert<String>(utf8.decode(bytes), shouldParseNumbers: false);
              parsedRows = PlanDataSheetConverter().parseFromCSV(rawData);
            } catch (e, s) {
              logger.e('import chaldea csv failed', e, s);
              EasyLoading.showError(e.toString());
            }
            if (mounted) setState(() {});
          },
          child: Text(S.current.import_csv_load_csv),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return SimpleDialog(
                  title: Text(S.current.import_csv_export_template),
                  children: [
                    ListTile(
                      title: Text(S.current.import_csv_export_all),
                      onTap: () {
                        Navigator.pop(context);
                        generateTemplate(true, true);
                      },
                    ),
                    ListTile(
                      title: Text(S.current.import_csv_export_favorite),
                      onTap: () {
                        Navigator.pop(context);
                        generateTemplate(false, true);
                      },
                    ),
                    ListTile(
                      title: Text(S.current.import_csv_export_empty),
                      onTap: () {
                        Navigator.pop(context);
                        generateTemplate(false, false);
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(S.current.import_csv_export_template),
        ),
        ElevatedButton(
          onPressed:
              parsedRows.isEmpty
                  ? null
                  : () {
                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) {
                        return SimpleConfirmDialog(
                          title: Text(S.current.confirm),
                          onTapOk: () {
                            for (final row in parsedRows) {
                              final svt = db.gameData.servantsWithDup[row.collectionNo];
                              if (svt == null) continue;
                              db.curUser.servants[row.collectionNo] = row.mergeStatus(
                                db.curUser.servants[row.collectionNo],
                              );
                              db.curSvtPlan[row.collectionNo] = row.mergePlan(db.curSvtPlan[row.collectionNo]);
                              final coinId = svt.coin?.item.id;
                              if (coinId != null && row.coin != null) {
                                db.curUser.items[coinId] = row.coin!;
                              }
                            }
                            db.itemCenter.init();
                            EasyLoading.showSuccess(S.current.import_data_success);
                          },
                        );
                      },
                    );
                  },
          child: Text(S.current.import_data),
        ),
      ],
    );
  }

  void generateTemplate(bool includeAll, bool includeFavorite) async {
    final data = PlanDataSheetConverter().generateCSV(includeAll, includeFavorite);
    final contents = const ListToCsvConverter().convert(data);
    final t = DateTime.now().toSafeFileName();
    final fn = 'chaldea_data_$t.csv';
    if (kIsWeb) {
      kPlatformMethods.downloadString(contents, fn);
      return;
    }
    String fp = joinPaths(db.paths.tempDir, 'chaldea_data_$t.csv');
    try {
      await FilePlus(fp).writeAsString(contents);
    } catch (e) {
      EasyLoading.showError(e.toString());
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return SimpleConfirmDialog(
          title: const Text('Filepath'),
          content: Text(db.paths.convertIosPath(fp)),
          showCancel: false,
          confirmText: PlatformU.isDesktop ? S.current.open : S.current.share,
          onTapOk: () {
            if (PlatformU.isDesktop) {
              openFile(pathlib.dirname(fp));
            } else {
              ShareX.shareFile(fp, context: context);
            }
          },
        );
      },
    );
  }
}
