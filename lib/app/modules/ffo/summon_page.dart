import 'dart:math';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:chaldea/app/modules/ffo/ffo_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'schema.dart';

class FFOSummonPage extends StatefulWidget {
  const FFOSummonPage({super.key});

  @override
  _FFOSummonPageState createState() => _FFOSummonPageState();
}

class _FFOSummonPageState extends State<FFOSummonPage> {
  int _curHistory = -1;
  List<List<FFOParams>> history = [];

  @override
  Widget build(BuildContext context) {
    _curHistory = _curHistory.clamp2(0, history.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freedom Order Summon'),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              history.clear();
              _curHistory = -1;
              setState(() {});
            },
            icon: const Icon(Icons.replay),
            tooltip: S.current.reset,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 6),
        children: [
          banner,
          summonBtns,
          if (FfoDB.i.isEmpty)
            Center(child: Text(S.current.ffo_missing_data_hint)),
          results,
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
          if (history.isNotEmpty)
            Center(
              child: Text(
                S.current.long_press_to_save_hint,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  FFOParams fixedParams = FFOParams();
  Widget _partChooser(FfoPartWhere where) {
    return PartChooser(
      where: where,
      part: fixedParams.of(where),
      placeholder: Center(child: Text(S.current.random)),
      onChanged: (part) {
        fixedParams.update(where, part);
        if (mounted) setState(() {});
      },
    );
  }

  Widget get banner {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: CachedNetworkImage(
        imageUrl:
            'https://news.fate-go.jp/wp-content/uploads/2021/ffo_cp_xikad/top_banner.png',
        errorWidget: (context, e, s) => const SizedBox(),
      ),
    );
  }

  Widget _summonButton(bool ten) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () => drawSummon(ten ? 10 : 1),
        child: db.getIconImage(
          FFOUtil.imgUrl(
              'UI/${ten ? 'btn_summon_10.png' : 'btn_summon_01.png'}'),
          height: 50,
          placeholder: (context) => ElevatedButton(
            onPressed: () => drawSummon(ten ? 10 : 1),
            child: Text('Gacha ×${ten ? 10 : 1}'),
          ),
        ),
      ),
    );
  }

  Widget get summonBtns {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summonButton(false),
          const SizedBox(width: 10),
          _summonButton(true),
        ],
      ),
    );
  }

  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  void drawSummon(int counts) async {
    // final svts = FfoDB.i.parts.values.where((e) => e.svt != null).toList();
    final categorized = {
      for (final where in FfoPartWhere.values)
        where: FfoDB.i.parts.values
            .where((e) => e.svt?.has(where) == true)
            .toList(),
    };
    FfoSvtPart? _getRandom(FfoPartWhere where) {
      final fixedSvt = fixedParams.of(where);
      if (fixedSvt != null) return fixedSvt;
      final svts = categorized[where]!;
      if (svts.isEmpty) return null;
      return svts[_random.nextInt(svts.length)];
    }

    history.add(List.generate(
      counts,
      (index) => FFOParams(
        headPart: _getRandom(FfoPartWhere.head),
        bodyPart: _getRandom(FfoPartWhere.body),
        bgPart: _getRandom(FfoPartWhere.bg),
        clipOverflow: true,
        cropNormalizedSize: true,
      ),
    ));
    _curHistory = history.length - 1;
    setState(() {});
  }

  Widget get results {
    if (history.isEmpty) return const SizedBox(height: 160);

    Widget _buildRow(List<FFOParams> rowItems) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in rowItems)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: FfoCard(
                params: p,
                showSave: true,
                showFullScreen: true,
              ),
            )
        ],
      );
    }

    Widget _buildOneHistory(List<FFOParams> data) {
      List<Widget> rows = [];
      rows.add(_buildRow(data.sublist(0, min(5, data.length))));
      if (data.length > 5) rows.add(_buildRow(data.sublist(5, data.length)));
      Widget child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
      );
      if (data.isNotEmpty) {
        child = FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        );
      }
      return child;
    }

    if (_curHistory < 0 || _curHistory >= history.length) {
      _curHistory = history.length - 1;
    }
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _curHistory == 0
                  ? null
                  : () {
                      setState(() {
                        _curHistory -= 1;
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: (512 * 5) / (720 * 2),
                child: _buildOneHistory(history[_curHistory]),
              ),
            ),
            IconButton(
              onPressed: _curHistory == history.length - 1
                  ? null
                  : () {
                      setState(() {
                        _curHistory += 1;
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        Text(
          '${_curHistory + 1}/${history.length}',
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
