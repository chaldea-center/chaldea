import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/ffo/ffo_card.dart';
import 'package:chaldea/app/modules/ffo/part_list.dart';
import 'package:chaldea/app/modules/ffo/schema.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'summon_page.dart';

class FreedomOrderPage extends StatefulWidget {
  FreedomOrderPage({Key? key}) : super(key: key);

  @override
  _FreedomOrderPageState createState() => _FreedomOrderPageState();
}

class _FreedomOrderPageState extends State<FreedomOrderPage> {
  FFOParams params = FFOParams();
  bool sameSvt = false;

  @override
  void initState() {
    super.initState();
    loadDB(false);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (FfoDB.i.isEmpty) {
      body = Center(
        child: ElevatedButton(
          onPressed: () {
            loadDB(false);
          },
          child: const Text('Load FFO DB'),
        ),
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: Center(
              child: FfoCard(
                params: params,
                showSave: true,
                showFullScreen: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                partChooser(FfoPartWhere.head),
                partChooser(FfoPartWhere.body),
                partChooser(FfoPartWhere.bg),
              ],
            ),
          ),
          bottomBar,
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Fate/Freedom Order', maxLines: 1),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => loadDB(true),
                child: const Text('Load FFO DB'),
              ),
              PopupMenuItem(
                onTap: () {
                  launch(HttpUrlHelper.projectDocUrl('freedom_order.html'));
                },
                child: Text(S.current.help),
              ),
            ],
          ),
        ],
      ),
      body: body,
    );
  }

  Widget partChooser(FfoPartWhere where) {
    final _part = params.of(where);
    String icon;
    switch (where) {
      case FfoPartWhere.head:
        icon = 'UI/icon_servant_head_on.png';
        break;
      case FfoPartWhere.body:
        icon = 'UI/icon_servant_body_on.png';
        break;
      case FfoPartWhere.bg:
        icon = 'UI/icon_servant_bg_on.png';
        break;
    }
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          db.getIconImage(FFOUtil.imgUrl(_part?.svt?.icon), height: 72),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              db.getIconImage(FFOUtil.imgUrl(icon), width: 16),
              Text(where.shownName),
            ],
          ),
        ],
      ),
      onTap: () {
        router.pushPage(
          FfoPartListPage(
            where: where,
            onSelected: (part) async {
              if (sameSvt) {
                params.bgPart = params.bodyPart = params.headPart = part;
              } else {
                params.update(where, part);
              }
              if (mounted) setState(() {});
            },
          ),
          detail: true,
        );
      },
    );
  }

  Widget get bottomBar {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          CheckboxWithLabel(
            value: params.cropNormalizedSize,
            label: Text(S.current.ffo_crop),
            onChanged: (v) async {
              if (v != null) {
                params.cropNormalizedSize = v;
              }
              setState(() {});
            },
          ),
          CheckboxWithLabel(
            value: sameSvt,
            label: Text(S.current.ffo_same_svt),
            onChanged: (v) async {
              if (v == null) return;
              sameSvt = v;
              if (sameSvt) {
                final _part = params.parts.firstWhereOrNull((e) => e != null);
                params.bgPart = params.bodyPart = params.headPart = _part;
              }
              setState(() {});
            },
          ),
          ElevatedButton(
            onPressed: params.isEmpty
                ? null
                : () => FFOUtil.showSaveShare(context: context, params: params),
            child: Text(S.current.save),
          ),
          ElevatedButton(
            onPressed: () {
              router.pushPage(const FFOSummonPage());
            },
            child: Text(S.current.simulator),
          ),
        ],
      ),
    );
  }

  FfoDB ffoDB = FfoDB.i;

  bool _loading = true;

  // load and save
  void loadDB(bool force) async {
    try {
      _loading = true;
      ffoDB.clear();
      if (mounted) setState(() {});
      for (final data
          in jsonDecode(await _readFile('FFOSpriteParts.json', force))) {
        final svt = FfoSvt.fromJson(data);
        ffoDB.servants[svt.collectionNo] = svt;
      }

      final csvrows = const CsvToListConverter(eol: '\n').convert(
          (await _readFile('CSV/ServantDB-Parts.csv', force))
              .replaceAll('\r\n', '\n'));
      for (final row in csvrows) {
        if (row[0] == 'id') {
          assert(row.length == 10, row.toString());
          continue;
        }
        final item = FfoSvtPart.fromList(row);
        ffoDB.parts[item.collectionNo] = item;
      }
      print('loaded csv: ${ffoDB.parts.length}');
    } catch (e, s) {
      logger.e('load FFO data failed', e, s);
      EasyLoading.showError(escapeDioError(e));
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  Future<String> _readFile(String fn, bool force) async {
    String url = FFOUtil.imgUrl(fn)!;
    final file = FilePlus(joinPaths(db.paths.tempDir, 'ffo', fn));
    if (file.existsSync() && !force) {
      try {
        return await file.readAsString();
      } catch (e, s) {
        logger.e('$fn corrupt', e, s);
      }
    }
    print('downloading: $url');
    final resp = await Dio()
        .get(url, options: Options(responseType: ResponseType.plain));
    await file.create(recursive: true);
    await file.writeAsString(resp.data as String);
    return resp.data;
  }
}
