import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
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
  Map<int, SvtStatus> statuses = {};
  Map<int, SvtPlan> plans = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.import_csv_title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('${statuses.length} records'),
                ),
              ],
            ),
          ),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(withData: true);
            final bytes = result?.files.getOrNull(0)?.bytes;
            if (bytes == null) return;
            try {
              final rawData = const CsvToListConverter().convert<String>(utf8.decode(bytes), shouldParseNumbers: false);
              statuses.clear();
              plans.clear();
              PlanDataSheetConverter().parseFromCSV(statuses, plans, rawData);
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
                    )
                  ],
                );
              },
            );
          },
          child: Text(S.current.import_csv_export_template),
        ),
        ElevatedButton(
          onPressed: statuses.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) {
                      return SimpleCancelOkDialog(
                        title: Text(S.current.confirm),
                        onTapOk: () {
                          db.curUser.servants
                            ..clear()
                            ..addAll(statuses);
                          db.curUser.curSvtPlan
                            ..clear()
                            ..addAll(plans);
                          db.itemCenter.init();
                          EasyLoading.showSuccess(S.current.import_data_success);
                        },
                      );
                    },
                  );
                },
          child: Text(S.current.import_data),
        )
      ],
    );
  }

  void generateTemplate(bool includeAll, bool includeFavorite) async {
    final data = PlanDataSheetConverter().generateCSV(includeAll, includeFavorite);
    final contents = const ListToCsvConverter().convert(data);
    final t = DateTime.now().toDateString();
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
        return SimpleCancelOkDialog(
          title: const Text('Filepath'),
          content: Text(db.paths.convertIosPath(fp)),
          hideCancel: true,
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
