import 'package:chaldea/components/components.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImportGudaPage extends StatefulWidget {
  const ImportGudaPage({Key? key}) : super(key: key);

  @override
  _ImportGudaPageState createState() => _ImportGudaPageState();
}

class _ImportGudaPageState extends State<ImportGudaPage> {
  String? gudaData;
  bool? itemOrSvt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        titleSpacing: 0,
        title: Text(
            LocalizedText.of(chs: 'Guda数据', jpn: 'Gudaデータ', eng: 'Guda Data')),
        actions: [
          IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.current.help),
                scrollable: true,
                content: Text(LocalizedText.of(
                    chs: '导入iOS应用"Guda"的数据，支持素材和从者',
                    jpn: 'iOSアプリ「Guda」のデータをインポートする',
                    eng: 'Import item or servant data from iOS app "Guda"')),
              ).showDialog(context);
            },
            icon: Icon(Icons.help),
            tooltip: S.current.help,
          ),
          IconButton(
            onPressed: importFile,
            icon: FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_source_file,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(gudaData ?? ''),
            ),
          ),
          kDefaultDivider,
          buttonBar,
        ],
      ),
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text(itemOrSvt == null
              ? S.current.import_data
              : itemOrSvt == true
                  ? S.current.import_guda_items
                  : S.current.import_guda_servants),
          onPressed: itemOrSvt == null ? null : _import,
        ),
      ],
    );
  }

  void importFile() async {
    try {
      FilePickerCross filePickerCross =
          await FilePickerCross.importFromStorage();
      gudaData = File(filePickerCross.path!).readAsStringSync();
      int cellNum = gudaData!.trim().split(';').first.split('/').length;
      itemOrSvt = cellNum == 3
          ? true
          : cellNum == 13
              ? false
              : null;
      if (mounted) {
        setState(() {});
      }
    } on FileSelectionCanceledError {
      //
    } catch (e, s) {
      logger.e('import guda file failed', e, s);
      EasyLoading.showError('Something went wrong\n$e');
      return;
    }
  }

  List<List<String>> _splitTable(String content) {
    List<String> lines = content.trim().split(';');
    final table =
        lines.map((row) => row.trim().split('/').map((e) => e.trim()).toList());
    return table.where((e) => e.isNotEmpty).toList();
  }

  void _import() {
    if (itemOrSvt == true) {
      _importGudaItems();
    } else if (itemOrSvt == false) {
      _importGudaSvts();
    }
  }

  void _importGudaItems() async {
    if (gudaData == null) return;
    try {
      List<List<String>> table = _splitTable(gudaData!);
      Map<String, int> items = {};
      final replaceKeys = {
        "万死之毒针": "万死的毒针",
        "震荡火药": "振荡火药",
        "閑古鈴": "闲古铃",
        "禍罪の矢尻": "祸罪之箭头",
        "暁光炉心": "晓光炉心",
        "九十九鏡": "九十九镜",
        "真理の卵": "真理之卵",
        "金棋": "金像"
      };
      for (var row in table) {
        if (row.isEmpty) continue;
        String itemKey = row[1], itemNum = row[2];
        itemKey = itemKey.replaceAll('金棋', '金像');
        if (replaceKeys.containsKey(itemKey)) {
          itemKey = replaceKeys[itemKey]!;
        }
        if (db.gameData.items.keys.contains(itemKey)) {
          items[itemKey] = int.parse(itemNum);
        } else {
          print('Item $itemKey not found');
        }
      }
      db.curUser.items.addAll(items);
      print(db.curUser.items);
      EasyLoading.showSuccess(S.of(context).import_data_success);
    } catch (e) {
      EasyLoading.showError('Invalid Guda Item format');
    }
  }

  void _importGudaSvts() async {
    if (gudaData == null) return;
    try {
      Map<int, ServantStatus> statuses = {};
      Map<int, ServantPlan> plans = {};

      List<List<String>> table = _splitTable(gudaData!);

      //            0 1  2 3  4 5 6 7  8  9
      // 0  1   2   3 4  5 6  7 8 9 10 11 12
      // 3/name/0  /1/4/ 4/10/2/5/4/9/ 85/92;
      final lvs = [60, 65, 70, 75, 80, 85, 90, 92, 94, 96, 98, 100];
      final startLvs = [65, 60, 65, 70, 80, 90];

      for (var row in table) {
        int svtNo = int.parse(row[0]);
        if (db.gameData.unavailableSvts.contains(svtNo)) continue;
        final svt = db.gameData.servants[svtNo];
        if (svt == null) continue;

        List<int> values =
            List.generate(10, (index) => int.parse(row[index + 3]));
        ServantPlan cur = ServantPlan(favorite: true),
            target = ServantPlan(favorite: true);
        cur
          ..ascension = values[0]
          ..skills = [values[2], values[4], values[6]]
          ..dress = List.generate(svt.costumeNos.length, (_) => 0);
        target
          ..ascension = values[1]
          ..skills = [values[3], values[5], values[7]]
          ..dress = List.generate(svt.costumeNos.length, (_) => 0);
        int rarity = svt.info.rarity;
        int startIndex = lvs.indexOf(startLvs[rarity]);
        cur.grail = lvs.indexOf(values[8]) - startIndex;
        target.grail = lvs.indexOf(values[9]) - startIndex;
        statuses[svtNo] = ServantStatus(curVal: cur);
        plans[svtNo] = target;
      }
      db.curUser.servants.addAll(statuses);
      db.curUser.curSvtPlan.addAll(plans);
      EasyLoading.showSuccess(S.of(context).import_data_success);
    } catch (e) {
      EasyLoading.showError('Invalid Guda servant format');
    }
  }
}
