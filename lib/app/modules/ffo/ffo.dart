import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/ffo/ffo_card.dart';
import 'package:chaldea/app/modules/ffo/schema.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'summon_page.dart';

class FreedomOrderPage extends StatefulWidget {
  FreedomOrderPage({super.key});

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
          child: Text(S.current.load_ffo_data),
        ),
      );
    } else {
      body = Column(
        children: [
          Expanded(child: Center(child: FfoCard(params: params, showSave: true, showFullScreen: true))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                _partChooser(FfoPartWhere.head),
                _partChooser(FfoPartWhere.body),
                _partChooser(FfoPartWhere.bg),
              ],
            ),
          ),
          SafeArea(child: bottomBar),
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
            itemBuilder:
                (context) => [
                  PopupMenuItem(onTap: () => loadDB(true), child: Text(S.current.load_ffo_data)),
                  PopupMenuItem(
                    onTap: () {
                      launch(ChaldeaUrl.doc('freedom_order'));
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

  Widget _partChooser(FfoPartWhere where) {
    return PartChooser(
      where: where,
      part: params.of(where),
      onChanged: (part) {
        if (sameSvt) {
          params.bgPart = params.bodyPart = params.headPart = part;
        } else {
          params.update(where, part);
        }
        if (mounted) setState(() {});
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
            onChanged: (v) {
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
            onPressed:
                params.isEmpty
                    ? null
                    : () async {
                      final data = await FFOUtil.toBinary(params);
                      if (data == null) {
                        EasyLoading.showError(S.current.failed);
                        return;
                      }
                      if (mounted) {
                        FFOUtil.showSaveShare(context: context, params: params, data: data);
                      }
                    },
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

  bool _loading = true;

  void loadDB(bool force) async {
    try {
      _loading = true;
      if (mounted) setState(() {});
      await FfoDB.i.load(force);
    } catch (e, s) {
      logger.e('load FFO data failed', e, s);
      EasyLoading.showError(escapeDioException(e));
    }
    _loading = false;
    if (mounted) setState(() {});
  }
}
