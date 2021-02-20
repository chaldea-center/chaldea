//@dart=2.12
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:file_picker_cross/file_picker_cross.dart';

class ImportGudaPage extends StatefulWidget {
  const ImportGudaPage({Key? key}) : super(key: key);

  @override
  ImportGudaPageState createState() => ImportGudaPageState();
}

class ImportGudaPageState extends State<ImportGudaPage> {
  String? gudaData;
  bool? itemOrSvt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  bool clearData = false;

  Widget get buttonBar {
    return ButtonBar(
      children: [
        ElevatedButton(
          child: Text(itemOrSvt == null
              ? S.current.import_data
              : itemOrSvt == true
                  ? S.current.import_guda_items
                  : S.current.import_guda_servants),
          onPressed: itemOrSvt == null ? null : _import,
        ),
        Checkbox(
          value: clearData,
          onChanged: (v) {
            if (v == true) {
              SimpleCancelOkDialog(
                title: Text(S.of(context).confirm),
                content: Text('Clear data before import it'),
                onTapOk: () {
                  setState(() => clearData = true);
                },
                onTapCancel: () {
                  setState(() => clearData = false);
                },
              ).show(context);
            } else {
              setState(() {
                clearData = v ?? clearData;
              });
            }
          },
        ),
        Text('清除已有数据')
      ],
    );
  }

  void importGudaFile() async {
    FilePickerCross? filePickerCross =
        await FilePickerCross.importFromStorage().catchError((e) => null);
    if (filePickerCross == null) // ignore: unnecessary_null_comparison
      return null;

    gudaData = File(filePickerCross.path).readAsStringSync();
    int cellNum = gudaData!.trim().split(';').first.split('/').length;
    itemOrSvt = cellNum == 3
        ? true
        : cellNum == 13
            ? false
            : null;

    if (mounted) {
      setState(() {});
    }
  }

  List<List<String>> _splitTable(String content) {
    List<String> lines = content.trim().split(';');
    final table =
        lines.map((row) => row.trim().split('/').map((e) => e.trim()).toList());
    return table.where((e) => e.isNotEmpty).toList();
  }

  _import() {
    if (itemOrSvt == true)
      _importGudaItems();
    else if (itemOrSvt == false) _importGudaSvts();
  }

  _importGudaItems() async {
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
      if (clearData) {
        db.curUser.items.clear();
      }
      db.curUser.items.addAll(items);
      print(db.curUser.items);
      db.saveUserData();
      EasyLoading.showSuccess(S.of(context).import_data_success);
    } catch (e) {
      EasyLoading.showError('Invalid Guda Item format');
    }
  }

  void _importGudaSvts() async {
    if (gudaData == null) return;
    try {
      if (clearData) {
        db.curUser.servants.clear();
        db.curUser.curSvtPlan.clear();
      }
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
        final svt = db.gameData.servants[svtNo];
        if (svt == null) continue;

        List<int> values =
            List.generate(10, (index) => int.parse(row[index + 3]));
        ServantPlan cur = ServantPlan(favorite: true),
            target = ServantPlan(favorite: true);
        cur
          ..ascension = values[0]
          ..skills = [values[2], values[4], values[6]]
          ..dress = List.generate(svt.itemCost.dressName.length, (_) => 0);
        target
          ..ascension = values[1]
          ..skills = [values[3], values[5], values[7]]
          ..dress = List.generate(svt.itemCost.dressName.length, (_) => 0);
        int rarity = svt.info.rarity;
        int startIndex = lvs.indexOf(startLvs[rarity]);
        cur.grail = lvs.indexOf(values[8]) - startIndex;
        target.grail = lvs.indexOf(values[9]) - startIndex;
        statuses[svtNo] = ServantStatus(curVal: cur);
        plans[svtNo] = target;
      }
      if (clearData) {
        db.curUser.servants.clear();
        db.curUser.curSvtPlan.clear();
      }
      db.curUser.servants.addAll(statuses);
      db.curUser.curSvtPlan.addAll(plans);
      db.saveUserData();
      EasyLoading.showToast(S.of(context).import_data_success);
    } catch (e) {
      EasyLoading.showError('Invalid Guda servant format');
    }
  }
}
